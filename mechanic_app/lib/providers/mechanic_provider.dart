import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';
import '../models/mechanic_assignment.dart';
import '../models/part_suggestion.dart';
import 'auth_provider.dart';

class MechanicProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
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
      final data = await _supabase
          .from('bookings')
          .select('''
            id,
            status,
            notes,
            estimated_completion_date,
            created_at,
            vehicles:customer_id!inner(
              id,
              make,
              model,
              year,
              license_plate,
              public_car_id
            ),
            customers:customer_id!inner(
              id,
              full_name,
              phone
            )
          ''')
          .eq('status', 'PENDING')
          .order('created_at', ascending: false);
      
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
      final mechanicUserId = _authProvider.userId;
      if (mechanicUserId == null) {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      await _supabase.from('mechanic_assignments').insert({
        'booking_id': bookingId,
        'mechanic_user_id': mechanicUserId,
        'status': 'ASSIGNED',
      });
      
      await fetchMyAssignments();
      await fetchAvailableBookings();
      _isLoading = false;
      notifyListeners();
      return true;
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
      final mechanicUserId = _authProvider.userId;
      if (mechanicUserId == null) {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final data = await _supabase
          .from('mechanic_assignments')
          .select('''
            id,
            status,
            notes,
            assigned_at,
            updated_at,
            bookings:booking_id!inner(
              id,
              status,
              notes,
              estimated_completion_date,
              created_at,
              vehicles:vehicle_id!inner(
                id,
                make,
                model,
                year,
                license_plate,
                public_car_id
              ),
              customers:customer_id!inner(
                id,
                full_name,
                phone
              )
            )
          ''')
          .eq('mechanic_user_id', mechanicUserId)
          .order('assigned_at', ascending: false);
      
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
      await _supabase
          .from('mechanic_assignments')
          .update({
            'status': status,
            if (notes != null) 'notes': notes,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', assignmentId);
      
      await fetchMyAssignments();
      _isLoading = false;
      notifyListeners();
      return true;
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
      final mechanicUserId = _authProvider.userId;
      if (mechanicUserId == null) {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      await _supabase.from('part_suggestions').insert({
        'booking_id': bookingId,
        'mechanic_user_id': mechanicUserId,
        'type': type,
        'description': description,
        if (priceSYP != null) 'price_syp': priceSYP,
        'status': 'PENDING_CUSTOMER_APPROVAL',
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
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
      final data = await _supabase
          .from('part_suggestions')
          .select('*')
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false);
      
      _partSuggestions = data.map((json) => PartSuggestion.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = 'Error loading part suggestions: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
