import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheDataSource {
  final SharedPreferences _prefs;

  CacheDataSource(this._prefs);

  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  Future<void> saveList(String key, List<dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  Future<List<dynamic>> getList(String key) async {
    final value = _prefs.getString(key);
    if (value != null) {
      return jsonDecode(value) as List<dynamic>;
    }
    return [];
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  Future<bool> isExpired(String key, Duration maxAge) async {
    final timestamp = _prefs.getInt('${key}_timestamp');
    if (timestamp == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final age = now - timestamp;
    return age > maxAge.inMilliseconds;
  }

  Future<void> setTimestamp(String key) async {
    await _prefs.setInt('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }
}
