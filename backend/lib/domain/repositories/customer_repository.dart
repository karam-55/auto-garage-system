import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<Customer> create(Customer customer);
  Future<Customer?> findById(String id);
  Future<Customer?> findByPhone(String phone);
  Future<List<Customer>> findAll();
  Future<Customer> update(Customer customer);
  Future<void> delete(String id);
}
