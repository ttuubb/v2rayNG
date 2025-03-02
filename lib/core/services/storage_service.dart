import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<void> setItem(String key, dynamic value);
  Future<dynamic> getItem(String key);
  Future<void> removeItem(String key);
  Future<void> clear();
}

class StorageServiceImpl implements StorageService {
  late SharedPreferences _prefs;

  StorageServiceImpl() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> setItem(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      throw Exception('Unsupported value type');
    }
  }

  @override
  Future<dynamic> getItem(String key) async {
    return _prefs.get(key);
  }

  @override
  Future<void> removeItem(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}