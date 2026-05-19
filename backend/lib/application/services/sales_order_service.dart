// Temporary stub service for Sales Orders
// TODO: Implement full service with proper domain layer

class SalesOrder {
  final int id;
  final String orderNumber;
  final String customerId;
  final DateTime orderDate;
  final double totalAmount;
  final String status;

  SalesOrder({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'order_date': orderDate.toIso8601String(),
      'total_amount': totalAmount,
      'status': status,
    };
  }
}

class SalesOrderService {
  final dynamic _repository;

  SalesOrderService(this._repository) {
    // TODO: Initialize use cases
  }

  Future<List<SalesOrder>> getAllSalesOrders() async {
    return [];
  }

  Future<SalesOrder?> getSalesOrder(int id) async {
    return null;
  }

  Future<SalesOrder> createSalesOrder(SalesOrder order) async {
    return order;
  }

  Future<SalesOrder> updateSalesOrder(SalesOrder order) async {
    return order;
  }

  Future<void> deleteSalesOrder(int id) async {
    // TODO: Implement deletion
  }
}
