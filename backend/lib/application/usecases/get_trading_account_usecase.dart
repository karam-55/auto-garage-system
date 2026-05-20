import 'package:postgres/postgres.dart';
import '../../infrastructure/database/database_connection.dart';

class GetTradingAccountUseCase {
  final DatabaseConnection _databaseConnection;

  GetTradingAccountUseCase(this._databaseConnection);

  Future<Map<String, dynamic>> execute(DateTime fromDate, DateTime toDate) async {
    return await _databaseConnection.runInTransaction((session) async {
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
}
