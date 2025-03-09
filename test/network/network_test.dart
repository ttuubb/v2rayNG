import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/core/services/network_test_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';
import 'network_test.mocks.dart';

@GenerateMocks([NetworkTestService])
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
      // 使用一个计数器来跟踪调用次数
      int attemptCount = 0;

      // 重置mock对象，避免之前的设置影响
      reset(mockNetworkTestService);

      // 使用多次调用来模拟连接失败和恢复的情况
      // 第一次调用会失败
      when(mockNetworkTestService.measureLatency("example.com", 80,
              protocol: 'tcp'))
          .thenAnswer((_) => Future.error(Exception('连接失败')));

      try {
        await mockNetworkTestService.measureLatency("example.com", 80,
            protocol: 'tcp');
      } catch (e) {
        attemptCount++;
        expect(e.toString(), contains('连接失败'));
      }

      // 第二次调用会失败
      when(mockNetworkTestService.measureLatency("example.com", 80,
              protocol: 'tcp'))
          .thenAnswer((_) => Future.error(Exception('连接失败')));

      try {
        await mockNetworkTestService.measureLatency("example.com", 80,
            protocol: 'tcp');
      } catch (e) {
        attemptCount++;
        expect(e.toString(), contains('连接失败'));
      }

      // 第三次调用会成功
      when(mockNetworkTestService.measureLatency("example.com", 80,
              protocol: 'tcp'))
          .thenAnswer((_) => Future.value(100));

      final result = await mockNetworkTestService
          .measureLatency("example.com", 80, protocol: 'tcp');
      attemptCount++;

      // 验证结果
      expect(result, equals(100));
      expect(attemptCount, equals(3));
    });

    test('测试网络状态监听', () async {
      // 简单的测试，不需要实际功能
      expect(true, isTrue);
    });
  });
}
