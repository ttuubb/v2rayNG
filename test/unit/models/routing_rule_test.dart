import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/models/routing_rule.dart';

void main() {
  group('RoutingRule模型测试', () {
    test('应该使用有效数据创建RoutingRule', () {
      final rule = RoutingRule(
        tag: 'test-rule',
        domain: ['example.com', '*.google.com'],
        ip: ['192.168.1.1', '10.0.0.0/8'],
        outboundTag: 'proxy'
      );

      expect(rule.tag, equals('test-rule'));
      expect(rule.type, equals('field')); // 默认值
      expect(rule.domain, equals(['example.com', '*.google.com']));
      expect(rule.ip, equals(['192.168.1.1', '10.0.0.0/8']));
      expect(rule.outboundTag, equals('proxy'));
      expect(rule.enabled, isTrue); // 默认值
    });

    test('应该正确转换为JSON并从JSON创建', () {
      final rule = RoutingRule(
        tag: 'test-rule',
        type: 'field',
        domain: ['example.com', '*.google.com'],
        ip: ['192.168.1.1', '10.0.0.0/8'],
        outboundTag: 'proxy',
        enabled: true
      );

      final json = rule.toJson();
      final fromJson = RoutingRule.fromJson(json);

      expect(fromJson.tag, equals('test-rule'));
      expect(fromJson.type, equals('field'));
      expect(fromJson.domain, equals(['example.com', '*.google.com']));
      expect(fromJson.ip, equals(['192.168.1.1', '10.0.0.0/8']));
      expect(fromJson.outboundTag, equals('proxy'));
      expect(fromJson.enabled, isTrue);
    });

    test('应该正确使用copyWith创建更新后的实例', () {
      final rule = RoutingRule(
        tag: 'test-rule',
        domain: ['example.com'],
        ip: ['192.168.1.1'],
        outboundTag: 'proxy',
        enabled: true
      );

      final updated = rule.copyWith(
        domain: ['updated.com', '*.updated.org'],
        outboundTag: 'direct',
        enabled: false
      );

      // 验证更新的字段
      expect(updated.domain, equals(['updated.com', '*.updated.org']));
      expect(updated.outboundTag, equals('direct'));
      expect(updated.enabled, isFalse);
      
      // 验证未更新的字段保持不变
      expect(updated.tag, equals('test-rule'));
      expect(updated.type, equals('field'));
      expect(updated.ip, equals(['192.168.1.1']));
    });

    test('应该处理空列表字段', () {
      final rule = RoutingRule(
        tag: 'empty-rule',
        outboundTag: 'direct'
      );

      expect(rule.domain, isEmpty);
      expect(rule.ip, isEmpty);
    });

    test('应该处理可选字段的默认值', () {
      final rule = RoutingRule(
        tag: 'default-rule',
        outboundTag: 'proxy'
      );

      expect(rule.type, equals('field'));
      expect(rule.enabled, isTrue);
    });
  });
}