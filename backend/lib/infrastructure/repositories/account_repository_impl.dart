import 'package:postgres/postgres.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../database/database_connection.dart';

class AccountRepositoryImpl implements AccountRepository {
  final DatabaseConnection _db;

  AccountRepositoryImpl(this._db);

  // Helper function to safely convert dynamic to int
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw ArgumentError('Cannot convert $value to int');
  }

  // Helper function to safely convert dynamic to int?
  int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.parse(value);
    return null;
  }

  // Helper function to safely convert dynamic to bool
  bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value == 't' || value == 'true' || value == '1';
    return false;
  }

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
    final data = row.toColumnMap();
    return account.copyWith(
      id: _toInt(data['id']),
      createdAt: data['created_at'] as DateTime,
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
    try {
      final data = row.toColumnMap();
      return Account(
        id: _toInt(data['id']),
        code: data['code'] as String,
        nameAr: data['name_ar'] as String,
        nameEn: data['name_en'] as String,
        parentId: _toIntOrNull(data['parent_id']),
        accountType: AccountType.fromString(data['account_type'] as String),
        isActive: _toBool(data['is_active']),
        createdAt: data['created_at'] as DateTime,
      );
    } catch (e) {
      rethrow;
    }
  }
}
