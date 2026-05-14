import 'validation_result.dart';

class BookingValidator {
  static ValidationResult validate(Map<String, dynamic> data) {
    final errors = <String>[];
    
    // التحقق من customerId
    if (data['customerId'] == null) {
      errors.add('معرف العميل مطلوب');
    }
    
    // التحقق من vehicleId
    if (data['vehicleId'] == null) {
      errors.add('معرف السيارة مطلوب');
    }
    
    // التحقق من serviceIds
    if (data['serviceIds'] == null || (data['serviceIds'] is List && (data['serviceIds'] as List).isEmpty)) {
      errors.add('يجب اختيار خدمة واحدة على الأقل');
    }
    
    // التحقق من status (اختياري)
    if (data['status'] != null && data['status'].toString().isNotEmpty) {
      final validStatuses = ['PENDING', 'IN_PROGRESS', 'WAITING_PARTS', 'READY', 'DELIVERED', 'CANCELLED'];
      if (!validStatuses.contains(data['status'])) {
        errors.add('الحالة غير صالحة');
      }
    }
    
    // التحقق من notes (اختياري)
    if (data['notes'] != null && data['notes'].toString().trim().isNotEmpty) {
      if (data['notes'].toString().trim().length > 1000) {
        errors.add('الملاحظات يجب أن لا تتجاوز 1000 حرف');
      }
    }
    
    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }
}
