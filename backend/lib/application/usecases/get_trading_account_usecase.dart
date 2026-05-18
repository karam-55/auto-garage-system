import 'package:postgres/postgres.dart';
import '../../infrastructure/database/database_connection.dart';

class GetTradingAccountUseCase {
  final DatabaseConnection _databaseConnection;

  GetTradingAccountUseCase(this._databaseConnection);

  Future<Map<String, dynamic>> execute(DateTime fromDate, DateTime toDate) async {
    final connection = await _databaseConnection.connection;

    // 1. إجمالي الإيرادات (من حسابات الإيرادات)
    final revenueResult = await connection.query('''
      SELECT 
        COALESCE(SUM(jl.credit - jl.debit), 0) as total_revenue
      FROM journal_lines jl
      JOIN journal_entries je ON jl.entry_id = je.id
      JOIN accounts a ON jl.account_id = a.id
      WHERE je.entry_date BETWEEN $1 AND $2
      AND a.account_type = 'revenue'
    ''', [fromDate, toDate]);

    final totalRevenue = (revenueResult.first[0] as num).toDouble();

    // 2. إجمالي تكلفة البضاعة المباعة (COGS)
    final cogsResult = await connection.query('''
      SELECT 
        COALESCE(SUM(jl.debit - jl.credit), 0) as total_cogs
      FROM journal_lines jl
      JOIN journal_entries je ON jl.entry_id = je.id
      JOIN accounts a ON jl.account_id = a.id
      WHERE je.entry_date BETWEEN $1 AND $2
      AND a.account_type = 'cogs'
    ''', [fromDate, toDate]);

    final totalCogs = (cogsResult.first[0] as num).toDouble();

    // 3. إجمالي الربح
    final grossProfit = totalRevenue - totalCogs;

    return {
      'totalRevenue': totalRevenue,
      'totalCogs': totalCogs,
      'grossProfit': grossProfit,
    };
  }
}
