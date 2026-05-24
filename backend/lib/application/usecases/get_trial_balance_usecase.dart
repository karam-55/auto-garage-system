import 'package:postgres/postgres.dart';
import '../../domain/entities/account.dart';
import '../../infrastructure/database/database_connection.dart';

class TrialBalanceLine {
  final Account account;
  final double totalDebit;
  final double totalCredit;

  TrialBalanceLine({
    required this.account,
    required this.totalDebit,
    required this.totalCredit,
  });
}

class GetTrialBalanceUseCase {
  final DatabaseConnection _db;

  GetTrialBalanceUseCase(
    this._db,
  );

  Future<List<TrialBalanceLine>> execute({
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

    // Single SQL query with JOINs to get trial balance
    // Uses idx_journal_lines_account_id for efficient grouping
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
          COALESCE(SUM(jl.debit), 0) as total_debit,
          COALESCE(SUM(jl.credit), 0) as total_credit
        FROM accounts a
        INNER JOIN journal_lines jl ON a.id = jl.account_id
        INNER JOIN journal_entries je ON jl.entry_id = je.id
        $whereClause
        GROUP BY a.id, a.code, a.name_ar, a.name_en, a.parent_id, a.account_type, a.is_active, a.created_at
        HAVING COALESCE(SUM(jl.debit), 0) != 0 OR COALESCE(SUM(jl.credit), 0) != 0
        ORDER BY a.code
      '''),
      parameters: parameters,
    );

    // Map results to TrialBalanceLine objects
    final trialBalance = result.map((row) {
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

      final totalDebit = double.tryParse(row[8].toString()) ?? 0.0;
      final totalCredit = double.tryParse(row[9].toString()) ?? 0.0;

      return TrialBalanceLine(
        account: account,
        totalDebit: totalDebit,
        totalCredit: totalCredit,
      );
    }).toList();

    return trialBalance;
  }
}
