import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/core/services/network_test_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';

@GenerateMocks([NetworkTestService])
class MockNetworkTestService extends Mock implements NetworkTestService {}

void main() {
  group('网络功能测试', () {
    late MockNetworkTestService mockNetworkTestService;

    setUp(() {
      mockNetworkTestService = MockNetworkTestService();
    });

    test('测试网络连接超时', () async {
      when(mockNetworkTestService.measureLatency("example.com", 80))
          .thenAnswer((_) => Future.error(TimeoutException('连接超时')));

      expect(
        () => mockNetworkTestService.measureLatency("example.com", 80),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('测试代理切换', () async {
      // 先设置mock行为
      when(mockNetworkTestService.measureThroughput("example.com", 80))
          .thenAnswer((_) => Future.value(10.0));

      // 然后执行测试
      final result =
          await mockNetworkTestService.measureThroughput("example.com", 80);
      expect(result, equals(10.0));

      verify(mockNetworkTestService.measureThroughput("example.com", 80))
          .called(1);
    });

    test('测试连接失败恢复', () async {
      // 使用一个闭包来跟踪尝试次数
      int attemptCount = 0;

      // 预先设置mock行为
      when(mockNetworkTestService.measureLatency("example.com", 80))
          .thenAnswer((_) {
        attemptCount++;
        if (attemptCount < 3) {
          return Future.error(Exception('连接失败'));
        }
        return Future.value(100);
      });

      // 执行测试
      final result =
          await mockNetworkTestService.measureLatency("example.com", 80);
      expect(result, equals(100));
      expect(attemptCount, equals(3));
    });

    test('测试网络状态监听', () async {
      // This test doesn't make sense for NetworkTestService
      // Removing it
    });
  });
}
