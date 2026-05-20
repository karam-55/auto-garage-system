import '../../infrastructure/database/database_connection.dart';
import '../../domain/entities/vendor.dart';
import '../../domain/repositories/vendor_repository.dart';

class VendorRepositoryImpl implements VendorRepository {
  final DatabaseConnection _db;

  VendorRepositoryImpl(this._db);

  @override
  Future<Vendor> create(Vendor vendor) async {
    final result = await _db.query(
      '''INSERT INTO vendors (name, phone, address, tax_number)
         VALUES (@name, @phone, @address, @taxNumber)
         RETURNING id, created_at''',
      substitutionValues: {
        'name': vendor.name,
        'phone': vendor.phone,
        'address': vendor.address,
        'taxNumber': vendor.taxNumber,
      },
    );
    final row = result.first;
    return vendor.copyWith(
      id: row[0] as int,
      createdAt: row[1] as DateTime,
    );
  }

  @override
  Future<Vendor?> findById(int id) async {
    final result = await _db.query(
      'SELECT id, name, phone, address, tax_number, created_at FROM vendors WHERE id = @id',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRowToVendor(result.first);
  }

  @override
  Future<List<Vendor>> findAll() async {
    final result = await _db.query(
      'SELECT id, name, phone, address, tax_number, created_at FROM vendors ORDER BY name',
    );
    return result.map(_mapRowToVendor).toList();
  }

  @override
  Future<Vendor> update(Vendor vendor) async {
    await _db.query(
      '''UPDATE vendors SET
         name = @name,
         phone = @phone,
         address = @address,
         tax_number = @taxNumber
         WHERE id = @id''',
      substitutionValues: {
        'id': vendor.id,
        'name': vendor.name,
        'phone': vendor.phone,
        'address': vendor.address,
        'taxNumber': vendor.taxNumber,
      },
    );
    return vendor;
  }

  @override
  Future<void> delete(int id) async {
    await _db.query('DELETE FROM vendors WHERE id = @id', substitutionValues: {'id': id});
  }

  Vendor _mapRowToVendor(dynamic row) {
    return Vendor(
      id: row[0] as int,
      name: row[1] as String,
      phone: row[2] as String?,
      address: row[3] as String?,
      taxNumber: row[4] as String?,
      createdAt: row[5] as DateTime,
    );
  }
}
