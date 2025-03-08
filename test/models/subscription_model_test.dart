import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/models/subscription_model.dart';

void main() {
  group('SubscriptionModel Tests', () {
    test('订阅模型序列化测试', () {
      final subscription = SubscriptionModel(
        name: 'Test Sub',
        url: 'https://example.com/sub',
        enabled: true,
        lastUpdate: DateTime(2024, 1, 1),
        updateInterval: const Duration(hours: 24),
      );

      final json = subscription.toJson();
      final decodedSub = SubscriptionModel.fromJson(json);

      expect(decodedSub.name, equals('Test Sub'));
      expect(decodedSub.url, equals('https://example.com/sub'));
      expect(decodedSub.enabled, isTrue);
      expect(decodedSub.lastUpdate, equals(DateTime(2024, 1, 1)));
      expect(decodedSub.updateInterval, equals(const Duration(hours: 24)));
    });

    test('订阅URL验证测试', () {
      final validSub = SubscriptionModel(
        name: 'Valid Sub',
        url: 'https://example.com/sub',
        enabled: true,
      );
      expect(validSub.validateUrl(), isTrue);

      final invalidSub = SubscriptionModel(
        name: 'Invalid Sub',
        url: 'not-a-url',
        enabled: true,
      );
      expect(invalidSub.validateUrl(), isFalse);
    });

    test('订阅更新时间检查测试', () {
      final subscription = SubscriptionModel(
        name: 'Test Sub',
        url: 'https://example.com/sub',
        enabled: true,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 25)),
        updateInterval: const Duration(hours: 24),
      );

      expect(subscription.needsUpdate(), isTrue);

      final recentlyUpdatedSub = SubscriptionModel(
        name: 'Recent Sub',
        url: 'https://example.com/sub',
        enabled: true,
        lastUpdate: DateTime.now(),
        updateInterval: const Duration(hours: 24),
      );

      expect(recentlyUpdatedSub.needsUpdate(), isFalse);
    });

    test('订阅禁用状态测试', () {
      final disabledSub = SubscriptionModel(
        name: 'Disabled Sub',
        url: 'https://example.com/sub',
        enabled: false,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 25)),
        updateInterval: const Duration(hours: 24),
      );

      // 即使超过更新间隔，禁用的订阅也不应该更新
      expect(disabledSub.needsUpdate(), isFalse);
    });
  });
}