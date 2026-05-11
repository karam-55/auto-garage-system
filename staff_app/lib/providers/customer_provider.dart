import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/customer.dart';

class CustomerProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoading = false;
  String? _errorMessage;
  
  CustomerProvider() : _apiService = ApiService();
  
  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> fetchCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get(ApiConstants.customers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _customers = data.map((json) => Customer.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load customers: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading customers: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> createCustomer(Customer customer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        ApiConstants.customers,
        body: customer.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final newCustomer = Customer.fromJson(json.decode(response.body));
        _customers.insert(0, newCustomer);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create customer: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error creating customer: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateCustomer(Customer customer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.put(
        '${ApiConstants.customerById}${customer.id}',
        body: customer.toJson(),
      );
      
      if (response.statusCode == 200) {
        final index = _customers.indexWhere((c) => c.id == customer.id);
        if (index != -1) {
          _customers[index] = Customer.fromJson(json.decode(response.body));
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update customer: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating customer: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteCustomer(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.delete('${ApiConstants.customerById}$customerId');
      
      if (response.statusCode == 200) {
        _customers.removeWhere((c) => c.id == customerId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to delete customer: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting customer: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void selectCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }
}
