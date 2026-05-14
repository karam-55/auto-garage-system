import 'validation_result.dart';
import 'common_validators.dart';

class UserValidator {
  static ValidationResult validate(Map<String, dynamic> data, {bool isUpdate = false}) {
    final errors = <String>[];
    
    // التحقق من username
    if (!isUpdate || data['username'] != null) {
      if (data['username'] == null || data['username'].toString().trim().isEmpty) {
        errors.add('اسم المستخدم مطلوب');
      } else {
        final username = data['username'].toString().trim();
        if (username.length < 3) {
          errors.add('اسم المستخدم يجب أن يكون 3 أحرف على الأقل');
        } else if (username.length > 50) {
          errors.add('اسم المستخدم يجب أن لا يتجاوز 50 حرف');
        } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
          errors.add('اسم المستخدم يجب أن يحتوي على أحرف، أرقام، وشرطات سفلية فقط');
        }
      }
    }
    
    // التحقق من password (مطلوب عند الإنشاء)
    if (!isUpdate) {
      if (data['password'] == null || data['password'].toString().isEmpty) {
        errors.add('كلمة المرور مطلوبة');
      } else {
        final password = data['password'].toString();
        if (password.length < 6) {
          errors.add('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
        }
      }
    } else if (data['password'] != null && data['password'].toString().isNotEmpty) {
      // عند التحديث، كلمة المرور اختيارية
      final password = data['password'].toString();
      if (password.length < 6) {
        errors.add('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }
    }
    
    // التحقق من fullName
    if (!isUpdate || data['fullName'] != null) {
      final nameResult = CommonValidators.validateName(data['fullName'], fieldName: 'الاسم الكامل');
      if (!nameResult.isValid) {
        errors.addAll(nameResult.errors);
      }
    }
    
    // التحقق من phone (اختياري)
    if (data['phone'] != null && data['phone'].toString().isNotEmpty) {
      final phoneResult = CommonValidators.validatePhone(data['phone']);
      if (!phoneResult.isValid) {
        errors.addAll(phoneResult.errors);
      }
    }
    
    // التحقق من role
    if (data['role'] != null && data['role'].toString().isNotEmpty) {
      final validRoles = ['ADMIN', 'MECHANIC', 'STAFF'];
      if (!validRoles.contains(data['role'])) {
        errors.add('الدور غير صالح');
      }
    }
    
    // ملاحظة: التحقق من فريدة username يجب أن يتم في Repository أو Service
    // لأنه يتطلب الوصول إلى قاعدة البيانات
    
    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }
}
