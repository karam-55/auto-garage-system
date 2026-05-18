import 'package:postgres/postgres.dart';
import '../../infrastructure/database/database_connection.dart';

class GetCashFlowStatementUseCase {
  final DatabaseConnection _databaseConnection;

  GetCashFlowStatementUseCase(this._databaseConnection);

  Future<Map<String, dynamic>> execute(DateTime startDate, DateTime endDate) async {
    final connection = await _databaseConnection.connection;

    // 1. صافي الربح من قائمة الدخل
    // سنستخدم حسابات الإيرادات والمصروفات
    final profitLossResult = await connection.query('''
      SELECT 
        COALESCE(SUM(CASE WHEN jl.debit > 0 THEN jl.debit ELSE 0 END) - 
                SUM(CASE WHEN jl.credit > 0 THEN jl.credit ELSE 0 END), 0) as net_profit
      FROM journal_lines jl
      JOIN journal_entries je ON jl.entry_id = je.id
      JOIN accounts a ON jl.account_id = a.id
      WHERE je.entry_date BETWEEN $1 AND $2
      AND a.account_type IN ('revenue', 'expense', 'cogs')
    ''', [startDate, endDate]);

    final netProfit = profitLossResult.first[0] as num;

    // 2. التغير في الذمم المدينة (العملاء)
    final receivablesStart = await _getBalanceAtDate(connection, 'receivable', startDate.subtract(const Duration(days: 1)));
    final receivablesEnd = await _getBalanceAtDate(connection, 'receivable', endDate);
    final changeReceivables = receivablesEnd - receivablesStart;

    // 3. التغير في المخزون
    final inventoryStart = await _getBalanceAtDate(connection, 'inventory', startDate.subtract(const Duration(days: 1)));
    final inventoryEnd = await _getBalanceAtDate(connection, 'inventory', endDate);
    final changeInventory = inventoryEnd - inventoryStart;

    // 4. التغير في الموردين (ذمم دائنة)
    final payablesStart = await _getBalanceAtDate(connection, 'payable', startDate.subtract(const Duration(days: 1)));
    final payablesEnd = await _getBalanceAtDate(connection, 'payable', endDate);
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
  }

  Future<double> _getBalanceAtDate(Connection connection, String accountType, DateTime asOfDate) async {
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

    final result = await connection.query('''
      SELECT 
        COALESCE(SUM(jl.debit - jl.credit), 0) as balance
      FROM journal_lines jl
      JOIN journal_entries je ON jl.entry_id = je.id
      JOIN accounts a ON jl.account_id = a.id
      WHERE je.entry_date <= $1
      $accountTypeFilter
    ''', [asOfDate]);

    return result.first[0] as double;
  }
}
