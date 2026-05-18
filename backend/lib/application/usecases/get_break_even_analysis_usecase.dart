import 'package:postgres/postgres.dart';
import '../../infrastructure/database/database_connection.dart';

class GetBreakEvenAnalysisUseCase {
  final DatabaseConnection _databaseConnection;

  GetBreakEvenAnalysisUseCase(this._databaseConnection);

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

    // 2. إجمالي التكاليف المتغيرة (COGS + أي مصروفات متغيرة)
    // حالياً سنعتبر COGS فقط كتكاليف متغيرة
    // يمكن إضافة عمود expense_behavior لاحقاً للتمييز بين الثابت والمتغير
    final variableCostsResult = await connection.query('''
      SELECT 
        COALESCE(SUM(jl.debit - jl.credit), 0) as total_variable_costs
      FROM journal_lines jl
      JOIN journal_entries je ON jl.entry_id = je.id
      JOIN accounts a ON jl.account_id = a.id
      WHERE je.entry_date BETWEEN $1 AND $2
      AND a.account_type = 'cogs'
    ''', [fromDate, toDate]);

    final totalVariableCosts = (variableCostsResult.first[0] as num).toDouble();

    // 3. إجمالي التكاليف الثابتة (المصروفات التشغيلية - الإيجار، الرواتب الإدارية، إلخ)
    // سنعتبر جميع حسابات المصروفات (باستثناء COGS) كتكاليف ثابتة
    final fixedCostsResult = await connection.query('''
      SELECT 
        COALESCE(SUM(jl.debit - jl.credit), 0) as total_fixed_costs
      FROM journal_lines jl
      JOIN journal_entries je ON jl.entry_id = je.id
      JOIN accounts a ON jl.account_id = a.id
      WHERE je.entry_date BETWEEN $1 AND $2
      AND a.account_type = 'expense'
    ''', [fromDate, toDate]);

    final totalFixedCosts = (fixedCostsResult.first[0] as num).toDouble();

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
  }
}
