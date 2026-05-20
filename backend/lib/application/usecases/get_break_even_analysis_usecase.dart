import 'package:postgres/postgres.dart';
import '../../infrastructure/database/database_connection.dart';

class GetBreakEvenAnalysisUseCase {
  final DatabaseConnection _databaseConnection;

  GetBreakEvenAnalysisUseCase(this._databaseConnection);

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

      final totalRevenue = (revenueResult.first[0] as num).toDouble();

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

      final totalVariableCosts = (variableCostsResult.first[0] as num).toDouble();

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
    });
  }
}
