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
      final result = await _db.execute(
        Sql.named('''
          INSERT INTO customers (id, full_name, phone, address, created_at)
          VALUES (@id, @fullName, @phone, @address, @createdAt)
          RETURNING *
        '''),
        parameters: {
          'id': customer.id.isEmpty ? _uuid.v4() : customer.id,
          'fullName': customer.fullName,
          'phone': customer.phone,
          'address': customer.address,
          'createdAt': customer.createdAt,
        },
      );

      return _mapRowToCustomer(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create customer: $e');
    }
  }

  @override
  Future<Customer?> findById(String id) async {
    try {
      final result = await _db.execute(
        Sql.named('SELECT * FROM customers WHERE id = @id'),
        parameters: {'id': id},
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
      final result = await _db.execute(
        Sql.named('SELECT * FROM customers WHERE phone = @phone'),
        parameters: {'phone': phone},
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
      final result = await _db.execute('SELECT * FROM customers ORDER BY created_at DESC');
      return result.map(_mapRowToCustomer).toList();
    } catch (e) {
      throw DatabaseException('Failed to find all customers: $e');
    }
  }

  @override
  Future<List<Customer>> search(String query) async {
    try {
      final searchPattern = '%$query%';
      final result = await _db.execute(
        Sql.named('''
          SELECT * FROM customers 
          WHERE full_name ILIKE @search OR phone ILIKE @search
          ORDER BY created_at DESC
        '''),
        parameters: {'search': searchPattern},
      );
      return result.map(_mapRowToCustomer).toList();
    } catch (e) {
      throw DatabaseException('Failed to search customers: $e');
    }
  }

  @override
  Future<Customer> update(Customer customer) async {
    try {
      final result = await _db.execute(
        Sql.named('''
          UPDATE customers 
          SET full_name = @fullName, phone = @phone, address = @address, updated_at = @updatedAt
          WHERE id = @id
          RETURNING *
        '''),
        parameters: {
          'id': customer.id,
          'fullName': customer.fullName,
          'phone': customer.phone,
          'address': customer.address,
          'updatedAt': DateTime.now().toUtc(),
        },
      );

      return _mapRowToCustomer(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update customer: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.execute(
        Sql.named('DELETE FROM customers WHERE id = @id'),
        parameters: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete customer: $e');
    }
  }

  Customer _mapRowToCustomer(ResultRow row) {
    try {
      final data = row.toColumnMap();
      return Customer(
        id: data['id'].toString(),
        fullName: data['full_name'] as String,
        phone: data['phone'] as String,
        address: data['address'] as String?,
        createdAt: data['created_at'] as DateTime,
        updatedAt: data['updated_at'] as DateTime?,
      );
    } catch (e) {
      rethrow;
    }
  }
}
