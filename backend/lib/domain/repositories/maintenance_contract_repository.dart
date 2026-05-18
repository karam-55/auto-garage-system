import '../entities/maintenance_contract.dart';

abstract class MaintenanceContractRepository {
  Future<MaintenanceContract> create(MaintenanceContract contract);
  Future<MaintenanceContract?> findById(int id);
  Future<List<MaintenanceContract>> findByCustomerId(String customerId);
  Future<List<MaintenanceContract>> findByVehicleId(String vehicleId);
  Future<List<MaintenanceContract>> findDueContracts();
  Future<List<MaintenanceContract>> findByAssetId(int assetId);
  Future<List<MaintenanceContract>> findByStatus(String status);
  Future<List<MaintenanceContract>> findAll();
  Future<MaintenanceContract> update(MaintenanceContract contract);
  Future<void> delete(int id);
}
