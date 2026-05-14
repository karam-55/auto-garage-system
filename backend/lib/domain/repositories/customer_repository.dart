import '../entities/customer.dart';
import '../../core/utils/pagination_result.dart';

abstract class CustomerRepository {
  Future<Customer> create(Customer customer);
  Future<Customer?> findById(String id);
  Future<Customer?> findByPhone(String phone);
  Future<List<Customer>> findAll();
  Future<List<Customer>> search(String query);
  Future<PaginationResult<Customer>> findAllPaginated({
    String? search,
    int page = 1,
    int limit = 20,
  });
  Future<Customer> update(Customer customer);
  Future<void> delete(String id);
}
