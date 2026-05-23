import 'cache_interface.dart';

class InMemoryCache implements CacheInterface {
  final Map<String, _CacheEntry> _cache = {};

  @override
  Future<String?> get(String key) async {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.expiry != null && DateTime.now().isAfter(entry.expiry!)) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  @override
  Future<void> set(String key, String value, {Duration? ttl}) async {
    final expiry = ttl != null ? DateTime.now().add(ttl) : null;
    _cache[key] = _CacheEntry(value, expiry);
  }

  @override
  Future<void> delete(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
  }
}

class _CacheEntry {
  final String value;
  final DateTime? expiry;

  _CacheEntry(this.value, this.expiry);
}
