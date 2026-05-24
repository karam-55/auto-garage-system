import 'package:postgres/postgres.dart';
import '../../domain/entities/account.dart';
import '../../infrastructure/database/database_connection.dart';

class ProfitLossLine {
  final Account account;
  final double amount;

  ProfitLossLine({
    required this.account,
    required this.amount,
  });
}

class ProfitLossReport {
  final List<ProfitLossLine> revenues;
  final List<ProfitLossLine> expenses;
  final double totalRevenue;
  final double totalExpense;
  final double netProfit;

  ProfitLossReport({
    required this.revenues,
    required this.expenses,
    required this.totalRevenue,
    required this.totalExpense,
    required this.netProfit,
  });
}

class GetProfitLossUseCase {
  final DatabaseConnection _db;

  GetProfitLossUseCase(
    this._db,
  );

  Future<ProfitLossReport> execute({
    DateTime? fromDate,
    DateTime? toDate,
    int? fiscalPeriodId,
  }) async {
    // Build WHERE clause based on filters
    final whereConditions = <String>[];
    final parameters = <String, dynamic>{};

    if (fromDate != null && toDate != null) {
      whereConditions.add('je.entry_date BETWEEN @fromDate AND @toDate');
      parameters['fromDate'] = fromDate;
      parameters['toDate'] = toDate;
    } else if (fiscalPeriodId != null) {
      whereConditions.add('je.fiscal_period_id = @fiscalPeriodId');
      parameters['fiscalPeriodId'] = fiscalPeriodId;
    }

    final whereClause = whereConditions.isNotEmpty 
        ? 'WHERE ${whereConditions.join(' AND ')}' 
        : '';

    // Single SQL query with JOINs to get profit & loss data
    // Uses idx_journal_lines_account_id and idx_accounts_account_type for efficient filtering
    final result = await _db.execute(
      Sql.named('''
        SELECT 
          a.id,
          a.code,
          a.name_ar,
          a.name_en,
          a.parent_id,
          a.account_type,
          a.is_active,
          a.created_at,
          CASE 
            WHEN a.account_type = 'revenue' THEN COALESCE(SUM(jl.credit - jl.debit), 0)
            WHEN a.account_type IN ('expense', 'cogs') THEN COALESCE(SUM(jl.debit - jl.credit), 0)
            ELSE 0
          END as balance
        FROM accounts a
        INNER JOIN journal_lines jl ON a.id = jl.account_id
        INNER JOIN journal_entries je ON jl.entry_id = je.id
        $whereClause
        AND a.account_type IN ('revenue', 'expense', 'cogs')
        GROUP BY a.id, a.code, a.name_ar, a.name_en, a.parent_id, a.account_type, a.is_active, a.created_at
        HAVING CASE 
          WHEN a.account_type = 'revenue' THEN COALESCE(SUM(jl.credit - jl.debit), 0)
          WHEN a.account_type IN ('expense', 'cogs') THEN COALESCE(SUM(jl.debit - jl.credit), 0)
          ELSE 0
        END != 0
        ORDER BY a.code
      '''),
      parameters: parameters,
    );

    // Map results to ProfitLossLine objects
    final revenues = <ProfitLossLine>[];
    final expenses = <ProfitLossLine>[];
    double totalRevenue = 0;
    double totalExpense = 0;

    for (final row in result) {
      final account = Account(
        id: row[0] as int,
        code: row[1] as String,
        nameAr: row[2] as String,
        nameEn: row[3] as String,
        parentId: row[4] as int?,
        accountType: AccountType.fromString(row[5] as String),
        isActive: row[6] as bool,
        createdAt: row[7] as DateTime,
      );

      final balance = double.tryParse(row[8].toString()) ?? 0.0;

      if (balance != 0) {
        final line = ProfitLossLine(account: account, amount: balance);
        
        if (account.accountType == AccountType.revenue) {
          revenues.add(line);
          totalRevenue += balance;
        } else if (account.accountType == AccountType.expense || 
                   account.accountType == AccountType.cogs) {
          expenses.add(line);
          totalExpense += balance;
        }
      }
    }

    final netProfit = totalRevenue - totalExpense;

    return ProfitLossReport(
      revenues: revenues,
      expenses: expenses,
      totalRevenue: totalRevenue,
      totalExpense: totalExpense,
      netProfit: netProfit,
    );
  }
}
