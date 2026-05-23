import 'package:postgres/postgres.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_line.dart';
import '../../domain/repositories/journal_repository.dart';
import '../database/database_connection.dart';
import '../../core/errors/exceptions.dart';

class JournalRepositoryImpl implements JournalRepository {
  final DatabaseConnection _db;

  JournalRepositoryImpl(this._db);

  @override
  Future<JournalEntry> createEntry(JournalEntry entry) async {
    final result = await _db.execute(
      Sql.named('''INSERT INTO journal_entries
         (entry_date, reference, description, is_reversing, reversing_date, is_reversed, created_by, fiscal_period_id)
         VALUES (@entryDate, @reference, @description, @isReversing, @reversingDate, @isReversed, @createdBy, @fiscalPeriodId)
         RETURNING id, created_at'''),
      parameters: {
        'entryDate': entry.entryDate,
        'reference': entry.reference,
        'description': entry.description,
        'isReversing': entry.isReversing,
        'reversingDate': entry.reversingDate,
        'isReversed': entry.isReversed,
        'createdBy': entry.createdBy,
        'fiscalPeriodId': entry.fiscalPeriodId,
      },
    );
    final row = result.first;
    return entry.copyWith(
      id: row[0] as int,
      createdAt: row[1] as DateTime,
    );
  }

  @override
  Future<JournalEntry?> findEntryById(int id) async {
    final result = await _db.execute(
      Sql.named('''SELECT id, entry_date, reference, description, is_reversing, reversing_date, is_reversed,
             created_by, created_at, approved_by, approved_at, fiscal_period_id
      FROM journal_entries WHERE id = @id'''),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRowToJournalEntry(result.first);
  }

  @override
  Future<List<JournalEntry>> findAllEntries({int? limit, int? offset}) async {
    final limitClause = limit != null ? 'LIMIT @limit' : '';
    final offsetClause = offset != null ? 'OFFSET @offset' : '';
    final result = await _db.execute(
      Sql.named('''SELECT id, entry_date, reference, description, is_reversing, reversing_date, is_reversed,
             created_by, created_at, approved_by, approved_at, fiscal_period_id
      FROM journal_entries ORDER BY entry_date DESC, id DESC $limitClause $offsetClause'''),
      parameters: {
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return result.map(_mapRowToJournalEntry).toList();
  }

  @override
  Future<List<JournalEntry>> findByDateRange(DateTime startDate, DateTime endDate) async {
    final result = await _db.execute(
      Sql.named('''SELECT id, entry_date, reference, description, is_reversing, reversing_date, is_reversed,
             created_by, created_at, approved_by, approved_at, fiscal_period_id
      FROM journal_entries WHERE entry_date >= @startDate AND entry_date <= @endDate
      ORDER BY entry_date DESC, id DESC'''),
      parameters: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return result.map(_mapRowToJournalEntry).toList();
  }

  @override
  Future<List<JournalEntry>> findByFiscalPeriod(int fiscalPeriodId) async {
    final result = await _db.execute(
      Sql.named('''SELECT id, entry_date, reference, description, is_reversing, reversing_date, is_reversed,
             created_by, created_at, approved_by, approved_at, fiscal_period_id
      FROM journal_entries WHERE fiscal_period_id = @fiscalPeriodId
      ORDER BY entry_date DESC, id DESC'''),
      parameters: {'fiscalPeriodId': fiscalPeriodId},
    );
    return result.map(_mapRowToJournalEntry).toList();
  }

  @override
  Future<JournalEntry> updateEntry(JournalEntry entry) async {
    await _db.execute(
      Sql.named('''UPDATE journal_entries SET
         entry_date = @entryDate,
         reference = @reference,
         description = @description,
         is_reversing = @isReversing,
         reversing_date = @reversingDate,
         is_reversed = @isReversed,
         approved_by = @approvedBy,
         approved_at = @approvedAt,
         fiscal_period_id = @fiscalPeriodId
         WHERE id = @id'''),
      parameters: {
        'id': entry.id,
        'entryDate': entry.entryDate,
        'reference': entry.reference,
        'description': entry.description,
        'isReversing': entry.isReversing,
        'reversingDate': entry.reversingDate,
        'isReversed': entry.isReversed,
        'approvedBy': entry.approvedBy,
        'approvedAt': entry.approvedAt,
        'fiscalPeriodId': entry.fiscalPeriodId,
      },
    );
    return entry;
  }

  @override
  Future<void> deleteEntry(int id) async {
    await _db.execute(
      Sql.named('DELETE FROM journal_entries WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<JournalLine> createLine(JournalLine line) async {
    final result = await _db.execute(
      Sql.named('''INSERT INTO journal_lines
         (entry_id, account_id, debit, credit, description, source_type, source_id)
         VALUES (@entryId, @accountId, @debit, @credit, @description, @sourceType, @sourceId)
         RETURNING id'''),
      parameters: {
        'entryId': line.entryId,
        'accountId': line.accountId,
        'debit': line.debit,
        'credit': line.credit,
        'description': line.description,
        'sourceType': line.sourceType,
        'sourceId': line.sourceId,
      },
    );
    final row = result.first;
    return line.copyWith(id: row[0] as int);
  }

  @override
  Future<List<JournalLine>> findLinesByEntryId(int entryId) async {
    try {
      final result = await _db.execute(
        Sql.named('SELECT * FROM journal_lines WHERE entry_id = @entryId'),
        parameters: {'entryId': entryId},
      );
      return result.map((row) => _mapRowToJournalLine(row)).toList();
    } catch (e) {
      throw DatabaseException('Failed to find lines by entry id: $e');
    }
  }

  @override
  Future<List<JournalLine>> findAllLines({int? limit, int? offset}) async {
    try {
      final limitClause = limit != null ? 'LIMIT @limit' : '';
      final offsetClause = offset != null ? 'OFFSET @offset' : '';
      final result = await _db.execute(
        Sql.named('SELECT * FROM journal_lines $limitClause $offsetClause'),
        parameters: {
          'limit': ?limit,
          'offset': ?offset,
        },
      );
      return result.map((row) => _mapRowToJournalLine(row)).toList();
    } catch (e) {
      throw DatabaseException('Failed to find all journal lines: $e');
    }
  }

  @override
  Future<JournalLine> updateLine(JournalLine line) async {
    await _db.execute(
      Sql.named('''UPDATE journal_lines SET
         account_id = @accountId,
         debit = @debit,
         credit = @credit,
         description = @description,
         source_type = @sourceType,
         source_id = @sourceId
         WHERE id = @id'''),
      parameters: {
        'id': line.id,
        'accountId': line.accountId,
        'debit': line.debit,
        'credit': line.credit,
        'description': line.description,
        'sourceType': line.sourceType,
        'sourceId': line.sourceId,
      },
    );
    return line;
  }

  @override
  Future<void> deleteLine(int id) async {
    await _db.execute(
      Sql.named('DELETE FROM journal_lines WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<Map<String, dynamic>> getTradingAccount(DateTime fromDate, DateTime toDate) async {
    return await _db.runInTransaction((session) async {
      // 1. إجمالي الإيرادات (من حسابات الإيرادات)
      final revenueResult = await session.execute(
        Sql.named('''
        SELECT 
          COALESCE(SUM(jl.credit - jl.debit), 0) as total_revenue
        FROM journal_lines jl
        JOIN journal_entries je ON jl.entry_id = je.id
        JOIN accounts a ON jl.account_id = a.id
        WHERE je.entry_date BETWEEN @fromDate AND @toDate
        AND a.account_type = 'revenue'
      '''),
        parameters: {
          'fromDate': fromDate,
          'toDate': toDate,
        },
      );

      final revenueData = revenueResult.first.toColumnMap();
      final totalRevenue = double.tryParse(revenueData['total_revenue'].toString()) ?? 0.0;

      // 2. إجمالي تكلفة البضاعة المباعة (COGS)
      final cogsResult = await session.execute(
        Sql.named('''
        SELECT 
          COALESCE(SUM(jl.debit - jl.credit), 0) as total_cogs
        FROM journal_lines jl
        JOIN journal_entries je ON jl.entry_id = je.id
        JOIN accounts a ON jl.account_id = a.id
        WHERE je.entry_date BETWEEN @fromDate AND @toDate
        AND a.account_type = 'cogs'
      '''),
        parameters: {
          'fromDate': fromDate,
          'toDate': toDate,
        },
      );

      final cogsData = cogsResult.first.toColumnMap();
      final totalCogs = double.tryParse(cogsData['total_cogs'].toString()) ?? 0.0;

      // 3. إجمالي الربح
      final grossProfit = totalRevenue - totalCogs;

      return {
        'totalRevenue': totalRevenue,
        'totalCogs': totalCogs,
        'grossProfit': grossProfit,
      };
    });
  }

  @override
  Future<double> getRetainedEarnings(DateTime asOfDate) async {
    final result = await _db.execute('''
      SELECT 
        COALESCE(SUM(CASE 
          WHEN a.account_type IN ('revenue', 'expense', 'cogs') 
          THEN jl.debit - jl.credit 
          ELSE 0 
        END), 0) as total_net_profit
      FROM journal_lines jl
      JOIN journal_entries je ON jl.entry_id = je.id
      JOIN accounts a ON jl.account_id = a.id
      WHERE je.entry_date <= @asOfDate
    ''', parameters: {'asOfDate': asOfDate});

    final totalNetProfit = result.first[0] as num;

    // حالياً لا يوجد جدول dividends، لذا سنرجع صافي الربح التراكمي
    // يمكن إضافة جدول dividends لاحقاً وطرح التوزيعات من هنا
    return totalNetProfit.toDouble();
  }

  @override
  Future<Map<String, dynamic>> getCashFlowStatement(DateTime startDate, DateTime endDate) async {
    return await _db.runInTransaction((session) async {
      // 1. صافي الربح من قائمة الدخل
      // سنستخدم حسابات الإيرادات والمصروفات
      final profitLossResult = await session.execute(
        Sql.named('''
        SELECT 
          COALESCE(SUM(CASE WHEN jl.debit > 0 THEN jl.debit ELSE 0 END) - 
                  SUM(CASE WHEN jl.credit > 0 THEN jl.credit ELSE 0 END), 0) as net_profit
        FROM journal_lines jl
        JOIN journal_entries je ON jl.entry_id = je.id
        JOIN accounts a ON jl.account_id = a.id
        WHERE je.entry_date BETWEEN @startDate AND @endDate
        AND a.account_type IN ('revenue', 'expense', 'cogs')
      '''),
        parameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
      );

      final profitLossData = profitLossResult.first.toColumnMap();
      final netProfit = double.tryParse(profitLossData['net_profit'].toString()) ?? 0.0;

      // 2. التغير في الذمم المدينة (العملاء)
      final receivablesStart = await _getBalanceAtDate(session, 'receivable', startDate.subtract(const Duration(days: 1)));
      final receivablesEnd = await _getBalanceAtDate(session, 'receivable', endDate);
      final changeReceivables = receivablesEnd - receivablesStart;

      // 3. التغير في المخزون
      final inventoryStart = await _getBalanceAtDate(session, 'inventory', startDate.subtract(const Duration(days: 1)));
      final inventoryEnd = await _getBalanceAtDate(session, 'inventory', endDate);
      final changeInventory = inventoryEnd - inventoryStart;

      // 4. التغير في الموردين (ذمم دائنة)
      final payablesStart = await _getBalanceAtDate(session, 'payable', startDate.subtract(const Duration(days: 1)));
      final payablesEnd = await _getBalanceAtDate(session, 'payable', endDate);
      final changePayables = payablesEnd - payablesStart;

      // حساب التدفق النقدي من العمليات التشغيلية
      final cashFlowFromOperations = netProfit.toDouble() - changeReceivables - changeInventory + changePayables;

      return {
        'netProfit': netProfit.toDouble(),
        'adjustments': {
          'changeInReceivables': -changeReceivables,
          'changeInInventory': -changeInventory,
          'changeInPayables': changePayables,
        },
        'cashFlowFromOperations': cashFlowFromOperations,
      };
    });
  }

  @override
  Future<Map<String, dynamic>> getBreakEvenAnalysis(DateTime fromDate, DateTime toDate) async {
    return await _db.runInTransaction((session) async {
      // 1. إجمالي الإيرادات (من حسابات الإيرادات)
      final revenueResult = await session.execute(
        Sql.named('''
        SELECT 
          COALESCE(SUM(jl.credit - jl.debit), 0) as total_revenue
        FROM journal_lines jl
        JOIN journal_entries je ON jl.entry_id = je.id
        JOIN accounts a ON jl.account_id = a.id
        WHERE je.entry_date BETWEEN @fromDate AND @toDate
        AND a.account_type = 'revenue'
      '''),
        parameters: {
          'fromDate': fromDate,
          'toDate': toDate,
        },
      );

      final revenueData = revenueResult.first.toColumnMap();
      final totalRevenue = double.tryParse(revenueData['total_revenue'].toString()) ?? 0.0;

      // 2. إجمالي التكاليف المتغيرة (COGS + أي مصروفات متغيرة)
      // حالياً سنعتبر COGS فقط كتكاليف متغيرة
      // يمكن إضافة عمود expense_behavior لاحقاً للتمييز بين الثابت والمتغير
      final variableCostsResult = await session.execute(
        Sql.named('''
        SELECT 
          COALESCE(SUM(jl.debit - jl.credit), 0) as total_variable_costs
        FROM journal_lines jl
        JOIN journal_entries je ON jl.entry_id = je.id
        JOIN accounts a ON jl.account_id = a.id
        WHERE je.entry_date BETWEEN @fromDate AND @toDate
        AND a.account_type = 'cogs'
      '''),
        parameters: {
          'fromDate': fromDate,
          'toDate': toDate,
        },
      );

      final variableCostsData = variableCostsResult.first.toColumnMap();
      final totalVariableCosts = double.tryParse(variableCostsData['total_variable_costs'].toString()) ?? 0.0;

      // 3. إجمالي التكاليف الثابتة (المصروفات التشغيلية - الإيجار، الرواتب الإدارية، إلخ)
      // سنعتبر جميع حسابات المصروفات (باستثناء COGS) كتكاليف ثابتة
      final fixedCostsResult = await session.execute(
        Sql.named('''
        SELECT 
          COALESCE(SUM(jl.debit - jl.credit), 0) as total_fixed_costs
        FROM journal_lines jl
        JOIN journal_entries je ON jl.entry_id = je.id
        JOIN accounts a ON jl.account_id = a.id
        WHERE je.entry_date BETWEEN @fromDate AND @toDate
        AND a.account_type = 'expense'
      '''),
        parameters: {
          'fromDate': fromDate,
          'toDate': toDate,
        },
      );

      final fixedCostsData = fixedCostsResult.first.toColumnMap();
      final totalFixedCosts = double.tryParse(fixedCostsData['total_fixed_costs'].toString()) ?? 0.0;

      // حسابات نقطة التعادل
      final contributionMargin = totalRevenue - totalVariableCosts;
      final contributionMarginRatio = totalRevenue > 0 ? contributionMargin / totalRevenue : 0.0;
      final breakEvenRevenue = contributionMarginRatio > 0 ? totalFixedCosts / contributionMarginRatio : 0.0;

      return {
        'totalRevenue': totalRevenue,
        'totalVariableCosts': totalVariableCosts,
        'totalFixedCosts': totalFixedCosts,
        'contributionMargin': contributionMargin,
        'contributionMarginRatio': contributionMarginRatio,
        'breakEvenRevenue': breakEvenRevenue,
      };
    });
  }

  Future<double> _getBalanceAtDate(Session session, String accountType, DateTime asOfDate) async {
    // حساب رصيد حساب معين حتى تاريخ معين
    // سنبحث عن حسابات بناءً على النوع (receivable, inventory, payable)
    String accountTypeFilter = '';
    if (accountType == 'receivable') {
      accountTypeFilter = "AND a.account_type = 'asset' AND (a.name_ar LIKE '%عميل%' OR a.name_ar LIKE '%ذمم%')";
    } else if (accountType == 'inventory') {
      accountTypeFilter = "AND a.account_type = 'asset' AND (a.name_ar LIKE '%مخزون%' OR a.name_ar LIKE '%بضاعة%')";
    } else if (accountType == 'payable') {
      accountTypeFilter = "AND a.account_type = 'liability' AND (a.name_ar LIKE '%مورد%' OR a.name_ar LIKE '%ذمم%')";
    }

    final result = await session.execute(
      Sql.named('''
      SELECT 
        COALESCE(SUM(jl.debit - jl.credit), 0) as balance
      FROM journal_lines jl
      JOIN journal_entries je ON jl.entry_id = je.id
      JOIN accounts a ON jl.account_id = a.id
      WHERE je.entry_date <= @asOfDate
      $accountTypeFilter
    '''),
      parameters: {
        'asOfDate': asOfDate,
      },
    );

    final resultData = result.first.toColumnMap();
    return double.tryParse(resultData['balance'].toString()) ?? 0.0;
  }

  JournalEntry _mapRowToJournalEntry(ResultRow row) {
    final data = row.toColumnMap();
    return JournalEntry(
      id: data['id'] is num ? (data['id'] as num).toInt() : 0,
      entryDate: data['entry_date'] is DateTime ? data['entry_date'] : DateTime.tryParse(data['entry_date'].toString()) ?? DateTime.now(),
      reference: data['reference'] as String?,
      description: data['description'] as String?,
      isReversing: data['is_reversing'] as bool? ?? false,
      reversingDate: data['reversing_date'] != null ? DateTime.tryParse(data['reversing_date'].toString()) : null,
      isReversed: data['is_reversed'] as bool? ?? false,
      createdBy: data['created_by'] as String?,
      createdAt: data['created_at'] is DateTime ? data['created_at'] : DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now(),
      approvedBy: data['approved_by'] as String?,
      approvedAt: data['approved_at'] != null ? DateTime.tryParse(data['approved_at'].toString()) : null,
      fiscalPeriodId: data['fiscal_period_id'] is num ? (data['fiscal_period_id'] as num).toInt() : null,
    );
  }

  JournalLine _mapRowToJournalLine(ResultRow row) {
    final data = row.toColumnMap();
    return JournalLine(
      id: data['id'] is num ? (data['id'] as num).toInt() : 0,
      entryId: data['entry_id'] is num ? (data['entry_id'] as num).toInt() : 0,
      accountId: data['account_id'] is num ? (data['account_id'] as num).toInt() : 0,
      debit: data['debit'] is num ? (data['debit'] as num).toDouble() : 0.0,
      credit: data['credit'] is num ? (data['credit'] as num).toDouble() : 0.0,
      description: data['description'] as String?,
      sourceType: data['source_type'] as String?,
      sourceId: data['source_id'] as String?,
    );
  }
}
