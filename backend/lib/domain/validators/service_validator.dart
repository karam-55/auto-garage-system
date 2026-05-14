import 'validation_result.dart';
import 'common_validators.dart';

class ServiceValidator {
  static ValidationResult validate(Map<String, dynamic> data) {
    final errors = <String>[];
    
    // التحقق من name
    final nameResult = CommonValidators.validateName(data['name'], fieldName: 'اسم الخدمة');
    if (!nameResult.isValid) {
      errors.addAll(nameResult.errors);
    }
    
    // التحقق من description (اختياري)
    if (data['description'] != null && data['description'].toString().trim().isNotEmpty) {
      if (data['description'].toString().trim().length > 500) {
        errors.add('الوصف يجب أن لا يتجاوز 500 حرف');
      }
    }
    
    // التحقق من priceSYP
    final priceResult = CommonValidators.validatePriceSYP(data['priceSYP']);
    if (!priceResult.isValid) {
      errors.addAll(priceResult.errors);
    }
    
    // التحقق من category (اختياري)
    if (data['category'] != null && data['category'].toString().trim().isNotEmpty) {
      if (data['category'].toString().trim().length > 100) {
        errors.add('الفئة يجب أن لا تتجاوز 100 حرف');
      }
    }
    
    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }
}
