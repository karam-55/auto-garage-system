import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/service.dart';

class ServiceProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Service> _services = [];
  Service? _selectedService;
  bool _isLoading = false;
  String? _errorMessage;
  
  ServiceProvider() : _apiService = ApiService();
  
  List<Service> get services => _services;
  Service? get selectedService => _selectedService;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> fetchServices({bool activeOnly = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('${ApiConstants.services}?activeOnly=$activeOnly');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _services = data.map((json) => Service.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load services: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading services: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> createService(Service service) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        ApiConstants.services,
        body: service.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final newService = Service.fromJson(json.decode(response.body));
        _services.insert(0, newService);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create service: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error creating service: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateService(Service service) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.put(
        '${ApiConstants.serviceById}${service.id}',
        body: service.toJson(),
      );
      
      if (response.statusCode == 200) {
        final index = _services.indexWhere((s) => s.id == service.id);
        if (index != -1) {
          _services[index] = Service.fromJson(json.decode(response.body));
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update service: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating service: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void selectService(Service? service) {
    _selectedService = service;
    notifyListeners();
  }
}
