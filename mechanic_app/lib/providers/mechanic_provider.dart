import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/booking.dart';
import '../models/mechanic_assignment.dart';
import '../models/part_suggestion.dart';

class MechanicProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Booking> _availableBookings = [];
  List<MechanicAssignment> _myAssignments = [];
  List<PartSuggestion> _partSuggestions = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  MechanicProvider() : _apiService = ApiService();
  
  List<Booking> get availableBookings => _availableBookings;
  List<MechanicAssignment> get myAssignments => _myAssignments;
  List<PartSuggestion> get partSuggestions => _partSuggestions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> fetchAvailableBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get(ApiConstants.availableBookings);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _availableBookings = data.map((json) => Booking.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load available bookings: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading available bookings: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> assignBooking(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        ApiConstants.assignBooking,
        body: {'bookingId': bookingId},
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchMyAssignments();
        await fetchAvailableBookings();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to assign booking: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error assigning booking: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> fetchMyAssignments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get(ApiConstants.myAssignments);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _myAssignments = data.map((json) => MechanicAssignment.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load assignments: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading assignments: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> updateAssignmentStatus(String assignmentId, String status, String? notes) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.patch(
        '${ApiConstants.updateAssignmentStatus}$assignmentId/status',
        body: {
          'status': status,
          if (notes != null) 'notes': notes,
        },
      );
      
      if (response.statusCode == 200) {
        await fetchMyAssignments();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update status: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating status: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> createPartSuggestion(String bookingId, String type, String description, double? priceSYP) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        '${ApiConstants.createPartSuggestion}$bookingId/part-suggestions',
        body: {
          'type': type,
          'description': description,
          if (priceSYP != null) 'priceSYP': priceSYP,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create part suggestion: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error creating part suggestion: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> fetchPartSuggestions(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('${ApiConstants.getPartSuggestions}$bookingId/part-suggestions');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _partSuggestions = data.map((json) => PartSuggestion.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load part suggestions: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading part suggestions: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
