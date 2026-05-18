import '../../domain/entities/quotation.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../application/usecases/quotation_usecases.dart';

class QuotationService {
  final QuotationRepository _repository;
  late final CreateQuotationUseCase _createUseCase;
  late final GetQuotationUseCase _getUseCase;
  late final UpdateQuotationUseCase _updateUseCase;
  late final DeleteQuotationUseCase _deleteUseCase;

  QuotationService(this._repository) {
    _createUseCase = CreateQuotationUseCase(_repository);
    _getUseCase = GetQuotationUseCase(_repository);
    _updateUseCase = UpdateQuotationUseCase(_repository);
    _deleteUseCase = DeleteQuotationUseCase(_repository);
  }

  Future<Quotation> createQuotation(Quotation quotation) async {
    return await _createUseCase.execute(quotation);
  }

  Future<Quotation?> getQuotation(int id) async {
    return await _getUseCase.execute(id);
  }

  Future<List<Quotation>> getAllQuotations() async {
    return await _getUseCase.executeAll();
  }

  Future<List<Quotation>> getQuotationsByCustomer(String customerId) async {
    return await _getUseCase.executeByCustomerId(customerId);
  }

  Future<Quotation> updateQuotation(Quotation quotation) async {
    return await _updateUseCase.execute(quotation);
  }

  Future<void> deleteQuotation(int id) async {
    await _deleteUseCase.execute(id);
  }

  Future<String> generateQuotationNumber() async {
    final quotations = await getAllQuotations();
    final lastQuotation = quotations.isNotEmpty ? quotations.first : null;
    final lastNumber = lastQuotation?.quotationNumber ?? 'QT-0000';
    final numberPart = int.tryParse(lastNumber.split('-')[1]) ?? 0;
    return 'QT-${(numberPart + 1).toString().padLeft(4, '0')}';
  }
}
