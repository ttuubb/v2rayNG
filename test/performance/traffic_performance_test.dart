import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:v2rayng/viewmodels/traffic_viewmodel.dart';
import 'package:v2rayng/models/traffic_stats.dart';
import 'package:v2rayng/models/traffic_history.dart';
import 'package:v2rayng/core/event_bus.dart';
import './performance_test_framework.dart';
import './test_service_locator.dart';

void main() {
  group('流量统计性能测试', () {
    late TrafficViewModel trafficViewModel;
    late EventBus eventBus;
    
    setUp(() async {
      // 初始化依赖注入
      await setupServiceLocator();
      trafficViewModel = GetIt.I<TrafficViewModel>();
      eventBus = GetIt.I<EventBus>();
    });
    
    tearDown(() {
      GetIt.I.reset();
    });
    
    test('实时流量统计性能测试', () async {
      // 测量处理大量流量统计事件的性能
      final processResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          // 模拟1000次流量统计更新事件
          for (int i = 0; i < 1000; i++) {
            eventBus.fire(TrafficStatsUpdatedEvent(
              uploadSpeed: 100.0 + i,
              downloadSpeed: 200.0 + i,
              totalUpload: 1000 + i * 100,
              totalDownload: 2000 + i * 200,
            ));
            // 添加小延迟以模拟真实场景
            await Future.delayed(Duration(milliseconds: 1));
          }
        },
        description: '处理1000次流量统计更新事件'
      );
      
      print(processResult);
      expect(processResult.success, true);
      
      // 验证最新的流量统计数据是否正确
      expect(trafficViewModel.currentStats, isNotNull);
      expect(trafficViewModel.currentStats!.uploadSpeed, greaterThan(0.0));
      expect(trafficViewModel.currentStats!.downloadSpeed, greaterThan(0.0));
    });
    
    test('流量历史记录性能测试', () async {
      // 准备测试数据 - 创建大量历史记录
      final historyRecords = List.generate(1000, (index) => TrafficHistory(
        serverId: 'test-server-${index % 10}',
        startTime: DateTime.now().subtract(Duration(days: index + 1)),
        endTime: DateTime.now().subtract(Duration(days: index)),
        uploadTotal: 1024 * 1024 * index,
        downloadTotal: 2048 * 1024 * index,
        period: 'day'
      ));
      
      // 测量批量保存历史记录的性能
      final saveResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          for (final record in historyRecords) {
            await trafficViewModel.saveTrafficHistory(record);
          }
        },
        description: '保存1000条流量历史记录'
      );
      
      print(saveResult);
      expect(saveResult.success, true);
      
      // 测量加载历史记录的性能
      final loadResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          await trafficViewModel.loadTrafficHistory('test-server-1');
        },
        description: '加载单个服务器的流量历史记录'
      );
      
      print(loadResult);
      expect(loadResult.success, true);
      
      // 测量统计分析的性能
      final analysisResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          await trafficViewModel.generateTrafficReport('test-server-1', 
            DateTime.now().subtract(Duration(days: 30)), 
            DateTime.now()
          );
        },
        description: '生成30天流量统计报告'
      );
      
      print(analysisResult);
      expect(analysisResult.success, true);
    });
    
    test('多服务器流量聚合性能测试', () async {
      // 测量多服务器流量聚合计算的性能
      final aggregateResult = await PerformanceTestFramework.measureExecutionTime(
        () async {
          // 模拟10个服务器同时产生流量数据
          for (int i = 0; i < 10; i++) {
            final serverId = 'test-server-$i';
            for (int j = 0; j < 100; j++) {
              eventBus.fire(TrafficStatsUpdatedEvent(
                uploadSpeed: 50.0 * i + j,
                downloadSpeed: 100.0 * i + j,
                totalUpload: 500 * i + j * 50,
                totalDownload: 1000 * i + j * 100,
                serverId: serverId
              ));
              // 添加小延迟以模拟真实场景
              await Future.delayed(Duration(milliseconds: 1));
            }
          }
          
          // 计算聚合流量
          await trafficViewModel.calculateAggregateTraffic();
        },
        description: '10个服务器各产生100次流量数据并聚合计算'
      );
      
      print(aggregateResult);
      expect(aggregateResult.success, true);
    });
  });
}

// 模拟流量统计更新事件
class TrafficStatsUpdatedEvent {
  final double uploadSpeed;
  final double downloadSpeed;
  final int totalUpload;
  final int totalDownload;
  final String? serverId;
  
  TrafficStatsUpdatedEvent({
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.totalUpload,
    required this.totalDownload,
    this.serverId,
  });
}