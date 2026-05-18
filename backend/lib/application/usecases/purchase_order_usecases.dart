import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_order_repository.dart';

class CreatePurchaseOrderUseCase {
  final PurchaseOrderRepository _repository;

  CreatePurchaseOrderUseCase(this._repository);

  Future<PurchaseOrder> execute(PurchaseOrder order) async {
    return await _repository.create(order);
  }
}

class GetPurchaseOrderUseCase {
  final PurchaseOrderRepository _repository;

  GetPurchaseOrderUseCase(this._repository);

  Future<PurchaseOrder?> execute(int id) async {
    return await _repository.findById(id);
  }

  Future<List<PurchaseOrder>> executeAll() async {
    return await _repository.findAll();
  }

  Future<List<PurchaseOrder>> executeByVendorId(int vendorId) async {
    return await _repository.findByVendorId(vendorId);
  }
}

class UpdatePurchaseOrderUseCase {
  final PurchaseOrderRepository _repository;

  UpdatePurchaseOrderUseCase(this._repository);

  Future<PurchaseOrder> execute(PurchaseOrder order) async {
    return await _repository.update(order);
  }
}

class DeletePurchaseOrderUseCase {
  final PurchaseOrderRepository _repository;

  DeletePurchaseOrderUseCase(this._repository);

  Future<void> execute(int id) async {
    await _repository.delete(id);
  }
}
