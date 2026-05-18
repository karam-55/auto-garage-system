import '../../domain/entities/fixed_asset.dart';
import '../../domain/entities/maintenance_contract.dart' as contract;
import '../../domain/repositories/fixed_asset_repository.dart';
import '../../domain/repositories/maintenance_contract_repository.dart';
import '../../application/usecases/fixed_asset_usecases.dart' as fa;

class FixedAssetService {
  final FixedAssetRepository _assetRepository;
  final MaintenanceContractRepository _contractRepository;
  late final fa.CreateFixedAssetUseCase _createAssetUseCase;
  late final fa.GetFixedAssetUseCase _getAssetUseCase;
  late final fa.UpdateFixedAssetUseCase _updateAssetUseCase;
  late final fa.DeleteFixedAssetUseCase _deleteAssetUseCase;
  late final fa.CreateMaintenanceContractUseCase _createContractUseCase;
  late final fa.GetMaintenanceContractUseCase _getContractUseCase;
  late final fa.UpdateMaintenanceContractUseCase _updateContractUseCase;
  late final fa.DeleteMaintenanceContractUseCase _deleteContractUseCase;

  FixedAssetService(this._assetRepository, this._contractRepository) {
    _createAssetUseCase = fa.CreateFixedAssetUseCase(_assetRepository);
    _getAssetUseCase = fa.GetFixedAssetUseCase(_assetRepository);
    _updateAssetUseCase = fa.UpdateFixedAssetUseCase(_assetRepository);
    _deleteAssetUseCase = fa.DeleteFixedAssetUseCase(_assetRepository);
    _createContractUseCase = fa.CreateMaintenanceContractUseCase(_contractRepository);
    _getContractUseCase = fa.GetMaintenanceContractUseCase(_contractRepository);
    _updateContractUseCase = fa.UpdateMaintenanceContractUseCase(_contractRepository);
    _deleteContractUseCase = fa.DeleteMaintenanceContractUseCase(_contractRepository);
  }

  Future<FixedAsset> createFixedAsset(FixedAsset asset) async {
    return await _createAssetUseCase.execute(asset);
  }

  Future<FixedAsset?> getFixedAsset(int id) async {
    return await _getAssetUseCase.execute(id);
  }

  Future<List<FixedAsset>> getAllFixedAssets() async {
    return await _getAssetUseCase.executeAll();
  }

  Future<List<FixedAsset>> getFixedAssetsByStatus(String status) async {
    return await _getAssetUseCase.executeByStatus(status);
  }

  Future<FixedAsset> updateFixedAsset(FixedAsset asset) async {
    return await _updateAssetUseCase.execute(asset);
  }

  Future<void> deleteFixedAsset(int id) async {
    await _deleteAssetUseCase.execute(id);
  }

  Future<contract.MaintenanceContract> createMaintenanceContract(contract.MaintenanceContract contract) async {
    return await _createContractUseCase.execute(contract);
  }

  Future<contract.MaintenanceContract?> getMaintenanceContract(int id) async {
    return await _getContractUseCase.execute(id);
  }

  Future<List<contract.MaintenanceContract>> getMaintenanceContractsByCustomerId(String customerId) async {
    return await _getContractUseCase.executeByCustomerId(customerId);
  }

  Future<List<contract.MaintenanceContract>> getMaintenanceContractsByVehicleId(String vehicleId) async {
    return await _getContractUseCase.executeByVehicleId(vehicleId);
  }

  Future<List<contract.MaintenanceContract>> getDueContracts() async {
    return await _getContractUseCase.executeDueContracts();
  }

  Future<List<contract.MaintenanceContract>> getContractsByCustomer(String customerId) async {
    return await _getContractUseCase.executeByCustomerId(customerId);
  }

  Future<List<contract.MaintenanceContract>> getContractsByVehicle(String vehicleId) async {
    return await _getContractUseCase.executeByVehicleId(vehicleId);
  }

  Future<contract.MaintenanceContract> updateMaintenanceContract(contract.MaintenanceContract contract) async {
    return await _updateContractUseCase.execute(contract);
  }

  Future<void> deleteMaintenanceContract(int id) async {
    await _deleteContractUseCase.execute(id);
  }
}
