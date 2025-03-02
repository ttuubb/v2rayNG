import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:v2rayng/models/server_config.dart';
import 'package:v2rayng/viewmodels/server_list_viewmodel.dart';
import './test_helper.dart';

void main() {
  group('服务器管理集成测试', () {
    late ServerListViewModel serverListViewModel;

    setUp(() async {
      await setupServiceLocator();
      serverListViewModel = GetIt.I<ServerListViewModel>();
    });

    tearDown(() {
      GetIt.I.reset();
    });

    test('服务器配置的增删改查操作', () async {
      // 测试添加服务器
      final testServer = ServerConfig(
        name: 'Test Server',
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
      expect(serverListViewModel.servers.length, 1);

      // 测试更新服务器配置
      final updatedServer = testServer.copyWith(
        name: 'Updated Server',
        port: 8443
      );
      await serverListViewModel.updateServer(testServer.id, updatedServer);
      expect(serverListViewModel.servers.first.name, 'Updated Server');
      expect(serverListViewModel.servers.first.port, 8443);

      // 测试删除服务器
      await serverListViewModel.deleteServer(testServer.id);
      expect(serverListViewModel.servers.isEmpty, true);
    });

    test('服务器连接状态管理', () async {
      final testServer = ServerConfig(
        name: 'Test Server',
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

      // 测试连接服务器
      await serverListViewModel.connectServer(testServer.id);
      expect(serverListViewModel.currentServer?.id, testServer.id);
      expect(serverListViewModel.isConnected, true);

      // 测试断开连接
      await serverListViewModel.disconnectServer();
      expect(serverListViewModel.currentServer, null);
      expect(serverListViewModel.isConnected, false);
    });

    test('服务器配置验证', () async {
      // 测试无效配置
      try {
        ServerConfig(
          name: '',
          address: '',
          port: 1000, // 使用有效端口，让其他验证失败
          protocol: 'invalid',
          settings: {}
        );
        fail('应该抛出ArgumentError异常');
      } catch (e) {
        expect(e, isA<ArgumentError>());
        expect((e as ArgumentError).message, 'Name cannot be empty');
      }


      // 测试重复配置
      final server1 = ServerConfig(
        name: 'Server 1',
        address: 'test.server.com',
        port: 443,
        protocol: 'vmess',
        settings: {
          'id': 'test-uuid-1',
          'alterId': 0,
          'security': 'auto'
        }
      );
      final server2 = ServerConfig(
        name: 'Server 2',
        address: 'test.server.com',
        port: 443,
        protocol: 'vmess',
        settings: {
          'id': 'test-uuid-2',
          'alterId': 0,
          'security': 'auto'
        }
      );
      await serverListViewModel.addServer(server1);
      expect(
        () => serverListViewModel.addServer(server2),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('duplicate server configuration')
        ))
      );
    });

    test('批量服务器操作', () async {
      final servers = List.generate(5, (index) => ServerConfig(
        name: 'Server $index',
        address: 'server$index.com',
        port: 443 + index,
        protocol: 'vmess',
        settings: {
          'id': 'test-uuid-$index',
          'alterId': 0,
          'security': 'auto'
        }
      ));

      // 测试批量导入
      await serverListViewModel.importServers(servers);
      expect(serverListViewModel.servers.length, 5);

      // 测试批量删除
      final serverIds = serverListViewModel.servers
        .map((server) => server.id)
        .toList();
      await serverListViewModel.deleteServers(serverIds);
      expect(serverListViewModel.servers.isEmpty, true);
    });
  });
}