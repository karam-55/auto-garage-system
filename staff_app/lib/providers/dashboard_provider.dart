import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService;
  
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _revenueStats = {};
  bool _isLoading = false;
  String? _errorMessage;
  
  DashboardProvider() : _apiService = ApiService();
  
  Map<String, dynamic> get stats => _stats;
  Map<String, dynamic> get revenueStats => _revenueStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get(ApiConstants.dashboardStats);
      
      if (response.statusCode == 200) {
        _stats = json.decode(response.body);
      } else {
        _errorMessage = 'Failed to load dashboard stats: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading dashboard stats: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> fetchRevenueStats({String period = 'month'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('${ApiConstants.dashboardRevenue}?period=$period');
      
      if (response.statusCode == 200) {
        _revenueStats = json.decode(response.body);
      } else {
        _errorMessage = 'Failed to load revenue stats: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading revenue stats: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
