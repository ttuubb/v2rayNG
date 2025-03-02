import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:v2rayng/viewmodels/server_list_viewmodel.dart';
import 'package:v2rayng/models/server_config.dart';
import 'package:v2rayng/models/repositories/server_repository.dart';

@GenerateMocks([ServerRepository])
import 'server_list_viewmodel_test.mocks.dart';

void main() {
  group('ServerListViewModel Tests', () {
    late ServerListViewModel viewModel;
    late MockServerRepository mockRepository;

    setUp(() {
      mockRepository = MockServerRepository();
      viewModel = ServerListViewModel(mockRepository);
      
      // 配置Mock行为
      when(mockRepository.getAllServers()).thenAnswer((_) async => []);
    });

    test('should initialize with empty server list', () {
      expect(viewModel.servers, isEmpty);
    });

    test('should add server successfully', () {
      final server = ServerConfig(
        name: 'Test Server',
        address: 'test.server.com',
        port: 443,
        protocol: 'vmess',
        settings: {'id': 'test-uuid', 'security': 'auto'}
      );

      // 配置Mock行为
      when(mockRepository.saveServer(any)).thenAnswer((_) async => true);
      when(mockRepository.getAllServers()).thenAnswer((_) async => [server]);
      
      // 执行测试
      viewModel.saveServer(server);
      
      // 验证结果
      verify(mockRepository.saveServer(any)).called(1);
    });

    test('should delete server successfully', () {
      final server = ServerConfig(
        id: 'test-id',
        name: 'Test Server',
        address: 'test.server.com',
        port: 443,
        protocol: 'vmess',
        settings: {'id': 'test-uuid', 'security': 'auto'}
      );

      // 配置Mock行为
      when(mockRepository.deleteServer('test-id')).thenAnswer((_) async => true);
      when(mockRepository.getAllServers()).thenAnswer((_) async => []);
      
      // 执行测试
      viewModel.deleteServer('test-id');
      
      // 验证结果
      verify(mockRepository.deleteServer('test-id')).called(1);
    });

    test('should update server successfully', () {
      final server = ServerConfig(
        id: 'test-id',
        name: 'Test Server',
        address: 'test.server.com',
        port: 443,
        protocol: 'vmess',
        settings: {'id': 'test-uuid', 'security': 'auto'}
      );

      final updatedServer = ServerConfig(
        id: 'test-id',
        name: 'Updated Server',
        address: 'test.server.com',
        port: 443,
        protocol: 'vmess',
        settings: {'id': 'test-uuid', 'security': 'auto'}
      );

      // 配置Mock行为
      when(mockRepository.saveServer(any)).thenAnswer((_) async => true);
      when(mockRepository.getAllServers()).thenAnswer((_) async => [updatedServer]);
      
      // 执行测试
      viewModel.saveServer(updatedServer);
      
      // 验证结果
      verify(mockRepository.saveServer(any)).called(1);
    });

    test('should notify listeners when server list changes', () {
      var notified = false;
      viewModel.addListener(() {
        notified = true;
      });

      final server = ServerConfig(
        name: 'Test Server',
        address: 'test.server.com',
        port: 443,
        protocol: 'vmess',
        settings: {'id': 'test-uuid', 'security': 'auto'}
      );

      // 配置Mock行为
      when(mockRepository.saveServer(any)).thenAnswer((_) async => true);
      when(mockRepository.getAllServers()).thenAnswer((_) async => [server]);
      
      // 执行测试
      viewModel.saveServer(server);
      
      // 验证结果
      expect(notified, isTrue);
    });
  });
}