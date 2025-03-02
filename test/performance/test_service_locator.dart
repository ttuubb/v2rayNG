import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:v2rayng/models/repositories/server_repository.dart';
import 'package:v2rayng/models/repositories/subscription_repository.dart';
import 'package:v2rayng/models/repositories/subscription_repository_impl.dart';
import 'package:v2rayng/viewmodels/server_list_viewmodel.dart';
import 'package:v2rayng/viewmodels/subscription_viewmodel.dart';
import 'package:v2rayng/viewmodels/traffic_viewmodel.dart';
import 'package:v2rayng/core/event_bus.dart';
import 'package:v2rayng/core/services/traffic_service.dart';
import 'package:v2rayng/core/services/local_storage.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // 注册EventBus单例
  getIt.registerSingleton<EventBus>(EventBus());
  
  // 注册SharedPreferences - 使用模拟值
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  
  // 初始化Hive
  try {
    // 在测试环境中为Hive提供临时目录
    Directory tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    
    // 注册Services
    final localStorage = HiveLocalStorage();
    await localStorage.init();
    getIt.registerSingleton<LocalStorage>(localStorage);
    getIt.registerSingleton<TrafficService>(TrafficServiceImpl(getIt<EventBus>(), localStorage));
  } catch (e) {
    print('Hive初始化错误: $e');
    // 如果初始化失败，使用模拟的LocalStorage
    final mockLocalStorage = MockLocalStorage();
    getIt.registerSingleton<LocalStorage>(mockLocalStorage);
    getIt.registerSingleton<TrafficService>(TrafficServiceImpl(getIt<EventBus>(), mockLocalStorage));
  }
  
  // 注册Repositories
  getIt.registerSingleton<ServerRepository>(ServerRepository(prefs));
  getIt.registerSingleton<SubscriptionRepository>(SubscriptionRepositoryImpl(prefs, http.Client()));
  
  // 注册ViewModels
  getIt.registerFactory<ServerListViewModel>(
    () => ServerListViewModel(getIt<ServerRepository>()),
  );
  getIt.registerFactory<SubscriptionViewModel>(
    () => SubscriptionViewModel(getIt<SubscriptionRepository>()),
  );
  getIt.registerFactory<TrafficViewModel>(
    () => TrafficViewModel(getIt<TrafficService>(), getIt<EventBus>()),
  );
}

// 模拟LocalStorage类，用于测试
class MockLocalStorage implements LocalStorage {
  final Map<String, dynamic> _storage = {};
  
  @override
  Future<void> init() async {}
  
  @override
  Future<void> setItem(String key, dynamic value) async {
    _storage[key] = value;
  }
  
  @override
  Future<dynamic> getItem(String key) async {
    return _storage[key];
  }
  
  @override
  Future<void> removeItem(String key) async {
    _storage.remove(key);
  }
  
  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }
  
  @override
  Future<void> clear() async {
    _storage.clear();
  }
}