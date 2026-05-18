import '../entities/vendor.dart';

abstract class VendorRepository {
  Future<Vendor> create(Vendor vendor);
  Future<Vendor?> findById(int id);
  Future<List<Vendor>> findAll();
  Future<Vendor> update(Vendor vendor);
  Future<void> delete(int id);
}
