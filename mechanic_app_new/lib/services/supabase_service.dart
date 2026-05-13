import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Auth operations
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      print('Attempting to connect to Supabase...');
      print('Username: $username');
      
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('username', username)
          .single();
      
      print('User found: ${response}');
      return response;
    } catch (e) {
      print('Supabase error: $e');
      print('Error type: ${e.runtimeType}');
      return null;
    }
  }
  
  Future<bool> register(String username, String fullName, String passwordHash, String role) async {
    try {
      print('Attempting to register user: $username');
      print('Role: $role');
      
      await _supabase.from('users').insert({
        'username': username,
        'full_name': fullName,
        'password_hash': passwordHash,
        'role': role,
      });
      
      print('User registered successfully');
      return true;
    } catch (e) {
      print('Registration error: $e');
      print('Error type: ${e.runtimeType}');
      return false;
    }
  }
  
  // Booking operations
  Future<List<Map<String, dynamic>>> fetchAvailableBookings() async {
    try {
      final data = await _supabase
          .from('bookings')
          .select('''
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
          ''')
          .eq('status', 'PENDING')
          .order('created_at', ascending: false);
      
      return data;
    } catch (e) {
      return [];
    }
  }
  
  Future<bool> assignBooking(String bookingId, String mechanicUserId) async {
    try {
      await _supabase.from('mechanic_assignments').insert({
        'booking_id': bookingId,
        'mechanic_user_id': mechanicUserId,
        'status': 'ASSIGNED',
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Assignment operations
  Future<List<Map<String, dynamic>>> fetchMyAssignments(String mechanicUserId) async {
    try {
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
      
      return data;
    } catch (e) {
      return [];
    }
  }
  
  Future<bool> updateAssignmentStatus(String assignmentId, String status, String? notes) async {
    try {
      await _supabase
          .from('mechanic_assignments')
          .update({
            'status': status,
            if (notes != null) 'notes': notes,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', assignmentId);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Part suggestion operations
  Future<bool> createPartSuggestion(String bookingId, String mechanicUserId, String type, String description, double? priceSYP) async {
    try {
      await _supabase.from('part_suggestions').insert({
        'booking_id': bookingId,
        'mechanic_user_id': mechanicUserId,
        'type': type,
        'description': description,
        if (priceSYP != null) 'price_syp': priceSYP,
        'status': 'PENDING_CUSTOMER_APPROVAL',
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<List<Map<String, dynamic>>> fetchPartSuggestions(String bookingId) async {
    try {
      final data = await _supabase
          .from('part_suggestions')
          .select('*')
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false);
      
      return data;
    } catch (e) {
      return [];
    }
  }
  
  // Repair operations
  Future<bool> addRepair(String bookingId, String mechanicUserId, String description, String status, double? cost) async {
    try {
      await _supabase.from('repairs').insert({
        'booking_id': bookingId,
        'mechanic_user_id': mechanicUserId,
        'description': description,
        'status': status,
        if (cost != null) 'cost': cost,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
