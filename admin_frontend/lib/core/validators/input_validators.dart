class InputValidators {
  static String? validateCustomerId(String? value) {
    if (value == null || value.isEmpty) {
      return 'معرف العميل مطلوب';
    }
    if (!RegExp(r'^[0-9a-f-]{36}$').hasMatch(value)) {
      return 'معرف العميل يجب أن يكون UUID صالح';
    }
    return null;
  }

  static String? validateVehicleId(String? value) {
    if (value == null || value.isEmpty) {
      return 'معرف المركبة مطلوب';
    }
    if (!RegExp(r'^[0-9a-f-]{36}$').hasMatch(value)) {
      return 'معرف المركبة يجب أن يكون UUID صالح';
    }
    return null;
  }

  static String? validateServiceSelection(List<String>? services) {
    if (services == null || services.isEmpty) {
      return 'يجب اختيار خدمة واحدة على الأقل';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (!RegExp(r'^[0-9+]{10,20}$').hasMatch(value)) {
      return 'رقم الهاتف غير صالح';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }
}
