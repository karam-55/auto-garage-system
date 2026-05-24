import 'package:postgres/postgres.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../database/database_connection.dart';

class AccountRepositoryImpl implements AccountRepository {
  final DatabaseConnection _db;

  AccountRepositoryImpl(this._db);

  @override
  Future<Account> create(Account account) async {
    final result = await _db.execute(
      Sql.named('''INSERT INTO accounts (code, name_ar, name_en, parent_id, account_type, is_active)
         VALUES (@code, @nameAr, @nameEn, @parentId, @accountType, @isActive)
         RETURNING id, created_at'''),
      parameters: {
        'code': account.code,
        'nameAr': account.nameAr,
        'nameEn': account.nameEn,
        'parentId': account.parentId,
        'accountType': account.accountType.value,
        'isActive': account.isActive,
      },
    );
    final row = result.first;
    return account.copyWith(
      id: row['id'] as int,
      createdAt: row['created_at'] as DateTime,
    );
  }

  @override
  Future<Account?> findById(int id) async {
    final result = await _db.execute(
      Sql.named('SELECT id, code, name_ar, name_en, parent_id, account_type, is_active, created_at FROM accounts WHERE id = @id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRowToAccount(result.first);
  }

  @override
  Future<List<Account>> findByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final result = await _db.execute(
      Sql.named('SELECT id, code, name_ar, name_en, parent_id, account_type, is_active, created_at FROM accounts WHERE id = ANY(@ids)'),
      parameters: {'ids': ids},
    );
    return result.map(_mapRowToAccount).toList();
  }

  @override
  Future<Account?> findByCode(String code) async {
    final result = await _db.execute(
      Sql.named('SELECT id, code, name_ar, name_en, parent_id, account_type, is_active, created_at FROM accounts WHERE code = @code'),
      parameters: {'code': code},
    );
    if (result.isEmpty) return null;
    return _mapRowToAccount(result.first);
  }

  @override
  Future<List<Account>> findAll() async {
    final result = await _db.execute(
      Sql.named('SELECT id, code, name_ar, name_en, parent_id, account_type, is_active, created_at FROM accounts ORDER BY code'),
    );
    return result.map(_mapRowToAccount).toList();
  }

  @override
  Future<List<Account>> findByType(String accountType) async {
    final result = await _db.execute(
      Sql.named('SELECT id, code, name_ar, name_en, parent_id, account_type, is_active, created_at FROM accounts WHERE account_type = @accountType ORDER BY code'),
      parameters: {'accountType': accountType},
    );
    return result.map(_mapRowToAccount).toList();
  }

  @override
  Future<List<Account>> findChildren(int parentId) async {
    final result = await _db.execute(
      Sql.named('SELECT id, code, name_ar, name_en, parent_id, account_type, is_active, created_at FROM accounts WHERE parent_id = @parentId ORDER BY code'),
      parameters: {'parentId': parentId},
    );
    return result.map(_mapRowToAccount).toList();
  }

  @override
  Future<Account> update(Account account) async {
    await _db.execute(
      Sql.named('''UPDATE accounts SET
         code = @code,
         name_ar = @nameAr,
         name_en = @nameEn,
         parent_id = @parentId,
         account_type = @accountType,
         is_active = @isActive
         WHERE id = @id'''),
      parameters: {
        'id': account.id,
        'code': account.code,
        'nameAr': account.nameAr,
        'nameEn': account.nameEn,
        'parentId': account.parentId,
        'accountType': account.accountType.value,
        'isActive': account.isActive,
      },
    );
    return account;
  }

  @override
  Future<void> delete(int id) async {
    await _db.execute(
      Sql.named('DELETE FROM accounts WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  Account _mapRowToAccount(ResultRow row) {
    return Account(
      id: row['id'] as int,
      code: row['code'] as String,
      nameAr: row['name_ar'] as String,
      nameEn: row['name_en'] as String,
      parentId: row['parent_id'] as int?,
      accountType: AccountType.fromString(row['account_type'] as String),
      isActive: row['is_active'] as bool,
      createdAt: row['created_at'] as DateTime,
    );
  }
}
