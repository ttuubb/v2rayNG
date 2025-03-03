import 'package:hive/hive.dart';

/// 本地存储服务接口
/// 提供基于键值对的持久化存储功能
abstract class LocalStorage {
  /// 初始化存储服务
  /// 在使用其他方法前必须先调用此方法
  Future<void> init();

  /// 存储键值对
  /// 
  /// [key] 存储键
  /// [value] 存储值，支持基本数据类型和可序列化的对象
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

  /// 检查是否包含指定键
  /// 
  /// [key] 要检查的存储键
  /// 返回是否存在该键
  Future<bool> containsKey(String key);

  /// 清除所有存储的数据
  Future<void> clear();
}

/// 基于Hive实现的本地存储服务
class HiveLocalStorage implements LocalStorage {
  /// Hive存储盒子实例
  late Box _box;

  @override
  Future<void> init() async {
    // 打开名为v2rayng_storage的存储盒子
    _box = await Hive.openBox('v2rayng_storage');
  }

  @override
  Future<void> setItem(String key, dynamic value) async {
    // 存储键值对到Hive盒子
    await _box.put(key, value);
  }

  @override
  Future<dynamic> getItem(String key) async {
    // 从Hive盒子中获取值
    return await _box.get(key);
  }

  @override
  Future<void> removeItem(String key) async {
    // 从Hive盒子中删除指定键的数据
    await _box.delete(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    // 检查Hive盒子是否包含指定键
    return _box.containsKey(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}