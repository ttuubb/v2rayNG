// Service Locator 文件说明：
// 该文件用于初始化依赖注入容器（Dependency Injection Container），通过 GetIt 库实现。
// 主要功能包括：
// 1. 注册 Repository（数据仓库）实例，用于管理应用的核心数据逻辑。
// 2. 注册 ViewModel（视图模型）实例，用于连接 UI 和业务逻辑。
// 3. 提供一个静态方法 `init`，在应用启动时调用以完成所有依赖的注册。

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:v2rayng/models/repositories/subscription_repository.dart';
import 'package:v2rayng/models/repositories/subscription_repository_impl.dart';
import '../../models/repositories/server_repository.dart';
import '../../viewmodels/server_list_viewmodel.dart';
import '../../viewmodels/subscription_viewmodel.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  // 初始化服务定位器，完成所有依赖的注册
  static Future<void> init() async {
    // 获取 SharedPreferences 实例，用于持久化存储
    final prefs = await SharedPreferences.getInstance();
    
    // 创建HTTP客户端实例
    final httpClient = http.Client();

    // 注册 ServerRepository 单例
    // ServerRepository 是核心的数据仓库，负责管理服务器相关数据
    getIt.registerSingleton<ServerRepository>(ServerRepository(prefs));

    // 注册 SubscriptionRepository 单例
    // SubscriptionRepository 负责管理订阅相关数据
    getIt.registerSingleton<SubscriptionRepository>(
      SubscriptionRepositoryImpl(prefs, httpClient)
    );
    
    // 注册 ServerListViewModel 工厂方法
    // ServerListViewModel 是视图模型，负责为服务器列表页面提供业务逻辑
    getIt.registerFactory<ServerListViewModel>(
      () => ServerListViewModel(getIt<ServerRepository>()),
    );
    // 注册 SubscriptionViewModel 工厂方法
    // SubscriptionViewModel 是视图模型，负责为订阅管理页面提供业务逻辑
    getIt.registerFactory<SubscriptionViewModel>(
      () => SubscriptionViewModel(getIt<SubscriptionRepository>()),
    );
  }
}