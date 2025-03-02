import 'package:hive/hive.dart';

abstract class LocalStorage {
  Future<void> init();
  Future<void> setItem(String key, dynamic value);
  Future<dynamic> getItem(String key);
  Future<void> removeItem(String key);
  Future<bool> containsKey(String key);
  Future<void> clear();
}

class HiveLocalStorage implements LocalStorage {
  late Box _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox('v2rayng_storage');
  }

  @override
  Future<void> setItem(String key, dynamic value) async {
    await _box.put(key, value);
  }

  @override
  Future<dynamic> getItem(String key) async {
    return await _box.get(key);
  }

  @override
  Future<void> removeItem(String key) async {
    await _box.delete(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _box.containsKey(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}