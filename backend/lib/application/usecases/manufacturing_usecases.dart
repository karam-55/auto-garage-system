import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/manufacturing_order.dart';
import '../../domain/repositories/bill_of_materials_repository.dart';
import '../../domain/repositories/manufacturing_order_repository.dart';

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

class CreateManufacturingOrderUseCase {
  final ManufacturingOrderRepository _repository;

  CreateManufacturingOrderUseCase(this._repository);

  Future<ManufacturingOrder> execute(ManufacturingOrder order) async {
    return await _repository.create(order);
  }
}

class GetManufacturingOrderUseCase {
  final ManufacturingOrderRepository _repository;

  GetManufacturingOrderUseCase(this._repository);

  Future<ManufacturingOrder?> execute(int id) async {
    return await _repository.findById(id);
  }

  Future<List<ManufacturingOrder>> executeAll() async {
    return await _repository.findAll();
  }

  Future<List<ManufacturingOrder>> executeByStatus(String status) async {
    return await _repository.findByStatus(status);
  }
}

class UpdateManufacturingOrderUseCase {
  final ManufacturingOrderRepository _repository;

  UpdateManufacturingOrderUseCase(this._repository);

  Future<ManufacturingOrder> execute(ManufacturingOrder order) async {
    return await _repository.update(order);
  }
}

class CompleteManufacturingOrderUseCase {
  final ManufacturingOrderRepository _repository;

  CompleteManufacturingOrderUseCase(this._repository);

  Future<ManufacturingOrder> execute(int orderId) async {
    final order = await _repository.findById(orderId);
    if (order == null) {
      throw Exception('Manufacturing order not found');
    }
    return await _repository.update(order.copyWith(
      status: 'completed',
      producedQuantity: order.quantityToProduce,
      endDate: DateTime.now(),
    ));
  }
}

class DeleteManufacturingOrderUseCase {
  final ManufacturingOrderRepository _repository;

  DeleteManufacturingOrderUseCase(this._repository);

  Future<void> execute(int id) async {
    await _repository.delete(id);
  }
}
