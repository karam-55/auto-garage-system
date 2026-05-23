class InputSanitizer {
  static String sanitize(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
  
  static Map<String, dynamic> sanitizeMap(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is String) {
        sanitized[key] = sanitize(value);
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = sanitizeMap(value);
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }
}
