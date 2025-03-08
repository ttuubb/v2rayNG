import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/services/subscription_service.dart';
import 'package:v2rayng/models/subscription_model.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('SubscriptionService Tests', () {
    late SubscriptionService subscriptionService;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      subscriptionService = SubscriptionService(httpClient: mockHttpClient);
    });

    test('订阅更新测试 - 成功场景', () async {
      final subscription = SubscriptionModel(
        name: 'Test Sub',
        url: 'https://example.com/sub',
        lastUpdated: DateTime.now(),
      );

      final mockResponse = http.Response(
        'vmess://example',
        200,
      );

      when(mockHttpClient.get(Uri.parse(subscription.url)))
          .thenAnswer((_) async => mockResponse);

      final result = await subscriptionService.updateSubscription(subscription);
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotEmpty);
    });

    test('订阅更新测试 - 网络错误', () async {
      final subscription = SubscriptionModel(
        name: 'Test Sub',
        url: 'https://example.com/sub',
        lastUpdated: DateTime.now(),
      );

      when(mockHttpClient.get(Uri.parse(subscription.url)))
          .thenThrow(Exception('Network error'));

      final result = await subscriptionService.updateSubscription(subscription);
      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
    });

    test('订阅更新测试 - 无效响应', () async {
      final subscription = SubscriptionModel(
        name: 'Test Sub',
        url: 'https://example.com/sub',
        lastUpdated: DateTime.now(),
      );

      final mockResponse = http.Response(
        'invalid content',
        200,
      );

      when(mockHttpClient.get(Uri.parse(subscription.url)))
          .thenAnswer((_) async => mockResponse);

      final result = await subscriptionService.updateSubscription(subscription);
      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
    });

    test('订阅更新测试 - 服务器错误', () async {
      final subscription = SubscriptionModel(
        name: 'Test Sub',
        url: 'https://example.com/sub',
        lastUpdated: DateTime.now(),
      );

      final mockResponse = http.Response(
        'Server Error',
        500,
      );

      when(mockHttpClient.get(Uri.parse(subscription.url)))
          .thenAnswer((_) async => mockResponse);

      final result = await subscriptionService.updateSubscription(subscription);
      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
    });
  });
}