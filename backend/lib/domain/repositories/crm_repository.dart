import '../entities/crm_lead.dart';

abstract class CrmLeadRepository {
  Future<CrmLead> create(CrmLead lead);
  Future<CrmLead?> findById(int id);
  Future<List<CrmLead>> findAll();
  Future<List<CrmLead>> findByCustomerId(String customerId);
  Future<List<CrmLead>> findByAssignedTo(String assignedTo);
  Future<CrmLead> update(CrmLead lead);
  Future<void> delete(int id);
}
