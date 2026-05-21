import '../../domain/entities/booking_invoice_data.dart';
import '../../domain/repositories/booking_invoice_data_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/journal_repository.dart';
import '../services/journal_service.dart';
import '../services/accounting_settings_service.dart';
import '../../core/errors/failures.dart';

/// Use case to process booking payment (full or partial)
/// 
/// Auto-Journaling:
/// When payment is received, creates a journal entry:
/// - If payment method is CASH:
///   - Debit: Cash Account (cashAccountId)
///   - Credit: Accounts Receivable (receivableAccountId)
/// - If payment method is ELECTRONIC:
///   - Debit: Bank Account (bankAccountId)
///   - Credit: Accounts Receivable (receivableAccountId)
/// - Source: booking_payment, sourceId: bookingId
class ProcessBookingPaymentUseCase {
  final BookingInvoiceDataRepository _invoiceDataRepository;
  final AccountRepository _accountRepository;
  final JournalRepository _journalRepository;
  final JournalService _journalService;
  final AccountingSettingsService _accountingSettingsService;

  ProcessBookingPaymentUseCase(
    this._invoiceDataRepository,
    this._accountRepository,
    this._journalRepository,
    this._journalService,
    this._accountingSettingsService,
  );

  Future<BookingInvoiceData> execute({
    required String bookingId,
    required String paymentMethod, // 'cash' or 'electronic'
    required double paymentAmount,
    required String? userId,
  }) async {
    try {
      // Get existing invoice data
      final invoiceData = await _invoiceDataRepository.findByBookingId(bookingId);
      if (invoiceData == null) {
        throw NotFoundFailure('Invoice not found for this booking');
      }

      // Validate payment amount
      if (paymentAmount <= 0) {
        throw ValidationFailure('Payment amount must be greater than 0');
      }

      if (paymentAmount > invoiceData.amountRemaining) {
        throw ValidationFailure('Payment amount cannot exceed remaining amount');
      }

      // Calculate new payment status
      final newAmountPaid = invoiceData.amountPaid + paymentAmount;
      final newAmountRemaining = invoiceData.amountRemaining - paymentAmount;
      String newPaymentStatus = invoiceData.paymentStatus;

      if (newAmountRemaining <= 0) {
        newPaymentStatus = 'paid';
      } else if (newAmountPaid > 0) {
        newPaymentStatus = 'partial';
      }

      // Update invoice data
      final updatedInvoice = invoiceData.copyWith(
        paymentMethod: paymentMethod,
        paymentStatus: newPaymentStatus,
        amountPaid: newAmountPaid,
        amountRemaining: newAmountRemaining,
      );

      await _invoiceDataRepository.update(updatedInvoice);

      // Create journal entry for payment
      try {
        final accountingSettings = await _accountingSettingsService.getSettings();
        
        // Determine which account to debit based on payment method
        int debitAccountId;
        if (paymentMethod == 'cash') {
          debitAccountId = accountingSettings.cashAccountId;
        } else {
          debitAccountId = accountingSettings.bankAccountId;
        }

        final journalEntry = await _journalService.createJournalEntry(
          date: DateTime.now(),
          reference: 'PAY-${bookingId.substring(0, 6)}',
          description: 'دفعة فاتورة حجز رقم $bookingId',
          lines: [
            JournalLineInput(
              accountId: debitAccountId,
              debit: paymentAmount,
              credit: 0,
              description: paymentMethod == 'cash' ? 'قبض نقدي من فاتورة حجز' : 'قبض إلكتروني من فاتورة حجز',
            ),
            JournalLineInput(
              accountId: accountingSettings.receivableAccountId,
              debit: 0,
              credit: paymentAmount,
              description: 'تسديد ذمم مدينة من فاتورة حجز',
            ),
          ],
          sourceType: 'booking_payment',
          sourceId: bookingId,
          createdBy: userId,
        );
        
        return updatedInvoice.copyWith(journalEntryId: journalEntry.id);
      } catch (e) {
        // Don't fail the payment if journal entry creation fails
        return updatedInvoice;
      }
    } catch (e) {
      throw ServerFailure('Failed to process payment: $e');
    }
  }
}

class JournalLineInput {
  final int accountId;
  final double debit;
  final double credit;
  final String? description;

  JournalLineInput({
    required this.accountId,
    required this.debit,
    required this.credit,
    this.description,
  });
}
