import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_order_repository.dart';
import '../../application/usecases/purchase_order_usecases.dart';

class PurchaseOrderService {
  final PurchaseOrderRepository _repository;
  late final CreatePurchaseOrderUseCase _createUseCase;
  late final GetPurchaseOrderUseCase _getUseCase;
  late final UpdatePurchaseOrderUseCase _updateUseCase;
  late final DeletePurchaseOrderUseCase _deleteUseCase;

  PurchaseOrderService(this._repository) {
    _createUseCase = CreatePurchaseOrderUseCase(_repository);
    _getUseCase = GetPurchaseOrderUseCase(_repository);
    _updateUseCase = UpdatePurchaseOrderUseCase(_repository);
    _deleteUseCase = DeletePurchaseOrderUseCase(_repository);
  }

  Future<PurchaseOrder> createOrder(PurchaseOrder order) async {
    return await _createUseCase.execute(order);
  }

  Future<PurchaseOrder?> getOrder(int id) async {
    return await _getUseCase.execute(id);
  }

  Future<List<PurchaseOrder>> getAllOrders() async {
    return await _getUseCase.executeAll();
  }

  Future<List<PurchaseOrder>> getOrdersByVendor(int vendorId) async {
    return await _getUseCase.executeByVendorId(vendorId);
  }

  Future<PurchaseOrder> updateOrder(PurchaseOrder order) async {
    return await _updateUseCase.execute(order);
  }

  Future<void> deleteOrder(int id) async {
    await _deleteUseCase.execute(id);
  }

  Future<String> generateOrderNumber() async {
    final orders = await getAllOrders();
    final lastOrder = orders.isNotEmpty ? orders.first : null;
    final lastNumber = lastOrder?.orderNumber ?? 'PO-0000';
    final numberPart = int.tryParse(lastNumber.split('-')[1]) ?? 0;
    return 'PO-${(numberPart + 1).toString().padLeft(4, '0')}';
  }
}
