import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/viewmodels/server_list_viewmodel.dart';
import 'package:v2rayng/models/repositories/server_repository.dart';
import 'package:v2rayng/models/server_config.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ServerRepository])
import 'server_list_viewmodel_test.mocks.dart';

void main() {
  group('ServerListViewModel Tests', () {
    late ServerListViewModel viewModel;
    late MockServerRepository mockRepository;

    setUp(() {
      mockRepository = MockServerRepository();
      viewModel = ServerListViewModel(mockRepository);

      // 设置默认的mock行为
      when(mockRepository.getAllServers()).thenAnswer((_) async => []);
    });

    test('初始状态测试', () {
      expect(viewModel.servers, isEmpty);
      expect(viewModel.currentServer, isNull);
    });

    test('添加服务器测试', () async {
      final server = ServerConfig(
        name: 'Test Server',
        address: 'example.com',
        port: 443,
        protocol: 'vmess',
        settings: {
          'uuid': 'test-uuid',
          'alterId': 0,
          'security': 'auto',
          'network': 'tcp',
        },
      );

      // 模拟添加服务器后的返回结果
      when(mockRepository.getAllServers()).thenAnswer((_) async => [server]);
      when(mockRepository.addServer(any)).thenAnswer((_) async {});

      // 强制重新创建viewModel以避免缓存问题
      viewModel = ServerListViewModel(mockRepository);

      // 添加服务器并验证结果
      await viewModel.addServer(server);

      // 强制等待异步操作完成
      await Future.delayed(Duration.zero);

      expect(viewModel.servers.length, equals(1));
      expect(viewModel.servers.first.address, equals('example.com'));
    });

    test('删除服务器测试', () async {
      final server = ServerConfig(
        name: 'Test Server',
        address: 'example.com',
        port: 443,
        protocol: 'vmess',
        settings: {
          'uuid': 'test-uuid',
          'alterId': 0,
          'security': 'auto',
          'network': 'tcp',
        },
      );

      // 首先模拟有一个服务器
      when(mockRepository.getAllServers()).thenAnswer((_) async => [server]);
      when(mockRepository.deleteServer(any)).thenAnswer((_) async {});

      // 强制重新创建viewModel以避免缓存问题
      viewModel = ServerListViewModel(mockRepository);

      // 强制加载服务器列表
      await viewModel.loadServers();

      // 强制等待异步操作完成
      await Future.delayed(Duration.zero);

      expect(viewModel.servers.length, equals(1));

      // 然后模拟删除服务器后的返回结果
      when(mockRepository.getAllServers()).thenAnswer((_) async => []);
      await viewModel.deleteServer(server.id);

      // 强制等待异步操作完成
      await Future.delayed(Duration.zero);

      expect(viewModel.servers, isEmpty);
    });

    test('选择服务器测试', () async {
      final server = ServerConfig(
        name: 'Test Server',
        address: 'example.com',
        port: 443,
        protocol: 'vmess',
        settings: {
          'uuid': 'test-uuid',
          'alterId': 0,
          'security': 'auto',
          'network': 'tcp',
        },
      );

      // 模拟有一个服务器
      when(mockRepository.getAllServers()).thenAnswer((_) async => [server]);

      // 模拟缓存过期，确保loadServers会真正加载数据
      viewModel = ServerListViewModel(mockRepository);

      // 强制加载服务器列表
      await viewModel.loadServers();

      // 强制等待异步操作完成
      await Future.delayed(Duration.zero);

      // 模拟连接服务器
      await viewModel.connectServer(server.id);

      // 强制等待异步操作完成
      await Future.delayed(Duration.zero);

      expect(viewModel.currentServer, isNotNull);
      expect(viewModel.currentServer?.address, equals('example.com'));
    });

    test('更新服务器测试', () async {
      final server = ServerConfig(
        name: 'Test Server',
        address: 'example.com',
        port: 443,
        protocol: 'vmess',
        settings: {
          'uuid': 'test-uuid',
          'alterId': 0,
          'security': 'auto',
          'network': 'tcp',
        },
      );

      // 首先模拟有一个服务器
      when(mockRepository.getAllServers()).thenAnswer((_) async => [server]);

      // 模拟缓存过期，确保loadServers会真正加载数据
      viewModel = ServerListViewModel(mockRepository);
      await viewModel.loadServers();

      // 强制等待异步操作完成
      await Future.delayed(Duration.zero);

      // 然后模拟更新服务器后的返回结果
      final updatedServerConfig = ServerConfig(
        id: server.id,
        name: 'Test Server',
        address: 'updated.example.com',
        port: 8443,
        protocol: 'vmess',
        settings: {
          'uuid': 'test-uuid',
          'alterId': 0,
          'security': 'auto',
          'network': 'tcp',
        },
      );

      when(mockRepository.getAllServers())
          .thenAnswer((_) async => [updatedServerConfig]);

      await viewModel.updateServer(server.id, updatedServerConfig);

      // 强制等待异步操作完成
      await Future.delayed(Duration.zero);

      expect(viewModel.servers.isNotEmpty, true);
      expect(viewModel.servers[0].address, equals('updated.example.com'));
      expect(viewModel.servers[0].port, equals(8443));
    });

    test('状态变化通知测试', () async {
      var notificationCount = 0;
      viewModel.addListener(() {
        notificationCount++;
      });

      final server = ServerConfig(
        name: 'Test Server',
        address: 'example.com',
        port: 443,
        protocol: 'vmess',
        settings: {
          'uuid': 'test-uuid',
          'alterId': 0,
          'security': 'auto',
          'network': 'tcp',
        },
      );

      // 模拟添加服务器后的返回结果
      when(mockRepository.getAllServers()).thenAnswer((_) async => [server]);
      await viewModel.addServer(server);

      // 强制等待异步操作完成
      await Future.delayed(Duration.zero);

      // 由于forceRefreshServers方法中调用了两次notifyListeners，所以这里期望值为2
      expect(notificationCount, equals(2));

      // 模拟连接服务器
      await viewModel.connectServer(server.id);

      // 强制等待异步操作完成
      await Future.delayed(Duration.zero);

      // 连接服务器会再次触发通知，所以总数为3
      expect(notificationCount, equals(3));

      // 模拟删除服务器后的返回结果
      when(mockRepository.getAllServers()).thenAnswer((_) async => []);
      await viewModel.deleteServer(server.id);

      // 强制等待异步操作完成
      await Future.delayed(Duration.zero);

      // 删除服务器会再次触发两次通知，所以总数为5
      expect(notificationCount, equals(5));
    });
  });
}
