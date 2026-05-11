import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/vehicle.dart';

class VehicleProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  bool _isLoading = false;
  String? _errorMessage;
  
  VehicleProvider() : _apiService = ApiService();
  
  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> fetchVehicles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get(ApiConstants.vehicles);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _vehicles = data.map((json) => Vehicle.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load vehicles: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading vehicles: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> fetchVehiclesByCustomer(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('${ApiConstants.vehiclesByCustomer}$customerId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _vehicles = data.map((json) => Vehicle.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load vehicles: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading vehicles: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> createVehicle(Vehicle vehicle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        ApiConstants.vehicles,
        body: vehicle.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final newVehicle = Vehicle.fromJson(json.decode(response.body));
        _vehicles.insert(0, newVehicle);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create vehicle: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error creating vehicle: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateVehicle(Vehicle vehicle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.put(
        '${ApiConstants.vehicleById}${vehicle.id}',
        body: vehicle.toJson(),
      );
      
      if (response.statusCode == 200) {
        final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
        if (index != -1) {
          _vehicles[index] = Vehicle.fromJson(json.decode(response.body));
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update vehicle: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating vehicle: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void selectVehicle(Vehicle? vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }
}
