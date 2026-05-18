import '../../domain/entities/bill_of_materials.dart';
import '../../domain/repositories/bill_of_materials_repository.dart';
import '../../application/usecases/manufacturing_usecases.dart';

class ManufacturingService {
  final BillOfMaterialsRepository _bomRepository;
  final ManufacturingOrderRepository _orderRepository;
  late final CreateBillOfMaterialsUseCase _createBomUseCase;
  late final GetBillOfMaterialsUseCase _getBomUseCase;
  late final UpdateBillOfMaterialsUseCase _updateBomUseCase;
  late final DeleteBillOfMaterialsUseCase _deleteBomUseCase;
  late final CreateManufacturingOrderUseCase _createOrderUseCase;
  late final GetManufacturingOrderUseCase _getOrderUseCase;
  late final UpdateManufacturingOrderUseCase _updateOrderUseCase;
  late final CompleteManufacturingOrderUseCase _completeOrderUseCase;
  late final DeleteManufacturingOrderUseCase _deleteOrderUseCase;

  ManufacturingService(this._bomRepository, this._orderRepository) {
    _createBomUseCase = CreateBillOfMaterialsUseCase(_bomRepository);
    _getBomUseCase = GetBillOfMaterialsUseCase(_bomRepository);
    _updateBomUseCase = UpdateBillOfMaterialsUseCase(_bomRepository);
    _deleteBomUseCase = DeleteBillOfMaterialsUseCase(_bomRepository);
    _createOrderUseCase = CreateManufacturingOrderUseCase(_orderRepository);
    _getOrderUseCase = GetManufacturingOrderUseCase(_orderRepository);
    _updateOrderUseCase = UpdateManufacturingOrderUseCase(_orderRepository);
    _completeOrderUseCase = CompleteManufacturingOrderUseCase(_orderRepository);
    _deleteOrderUseCase = DeleteManufacturingOrderUseCase(_orderRepository);
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

  Future<ManufacturingOrder> createManufacturingOrder(ManufacturingOrder order) async {
    return await _createOrderUseCase.execute(order);
  }

  Future<ManufacturingOrder?> getManufacturingOrder(int id) async {
    return await _getOrderUseCase.execute(id);
  }

  Future<List<ManufacturingOrder>> getAllManufacturingOrders() async {
    return await _getOrderUseCase.executeAll();
  }

  Future<List<ManufacturingOrder>> getManufacturingOrdersByStatus(String status) async {
    return await _getOrderUseCase.executeByStatus(status);
  }

  Future<ManufacturingOrder> updateManufacturingOrder(ManufacturingOrder order) async {
    return await _updateOrderUseCase.execute(order);
  }

  Future<ManufacturingOrder> completeManufacturingOrder(int orderId) async {
    return await _completeOrderUseCase.execute(orderId);
  }

  Future<void> deleteManufacturingOrder(int id) async {
    await _deleteOrderUseCase.execute(id);
  }
}
