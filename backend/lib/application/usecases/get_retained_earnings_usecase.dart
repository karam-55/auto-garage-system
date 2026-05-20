import 'package:postgres/postgres.dart';
import '../../infrastructure/database/database_connection.dart';

class GetRetainedEarningsUseCase {
  final DatabaseConnection _databaseConnection;

  GetRetainedEarningsUseCase(this._databaseConnection);

  Future<double> execute(DateTime asOfDate) async {
    final result = await _databaseConnection.execute('''
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
}
