import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/models/traffic_history.dart';

void main() {
  group('TrafficHistory模型测试', () {
    test('应该使用有效数据创建TrafficHistory', () {
      final timestamp = DateTime.now();
      final history = TrafficHistory(
        startTime: timestamp,
        endTime: timestamp.add(Duration(hours: 1)),
        uploadTotal: 1024 * 1024 * 100, // 100 MB
        downloadTotal: 1024 * 1024 * 200, // 200 MB
        serverId: 'server-001',
        period: 'hour'
      );

      expect(history.startTime, equals(timestamp));
      expect(history.uploadTotal, equals(1024 * 1024 * 100));
      expect(history.downloadTotal, equals(1024 * 1024 * 200));
      expect(history.serverId, equals('server-001'));
    });

    test('应该正确转换为JSON并从JSON创建', () {
      final startTime = DateTime(2023, 1, 1);
      final endTime = DateTime(2023, 1, 1, 1); // 1小时后
      final history = TrafficHistory(
        startTime: startTime,
        endTime: endTime,
        uploadTotal: 1024 * 1024 * 100, // 100 MB
        downloadTotal: 1024 * 1024 * 200, // 200 MB
        serverId: 'server-001',
        period: 'hour'
      );

      final json = history.toJson();
      final fromJson = TrafficHistory.fromJson(json);

      expect(fromJson.startTime.year, equals(startTime.year));
      expect(fromJson.startTime.month, equals(startTime.month));
      expect(fromJson.startTime.day, equals(startTime.day));
      expect(fromJson.uploadTotal, equals(1024 * 1024 * 100));
      expect(fromJson.downloadTotal, equals(1024 * 1024 * 200));
      expect(fromJson.serverId, equals('server-001'));
    });

    test('应该正确使用copyWith创建更新后的实例', () {
      final startTime = DateTime(2023, 1, 1);
      final endTime = DateTime(2023, 1, 1, 1);
      final history = TrafficHistory(
        startTime: startTime,
        endTime: endTime,
        uploadTotal: 1024 * 1024 * 100, // 100 MB
        downloadTotal: 1024 * 1024 * 200, // 200 MB
        serverId: 'server-001',
        period: 'hour'
      );

      final newStartTime = DateTime(2023, 1, 2);
      final newEndTime = DateTime(2023, 1, 2, 1);
      final updated = history.copyWith(
        startTime: newStartTime,
        endTime: newEndTime,
        uploadTotal: 1024 * 1024 * 150, // 150 MB
      );

      // 验证更新的字段
      expect(updated.startTime, equals(newStartTime));
      expect(updated.endTime, equals(newEndTime));
      expect(updated.uploadTotal, equals(1024 * 1024 * 150));
      
      // 验证未更新的字段保持不变
      expect(updated.downloadTotal, equals(1024 * 1024 * 200));
      expect(updated.serverId, equals('server-001'));
    });

    test('应该处理可选字段的默认值', () {
      final timestamp = DateTime.now();
      final history = TrafficHistory(
        startTime: timestamp,
        endTime: timestamp.add(Duration(hours: 1)),
        uploadTotal: 1024 * 1024 * 100, // 100 MB
        downloadTotal: 1024 * 1024 * 200, // 200 MB
        period: 'hour',
        serverId: 'server-001' // 添加必需的serverId参数
      );

      expect(history.details, isNull);
    });

    test('应该正确计算总流量', () {
      final timestamp = DateTime.now();
      final history = TrafficHistory(
        startTime: timestamp,
        endTime: timestamp.add(Duration(hours: 1)),
        uploadTotal: 1024 * 1024 * 100, // 100 MB
        downloadTotal: 1024 * 1024 * 200, // 200 MB
        period: 'hour',
        serverId: 'server-001' // 添加必需的serverId参数
      );

      // 总流量应该是上传和下载的总和
      final totalTraffic = history.uploadTotal + history.downloadTotal;
      expect(totalTraffic, equals(1024 * 1024 * 300)); // 300 MB
    });
  });
}