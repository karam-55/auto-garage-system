// Stub implementation for flutter_secure_storage on web
// This file is used when dart.library.io is not available (web platform)

class FlutterSecureStorage {
  FlutterSecureStorage();

  Future<String?> read({required String key}) async {
    return null;
  }

  Future<void> write({required String key, required String value}) async {
    // No-op on web
  }

  Future<void> delete({required String key}) async {
    // No-op on web
  }

  Future<void> deleteAll() async {
    // No-op on web
  }

  Future<bool> containsKey({required String key}) async {
    return false;
  }

  Future<Map<String, String>> readAll() async {
    return {};
  }
}
