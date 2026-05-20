import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/booking_invoice_data_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../core/errors/failures.dart';
import '../services/journal_service.dart';
import '../services/accounting_settings_service.dart';

class UpdateBookingStatusUseCase {
  final BookingRepository _bookingRepository;
  final BookingInvoiceDataRepository _invoiceDataRepository;
  final AccountRepository _accountRepository;
  final JournalRepository _journalRepository;
  final JournalService _journalService;
  final AccountingSettingsService _accountingSettingsService;

  UpdateBookingStatusUseCase(
    this._bookingRepository,
    this._invoiceDataRepository,
    this._accountRepository,
    this._journalRepository,
    this._journalService,
    this._accountingSettingsService,
  );

  Future<Booking> execute(String bookingId, BookingStatus newStatus, {String? userId}) async {
    try {
      final booking = await _bookingRepository.findById(bookingId);
      if (booking == null) {
        throw NotFoundFailure('Booking not found');
      }

      final updatedBooking = booking.copyWith(
        status: newStatus,
        updatedAt: DateTime.now().toUtc(),
      );

      final result = await _bookingRepository.update(updatedBooking);

      // Create revenue journal entry when status is DELIVERED
      if (newStatus == BookingStatus.DELIVERED) {
        try {
          final invoiceData = await _invoiceDataRepository.findByBookingId(bookingId);
          if (invoiceData != null && invoiceData.journalEntryId == null) {
            final accountingSettings = await _accountingSettingsService.getSettings();
            
            // Calculate totals from invoice snapshots
            double totalServices = 0;
            double totalParts = 0;
            
            if (invoiceData.servicesSnapshot != null) {
              final services = invoiceData.servicesSnapshot as List;
              for (final s in services) {
                totalServices += (s['priceSYP'] as num).toDouble();
              }
            }
            
            if (invoiceData.partsSnapshot != null) {
              final parts = invoiceData.partsSnapshot as List;
              for (final p in parts) {
                totalParts += (p['price'] as num).toDouble();
              }
            }
            
            final totalAmount = totalServices + totalParts;
            
            if (totalAmount > 0) {
              final journalEntry = await _journalService.createJournalEntry(
                date: DateTime.now(),
                reference: 'INV-${booking.publicToken?.substring(0, 6) ?? bookingId.substring(0, 6)}',
                description: 'فاتورة حجز رقم $bookingId',
                lines: [
                  JournalLineInput(
                    accountId: accountingSettings.receivableAccountId,
                    debit: totalAmount,
                    credit: 0,
                    description: 'قيمة الفاتورة على العميل',
                  ),
                  if (totalServices > 0)
                    JournalLineInput(
                      accountId: accountingSettings.revenueServiceAccountId,
                      debit: 0,
                      credit: totalServices,
                      description: 'إيرادات الخدمات',
                    ),
                  if (totalParts > 0)
                    JournalLineInput(
                      accountId: accountingSettings.revenuePartsAccountId,
                      debit: 0,
                      credit: totalParts,
                      description: 'إيرادات قطع الغيار',
                    ),
                ],
                sourceType: 'booking',
                sourceId: bookingId,
                createdBy: userId,
              );
              
              // Update invoice with journal entry ID
              final updatedInvoice = invoiceData.copyWith(journalEntryId: journalEntry.id);
              await _invoiceDataRepository.update(updatedInvoice);
            }
          }
        } catch (e) {
          // Don't fail the status update if journal entry creation fails
        }
      }

      return result;
    } catch (e) {
      throw ServerFailure('Failed to update booking status: $e');
    }
  }
}
