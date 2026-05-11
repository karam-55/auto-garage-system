import '../entities/vehicle.dart';
import '../../core/errors/failures.dart';

abstract class VehicleRepository {
  Future<Vehicle> create(Vehicle vehicle);
  Future<Vehicle?> findById(String id);
  Future<List<Vehicle>> findByCustomerId(String customerId);
  Future<List<Vehicle>> findAll();
  Future<Vehicle> update(Vehicle vehicle);
  Future<void> delete(String id);
}
