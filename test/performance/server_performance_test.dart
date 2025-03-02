import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:v2rayng/viewmodels/server_list_viewmodel.dart';
import 'package:v2rayng/models/server_config.dart';
import './performance_test_framework.dart';
import './test_service_locator.dart';

void main() {
  // 确保Flutter绑定已初始化
  TestWidgetsFlutterBinding.ensureInitialized();
  group('服务器列表性能测试', () {
    late ServerListViewModel serverListViewModel;
    
    setUp(() async {
      // 初始化依赖注入
      await setupServiceLocator();
      serverListViewModel = GetIt.I<ServerListViewModel>();
    });
    
    tearDown(() {
      GetIt.I.reset();
    });
    
    test('服务器列表加载性能测试', () async {
      // 准备测试数据 - 创建大量服务器配置
      final servers = List.generate(500, (index) => ServerConfig(
        name: 'Server $index',
        address: 'server$index.example.com',
        port: 443 + (index % 1000),
        protocol: index % 2 == 0 ? 'vmess' : 'trojan',
        settings: {
          'id': 'test-uuid-$index',
          'alterId': 0,
          'security': 'auto'
        }
      ));
      
      // 测量批量添加服务器的性能
      final addResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          for (final server in servers) {
            await serverListViewModel.addServer(server);
          }
        },
        description: '批量添加500个服务器配置'
      );
      
      // 输出性能测试结果
      print(addResult);
      expect(addResult.success, true);
      
      // 测量服务器列表排序性能
      final sortResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          // 模拟按延迟排序
          final sortedServers = List<ServerConfig>.from(serverListViewModel.servers);
          sortedServers.sort((a, b) => (a.latency ?? double.infinity).compareTo(b.latency ?? double.infinity));
        },
        description: '对500个服务器按延迟排序'
      );
      
      print(sortResult);
      expect(sortResult.success, true);
      
      // 测量服务器列表过滤性能
      final filterResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          // 模拟过滤服务器
          final filteredServers = serverListViewModel.servers.where(
            (server) => server.name.contains('Server 1')
          ).toList();
        },
        description: '从500个服务器中过滤服务器'
      );
      
      print(filterResult);
      expect(filterResult.success, true);
      
      // 测量批量删除服务器的性能
      final deleteResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          for (final server in servers) {
            await serverListViewModel.deleteServer(server.id);
          }
        },
        description: '批量删除500个服务器配置'
      );
      
      print(deleteResult);
      expect(deleteResult.success, true);
    });
    
    test('服务器连接测试性能', () async {
      // 创建测试服务器
      final testServer = ServerConfig(
        name: 'Performance Test Server',
        address: 'test.server.com',
        port: 443,
        protocol: 'vmess',
        settings: {
          'id': 'test-uuid',
          'alterId': 0,
          'security': 'auto'
        }
      );
      await serverListViewModel.addServer(testServer);
      
      // 测量测试连接性能 - 模拟测试连接
      final testConnectionResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          // 模拟测试连接
          await Future.delayed(Duration(milliseconds: 100));
          // 更新服务器延迟
          final updatedServer = testServer.copyWith(latency: 100.0);
          await serverListViewModel.updateServer(testServer.id, updatedServer);
        },
        description: '测试服务器连接性能'
      );
      
      print(testConnectionResult);
      expect(testConnectionResult.success, true);
    });
  });
}