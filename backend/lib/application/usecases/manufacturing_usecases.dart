import '../../domain/entities/bill_of_materials.dart';
import '../../domain/repositories/bill_of_materials_repository.dart';

class CreateBillOfMaterialsUseCase {
  final BillOfMaterialsRepository _repository;

  CreateBillOfMaterialsUseCase(this._repository);

  Future<BillOfMaterials> execute(BillOfMaterials bom) async {
    return await _repository.create(bom);
  }
}

class GetBillOfMaterialsUseCase {
  final BillOfMaterialsRepository _repository;

  GetBillOfMaterialsUseCase(this._repository);

  Future<BillOfMaterials?> execute(int id) async {
    return await _repository.findById(id);
  }

  Future<List<BillOfMaterials>> executeAll() async {
    return await _repository.findAll();
  }

  Future<List<BillOfMaterials>> executeByServiceId(String serviceId) async {
    return await _repository.findByServiceId(serviceId);
  }
}

class UpdateBillOfMaterialsUseCase {
  final BillOfMaterialsRepository _repository;

  UpdateBillOfMaterialsUseCase(this._repository);

  Future<BillOfMaterials> execute(BillOfMaterials bom) async {
    return await _repository.update(bom);
  }
}

class DeleteBillOfMaterialsUseCase {
  final BillOfMaterialsRepository _repository;

  DeleteBillOfMaterialsUseCase(this._repository);

  Future<void> execute(int id) async {
    await _repository.delete(id);
  }
}
