import '../entities/fiscal_period.dart';

abstract class FiscalPeriodRepository {
  Future<FiscalPeriod> create(FiscalPeriod period);
  Future<FiscalPeriod?> findById(int id);
  Future<List<FiscalPeriod>> findAll();
  Future<FiscalPeriod?> findActive();
  Future<FiscalPeriod> update(FiscalPeriod period);
  Future<void> delete(int id);
}
