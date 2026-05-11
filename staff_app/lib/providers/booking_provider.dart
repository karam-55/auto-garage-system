import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/booking.dart';
import '../models/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Booking> _bookings = [];
  Booking? _selectedBooking;
  List<BookingService> _bookingServices = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  BookingProvider() : _apiService = ApiService();
  
  List<Booking> get bookings => _bookings;
  Booking? get selectedBooking => _selectedBooking;
  List<BookingService> get bookingServices => _bookingServices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> fetchBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get(ApiConstants.bookings);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _bookings = data.map((json) => Booking.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load bookings: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading bookings: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> fetchBookingsByCustomer(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('${ApiConstants.bookingsByCustomer}$customerId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _bookings = data.map((json) => Booking.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load bookings: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading bookings: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> fetchBookingsByStatus(String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('${ApiConstants.bookingsByStatus}$status');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _bookings = data.map((json) => Booking.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load bookings: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading bookings: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        ApiConstants.bookings,
        body: bookingData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final newBooking = Booking.fromJson(json.decode(response.body));
        _bookings.insert(0, newBooking);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create booking: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error creating booking: $e';
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
      final response = await _apiService.patch(
        '${ApiConstants.updateBookingStatus}$bookingId/status',
        body: {'status': status},
      );
      
      if (response.statusCode == 200) {
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _bookings[index] = Booking.fromJson(json.decode(response.body));
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update booking status: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating booking status: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> fetchBookingServices(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('${ApiConstants.bookingById}$bookingId');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['services'] != null) {
          final List<dynamic> services = data['services'];
          _bookingServices = services.map((json) => BookingService.fromJson(json)).toList();
        }
      } else {
        _errorMessage = 'Failed to load booking services: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading booking services: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  void selectBooking(Booking? booking) {
    _selectedBooking = booking;
    notifyListeners();
  }
}
