import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/models/traffic_stats.dart';

void main() {
  group('TrafficStats模型测试', () {
    test('应该使用有效数据创建TrafficStats', () {
      final timestamp = DateTime.now();
      final stats = TrafficStats(
        uploadSpeed: 1024.5,
        downloadSpeed: 2048.75,
        totalUpload: 10240,
        totalDownload: 20480,
        timestamp: timestamp,
        serverId: 'server-001'
      );

      expect(stats.uploadSpeed, equals(1024.5));
      expect(stats.downloadSpeed, equals(2048.75));
      expect(stats.totalUpload, equals(10240));
      expect(stats.totalDownload, equals(20480));
      expect(stats.timestamp, equals(timestamp));
      expect(stats.serverId, equals('server-001'));
    });

    test('应该正确转换为JSON并从JSON创建', () {
      final timestamp = DateTime(2023, 1, 1, 12, 0);
      final stats = TrafficStats(
        uploadSpeed: 1024.5,
        downloadSpeed: 2048.75,
        totalUpload: 10240,
        totalDownload: 20480,
        timestamp: timestamp,
        serverId: 'server-001'
      );

      final json = stats.toJson();
      final fromJson = TrafficStats.fromJson(json);

      expect(fromJson.uploadSpeed, equals(1024.5));
      expect(fromJson.downloadSpeed, equals(2048.75));
      expect(fromJson.totalUpload, equals(10240));
      expect(fromJson.totalDownload, equals(20480));
      expect(fromJson.timestamp.millisecondsSinceEpoch, equals(timestamp.millisecondsSinceEpoch));
      expect(fromJson.serverId, equals('server-001'));
    });

    test('应该正确使用copyWith创建更新后的实例', () {
      final timestamp = DateTime(2023, 1, 1, 12, 0);
      final stats = TrafficStats(
        uploadSpeed: 1024.5,
        downloadSpeed: 2048.75,
        totalUpload: 10240,
        totalDownload: 20480,
        timestamp: timestamp,
        serverId: 'server-001'
      );

      final newTimestamp = DateTime(2023, 1, 1, 12, 30);
      final updated = stats.copyWith(
        uploadSpeed: 2000.0,
        totalUpload: 15000,
        timestamp: newTimestamp
      );

      // 验证更新的字段
      expect(updated.uploadSpeed, equals(2000.0));
      expect(updated.totalUpload, equals(15000));
      expect(updated.timestamp, equals(newTimestamp));
      
      // 验证未更新的字段保持不变
      expect(updated.downloadSpeed, equals(2048.75));
      expect(updated.totalDownload, equals(20480));
      expect(updated.serverId, equals('server-001'));
    });

    test('应该处理可选字段的默认值', () {
      final timestamp = DateTime.now();
      final stats = TrafficStats(
        uploadSpeed: 1024.5,
        downloadSpeed: 2048.75,
        totalUpload: 10240,
        totalDownload: 20480,
        timestamp: timestamp
      );

      expect(stats.serverId, isNull);
    });

    test('应该正确计算流量单位转换', () {
      final timestamp = DateTime.now();
      final stats = TrafficStats(
        uploadSpeed: 1024 * 1024.0, // 1 MB/s
        downloadSpeed: 1024 * 1024 * 2.5, // 2.5 MB/s
        totalUpload: 1024 * 1024 * 1024, // 1 GB
        totalDownload: 1024 * 1024 * 1024 * 2, // 2 GB
        timestamp: timestamp
      );

      // 这里可以添加流量单位转换的测试，如果模型中有这样的方法
      // 例如：expect(stats.getUploadSpeedMbps(), closeTo(8.0, 0.01)); // 8 Mbps
    });
  });
}