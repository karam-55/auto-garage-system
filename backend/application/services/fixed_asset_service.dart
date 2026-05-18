import '../../domain/entities/fixed_asset.dart';
import '../../domain/repositories/fixed_asset_repository.dart';
import '../../application/usecases/fixed_asset_usecases.dart';

class FixedAssetService {
  final FixedAssetRepository _assetRepository;
  final MaintenanceContractRepository _contractRepository;
  late final CreateFixedAssetUseCase _createAssetUseCase;
  late final GetFixedAssetUseCase _getAssetUseCase;
  late final UpdateFixedAssetUseCase _updateAssetUseCase;
  late final DeleteFixedAssetUseCase _deleteAssetUseCase;
  late final CreateMaintenanceContractUseCase _createContractUseCase;
  late final GetMaintenanceContractUseCase _getContractUseCase;
  late final UpdateMaintenanceContractUseCase _updateContractUseCase;
  late final DeleteMaintenanceContractUseCase _deleteContractUseCase;

  FixedAssetService(this._assetRepository, this._contractRepository) {
    _createAssetUseCase = CreateFixedAssetUseCase(_assetRepository);
    _getAssetUseCase = GetFixedAssetUseCase(_assetRepository);
    _updateAssetUseCase = UpdateFixedAssetUseCase(_assetRepository);
    _deleteAssetUseCase = DeleteFixedAssetUseCase(_assetRepository);
    _createContractUseCase = CreateMaintenanceContractUseCase(_contractRepository);
    _getContractUseCase = GetMaintenanceContractUseCase(_contractRepository);
    _updateContractUseCase = UpdateMaintenanceContractUseCase(_contractRepository);
    _deleteContractUseCase = DeleteMaintenanceContractUseCase(_contractRepository);
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

  Future<MaintenanceContract> createMaintenanceContract(MaintenanceContract contract) async {
    return await _createContractUseCase.execute(contract);
  }

  Future<MaintenanceContract?> getMaintenanceContract(int id) async {
    return await _getContractUseCase.execute(id);
  }

  Future<List<MaintenanceContract>> getContractsByCustomer(String customerId) async {
    return await _getContractUseCase.executeByCustomerId(customerId);
  }

  Future<List<MaintenanceContract>> getContractsByVehicle(String vehicleId) async {
    return await _getContractUseCase.executeByVehicleId(vehicleId);
  }

  Future<List<MaintenanceContract>> getDueContracts() async {
    return await _getContractUseCase.executeDueContracts();
  }

  Future<MaintenanceContract> updateMaintenanceContract(MaintenanceContract contract) async {
    return await _updateContractUseCase.execute(contract);
  }

  Future<void> deleteMaintenanceContract(int id) async {
    await _deleteContractUseCase.execute(id);
  }
}
