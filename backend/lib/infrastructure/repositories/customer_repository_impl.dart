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
      print('Creating customer: ${customer.fullName}');
      final id = customer.id.isEmpty ? _uuid.v4() : customer.id;
      print('Customer ID: $id');
      
      // Use simple query without Sql.named for better compatibility
      final result = await _db.connection.execute('''
        INSERT INTO customers (id, full_name, phone, address, created_at)
        VALUES ('$id', '${customer.fullName}', '${customer.phone}', '${customer.address ?? ''}', '${customer.createdAt.toIso8601String()}')
        RETURNING *
      ''');

      print('Customer created successfully');
      return _mapRowToCustomer(result.first);
    } catch (e) {
      print('Error creating customer: $e');
      throw DatabaseException('Failed to create customer: $e');
    }
  }

  @override
  Future<Customer?> findById(String id) async {
    try {
      final result = await _db.connection.execute(
        'SELECT * FROM customers WHERE id = @id',
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
      final result = await _db.connection.execute(
        'SELECT * FROM customers WHERE phone = @phone',
        parameters: {'phone': phone} as Map<String, dynamic>,
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
      print('Finding all customers...');
      final result = await _db.connection.execute('SELECT * FROM customers ORDER BY created_at DESC');
      print('Found ${result.length} customers');
      return result.map(_mapRowToCustomer).toList();
    } catch (e) {
      print('Error finding all customers: $e');
      throw DatabaseException('Failed to find all customers: $e');
    }
  }

  @override
  Future<Customer> update(Customer customer) async {
    try {
      print('Updating customer: ${customer.id}');
      final updatedAt = DateTime.now().toUtc().toIso8601String();
      
      // Use simple query without Sql.named for better compatibility
      final result = await _db.connection.execute('''
        UPDATE customers 
        SET full_name = '${customer.fullName}', phone = '${customer.phone}', address = '${customer.address ?? ''}', updated_at = '$updatedAt'
        WHERE id = '${customer.id}'
        RETURNING *
      ''');

      print('Customer updated successfully');
      return _mapRowToCustomer(result.first);
    } catch (e) {
      print('Error updating customer: $e');
      throw DatabaseException('Failed to update customer: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.connection.execute(
        'DELETE FROM customers WHERE id = @id',
        parameters: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete customer: $e');
    }
  }

  Customer _mapRowToCustomer(ResultRow row) {
    try {
      final data = row.toColumnMap();
      print('Mapping customer row: $data');
      return Customer(
        id: data['id'].toString(),
        fullName: data['full_name'] as String,
        phone: data['phone'] as String,
        address: data['address'] as String?,
        createdAt: data['created_at'] as DateTime,
        updatedAt: data['updated_at'] as DateTime?,
      );
    } catch (e) {
      print('Error mapping customer row: $e');
      print('Row data: ${row.toColumnMap()}');
      rethrow;
    }
  }
}
