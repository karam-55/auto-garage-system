import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../core/errors/exceptions.dart';
import '../database/database_connection.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  CustomerRepositoryImpl(this._db);

  @override
  Future<Customer> create(Customer customer) async {
    try {
      final result = await _db.connection.query('''
        INSERT INTO customers (id, full_name, phone, address, created_at)
        VALUES (@id, @fullName, @phone, @address, @createdAt)
        RETURNING *
      ''', substitutionValues: {
        'id': customer.id.isEmpty ? _uuid.v4() : customer.id,
        'fullName': customer.fullName,
        'phone': customer.phone,
        'address': customer.address,
        'createdAt': customer.createdAt,
      });

      return _mapRowToCustomer(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create customer: $e');
    }
  }

  @override
  Future<Customer?> findById(String id) async {
    try {
      final result = await _db.connection.query(
        'SELECT * FROM customers WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (result.isEmpty) return null;
      return _mapRowToCustomer(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find customer by id: $e');
    }
  }

  @override
  Future<Customer?> findByPhone(String phone) async {
    try {
      final result = await _db.connection.query(
        'SELECT * FROM customers WHERE phone = @phone',
        substitutionValues: {'phone': phone},
      );

      if (result.isEmpty) return null;
      return _mapRowToCustomer(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find customer by phone: $e');
    }
  }

  @override
  Future<List<Customer>> findAll() async {
    try {
      final result = await _db.connection.query('SELECT * FROM customers ORDER BY created_at DESC');
      return result.map(_mapRowToCustomer).toList();
    } catch (e) {
      throw DatabaseException('Failed to find all customers: $e');
    }
  }

  @override
  Future<Customer> update(Customer customer) async {
    try {
      final result = await _db.connection.query('''
        UPDATE customers 
        SET full_name = @fullName, phone = @phone, address = @address, updated_at = @updatedAt
        WHERE id = @id
        RETURNING *
      ''', substitutionValues: {
        'id': customer.id,
        'fullName': customer.fullName,
        'phone': customer.phone,
        'address': customer.address,
        'updatedAt': DateTime.now().toUtc(),
      });

      return _mapRowToCustomer(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update customer: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.connection.query(
        'DELETE FROM customers WHERE id = @id',
        substitutionValues: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete customer: $e');
    }
  }

  Customer _mapRowToCustomer(PostgreSQLResultRow row) {
    return Customer(
      id: row['id'].toString(),
      fullName: row['full_name'],
      phone: row['phone'],
      address: row['address'],
      createdAt: row['created_at'],
      updatedAt: row['updated_at'],
    );
  }
}
