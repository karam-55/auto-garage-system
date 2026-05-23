import '../entities/account.dart';

abstract class AccountRepository {
  Future<Account> create(Account account);
  Future<Account?> findById(int id);
  Future<List<Account>> findByIds(List<int> ids);
  Future<Account?> findByCode(String code);
  Future<List<Account>> findAll();
  Future<List<Account>> findByType(String accountType);
  Future<List<Account>> findChildren(int parentId);
  Future<Account> update(Account account);
  Future<void> delete(int id);
}
