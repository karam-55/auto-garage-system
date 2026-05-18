import '../entities/fixed_asset.dart';

abstract class FixedAssetRepository {
  Future<FixedAsset> create(FixedAsset asset);
  Future<FixedAsset?> findById(int id);
  Future<List<FixedAsset>> findAll();
  Future<List<FixedAsset>> findByStatus(String status);
  Future<FixedAsset> update(FixedAsset asset);
  Future<void> delete(int id);
}

abstract class MaintenanceContractRepository {
  Future<MaintenanceContract> create(MaintenanceContract contract);
  Future<MaintenanceContract?> findById(int id);
  Future<List<MaintenanceContract>> findByCustomerId(String customerId);
  Future<List<MaintenanceContract>> findByVehicleId(String vehicleId);
  Future<List<MaintenanceContract>> findDueContracts();
  Future<MaintenanceContract> update(MaintenanceContract contract);
  Future<void> delete(int id);
}
