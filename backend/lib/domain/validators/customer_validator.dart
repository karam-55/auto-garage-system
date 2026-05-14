import 'validation_result.dart';
import 'common_validators.dart';

class CustomerValidator {
  static ValidationResult validate(Map<String, dynamic> data, {bool checkUniqueness = false}) {
    final errors = <String>[];
    
    // التحقق من fullName
    final nameResult = CommonValidators.validateName(data['fullName'], fieldName: 'الاسم الكامل');
    if (!nameResult.isValid) {
      errors.addAll(nameResult.errors);
    }
    
    // التحقق من phone
    final phoneResult = CommonValidators.validatePhone(data['phone']);
    if (!phoneResult.isValid) {
      errors.addAll(phoneResult.errors);
    }
    
    // التحقق من address (اختياري)
    if (data['address'] != null && data['address'].toString().trim().isNotEmpty) {
      if (data['address'].toString().trim().length > 500) {
        errors.add('العنوان يجب أن لا يتجاوز 500 حرف');
      }
    }
    
    // ملاحظة: التحقق من فريدة phone يجب أن يتم في Repository أو Service
    // لأنه يتطلب الوصول إلى قاعدة البيانات
    
    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }
}
