import 'validation_result.dart';
import 'common_validators.dart';

class VehicleValidator {
  static ValidationResult validate(Map<String, dynamic> data) {
    final errors = <String>[];
    
    // التحقق من customerId
    if (data['customerId'] == null) {
      errors.add('معرف العميل مطلوب');
    }
    
    // التحقق من make
    final makeResult = CommonValidators.validateName(data['make'], fieldName: 'الماركة');
    if (!makeResult.isValid) {
      errors.addAll(makeResult.errors);
    }
    
    // التحقق من model
    final modelResult = CommonValidators.validateName(data['model'], fieldName: 'الموديل');
    if (!modelResult.isValid) {
      errors.addAll(modelResult.errors);
    }
    
    // التحقق من year (اختياري)
    if (data['year'] != null && data['year'].toString().isNotEmpty) {
      final yearResult = CommonValidators.validateYear(data['year']);
      if (!yearResult.isValid) {
        errors.addAll(yearResult.errors);
      }
    }
    
    // التحقق من licensePlate
    final plateResult = CommonValidators.validateLicensePlate(data['licensePlate']);
    if (!plateResult.isValid) {
      errors.addAll(plateResult.errors);
    }
    
    // التحقق من color (اختياري)
    if (data['color'] != null && data['color'].toString().trim().isNotEmpty) {
      if (data['color'].toString().trim().length > 50) {
        errors.add('اللون يجب أن لا يتجاوز 50 حرف');
      }
    }
    
    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }
}
