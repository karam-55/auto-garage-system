import '../entities/service.dart';

abstract class ServiceRepository {
  Future<Service> create(Service service);
  Future<Service?> findById(String id);
  Future<List<Service>> findAll({bool activeOnly = true});
  Future<Service> update(Service service);
  Future<void> delete(String id);
}
