import 'package:postgres/postgres.dart';
import '../../domain/entities/fiscal_period.dart';
import '../../domain/repositories/fiscal_period_repository.dart';
import '../database/database_connection.dart';

class FiscalPeriodRepositoryImpl implements FiscalPeriodRepository {
  final DatabaseConnection _db;

  FiscalPeriodRepositoryImpl(this._db);

  @override
  Future<FiscalPeriod> create(FiscalPeriod period) async {
    final result = await _db.execute(
      Sql.named('''INSERT INTO fiscal_periods (name, start_date, end_date, is_closed)
         VALUES (@name, @startDate, @endDate, @isClosed)
         RETURNING id, created_at'''),
      parameters: {
        'name': period.name,
        'startDate': period.startDate,
        'endDate': period.endDate,
        'isClosed': period.isClosed,
      },
    );
    final row = result.first;
    return period.copyWith(
      id: row[0] as int,
      createdAt: row[1] as DateTime,
    );
  }

  @override
  Future<FiscalPeriod?> findById(int id) async {
    final result = await _db.execute(
      Sql.named('SELECT id, name, start_date, end_date, is_closed, created_at FROM fiscal_periods WHERE id = @id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRowToFiscalPeriod(result.first);
  }

  @override
  Future<List<FiscalPeriod>> findAll() async {
    final result = await _db.execute(
      Sql.named('SELECT id, name, start_date, end_date, is_closed, created_at FROM fiscal_periods ORDER BY start_date DESC'),
    );
    return result.map(_mapRowToFiscalPeriod).toList();
  }

  @override
  Future<FiscalPeriod?> findActive() async {
    final result = await _db.execute(
      Sql.named('''SELECT id, name, start_date, end_date, is_closed, created_at 
      FROM fiscal_periods WHERE is_closed = false 
      ORDER BY start_date DESC LIMIT 1'''),
    );
    if (result.isEmpty) return null;
    return _mapRowToFiscalPeriod(result.first);
  }

  @override
  Future<FiscalPeriod> update(FiscalPeriod period) async {
    await _db.execute(
      Sql.named('''UPDATE fiscal_periods SET
         name = @name,
         start_date = @startDate,
         end_date = @endDate,
         is_closed = @isClosed
         WHERE id = @id'''),
      parameters: {
        'id': period.id,
        'name': period.name,
        'startDate': period.startDate,
        'endDate': period.endDate,
        'isClosed': period.isClosed,
      },
    );
    return period;
  }

  @override
  Future<void> delete(int id) async {
    await _db.execute(
      Sql.named('DELETE FROM fiscal_periods WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  FiscalPeriod _mapRowToFiscalPeriod(ResultRow row) {
    return FiscalPeriod(
      id: row[0] as int,
      name: row[1] as String,
      startDate: row[2] as DateTime,
      endDate: row[3] as DateTime,
      isClosed: row[4] as bool,
      createdAt: row[5] as DateTime,
    );
  }
}
