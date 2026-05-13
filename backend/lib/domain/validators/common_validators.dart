import 'validation_result.dart';

class CommonValidators {
  static ValidationResult validatePhone(String? phone) {
    final errors = <String>[];
    
    if (phone == null || phone.isEmpty) {
      errors.add('رقم الهاتف مطلوب');
    } else if (phone.length < 10) {
      errors.add('رقم الهاتف يجب أن يكون 10 أرقام على الأقل');
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      errors.add('رقم الهاتف يجب أن يحتوي على أرقام فقط');
    }
    
    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  static ValidationResult validatePriceSYP(dynamic price) {
    final errors = <String>[];
    
    if (price == null) {
      errors.add('السعر مطلوب');
    } else {
      final numValue = num.tryParse(price.toString());
      if (numValue == null) {
        errors.add('السعر يجب أن يكون رقماً');
      } else if (numValue <= 0) {
        errors.add('السعر يجب أن يكون أكبر من صفر');
      }
    }
    
    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  static ValidationResult validateLicensePlate(String? plate) {
    final errors = <String>[];
    
    if (plate == null || plate.trim().isEmpty) {
      errors.add('رقم اللوحة مطلوب');
    } else if (plate.trim().length < 3) {
      errors.add('رقم اللوحة يجب أن يكون 3 أحرف على الأقل');
    }
    
    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  static ValidationResult validateName(String? name, {String fieldName = 'الاسم'}) {
    final errors = <String>[];
    
    if (name == null || name.trim().isEmpty) {
      errors.add('$fieldName مطلوب');
    } else if (name.trim().length < 2) {
      errors.add('$fieldName يجب أن يكون حرفين على الأقل');
    } else if (name.trim().length > 255) {
      errors.add('$fieldName يجب أن لا يتجاوز 255 حرف');
    }
    
    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  static ValidationResult validateYear(dynamic year) {
    final errors = <String>[];
    
    if (year != null && year.toString().isNotEmpty) {
      final yearValue = int.tryParse(year.toString());
      if (yearValue == null) {
        errors.add('السنة يجب أن تكون رقماً');
      } else if (yearValue < 1900) {
        errors.add('السنة يجب أن تكون 1900 أو أكبر');
      } else if (yearValue > DateTime.now().year + 1) {
        errors.add('السنة يجب أن تكون سنة صحيحة');
      }
    }
    
    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  static ValidationResult validateRequired(dynamic value, {String fieldName = 'الحقل'}) {
    final errors = <String>[];
    
    if (value == null || (value is String && value.trim().isEmpty)) {
      errors.add('$fieldName مطلوب');
    }
    
    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }
}
