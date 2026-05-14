import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/mechanic_assignment.dart';
import '../models/part_suggestion.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class MechanicProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider;
  
  List<Booking> _availableBookings = [];
  List<MechanicAssignment> _myAssignments = [];
  List<PartSuggestion> _partSuggestions = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  MechanicProvider(this._authProvider);
  
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
      final data = await _apiService.fetchAvailableBookings();
      _availableBookings = data.map((json) => Booking.fromJson(json)).toList();
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
      final success = await _apiService.assignBooking(bookingId, '');
      
      if (success) {
        await fetchMyAssignments();
        await fetchAvailableBookings();
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
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
      final data = await _apiService.fetchMyAssignments('');
      _myAssignments = data.map((json) => MechanicAssignment.fromJson(json)).toList();
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
      final success = await _apiService.updateAssignmentStatus(assignmentId, status, notes);
      
      if (success) {
        await fetchMyAssignments();
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
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
      final success = await _apiService.createPartSuggestion(
        bookingId,
        '',
        type,
        description,
        priceSYP,
      );
      
      _isLoading = false;
      notifyListeners();
      return success;
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
      final data = await _apiService.fetchPartSuggestions(bookingId);
      _partSuggestions = data.map((json) => PartSuggestion.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = 'Error loading part suggestions: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> addRepair(String bookingId, String description, String status, double? cost) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await _apiService.addRepair(
        bookingId,
        '',
        description,
        status,
        cost,
      );
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error adding repair: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await _apiService.updateBookingStatus(bookingId, status);
      
      if (success) {
        await fetchMyAssignments();
        await fetchAvailableBookings();
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error updating booking status: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<List<dynamic>> fetchInventory() async {
    try {
      final data = await _apiService.fetchInventory();
      return data;
    } catch (e) {
      _errorMessage = 'Error loading inventory: $e';
      return [];
    }
  }
  
  Future<bool> consumePart(String variantId, int quantity, String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await _apiService.consumePart(variantId, quantity, bookingId);
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error consuming part: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<Map<String, dynamic>?> fetchInvoice(String bookingId) async {
    try {
      final data = await _apiService.fetchInvoice(bookingId);
      return data;
    } catch (e) {
      _errorMessage = 'Error loading invoice: $e';
      return null;
    }
  }
}
