import '../../domain/entities/crm_lead.dart';
import '../../domain/repositories/crm_repository.dart';
import '../../application/usecases/crm_usecases.dart';

class CrmService {
  final CrmLeadRepository _leadRepository;
  final CrmActivityRepository _activityRepository;
  late final CreateCrmLeadUseCase _createLeadUseCase;
  late final GetCrmLeadUseCase _getLeadUseCase;
  late final UpdateCrmLeadUseCase _updateLeadUseCase;
  late final ConvertLeadToCustomerUseCase _convertLeadUseCase;
  late final DeleteCrmLeadUseCase _deleteLeadUseCase;
  late final CreateCrmActivityUseCase _createActivityUseCase;
  late final GetCrmActivityUseCase _getActivityUseCase;
  late final DeleteCrmActivityUseCase _deleteActivityUseCase;

  CrmService(this._leadRepository, this._activityRepository) {
    _createLeadUseCase = CreateCrmLeadUseCase(_leadRepository);
    _getLeadUseCase = GetCrmLeadUseCase(_leadRepository);
    _updateLeadUseCase = UpdateCrmLeadUseCase(_leadRepository);
    _convertLeadUseCase = ConvertLeadToCustomerUseCase(_leadRepository);
    _deleteLeadUseCase = DeleteCrmLeadUseCase(_leadRepository);
    _createActivityUseCase = CreateCrmActivityUseCase(_activityRepository);
    _getActivityUseCase = GetCrmActivityUseCase(_activityRepository);
    _deleteActivityUseCase = DeleteCrmActivityUseCase(_activityRepository);
  }

  Future<CrmLead> createLead(CrmLead lead) async {
    return await _createLeadUseCase.execute(lead);
  }

  Future<CrmLead?> getLead(int id) async {
    return await _getLeadUseCase.execute(id);
  }

  Future<List<CrmLead>> getAllLeads() async {
    return await _getLeadUseCase.executeAll();
  }

  Future<List<CrmLead>> getLeadsByCustomer(String customerId) async {
    return await _getLeadUseCase.executeByCustomerId(customerId);
  }

  Future<List<CrmLead>> getLeadsByAssignedTo(String assignedTo) async {
    return await _getLeadUseCase.executeByAssignedTo(assignedTo);
  }

  Future<CrmLead> updateLead(CrmLead lead) async {
    return await _updateLeadUseCase.execute(lead);
  }

  Future<CrmLead> convertLeadToCustomer(int leadId) async {
    return await _convertLeadUseCase.execute(leadId);
  }

  Future<void> deleteLead(int id) async {
    await _deleteLeadUseCase.execute(id);
  }

  Future<CrmActivity> createActivity(CrmActivity activity) async {
    return await _createActivityUseCase.execute(activity);
  }

  Future<CrmActivity?> getActivity(int id) async {
    return await _getActivityUseCase.execute(id);
  }

  Future<List<CrmActivity>> getActivitiesByLeadId(int leadId) async {
    return await _getActivityUseCase.executeByLeadId(leadId);
  }

  Future<List<CrmActivity>> getActivitiesByCustomerId(String customerId) async {
    return await _getActivityUseCase.executeByCustomerId(customerId);
  }

  Future<void> deleteActivity(int id) async {
    await _deleteActivityUseCase.execute(id);
  }
}
