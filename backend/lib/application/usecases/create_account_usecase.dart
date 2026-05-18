import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

class CreateAccountUseCase {
  final AccountRepository _repository;

  CreateAccountUseCase(this._repository);

  Future<Account> execute({
    required String code,
    required String nameAr,
    required String nameEn,
    int? parentId,
    required String accountType,
    bool isActive = true,
  }) async {
    final account = Account(
      id: 0, // Will be set by repository
      code: code,
      nameAr: nameAr,
      nameEn: nameEn,
      parentId: parentId,
      accountType: AccountType.fromString(accountType),
      isActive: isActive,
      createdAt: DateTime.now().toUtc(),
    );
    return await _repository.create(account);
  }
}
