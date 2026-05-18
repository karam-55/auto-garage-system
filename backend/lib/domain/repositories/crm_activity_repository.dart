import '../entities/crm_activity.dart';

abstract class CrmActivityRepository {
  Future<CrmActivity> create(CrmActivity activity);
  Future<CrmActivity?> findById(int id);
  Future<List<CrmActivity>> findByLeadId(int leadId);
  Future<List<CrmActivity>> findByCustomerId(String customerId);
  Future<List<CrmActivity>> findAll();
  Future<CrmActivity> update(CrmActivity activity);
  Future<void> delete(int id);
}
