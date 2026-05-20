import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/vendor.dart';
import '../../domain/entities/purchase_invoice.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../../domain/repositories/purchase_invoice_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/bank_account_repository.dart';
import '../middlewares/auth_middleware.dart';
import '../../infrastructure/database/database_connection.dart';
import '../../application/usecases/create_vendor_usecase.dart';
import '../../application/usecases/update_vendor_usecase.dart';
import '../../application/usecases/delete_vendor_usecase.dart';
import '../../application/usecases/get_all_vendors_usecase.dart';
import '../../application/usecases/create_purchase_invoice_usecase.dart';
import '../../application/usecases/pay_purchase_invoice_usecase.dart';
import '../../application/usecases/create_expense_usecase.dart';
import '../../application/usecases/reconcile_bank_account_usecase.dart';
import '../../domain/entities/role.dart';
import '../../application/services/journal_service.dart';
import '../../application/services/accounting_settings_service.dart';
import '../../infrastructure/repositories/company_settings_repository_impl.dart';
import '../../infrastructure/repositories/journal_repository_impl.dart';
import '../../infrastructure/repositories/account_repository_impl.dart';
import '../../infrastructure/repositories/vendor_repository_impl.dart';
import '../../infrastructure/repositories/purchase_invoice_repository_impl.dart';
import '../../infrastructure/repositories/expense_repository_impl.dart';
import '../../infrastructure/repositories/bank_account_repository_impl.dart';
import '../../infrastructure/repositories/inventory_variant_repository_impl.dart';

class FinancialRoutes {
  final VendorRepository _vendorRepository;
  final PurchaseInvoiceRepository _purchaseInvoiceRepository;
  final ExpenseRepository _expenseRepository;
  final BankAccountRepository _bankAccountRepository;
  final AuthMiddleware _authMiddleware;
  final CreateVendorUseCase _createVendorUseCase;
  final UpdateVendorUseCase _updateVendorUseCase;
  final DeleteVendorUseCase _deleteVendorUseCase;
  final GetAllVendorsUseCase _getAllVendorsUseCase;
  final CreatePurchaseInvoiceUseCase _createPurchaseInvoiceUseCase;
  final PayPurchaseInvoiceUseCase _payPurchaseInvoiceUseCase;
  final CreateExpenseUseCase _createExpenseUseCase;
  final ReconcileBankAccountUseCase _reconcileBankAccountUseCase;

  FinancialRoutes(
    this._vendorRepository,
    this._purchaseInvoiceRepository,
    this._expenseRepository,
    this._bankAccountRepository,
    this._authMiddleware,
    this._createVendorUseCase,
    this._updateVendorUseCase,
    this._deleteVendorUseCase,
    this._getAllVendorsUseCase,
    this._createPurchaseInvoiceUseCase,
    this._payPurchaseInvoiceUseCase,
    this._createExpenseUseCase,
    this._reconcileBankAccountUseCase,
  );

  factory FinancialRoutes.create(DatabaseConnection db, AuthMiddleware authMiddleware) {
    final vendorRepository = VendorRepositoryImpl(db);
    final purchaseInvoiceRepository = PurchaseInvoiceRepositoryImpl(db);
    final expenseRepository = ExpenseRepositoryImpl(db);
    final bankAccountRepository = BankAccountRepositoryImpl(db);
    final journalRepository = JournalRepositoryImpl(db);
    final accountRepository = AccountRepositoryImpl(db);
    final companySettingsRepository = CompanySettingsRepositoryImpl(db);
    final inventoryVariantRepository = InventoryVariantRepositoryImpl(db);
    final journalService = JournalService(journalRepository, accountRepository);
    final accountingSettingsService = AccountingSettingsService(companySettingsRepository, accountRepository);
    
    final createVendorUseCase = CreateVendorUseCase(vendorRepository);
    final updateVendorUseCase = UpdateVendorUseCase(vendorRepository);
    final deleteVendorUseCase = DeleteVendorUseCase(vendorRepository);
    final getAllVendorsUseCase = GetAllVendorsUseCase(vendorRepository);
    final createPurchaseInvoiceUseCase = CreatePurchaseInvoiceUseCase(purchaseInvoiceRepository);
    final payPurchaseInvoiceUseCase = PayPurchaseInvoiceUseCase(purchaseInvoiceRepository);
    final createExpenseUseCase = CreateExpenseUseCase(expenseRepository);
    final reconcileBankAccountUseCase = ReconcileBankAccountUseCase(bankAccountRepository);
    
    return FinancialRoutes(
      vendorRepository,
      purchaseInvoiceRepository,
      expenseRepository,
      bankAccountRepository,
      authMiddleware,
      createVendorUseCase,
      updateVendorUseCase,
      deleteVendorUseCase,
      getAllVendorsUseCase,
      createPurchaseInvoiceUseCase,
      payPurchaseInvoiceUseCase,
      createExpenseUseCase,
      reconcileBankAccountUseCase,
    );
  }

  Router get router {
    final router = Router();

    // Vendors
    router.get('/api/vendors', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getVendors)));
    router.post('/api/vendors', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_createVendor)));
    router.put('/api/vendors/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_updateVendor)));
    router.delete('/api/vendors/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteVendor)));

    // Purchase Invoices
    router.get('/api/purchase-invoices', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getPurchaseInvoices)));
    router.post('/api/purchase-invoices', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_createPurchaseInvoice)));
    router.put('/api/purchase-invoices/<id>/pay', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_payPurchaseInvoice)));

    // Expenses
    router.get('/api/expenses', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getExpenses)));
    router.post('/api/expenses', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_createExpense)));
    router.delete('/api/expenses/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteExpense)));

    // Bank Accounts
    router.get('/api/bank-accounts', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getBankAccounts)));
    router.post('/api/bank-accounts', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_createBankAccount)));
    router.get('/api/bank-accounts/<id>/reconciliation', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_getBankReconciliation)));
    router.post('/api/bank-accounts/<id>/reconcile', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_reconcileBankAccount)));

    return router;
  }

  Future<Response> _getVendors(Request request) async {
    try {
      final vendors = await _getAllVendorsUseCase.execute();
      return Response.ok(jsonEncode(vendors.map((v) => v.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch vendors: $e'}));
    }
  }

  Future<Response> _createVendor(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final vendor = Vendor(
        id: 0,
        name: data['name'] as String,
        phone: data['phone'] as String?,
        address: data['address'] as String?,
        taxNumber: data['tax_number'] as String?,
        createdAt: DateTime.now(),
      );
      final created = await _createVendorUseCase.execute(vendor);
      return Response.ok(jsonEncode(created.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create vendor: $e'}));
    }
  }

  Future<Response> _updateVendor(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final vendor = Vendor(
        id: id,
        name: data['name'] as String,
        phone: data['phone'] as String?,
        address: data['address'] as String?,
        taxNumber: data['tax_number'] as String?,
        createdAt: DateTime.now(),
      );
      final updated = await _updateVendorUseCase.execute(vendor);
      return Response.ok(jsonEncode(updated.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update vendor: $e'}));
    }
  }

  Future<Response> _deleteVendor(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _deleteVendorUseCase.execute(id);
      return Response.ok(jsonEncode({'message': 'Vendor deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete vendor: $e'}));
    }
  }

  Future<Response> _getPurchaseInvoices(Request request) async {
    try {
      final invoices = await _purchaseInvoiceRepository.findAll();
      return Response.ok(jsonEncode(invoices.map((i) => i.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch purchase invoices: $e'}));
    }
  }

  Future<Response> _createPurchaseInvoice(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final invoice = PurchaseInvoice(
        id: 0,
        vendorId: data['vendor_id'] as int,
        invoiceNumber: data['invoice_number'] as String,
        issueDate: DateTime.parse(data['issue_date'] as String),
        dueDate: data['due_date'] != null ? DateTime.parse(data['due_date'] as String) : null,
        totalAmount: (data['total_amount'] as num).toDouble(),
        paidAmount: 0,
        status: 'unpaid',
        createdAt: DateTime.now(),
      );

      final itemsData = data['items'] as List<dynamic>;
      final items = itemsData.map((itemData) => PurchaseInvoiceItem(
        id: 0,
        invoiceId: 0,
        inventoryVariantId: itemData['inventory_variant_id'] as String,
        quantity: itemData['quantity'] as int,
        unitPrice: (itemData['unit_price'] as num).toDouble(),
        totalPrice: (itemData['total_price'] as num).toDouble(),
      )).toList();

      final created = await _createPurchaseInvoiceUseCase.execute(invoice, items, 'current_user');
      return Response.ok(jsonEncode(created.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create purchase invoice: $e'}));
    }
  }

  Future<Response> _payPurchaseInvoice(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final paymentAmount = (data['payment_amount'] as num).toDouble();
      final paymentDate = DateTime.parse(data['payment_date'] as String);
      
      final updated = await _payPurchaseInvoiceUseCase.execute(id, paymentAmount, paymentDate, 'current_user');
      return Response.ok(jsonEncode(updated.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to pay purchase invoice: $e'}));
    }
  }

  Future<Response> _getExpenses(Request request) async {
    try {
      final expenses = await _expenseRepository.findAll();
      return Response.ok(jsonEncode(expenses.map((e) => e.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch expenses: $e'}));
    }
  }

  Future<Response> _createExpense(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final expense = Expense(
        id: 0,
        expenseDate: DateTime.parse(data['expense_date'] as String),
        accountId: data['account_id'] as int,
        amount: (data['amount'] as num).toDouble(),
        description: data['description'] as String?,
        paymentMethod: data['payment_method'] as String?,
        attachmentUrl: data['attachment_url'] as String?,
        createdBy: 'current_user',
        createdAt: DateTime.now(),
      );

      final created = await _createExpenseUseCase.execute(expense, 'current_user');
      return Response.ok(jsonEncode(created.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create expense: $e'}));
    }
  }

  Future<Response> _deleteExpense(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _expenseRepository.delete(id);
      return Response.ok(jsonEncode({'message': 'Expense deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete expense: $e'}));
    }
  }

  Future<Response> _getBankAccounts(Request request) async {
    try {
      final accounts = await _bankAccountRepository.findAll();
      return Response.ok(jsonEncode(accounts.map((a) => a.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch bank accounts: $e'}));
    }
  }

  Future<Response> _createBankAccount(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final account = BankAccount(
        id: 0,
        accountName: data['account_name'] as String,
        accountNumber: data['account_number'] as String?,
        bankName: data['bank_name'] as String?,
        initialBalance: (data['initial_balance'] as num?)?.toDouble() ?? 0,
        currentBalance: (data['initial_balance'] as num?)?.toDouble() ?? 0,
        isActive: true,
        accountId: data['account_id'] as int?,
      );
      final created = await _bankAccountRepository.create(account);
      return Response.ok(jsonEncode(created.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create bank account: $e'}));
    }
  }

  Future<Response> _getBankReconciliation(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final reconciliations = await _bankAccountRepository.findReconciliationsByBankAccountId(id);
      return Response.ok(jsonEncode(reconciliations.map((r) => r.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch bank reconciliation: $e'}));
    }
  }

  Future<Response> _reconcileBankAccount(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final statementDate = DateTime.parse(data['statement_date'] as String);
      final statementBalance = (data['statement_balance'] as num).toDouble();
      final matchedJournalLineIds = (data['matched_journal_line_ids'] as List<dynamic>).map((e) => e as int).toList();
      
      final reconciled = await _reconcileBankAccountUseCase.execute(id, statementDate, statementBalance, matchedJournalLineIds, 'current_user');
      return Response.ok(jsonEncode(reconciled.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to reconcile bank account: $e'}));
    }
  }
}
