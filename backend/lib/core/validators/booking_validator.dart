class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class BookingValidator {
  static void validateCreateBooking(Map<String, dynamic> data) {
    if (!data.containsKey('customerId') || data['customerId'] == null) {
      throw ValidationException('customerId is required');
    }
    if (!data.containsKey('vehicleId') || data['vehicleId'] == null) {
      throw ValidationException('vehicleId is required');
    }
    if (!data.containsKey('services') || (data['services'] as List).isEmpty) {
      throw ValidationException('At least one service is required');
    }
  }
}
