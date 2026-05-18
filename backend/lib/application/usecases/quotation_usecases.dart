import '../../domain/entities/quotation.dart';
import '../../domain/repositories/quotation_repository.dart';

class CreateQuotationUseCase {
  final QuotationRepository _repository;

  CreateQuotationUseCase(this._repository);

  Future<Quotation> execute(Quotation quotation) async {
    return await _repository.create(quotation);
  }
}

class GetQuotationUseCase {
  final QuotationRepository _repository;

  GetQuotationUseCase(this._repository);

  Future<Quotation?> execute(int id) async {
    return await _repository.findById(id);
  }

  Future<List<Quotation>> executeAll() async {
    return await _repository.findAll();
  }

  Future<List<Quotation>> executeByCustomerId(String customerId) async {
    return await _repository.findByCustomerId(customerId);
  }
}

class UpdateQuotationUseCase {
  final QuotationRepository _repository;

  UpdateQuotationUseCase(this._repository);

  Future<Quotation> execute(Quotation quotation) async {
    return await _repository.update(quotation);
  }
}

class DeleteQuotationUseCase {
  final QuotationRepository _repository;

  DeleteQuotationUseCase(this._repository);

  Future<void> execute(int id) async {
    await _repository.delete(id);
  }
}
