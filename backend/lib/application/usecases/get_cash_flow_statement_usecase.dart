import 'package:postgres/postgres.dart';
import '../../infrastructure/database/database_connection.dart';

class GetCashFlowStatementUseCase {
  final DatabaseConnection _databaseConnection;

  GetCashFlowStatementUseCase(this._databaseConnection);

  Future<Map<String, dynamic>> execute(DateTime startDate, DateTime endDate) async {
    return await _databaseConnection.runInTransaction((session) async {
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
}
