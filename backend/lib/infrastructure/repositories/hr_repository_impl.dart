import 'package:postgres/postgres.dart';
import '../../domain/entities/employee_contract.dart';
import '../../domain/repositories/hr_repository.dart';
import '../database/database_connection.dart';

class EmployeeContractRepositoryImpl implements EmployeeContractRepository {
  final DatabaseConnection _db;

  EmployeeContractRepositoryImpl(this._db);

  @override
  Future<EmployeeContract> create(EmployeeContract contract) async {
    final result = await _db.pool.execute(
      Sql.named('''
        INSERT INTO employee_contracts (user_id, contract_type, start_date, end_date, base_salary, benefits)
        VALUES (@userId, @contractType, @startDate, @endDate, @baseSalary, @benefits)
        RETURNING id, created_at, updated_at
      '''),
      parameters: {
        'userId': contract.userId,
        'contractType': contract.contractType,
        'startDate': contract.startDate,
        'endDate': contract.endDate,
        'baseSalary': contract.baseSalary,
        'benefits': contract.benefits,
      },
    );

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;
    final updatedAt = row[2] as DateTime;

    return contract.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<EmployeeContract?> findById(int id) async {
    final result = await _db.pool.execute(
      Sql.named('SELECT * FROM employee_contracts WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToContract(row);
  }

  @override
  Future<List<EmployeeContract>> findByUserId(String userId) async {
    final result = await _db.pool.execute(
      Sql.named('SELECT * FROM employee_contracts WHERE user_id = @userId ORDER BY start_date DESC'),
      parameters: {'userId': userId},
    );

    return result.map((row) => _mapRowToContract(row)).toList();
  }

  @override
  Future<List<EmployeeContract>> findAll() async {
    final result = await _db.pool.execute(
      'SELECT * FROM employee_contracts ORDER BY start_date DESC',
    );

    return result.map((row) => _mapRowToContract(row)).toList();
  }

  @override
  Future<EmployeeContract> update(EmployeeContract contract) async {
    await _db.pool.execute(
      Sql.named('''
        UPDATE employee_contracts
        SET user_id = @userId, contract_type = @contractType, start_date = @startDate, end_date = @endDate,
            base_salary = @baseSalary, benefits = @benefits, updated_at = NOW()
        WHERE id = @id
      '''),
      parameters: {
        'userId': contract.userId,
        'contractType': contract.contractType,
        'startDate': contract.startDate,
        'endDate': contract.endDate,
        'baseSalary': contract.baseSalary,
        'benefits': contract.benefits,
        'id': contract.id,
      },
    );

    return contract.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute(
      Sql.named('DELETE FROM employee_contracts WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  EmployeeContract _mapRowToContract(List<dynamic> row) {
    return EmployeeContract(
      id: row[0] as int,
      userId: row[1] as String,
      contractType: row[2] as String,
      startDate: row[3] as DateTime,
      endDate: row[4] as DateTime?,
      baseSalary: row[5] as double?,
      benefits: row[6] as String?,
      createdAt: row[7] as DateTime,
      updatedAt: row[8] as DateTime,
    );
  }
}
