import '../../domain/entities/quotation.dart';
import '../../domain/repositories/quotation_repository.dart';

class QuotationService {
  final QuotationRepository _repository;

  QuotationService(this._repository);

  Future<Quotation> createQuotation(Quotation quotation) async {
    return await _repository.create(quotation);
  }

  Future<Quotation?> getQuotation(int id) async {
    return await _repository.findById(id);
  }

  Future<List<Quotation>> getAllQuotations() async {
    return await _repository.findAll();
  }

  Future<List<Quotation>> getQuotationsByCustomer(String customerId) async {
    return await _repository.findByCustomerId(customerId);
  }

  Future<Quotation> updateQuotation(Quotation quotation) async {
    return await _repository.update(quotation);
  }

  Future<void> deleteQuotation(int id) async {
    await _repository.delete(id);
  }

  Future<String> generateQuotationNumber() async {
    final quotations = await getAllQuotations();
    final lastQuotation = quotations.isNotEmpty ? quotations.first : null;
    final lastNumber = lastQuotation?.quotationNumber ?? 'QT-0000';
    final numberPart = int.tryParse(lastNumber.split('-')[1]) ?? 0;
    return 'QT-${(numberPart + 1).toString().padLeft(4, '0')}';
  }
}
