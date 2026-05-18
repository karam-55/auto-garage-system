import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_line.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../infrastructure/repositories/account_repository_impl.dart';
import '../../infrastructure/repositories/journal_repository_impl.dart';
import '../middlewares/auth_middleware.dart';
import '../../infrastructure/database/database_connection.dart';
import '../../application/services/journal_service.dart';
import '../../domain/entities/role.dart';
import '../../application/usecases/get_trial_balance_usecase.dart';
import '../../application/usecases/get_profit_loss_usecase.dart';
import '../../application/usecases/get_balance_sheet_usecase.dart';
import '../../application/usecases/get_general_ledger_usecase.dart';
import '../../application/usecases/get_cash_flow_statement_usecase.dart';
import '../../application/usecases/get_break_even_analysis_usecase.dart';
import '../../application/usecases/get_trading_account_usecase.dart';

class AccountingRoutes {
  final AccountRepository _accountRepository;
  final JournalRepository _journalRepository;
  final JournalService _journalService;
  final AuthMiddleware _authMiddleware;
  final GetTrialBalanceUseCase _getTrialBalanceUseCase;
  final GetProfitLossUseCase _getProfitLossUseCase;
  final GetBalanceSheetUseCase _getBalanceSheetUseCase;
  final GetGeneralLedgerUseCase _getGeneralLedgerUseCase;
  final GetCashFlowStatementUseCase _getCashFlowStatementUseCase;
  final GetBreakEvenAnalysisUseCase _getBreakEvenAnalysisUseCase;
  final GetTradingAccountUseCase _getTradingAccountUseCase;

  AccountingRoutes(
    this._accountRepository,
    this._journalRepository,
    this._journalService,
    this._authMiddleware,
    this._getTrialBalanceUseCase,
    this._getProfitLossUseCase,
    this._getBalanceSheetUseCase,
    this._getGeneralLedgerUseCase,
    this._getCashFlowStatementUseCase,
    this._getBreakEvenAnalysisUseCase,
    this._getTradingAccountUseCase,
  );

  factory AccountingRoutes.create(DatabaseConnection db, AuthMiddleware authMiddleware) {
    final accountRepository = AccountRepositoryImpl(db);
    final journalRepository = JournalRepositoryImpl(db);
    final journalService = JournalService(journalRepository, accountRepository);
    final getTrialBalanceUseCase = GetTrialBalanceUseCase(journalRepository, accountRepository);
    final getProfitLossUseCase = GetProfitLossUseCase(journalRepository, accountRepository);
    final getBalanceSheetUseCase = GetBalanceSheetUseCase(journalRepository, accountRepository);
    final getGeneralLedgerUseCase = GetGeneralLedgerUseCase(journalRepository, accountRepository);
    final getCashFlowStatementUseCase = GetCashFlowStatementUseCase(db);
    final getBreakEvenAnalysisUseCase = GetBreakEvenAnalysisUseCase(db);
    final getTradingAccountUseCase = GetTradingAccountUseCase(db);
    
    return AccountingRoutes(
      accountRepository,
      journalRepository,
      journalService,
      authMiddleware,
      getTrialBalanceUseCase,
      getProfitLossUseCase,
      getBalanceSheetUseCase,
      getGeneralLedgerUseCase,
      getCashFlowStatementUseCase,
      getBreakEvenAnalysisUseCase,
      getTradingAccountUseCase,
    );
  }

  Router get router {
    final router = Router();

    // GET /api/accounts
    router.get('/api/accounts', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getAccounts)));

    // POST /api/accounts
    router.post('/api/accounts', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_createAccount)));

    // PUT /api/accounts/<id>
    router.put('/api/accounts/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_updateAccount)));

    // DELETE /api/accounts/<id>
    router.delete('/api/accounts/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteAccount)));

    // GET /api/accounts/<id>
    router.get('/api/accounts/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getAccountById)));

    // GET /api/journal-entries
    router.get('/api/journal-entries', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getJournalEntries)));

    // POST /api/journal-entries
    router.post('/api/journal-entries', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_createJournalEntry)));

    // PUT /api/journal-entries/<id>
    router.put('/api/journal-entries/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_updateJournalEntry)));

    // DELETE /api/journal-entries/<id>
    router.delete('/api/journal-entries/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_deleteJournalEntry)));

    // GET /api/journal-entries/<id>
    router.get('/api/journal-entries/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getJournalEntryById)));

    // GET /api/trial-balance
    router.get('/api/trial-balance', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getTrialBalance)));

    // GET /api/reports/profit-loss
    router.get('/api/reports/profit-loss', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getProfitLoss)));

    // GET /api/reports/balance-sheet
    router.get('/api/reports/balance-sheet', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getBalanceSheet)));

    // GET /api/reports/general-ledger
    router.get('/api/reports/general-ledger', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getGeneralLedger)));

    // GET /api/reports/cash-flow
    router.get('/api/reports/cash-flow', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getCashFlow)));

    // GET /api/reports/break-even
    router.get('/api/reports/break-even', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getBreakEven)));

    // GET /api/reports/trading
    router.get('/api/reports/trading', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getTrading)));

    return router;
  }

  Future<Response> _getAccounts(Request request) async {
    try {
      final accounts = await _accountRepository.findAll();
      return Response.ok(jsonEncode(accounts.map((a) => a.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch accounts: $e'}),
      );
    }
  }

  Future<Response> _createAccount(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final account = Account(
        id: 0,
        code: data['code'] as String,
        nameAr: data['name_ar'] as String,
        nameEn: data['name_en'] as String,
        parentId: data['parent_id'] as int?,
        accountType: AccountType.fromString(data['account_type'] as String),
        isActive: data['is_active'] as bool? ?? true,
        createdAt: DateTime.now().toUtc(),
      );

      final created = await _accountRepository.create(account);
      return Response.ok(jsonEncode(created.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create account: $e'}),
      );
    }
  }

  Future<Response> _getAccountById(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final account = await _accountRepository.findById(id);
      if (account == null) {
        return Response.notFound(jsonEncode({'error': 'Account not found'}));
      }
      return Response.ok(jsonEncode(account.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch account: $e'}),
      );
    }
  }

  Future<Response> _updateAccount(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final existing = await _accountRepository.findById(id);
      if (existing == null) {
        return Response.notFound(jsonEncode({'error': 'Account not found'}));
      }

      final updated = existing.copyWith(
        code: data['code'] as String? ?? existing.code,
        nameAr: data['nameAr'] as String? ?? existing.nameAr,
        nameEn: data['nameEn'] as String? ?? existing.nameEn,
        parentId: data['parentId'] as int?,
        accountType: data['accountType'] != null ? AccountType.fromString(data['accountType'] as String) : existing.accountType,
        isActive: data['isActive'] as bool? ?? existing.isActive,
      );

      final result = await _accountRepository.update(updated);
      return Response.ok(jsonEncode(result.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update account: $e'}),
      );
    }
  }

  Future<Response> _deleteAccount(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _accountRepository.delete(id);
      return Response.ok(jsonEncode({'message': 'Account deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete account: $e'}),
      );
    }
  }

  Future<Response> _getJournalEntries(Request request) async {
    try {
      final entries = await _journalRepository.findAllEntries();
      return Response.ok(jsonEncode(entries.map((e) => e.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch journal entries: $e'}),
      );
    }
  }

  Future<Response> _createJournalEntry(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final linesData = data['lines'] as List;
      final lines = linesData.map((l) => JournalLineInput(
        accountId: l['account_id'] as int,
        debit: (l['debit'] as num).toDouble(),
        credit: (l['credit'] as num).toDouble(),
        description: l['description'] as String?,
      )).toList();

      final entry = await _journalService.createJournalEntry(
        date: DateTime.parse(data['entry_date'] as String),
        reference: data['reference'] as String? ?? '',
        description: data['description'] as String? ?? '',
        lines: lines,
        sourceType: data['source_type'] as String,
        sourceId: data['source_id'] as String,
        isReversing: data['is_reversing'] as bool? ?? false,
        reversingDate: data['reversing_date'] != null ? DateTime.parse(data['reversing_date'] as String) : null,
        createdBy: request.context['user'] != null ? (request.context['user'] as dynamic).id : null,
        fiscalPeriodId: data['fiscal_period_id'] as int?,
      );

      return Response.ok(jsonEncode(entry.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create journal entry: $e'}),
      );
    }
  }

  Future<Response> _getJournalEntryById(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final entry = await _journalRepository.findEntryById(id);
      if (entry == null) {
        return Response.notFound(jsonEncode({'error': 'Journal entry not found'}));
      }
      final lines = await _journalRepository.findLinesByEntryId(id);
      return Response.ok(jsonEncode({
        'id': entry.id,
        'entryDate': entry.entryDate.toIso8601String(),
        'reference': entry.reference,
        'description': entry.description,
        'lines': lines.map((l) => l.toJson()).toList(),
        'isReversing': entry.isReversing,
        'reversingDate': entry.reversingDate?.toIso8601String(),
        'isReversed': entry.isReversed,
        'createdBy': entry.createdBy,
        'createdAt': entry.createdAt.toIso8601String(),
        'approvedBy': entry.approvedBy,
        'approvedAt': entry.approvedAt?.toIso8601String(),
        'fiscalPeriodId': entry.fiscalPeriodId,
      }));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch journal entry: $e'}),
      );
    }
  }

  Future<Response> _updateJournalEntry(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final existing = await _journalRepository.findEntryById(id);
      if (existing == null) {
        return Response.notFound(jsonEncode({'error': 'Journal entry not found'}));
      }

      // For now, we don't allow updating journal entries
      return Response.badRequest(
        body: jsonEncode({'error': 'Updating journal entries is not supported yet'}),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update journal entry: $e'}),
      );
    }
  }

  Future<Response> _deleteJournalEntry(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final existing = await _journalRepository.findEntryById(id);
      if (existing == null) {
        return Response.notFound(jsonEncode({'error': 'Journal entry not found'}));
      }

      // For now, we don't allow deleting journal entries
      return Response.badRequest(
        body: jsonEncode({'error': 'Deleting journal entries is not supported yet'}),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete journal entry: $e'}),
      );
    }
  }

  Future<Response> _getTrialBalance(Request request) async {
    try {
      final params = request.url.queryParameters;
      DateTime? fromDate;
      DateTime? toDate;
      int? fiscalPeriodId;

      if (params['from'] != null && params['to'] != null) {
        fromDate = DateTime.parse(params['from']!);
        toDate = DateTime.parse(params['to']!);
      }
      if (params['fiscalPeriodId'] != null) {
        fiscalPeriodId = int.parse(params['fiscalPeriodId']!);
      }

      final trialBalance = await _getTrialBalanceUseCase.execute(
        fromDate: fromDate,
        toDate: toDate,
        fiscalPeriodId: fiscalPeriodId,
      );

      return Response.ok(jsonEncode({
        'lines': trialBalance.map((line) => {
          'account': line.account.toJson(),
          'totalDebit': line.totalDebit,
          'totalCredit': line.totalCredit,
        }).toList(),
      }));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch trial balance: $e'}),
      );
    }
  }

  Future<Response> _getProfitLoss(Request request) async {
    try {
      final params = request.url.queryParameters;
      DateTime? fromDate;
      DateTime? toDate;
      int? fiscalPeriodId;

      if (params['from'] != null && params['to'] != null) {
        fromDate = DateTime.parse(params['from']!);
        toDate = DateTime.parse(params['to']!);
      }
      if (params['fiscalPeriodId'] != null) {
        fiscalPeriodId = int.parse(params['fiscalPeriodId']!);
      }

      final profitLoss = await _getProfitLossUseCase.execute(
        fromDate: fromDate,
        toDate: toDate,
        fiscalPeriodId: fiscalPeriodId,
      );

      return Response.ok(jsonEncode({
        'revenues': profitLoss.revenues.map((line) => {
          'account': line.account.toJson(),
          'amount': line.amount,
        }).toList(),
        'expenses': profitLoss.expenses.map((line) => {
          'account': line.account.toJson(),
          'amount': line.amount,
        }).toList(),
        'totalRevenue': profitLoss.totalRevenue,
        'totalExpense': profitLoss.totalExpense,
        'netProfit': profitLoss.netProfit,
      }));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch profit & loss: $e'}),
      );
    }
  }

  Future<Response> _getBalanceSheet(Request request) async {
    try {
      final params = request.url.queryParameters;
      DateTime? asOfDate;
      int? fiscalPeriodId;

      if (params['asOfDate'] != null) {
        asOfDate = DateTime.parse(params['asOfDate']!);
      }
      if (params['fiscalPeriodId'] != null) {
        fiscalPeriodId = int.parse(params['fiscalPeriodId']!);
      }

      final balanceSheet = await _getBalanceSheetUseCase.execute(
        asOfDate: asOfDate,
        fiscalPeriodId: fiscalPeriodId,
      );

      return Response.ok(jsonEncode({
        'assets': balanceSheet.assets.map((line) => {
          'account': line.account.toJson(),
          'balance': line.balance,
        }).toList(),
        'liabilities': balanceSheet.liabilities.map((line) => {
          'account': line.account.toJson(),
          'balance': line.balance,
        }).toList(),
        'totalAssets': balanceSheet.totalAssets,
        'totalLiabilities': balanceSheet.totalLiabilities,
        'equity': balanceSheet.equity,
      }));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch balance sheet: $e'}),
      );
    }
  }

  Future<Response> _getGeneralLedger(Request request) async {
    try {
      final params = request.url.queryParameters;
      DateTime? fromDate;
      DateTime? toDate;
      int? accountId;
      int? fiscalPeriodId;

      if (params['from'] != null && params['to'] != null) {
        fromDate = DateTime.parse(params['from']!);
        toDate = DateTime.parse(params['to']!);
      }
      if (params['accountId'] != null) {
        accountId = int.parse(params['accountId']!);
      }
      if (params['fiscalPeriodId'] != null) {
        fiscalPeriodId = int.parse(params['fiscalPeriodId']!);
      }

      final generalLedger = await _getGeneralLedgerUseCase.execute(
        fromDate: fromDate,
        toDate: toDate,
        accountId: accountId,
        fiscalPeriodId: fiscalPeriodId,
      );

      return Response.ok(jsonEncode({
        'entries': generalLedger.map((entry) => {
          'date': entry.date.toIso8601String(),
          'reference': entry.reference,
          'description': entry.description,
          'account': entry.account.toJson(),
          'debit': entry.debit,
          'credit': entry.credit,
          'lineDescription': entry.lineDescription,
        }).toList(),
      }));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch general ledger: $e'}),
      );
    }
  }

  Future<Response> _getCashFlow(Request request) async {
    try {
      final params = request.url.queryParameters;
      if (params['from'] == null || params['to'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing required parameters: from and to'}),
        );
      }

      final fromDate = DateTime.parse(params['from']!);
      final toDate = DateTime.parse(params['to']!);

      final cashFlow = await _getCashFlowStatementUseCase.execute(fromDate, toDate);

      return Response.ok(jsonEncode(cashFlow));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch cash flow statement: $e'}),
      );
    }
  }

  Future<Response> _getBreakEven(Request request) async {
    try {
      final params = request.url.queryParameters;
      if (params['from'] == null || params['to'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing required parameters: from and to'}),
        );
      }

      final fromDate = DateTime.parse(params['from']!);
      final toDate = DateTime.parse(params['to']!);

      final breakEven = await _getBreakEvenAnalysisUseCase.execute(fromDate, toDate);

      return Response.ok(jsonEncode(breakEven));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch break-even analysis: $e'}),
      );
    }
  }

  Future<Response> _getTrading(Request request) async {
    try {
      final params = request.url.queryParameters;
      if (params['from'] == null || params['to'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing required parameters: from and to'}),
        );
      }

      final fromDate = DateTime.parse(params['from']!);
      final toDate = DateTime.parse(params['to']!);

      final trading = await _getTradingAccountUseCase.execute(fromDate, toDate);

      return Response.ok(jsonEncode(trading));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch trading account: $e'}),
      );
    }
  }
}
