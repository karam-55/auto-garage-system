abstract class CacheInterface {
  Future<String?> get(String key);
  Future<void> set(String key, String value, {Duration? ttl});
  Future<void> delete(String key);
  Future<void> clear();
}
