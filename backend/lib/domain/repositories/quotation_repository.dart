import '../entities/quotation.dart';

abstract class QuotationRepository {
  Future<Quotation> create(Quotation quotation);
  Future<Quotation?> findById(int id);
  Future<List<Quotation>> findAll();
  Future<List<Quotation>> findByCustomerId(String customerId);
  Future<Quotation> update(Quotation quotation);
  Future<void> delete(int id);
}
