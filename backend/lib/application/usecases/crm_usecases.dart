import '../../domain/entities/crm_lead.dart';
import '../../domain/entities/crm_activity.dart';
import '../../domain/repositories/crm_repository.dart';

class CreateCrmLeadUseCase {
  final CrmLeadRepository _repository;

  CreateCrmLeadUseCase(this._repository);

  Future<CrmLead> execute(CrmLead lead) async {
    return await _repository.create(lead);
  }
}

class GetCrmLeadUseCase {
  final CrmLeadRepository _repository;

  GetCrmLeadUseCase(this._repository);

  Future<CrmLead?> execute(int id) async {
    return await _repository.findById(id);
  }

  Future<List<CrmLead>> executeAll() async {
    return await _repository.findAll();
  }

  Future<List<CrmLead>> executeByCustomerId(String customerId) async {
    return await _repository.findByCustomerId(customerId);
  }

  Future<List<CrmLead>> executeByAssignedTo(String assignedTo) async {
    return await _repository.findByAssignedTo(assignedTo);
  }
}

class UpdateCrmLeadUseCase {
  final CrmLeadRepository _repository;

  UpdateCrmLeadUseCase(this._repository);

  Future<CrmLead> execute(CrmLead lead) async {
    return await _repository.update(lead);
  }
}

class ConvertLeadToCustomerUseCase {
  final CrmLeadRepository _repository;

  ConvertLeadToCustomerUseCase(this._repository);

  Future<CrmLead> execute(int leadId) async {
    final lead = await _repository.findById(leadId);
    if (lead == null) {
      throw Exception('Lead not found');
    }
    return await _repository.update(lead.copyWith(
      status: 'converted',
      updatedAt: DateTime.now(),
    ));
  }
}

class DeleteCrmLeadUseCase {
  final CrmLeadRepository _repository;

  DeleteCrmLeadUseCase(this._repository);

  Future<void> execute(int id) async {
    await _repository.delete(id);
  }
}

class CreateCrmActivityUseCase {
  final CrmActivityRepository _repository;

  CreateCrmActivityUseCase(this._repository);

  Future<CrmActivity> execute(CrmActivity activity) async {
    return await _repository.create(activity);
  }
}

class GetCrmActivityUseCase {
  final CrmActivityRepository _repository;

  GetCrmActivityUseCase(this._repository);

  Future<CrmActivity?> execute(int id) async {
    return await _repository.findById(id);
  }

  Future<List<CrmActivity>> executeByLeadId(int leadId) async {
    return await _repository.findByLeadId(leadId);
  }

  Future<List<CrmActivity>> executeByCustomerId(String customerId) async {
    return await _repository.findByCustomerId(customerId);
  }
}

class DeleteCrmActivityUseCase {
  final CrmActivityRepository _repository;

  DeleteCrmActivityUseCase(this._repository);

  Future<void> execute(int id) async {
    await _repository.delete(id);
  }
}
