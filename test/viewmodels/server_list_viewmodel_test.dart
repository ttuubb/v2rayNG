import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/viewmodels/server_list_viewmodel.dart';
import 'package:v2rayng/models/config_model.dart';

void main() {
  group('ServerListViewModel Tests', () {
    late ServerListViewModel viewModel;

    setUp(() {
      viewModel = ServerListViewModel();
    });

    test('初始状态测试', () {
      expect(viewModel.servers, isEmpty);
      expect(viewModel.selectedServer, isNull);
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
      expect(viewModel.servers.first.address, equals('example.com'));
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

    test('选择服务器测试', () {
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
      viewModel.selectServer(0);

      expect(viewModel.selectedServer, isNotNull);
      expect(viewModel.selectedServer?.address, equals('example.com'));
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

      final updatedServer = server.copyWith(
        address: 'updated.example.com',
        port: 8443
      );

      viewModel.updateServer(0, updatedServer);

      expect(viewModel.servers[0].address, equals('updated.example.com'));
      expect(viewModel.servers[0].port, equals(8443));
    });

    test('状态变化通知测试', () {
      var notificationCount = 0;
      viewModel.addListener(() {
        notificationCount++;
      });

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
      expect(notificationCount, equals(1));

      viewModel.selectServer(0);
      expect(notificationCount, equals(2));

      viewModel.removeServer(0);
      expect(notificationCount, equals(3));
    });
  });
}