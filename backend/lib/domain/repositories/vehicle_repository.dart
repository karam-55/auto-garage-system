import '../entities/vehicle.dart';
import '../../core/utils/pagination_result.dart';

abstract class VehicleRepository {
  Future<Vehicle> create(Vehicle vehicle);
  Future<Vehicle?> findById(String id);
  Future<List<Vehicle>> findByCustomerId(String customerId);
  Future<List<Vehicle>> findAll();
  Future<PaginationResult<Vehicle>> findAllPaginated({
    String? search,
    int page = 1,
    int limit = 20,
  });
  Future<Vehicle> update(Vehicle vehicle);
  Future<void> delete(String id);
}
