import 'package:shared_preferences/shared_preferences.dart';

/// 存储服务接口
/// 提供基于SharedPreferences的键值对存储功能
/// 支持存储基本数据类型和字符串列表
abstract class StorageService {
  /// 存储键值对
  /// 
  /// [key] 存储键
  /// [value] 存储值，支持String、int、double、bool和List<String>类型
  /// 如果值类型不支持则抛出异常
  Future<void> setItem(String key, dynamic value);

  /// 获取存储的值
  /// 
  /// [key] 存储键
  /// 返回存储的值，如果键不存在则返回null
  Future<dynamic> getItem(String key);

  /// 删除指定键的存储项
  /// 
  /// [key] 要删除的存储键
  Future<void> removeItem(String key);

  /// 清除所有存储的数据
  Future<void> clear();
}

/// SharedPreferences存储服务实现类
class StorageServiceImpl implements StorageService {
  /// SharedPreferences实例
  late SharedPreferences _prefs;

  /// 构造函数
  /// 初始化SharedPreferences实例
  StorageServiceImpl() {
    _init();
  }

  /// 初始化方法
  /// 获取SharedPreferences实例
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> setItem(String key, dynamic value) async {
    // 根据值类型调用对应的存储方法
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
      // 不支持的值类型抛出异常
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