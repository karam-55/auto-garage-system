import '../entities/service.dart';
import '../../core/errors/failures.dart';

abstract class ServiceRepository {
  Future<Service> create(Service service);
  Future<Service?> findById(String id);
  Future<List<Service>> findAll({bool activeOnly = true});
  Future<Service> update(Service service);
  Future<void> delete(String id);
}
