import '../../domain/entities/bill_of_materials.dart';
import '../../domain/repositories/bill_of_materials_repository.dart';
import '../../application/usecases/manufacturing_usecases.dart';

class ManufacturingService {
  final BillOfMaterialsRepository _bomRepository;
  late final CreateBillOfMaterialsUseCase _createBomUseCase;
  late final GetBillOfMaterialsUseCase _getBomUseCase;
  late final UpdateBillOfMaterialsUseCase _updateBomUseCase;
  late final DeleteBillOfMaterialsUseCase _deleteBomUseCase;

  ManufacturingService(this._bomRepository, dynamic orderRepository) {
    _createBomUseCase = CreateBillOfMaterialsUseCase(_bomRepository);
    _getBomUseCase = GetBillOfMaterialsUseCase(_bomRepository);
    _updateBomUseCase = UpdateBillOfMaterialsUseCase(_bomRepository);
    _deleteBomUseCase = DeleteBillOfMaterialsUseCase(_bomRepository);
  }

  Future<BillOfMaterials> createBom(BillOfMaterials bom) async {
    return await _createBomUseCase.execute(bom);
  }

  Future<BillOfMaterials?> getBom(int id) async {
    return await _getBomUseCase.execute(id);
  }

  Future<List<BillOfMaterials>> getAllBoms() async {
    return await _getBomUseCase.executeAll();
  }

  Future<List<BillOfMaterials>> getBomsByServiceId(String serviceId) async {
    return await _getBomUseCase.executeByServiceId(serviceId);
  }

  Future<BillOfMaterials> updateBom(BillOfMaterials bom) async {
    return await _updateBomUseCase.execute(bom);
  }

  Future<void> deleteBom(int id) async {
    await _deleteBomUseCase.execute(id);
  }
}
