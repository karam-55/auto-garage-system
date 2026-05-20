import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/crm_lead.dart';
import '../../domain/entities/crm_activity.dart';
import '../../domain/repositories/crm_repository.dart';
import '../../domain/repositories/crm_activity_repository.dart';
import '../../application/usecases/crm_usecases.dart';
import '../middlewares/json_middleware.dart';
import '../middlewares/auth_middleware.dart';

class CrmRoutes {
  final CrmLeadRepository _leadRepository;
  final CrmActivityRepository _activityRepository;
  final AuthMiddleware _authMiddleware;

  CrmRoutes(
    this._leadRepository,
    this._activityRepository,
    this._authMiddleware,
  );

  Router get router {
    final router = Router();

    // CRM Leads
    router.get('/api/crm/leads', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.MANAGER_SALES, Role.MANAGER, Role.OWNER])(_getAllLeads)));
    router.get('/api/crm/leads/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.MANAGER_SALES, Role.MANAGER, Role.OWNER])(_getLeadById)));
    router.post('/api/crm/leads', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.MANAGER_SALES, Role.MANAGER, Role.OWNER])(_createLead)));
    router.put('/api/crm/leads/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.MANAGER_SALES, Role.MANAGER, Role.OWNER])(_updateLead)));
    router.put('/api/crm/leads/<id>/convert', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.MANAGER_SALES, Role.MANAGER, Role.OWNER])(_convertLead)));
    router.delete('/api/crm/leads/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.OWNER)(_deleteLead)));

    // CRM Activities
    router.get('/api/crm/activities', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.MANAGER_SALES, Role.MANAGER, Role.OWNER])(_getAllActivities)));
    router.get('/api/crm/activities/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.MANAGER_SALES, Role.MANAGER, Role.OWNER])(_getActivityById)));
    router.post('/api/crm/activities', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.MANAGER_SALES, Role.MANAGER, Role.OWNER])(_createActivity)));
    router.put('/api/crm/activities/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.MANAGER_SALES, Role.MANAGER, Role.OWNER])(_updateActivity)));
    router.delete('/api/crm/activities/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.OWNER)(_deleteActivity)));

    return router;
  }

  // CRM Leads handlers
  Future<Response> _getAllLeads(Request request) async {
    try {
      final useCase = GetCrmLeadUseCase(_leadRepository);
      final leads = await useCase.executeAll();
      return Response.ok(jsonEncode(leads.map((l) => l.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get leads: $e'}));
    }
  }

  Future<Response> _getLeadById(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid lead ID'}));
    }
    try {
      final useCase = GetCrmLeadUseCase(_leadRepository);
      final lead = await useCase.execute(id);
      if (lead == null) {
        return Response.notFound(jsonEncode({'error': 'Lead not found'}));
      }
      return Response.ok(jsonEncode(lead.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get lead: $e'}));
    }
  }

  Future<Response> _createLead(Request request) async {
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }
    try {
      final lead = CrmLead(
        id: body['id'] ?? DateTime.now().millisecondsSinceEpoch,
        name: body['name'],
        phone: body['phone'],
        company: body['company'],
        status: body['status'] ?? 'new',
        assignedTo: body['assignedTo'],
        estimatedValue: (body['estimatedValue'] as num?)?.toDouble(),
        source: body['source'],
        customerId: body['customerId'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final useCase = CreateCrmLeadUseCase(_leadRepository);
      final createdLead = await useCase.execute(lead);
      return Response.ok(jsonEncode(createdLead.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create lead: $e'}));
    }
  }

  Future<Response> _updateLead(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid lead ID'}));
    }
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }
    try {
      final lead = CrmLead(
        id: id,
        name: body['name'],
        phone: body['phone'],
        company: body['company'],
        status: body['status'] ?? 'new',
        assignedTo: body['assignedTo'],
        estimatedValue: (body['estimatedValue'] as num?)?.toDouble(),
        source: body['source'],
        customerId: body['customerId'],
        createdAt: DateTime.parse(body['createdAt']),
        updatedAt: DateTime.now(),
      );
      
      final useCase = UpdateCrmLeadUseCase(_leadRepository);
      final updatedLead = await useCase.execute(lead);
      return Response.ok(jsonEncode(updatedLead.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update lead: $e'}));
    }
  }

  Future<Response> _convertLead(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid lead ID'}));
    }
    try {
      final useCase = ConvertLeadToCustomerUseCase(_leadRepository);
      final convertedLead = await useCase.execute(id);
      return Response.ok(jsonEncode(convertedLead.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to convert lead: $e'}));
    }
  }

  Future<Response> _deleteLead(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid lead ID'}));
    }
    try {
      final useCase = DeleteCrmLeadUseCase(_leadRepository);
      await useCase.execute(id);
      return Response.ok(jsonEncode({'message': 'Lead deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete lead: $e'}));
    }
  }

  // CRM Activities handlers
  Future<Response> _getAllActivities(Request request) async {
    try {
      final useCase = GetCrmActivityUseCase(_activityRepository);
      final activities = await useCase.executeByLeadId(0);
      return Response.ok(jsonEncode(activities.map((a) => a.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get activities: $e'}));
    }
  }

  Future<Response> _getActivityById(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid activity ID'}));
    }
    try {
      final useCase = GetCrmActivityUseCase(_activityRepository);
      final activity = await useCase.execute(id);
      if (activity == null) {
        return Response.notFound(jsonEncode({'error': 'Activity not found'}));
      }
      return Response.ok(jsonEncode(activity.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get activity: $e'}));
    }
  }

  Future<Response> _createActivity(Request request) async {
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }
    try {
      final activity = CrmActivity(
        id: body['id'] ?? DateTime.now().millisecondsSinceEpoch,
        leadId: body['leadId'],
        customerId: body['customerId'],
        type: body['type'],
        description: body['description'],
        date: body['date'] != null ? DateTime.parse(body['date']) : DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final useCase = CreateCrmActivityUseCase(_activityRepository);
      final createdActivity = await useCase.execute(activity);
      return Response.ok(jsonEncode(createdActivity.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create activity: $e'}));
    }
  }

  Future<Response> _updateActivity(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid activity ID'}));
    }
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }
    try {
      final activity = CrmActivity(
        id: id,
        leadId: body['leadId'],
        customerId: body['customerId'],
        type: body['type'],
        description: body['description'],
        date: body['date'] != null ? DateTime.parse(body['date']) : DateTime.now(),
        createdAt: DateTime.parse(body['createdAt']),
        updatedAt: DateTime.now(),
      );
      
      final useCase = UpdateCrmActivityUseCase(_activityRepository);
      final updatedActivity = await useCase.execute(activity);
      return Response.ok(jsonEncode(updatedActivity.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update activity: $e'}));
    }
  }

  Future<Response> _deleteActivity(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid activity ID'}));
    }
    try {
      final useCase = DeleteCrmActivityUseCase(_activityRepository);
      await useCase.execute(id);
      return Response.ok(jsonEncode({'message': 'Activity deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete activity: $e'}));
    }
  }
}
