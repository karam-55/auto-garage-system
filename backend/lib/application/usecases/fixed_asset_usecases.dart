import '../../domain/entities/fixed_asset.dart';
import '../../domain/entities/maintenance_contract.dart';
import '../../domain/repositories/fixed_asset_repository.dart';

class CreateFixedAssetUseCase {
  final FixedAssetRepository _repository;

  CreateFixedAssetUseCase(this._repository);

  Future<FixedAsset> execute(FixedAsset asset) async {
    return await _repository.create(asset);
  }
}

class GetFixedAssetUseCase {
  final FixedAssetRepository _repository;

  GetFixedAssetUseCase(this._repository);

  Future<FixedAsset?> execute(int id) async {
    return await _repository.findById(id);
  }

  Future<List<FixedAsset>> executeAll() async {
    return await _repository.findAll();
  }

  Future<List<FixedAsset>> executeByStatus(String status) async {
    return await _repository.findByStatus(status);
  }
}

class UpdateFixedAssetUseCase {
  final FixedAssetRepository _repository;

  UpdateFixedAssetUseCase(this._repository);

  Future<FixedAsset> execute(FixedAsset asset) async {
    return await _repository.update(asset);
  }
}

class DeleteFixedAssetUseCase {
  final FixedAssetRepository _repository;

  DeleteFixedAssetUseCase(this._repository);

  Future<void> execute(int id) async {
    await _repository.delete(id);
  }
}

class CreateMaintenanceContractUseCase {
  final MaintenanceContractRepository _repository;

  CreateMaintenanceContractUseCase(this._repository);

  Future<MaintenanceContract> execute(MaintenanceContract contract) async {
    return await _repository.create(contract);
  }
}

class GetMaintenanceContractUseCase {
  final MaintenanceContractRepository _repository;

  GetMaintenanceContractUseCase(this._repository);

  Future<MaintenanceContract?> execute(int id) async {
    return await _repository.findById(id);
  }

  Future<List<MaintenanceContract>> executeByCustomerId(String customerId) async {
    return await _repository.findByCustomerId(customerId);
  }

  Future<List<MaintenanceContract>> executeByVehicleId(String vehicleId) async {
    return await _repository.findByVehicleId(vehicleId);
  }

  Future<List<MaintenanceContract>> executeDueContracts() async {
    return await _repository.findDueContracts();
  }
}

class UpdateMaintenanceContractUseCase {
  final MaintenanceContractRepository _repository;

  UpdateMaintenanceContractUseCase(this._repository);

  Future<MaintenanceContract> execute(MaintenanceContract contract) async {
    return await _repository.update(contract);
  }
}

class DeleteMaintenanceContractUseCase {
  final MaintenanceContractRepository _repository;

  DeleteMaintenanceContractUseCase(this._repository);

  Future<void> execute(int id) async {
    await _repository.delete(id);
  }
}
