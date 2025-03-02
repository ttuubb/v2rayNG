import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v2rayng/core/di/service_locator.dart';
import 'package:v2rayng/models/repositories/server_repository.dart';
import 'package:v2rayng/models/repositories/subscription_repository.dart';
import 'package:v2rayng/viewmodels/server_list_viewmodel.dart';
import 'package:v2rayng/viewmodels/subscription_viewmodel.dart';
import 'package:v2rayng/viewmodels/routing_rule_viewmodel.dart';
import 'package:v2rayng/core/services/local_storage.dart';
import 'package:mockito/mockito.dart';
import 'mock_repositories.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

final GetIt getIt = GetIt.instance;

// 这是测试文件中使用的方法，它调用setupTestServiceLocator
Future<void> setupServiceLocator() async {
  // 确保GetIt实例是干净的
  if (GetIt.I.isRegistered<ServerRepository>()) {
    GetIt.I.reset();
  }
  
  // 调用测试专用的服务定位器设置
  await setupTestServiceLocator();
}

Future<void> setupTestServiceLocator() async {
  // 设置SharedPreferences为测试模式
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  
  // 注册Repository
  getIt.registerSingleton<ServerRepository>(ServerRepository(prefs));
  
  // 注册模拟的SubscriptionRepository
  final mockSubscriptionRepository = MockSubscriptionRepository();
  getIt.registerSingleton<SubscriptionRepository>(mockSubscriptionRepository);
  
  // 注册MockLocalStorage
  final mockLocalStorage = MockLocalStorage();
  getIt.registerSingleton<LocalStorage>(mockLocalStorage);

  // 注册ViewModel
  getIt.registerFactory<ServerListViewModel>(
    () => ServerListViewModel(getIt<ServerRepository>()),
  );
  
  getIt.registerFactory<SubscriptionViewModel>(
    () => SubscriptionViewModel(getIt<SubscriptionRepository>()),
  );
  
  getIt.registerFactory<RoutingRuleViewModel>(
    () => RoutingRuleViewModel(getIt<LocalStorage>()),
  );
}