import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/models/subscription.dart';

void main() {
  group('Subscription模型测试', () {
    test('应该使用有效数据创建Subscription', () {
      final subscription = Subscription(
        name: '测试订阅',
        url: 'https://example.com/sub',
        autoUpdate: true,
        updateInterval: 12
      );

      expect(subscription.name, equals('测试订阅'));
      expect(subscription.url, equals('https://example.com/sub'));
      expect(subscription.autoUpdate, equals(true));
      expect(subscription.updateInterval, equals(12));
      expect(subscription.id, isNotNull);
      expect(subscription.isUpdating, equals(false));
    });

    test('应该正确转换为JSON并从JSON创建', () {
      final subscription = Subscription(
        id: 'test-id',
        name: '测试订阅',
        url: 'https://example.com/sub',
        autoUpdate: true,
        updateInterval: 12,
        lastUpdateTime: DateTime(2023, 1, 1, 12, 0)
      );

      final json = subscription.toJson();
      final fromJson = Subscription.fromJson(json);

      expect(fromJson.id, equals('test-id'));
      expect(fromJson.name, equals('测试订阅'));
      expect(fromJson.url, equals('https://example.com/sub'));
      expect(fromJson.autoUpdate, equals(true));
      expect(fromJson.updateInterval, equals(12));
      expect(fromJson.lastUpdateTime, equals(DateTime(2023, 1, 1, 12, 0)));
      expect(fromJson.isUpdating, equals(false));
    });

    test('应该正确使用copyWith创建更新后的实例', () {
      final subscription = Subscription(
        id: 'test-id',
        name: '测试订阅',
        url: 'https://example.com/sub',
        autoUpdate: true,
        updateInterval: 12
      );

      final updated = subscription.copyWith(
        name: '更新后的订阅',
        autoUpdate: false,
        lastError: '更新失败'
      );

      // 验证更新的字段
      expect(updated.name, equals('更新后的订阅'));
      expect(updated.autoUpdate, equals(false));
      expect(updated.lastError, equals('更新失败'));
      
      // 验证未更新的字段保持不变
      expect(updated.id, equals('test-id'));
      expect(updated.url, equals('https://example.com/sub'));
      expect(updated.updateInterval, equals(12));
    });

    test('应该处理可选字段的默认值', () {
      final subscription = Subscription(
        name: '测试订阅',
        url: 'https://example.com/sub'
      );

      expect(subscription.autoUpdate, equals(true));
      expect(subscription.updateInterval, equals(24));
      expect(subscription.lastUpdateTime, isNull);
      expect(subscription.lastError, isNull);
    });
  });
}