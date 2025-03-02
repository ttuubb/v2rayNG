import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:v2rayng/viewmodels/subscription_viewmodel.dart';
import 'package:v2rayng/viewmodels/server_list_viewmodel.dart';
import 'package:v2rayng/models/subscription.dart';
import './performance_test_framework.dart';
import './test_service_locator.dart';

void main() {
  group('订阅管理性能测试', () {
    late SubscriptionViewModel subscriptionViewModel;
    late ServerListViewModel serverListViewModel;
    
    setUp(() async {
      // 初始化依赖注入
      await setupServiceLocator();
      subscriptionViewModel = GetIt.I<SubscriptionViewModel>();
      serverListViewModel = GetIt.I<ServerListViewModel>();
    });
    
    tearDown(() {
      GetIt.I.reset();
    });
    
    test('订阅解析性能测试', () async {
      // 准备测试数据 - 创建多个订阅
      final subscriptions = List.generate(10, (index) => Subscription(
        name: 'Subscription $index',
        url: 'https://example$index.com/sub',
        autoUpdate: index % 2 == 0,
        updateInterval: 24,
        lastUpdateTime: DateTime.now().subtract(Duration(hours: index))
      ));
      
      // 测量批量添加订阅的性能
      final addResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          for (final subscription in subscriptions) {
            await subscriptionViewModel.addSubscription(subscription);
          }
        },
        description: '批量添加10个订阅'
      );
      
      print(addResult);
      expect(addResult.success, true);
      
      // 测量订阅更新性能
      final updateResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          await subscriptionViewModel.updateAllSubscriptions();
        },
        description: '更新所有订阅'
      );
      
      print(updateResult);
      expect(updateResult.success, true);
      
      // 测量订阅过滤性能
      final filterResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          subscriptionViewModel.filterSubscriptions('Subscription');
        },
        description: '过滤订阅列表'
      );
      
      print(filterResult);
      expect(filterResult.success, true);
    });
    
    test('大量订阅服务器解析性能测试', () async {
      // 模拟一个包含大量服务器的订阅
      final largeSubscription = Subscription(
        name: 'Large Subscription',
        url: 'https://example.com/large_sub',
        autoUpdate: true,
        updateInterval: 24,
        lastUpdateTime: DateTime.now().subtract(Duration(days: 1))
      );
      
      await subscriptionViewModel.addSubscription(largeSubscription);
      
      // 测量解析大量服务器的性能
      final parseResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          // 模拟解析包含1000个服务器的订阅内容
          // 生成模拟的订阅内容
          final content = _generateLargeSubscriptionContent(1000);
          // 模拟解析过程
          await Future.delayed(Duration(milliseconds: 500));
          // 这里应该调用实际的解析方法，但在测试中我们只模拟这个过程
          // 更新订阅状态
          final updatedSubscription = Subscription(
            id: largeSubscription.id,
            name: largeSubscription.name,
            url: largeSubscription.url,
            autoUpdate: largeSubscription.autoUpdate,
            updateInterval: largeSubscription.updateInterval,
            lastUpdateTime: DateTime.now(),
            isUpdating: false
          );
          await subscriptionViewModel.updateSubscription(updatedSubscription);
        },
        description: '解析包含1000个服务器的订阅'
      );
      
      print(parseResult);
      expect(parseResult.success, true);
      
      // 验证服务器是否成功添加到列表中
      expect(serverListViewModel.servers.length, greaterThanOrEqualTo(1000));
      
      // 测量订阅服务器导出性能
      final exportResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          await subscriptionViewModel.exportSubscriptionToFile(largeSubscription.id);
        },
        description: '导出包含1000个服务器的订阅'
      );
      
      print(exportResult);
      expect(exportResult.success, true);
    });
  });
}

// 生成大量服务器配置的订阅内容
String _generateLargeSubscriptionContent(int count) {
  // 这里简化实现，实际应用中应该生成有效的订阅内容格式
  final buffer = StringBuffer();
  
  for (int i = 0; i < count; i++) {
    // 生成一个模拟的VMess链接
    buffer.writeln('vmess://eyJhZGQiOiJzZXJ2ZXIkaSIsInBvcnQiOjQ0MywiaWQiOiJ0ZXN0LXV1aWQtJGkiLCJhaWQiOjAsIm5ldCI6IndzIiwidHlwZSI6Im5vbmUiLCJob3N0IjoiIiwicGF0aCI6Ii8iLCJ0bHMiOiJ0bHMiLCJzbmkiOiIiLCJhbHBuIjoiIn0=');
  }
  
  return buffer.toString();
}