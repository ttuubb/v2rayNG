import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/models/server_list_view_model.dart';
import 'package:v2rayng/models/config_model.dart';

void main() {
  group('ServerListViewModel Tests', () {
    late ServerListViewModel viewModel;

    setUp(() {
      viewModel = ServerListViewModel();
    });

    test('初始状态测试', () {
      expect(viewModel.servers, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
    });

    test('添加服务器测试', () {
      final server = ConfigModel(
        protocol: 'vmess',
        address: 'example.com',
        port: 443,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );

      viewModel.addServer(server);
      expect(viewModel.servers.length, equals(1));
      expect(viewModel.servers.first, equals(server));
    });

    test('删除服务器测试', () {
      final server = ConfigModel(
        protocol: 'vmess',
        address: 'example.com',
        port: 443,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );

      viewModel.addServer(server);
      expect(viewModel.servers.length, equals(1));

      viewModel.removeServer(0);
      expect(viewModel.servers, isEmpty);
    });

    test('更新服务器测试', () {
      final server = ConfigModel(
        protocol: 'vmess',
        address: 'example.com',
        port: 443,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );

      viewModel.addServer(server);

      final updatedServer = server.copyWith(address: 'new.example.com');
      viewModel.updateServer(0, updatedServer);

      expect(viewModel.servers[0].address, equals('new.example.com'));
    });

    test('加载状态测试', () {
      viewModel.setLoading(true);
      expect(viewModel.isLoading, isTrue);

      viewModel.setLoading(false);
      expect(viewModel.isLoading, isFalse);
    });

    test('错误处理测试', () {
      const errorMessage = '加载失败';
      viewModel.setError(errorMessage);
      expect(viewModel.error, equals(errorMessage));

      viewModel.clearError();
      expect(viewModel.error, isNull);
    });

    test('批量更新服务器测试', () {
      final servers = [
        ConfigModel(
          protocol: 'vmess',
          address: 'server1.com',
          port: 443,
          uuid: 'uuid1',
          alterId: 0,
          security: 'auto',
          network: 'tcp',
        ),
        ConfigModel(
          protocol: 'vmess',
          address: 'server2.com',
          port: 443,
          uuid: 'uuid2',
          alterId: 0,
          security: 'auto',
          network: 'tcp',
        ),
      ];

      viewModel.setServers(servers);
      expect(viewModel.servers.length, equals(2));
      expect(viewModel.servers[0].address, equals('server1.com'));
      expect(viewModel.servers[1].address, equals('server2.com'));
    });
  });
}