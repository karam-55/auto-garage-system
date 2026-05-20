import '../entities/sales_order.dart';

abstract class SalesOrderRepository {
  Future<SalesOrder> create(SalesOrder order);
  Future<SalesOrder?> findById(int id);
  Future<List<SalesOrder>> findAll();
  Future<List<SalesOrder>> findByCustomer(String customerId);
  Future<SalesOrder> update(SalesOrder order);
  Future<void> delete(int id);
}
