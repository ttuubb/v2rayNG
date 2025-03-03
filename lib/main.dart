import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'viewmodels/server_list_viewmodel.dart';
import 'views/server_list_page.dart';
import 'views/server_detail_page.dart';

/// 应用程序入口点
/// 
/// 初始化必要的服务和依赖，然后启动应用程序
void main() async {
  // 确保Flutter绑定初始化，这对于调用平台通道和使用Flutter引擎功能是必需的
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化依赖注入服务定位器，用于管理应用程序的依赖关系
  await ServiceLocator.init();
  // 运行应用程序主体
  runApp(const MyApp());
}

/// 应用程序根组件
/// 
/// 配置应用程序的全局设置，如主题、路由和状态管理
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 配置全局状态管理提供者
      providers: [
        // 注册服务器列表视图模型，用于管理服务器列表的状态
        ChangeNotifierProvider<ServerListViewModel>(
          create: (_) => getIt<ServerListViewModel>(),
        ),
      ],
      child: MaterialApp(
        title: 'V2rayNG',
        // 配置应用程序亮色主题
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // 配置应用程序暗色主题
        darkTheme: ThemeData.dark().copyWith(
          useMaterial3: true,
        ),
        // 设置应用程序首页
        home: const HomePage(),
        // 定义应用程序路由表
        routes: {
          '/serverList': (context) => const ServerListPage(),
          '/serverDetail': (context) => const ServerDetailPage(),
        },
      ),
    );
  }
}

/// 应用程序首页
/// 
/// 显示欢迎信息和导航到服务器列表的入口
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('V2rayNG'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 欢迎标题
            const Text('欢迎使用 V2rayNG', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            // 导航按钮
            ElevatedButton(
              onPressed: () {
                // 点击时导航到服务器列表页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServerListPage(),
                  ),
                );
              },
              child: const Text('服务器列表'),
            ),
          ],
        ),
      ),
    );
  }
}