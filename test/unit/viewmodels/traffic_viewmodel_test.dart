import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';
import 'package:v2rayng/core/event_bus.dart';
import 'package:v2rayng/core/events/app_events.dart';
import 'package:v2rayng/core/services/traffic_service.dart';
import 'package:v2rayng/models/traffic_stats.dart';
import 'package:v2rayng/models/traffic_history.dart';
import 'package:v2rayng/viewmodels/traffic_viewmodel.dart';

// 生成Mock类
@GenerateMocks([TrafficService, EventBus])
import 'traffic_viewmodel_test.mocks.dart';

void main() {
  group('TrafficViewModel单元测试', () {
    late MockTrafficService mockTrafficService;
    late MockEventBus mockEventBus;
    late TrafficViewModel viewModel;
    late StreamController<TrafficStatsUpdatedEvent> statsStreamController;
    
    setUp(() {
      // 创建Mock对象
      mockTrafficService = MockTrafficService();
      mockEventBus = MockEventBus();
      
      // 设置Stream控制器
      statsStreamController = StreamController<TrafficStatsUpdatedEvent>.broadcast();
      
      // 配置Mock行为
      when(mockEventBus.on<TrafficStatsUpdatedEvent>()).thenAnswer((_) => statsStreamController.stream);
      
      // 创建ViewModel实例
      viewModel = TrafficViewModel(mockTrafficService, mockEventBus);
    });
    
    tearDown(() {
      // 清理资源
      statsStreamController.close();
    });
    
    test('初始状态测试', () {
      // 验证初始状态
      expect(viewModel.currentStats, isNull);
      expect(viewModel.history, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNull);
    });
    
    test('加载流量统计数据测试', () async {
      // 准备测试数据
      final testStats = TrafficStats(
        uploadSpeed: 1024.0,
        downloadSpeed: 2048.0,
        totalUpload: 10240,
        totalDownload: 20480,
        timestamp: DateTime.now(),
        serverId: 'server-001'
      );
      
      // 配置Mock行为
      when(mockTrafficService.getCurrentStats('server-001'))
          .thenAnswer((_) => testStats);
      
      // 模拟流量更新事件
      final event = TrafficStatsUpdatedEvent(
        uploadSpeed: 1024.0,
        downloadSpeed: 2048.0,
        totalUpload: 10240,
        totalDownload: 20480
      );
      
      statsStreamController.add(event);
      
      // 等待异步处理完成
      await Future.delayed(Duration.zero);
      
      // 验证结果
      expect(viewModel.currentStats, isNotNull);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNull);
    });
    
    test('加载流量历史记录测试', () async {
      // 准备测试数据
      final now = DateTime.now();
      final testHistory = [
        TrafficHistory(
          uploadTotal: 1024 * 1024 * 100,
          downloadTotal: 1024 * 1024 * 200,
          serverId: 'server-001',
          startTime: now.subtract(Duration(hours: 1)),
          endTime: now,
          period: 'hour'
        ),
        TrafficHistory(
          uploadTotal: 1024 * 1024 * 150,
          downloadTotal: 1024 * 1024 * 250,
          serverId: 'server-001',
          startTime: now.subtract(Duration(hours: 2)),
          endTime: now.subtract(Duration(hours: 1)),
          period: 'hour'
        ),
      ];
      
      // 配置Mock行为
      when(mockTrafficService.getTrafficHistory('server-001'))
          .thenAnswer((_) async => testHistory);
      
      // 执行测试
      await viewModel.loadTrafficHistory('server-001');
      
      // 验证结果
      expect(viewModel.history.length, equals(2));
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNull);
      verify(mockTrafficService.getTrafficHistory('server-001')).called(1);
    });
    
    test('清除流量历史数据测试', () async {
      // 准备测试数据
      final now = DateTime.now();
      final testHistory = [
        TrafficHistory(
          uploadTotal: 1024 * 1024 * 100,
          downloadTotal: 1024 * 1024 * 200,
          serverId: 'server-001',
          startTime: now.subtract(Duration(hours: 1)),
          endTime: now,
          period: 'hour'
        ),
      ];
      
      // 配置Mock行为
      when(mockTrafficService.getTrafficHistory('server-001'))
          .thenAnswer((_) async => testHistory);
      when(mockTrafficService.clearTrafficHistory('server-001'))
          .thenAnswer((_) async => {});
      
      // 先加载数据
      await viewModel.loadTrafficHistory('server-001');
      expect(viewModel.history.length, 1);
      
      // 执行清除操作
      await viewModel.clearTrafficHistory('server-001');
      
      // 验证结果
      verify(mockTrafficService.clearTrafficHistory('server-001')).called(1);
      expect(viewModel.history, isEmpty);
    });
  });
}

// 注意：使用从 app_events.dart 导入的 TrafficStatsUpdatedEvent 类