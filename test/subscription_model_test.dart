import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/models/subscription_model.dart';

void main() {
  group('SubscriptionModel Tests', () {
    test('fromJson and toJson', () {
      final now = DateTime.now();
      final model = SubscriptionModel(
        name: 'Test Sub',
        url: 'https://example.com/sub',
        enabled: true,
        lastUpdate: now,
        updateInterval: const Duration(hours: 12),
      );

      final json = model.toJson();
      final decoded = SubscriptionModel.fromJson(json);

      expect(decoded.name, equals('Test Sub'));
      expect(decoded.url, equals('https://example.com/sub'));
      expect(decoded.enabled, isTrue);
      expect(decoded.lastUpdate?.toIso8601String(), equals(now.toIso8601String()));
      expect(decoded.updateInterval.inHours, equals(12));
    });

    test('validateUrl with valid URLs', () {
      final validUrls = [
        'http://example.com',
        'https://sub.example.com/path',
        'http://localhost:8080',
      ];

      for (final url in validUrls) {
        final model = SubscriptionModel(name: 'Test', url: url);
        expect(model.validateUrl(), isTrue, reason: 'URL should be valid: $url');
      }
    });

    test('validateUrl with invalid URLs', () {
      final invalidUrls = [
        'ftp://example.com',
        'not-a-url',
        '',
        'file:///path',
      ];

      for (final url in invalidUrls) {
        final model = SubscriptionModel(name: 'Test', url: url);
        expect(model.validateUrl(), isFalse, reason: 'URL should be invalid: $url');
      }
    });

    group('needsUpdate scenarios', () {
      final now = DateTime.now();
      
      test('disabled subscription', () {
        final model = SubscriptionModel(
          name: 'Test',
          url: 'https://example.com',
          enabled: false,
          lastUpdate: now,
        );
        expect(model.needsUpdate(), isFalse);
      });

      test('never updated', () {
        final model = SubscriptionModel(
          name: 'Test',
          url: 'https://example.com',
          enabled: true,
          lastUpdate: null,
        );
        expect(model.needsUpdate(), isTrue);
      });

      test('recently updated', () {
        final model = SubscriptionModel(
          name: 'Test',
          url: 'https://example.com',
          enabled: true,
          lastUpdate: now,
          updateInterval: const Duration(hours: 24),
        );
        expect(model.needsUpdate(), isFalse);
      });

      test('update needed', () {
        final model = SubscriptionModel(
          name: 'Test',
          url: 'https://example.com',
          enabled: true,
          lastUpdate: now.subtract(const Duration(hours: 25)),
          updateInterval: const Duration(hours: 24),
        );
        expect(model.needsUpdate(), isTrue);
      });
    });
  });
}