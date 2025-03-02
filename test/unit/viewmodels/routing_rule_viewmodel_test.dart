import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:v2rayng/core/services/local_storage.dart';
import 'package:v2rayng/models/routing_rule.dart';
import 'package:v2rayng/viewmodels/routing_rule_viewmodel.dart';

// 生成Mock类
@GenerateMocks([LocalStorage])
import 'routing_rule_viewmodel_test.mocks.dart';

void main() {
  group('RoutingRuleViewModel单元测试', () {
    late MockLocalStorage mockStorage;
    late RoutingRuleViewModel viewModel;
    
    setUp(() {
      // 创建Mock对象
      mockStorage = MockLocalStorage();
      
      // 创建ViewModel实例
      viewModel = RoutingRuleViewModel(mockStorage);
    });
    
    test('初始状态测试', () {
      // 验证初始状态
      expect(viewModel.rules, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNull);
    });
    
    test('加载路由规则测试', () async {
      // 准备测试数据
      final testRules = [
        RoutingRule(
          tag: 'rule1',
          domain: ['example.com', '*.google.com'],
          ip: [],
          outboundTag: 'proxy',
          enabled: true
        ),
        RoutingRule(
          tag: 'rule2',
          domain: [],
          ip: ['192.168.1.1', '10.0.0.0/8'],
          outboundTag: 'direct',
          enabled: false
        ),
      ];
      
      // 配置Mock行为
      when(mockStorage.getItem('routing_rules'))
          .thenAnswer((_) async => testRules.map((r) => r.toJson()).toList());
      
      // 执行测试
      await viewModel.loadRules();
      
      // 验证结果
      expect(viewModel.rules.length, equals(2));
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNull);
      verify(mockStorage.getItem('routing_rules')).called(1);
    });
    
    test('保存路由规则测试', () async {
      // 准备测试数据
      final newRule = RoutingRule(
        tag: 'new-rule',
        domain: ['example.org'],
        ip: ['192.168.0.1'],
        outboundTag: 'proxy',
        enabled: true
      );
      
      // 配置Mock行为
      when(mockStorage.getItem('routing_rules'))
          .thenAnswer((_) async => []);
      when(mockStorage.setItem('routing_rules', any))
          .thenAnswer((_) async => true);
      
      // 加载初始空规则列表
      await viewModel.loadRules();
      
      // 执行测试 - 添加新规则
      await viewModel.saveRule(newRule);
      
      // 验证结果
      expect(viewModel.rules.length, 1);
      expect(viewModel.rules.first.tag, 'new-rule');
      verify(mockStorage.setItem('routing_rules', any)).called(1);
    });
    
    test('更新路由规则测试', () async {
      // 准备测试数据
      final initialRule = RoutingRule(
        tag: 'test-rule',
        domain: ['example.com'],
        ip: [],
        outboundTag: 'proxy',
        enabled: true
      );
      
      final updatedRule = RoutingRule(
        tag: 'test-rule', // 相同的tag表示更新
        domain: ['example.com', 'updated.com'],
        ip: ['192.168.1.1'],
        outboundTag: 'direct', // 修改了出站标签
        enabled: false // 修改了启用状态
      );
      
      // 配置Mock行为
      when(mockStorage.getItem('routing_rules'))
          .thenAnswer((_) async => [initialRule.toJson()]);
      when(mockStorage.setItem('routing_rules', any))
          .thenAnswer((_) async => true);
      
      // 加载初始规则
      await viewModel.loadRules();
      expect(viewModel.rules.length, 1);
      expect(viewModel.rules.first.outboundTag, 'proxy');
      
      // 执行测试 - 更新规则
      await viewModel.saveRule(updatedRule);
      
      // 验证结果
      expect(viewModel.rules.length, 1); // 数量不变
      expect(viewModel.rules.first.tag, 'test-rule');
      expect(viewModel.rules.first.outboundTag, 'direct'); // 验证更新
      expect(viewModel.rules.first.enabled, false); // 验证更新
      expect(viewModel.rules.first.domain.length, 2); // 验证更新
      expect(viewModel.rules.first.ip.length, 1); // 验证更新
      verify(mockStorage.setItem('routing_rules', any)).called(1);
    });
    
    test('删除路由规则测试', () async {
      // 准备测试数据
      final rule1 = RoutingRule(
        tag: 'rule1',
        domain: ['example.com'],
        ip: [],
        outboundTag: 'proxy',
        enabled: true
      );
      
      final rule2 = RoutingRule(
        tag: 'rule2',
        domain: [],
        ip: ['192.168.1.1'],
        outboundTag: 'direct',
        enabled: true
      );
      
      // 配置Mock行为
      when(mockStorage.getItem('routing_rules'))
          .thenAnswer((_) async => [rule1.toJson(), rule2.toJson()]);
      when(mockStorage.setItem('routing_rules', any))
          .thenAnswer((_) async => true);
      
      // 加载初始规则
      await viewModel.loadRules();
      expect(viewModel.rules.length, 2);
      
      // 执行测试 - 删除规则
      await viewModel.deleteRule('rule1');
      
      // 验证结果
      expect(viewModel.rules.length, 1);
      expect(viewModel.rules.first.tag, 'rule2');
      verify(mockStorage.setItem('routing_rules', any)).called(1);
    });
    
    test('启用/禁用路由规则测试', () async {
      // 准备测试数据
      final rule = RoutingRule(
        tag: 'test-rule',
        domain: ['example.com'],
        ip: [],
        outboundTag: 'proxy',
        enabled: true
      );
      
      // 配置Mock行为
      when(mockStorage.getItem('routing_rules'))
          .thenAnswer((_) async => [rule.toJson()]);
      when(mockStorage.setItem('routing_rules', any))
          .thenAnswer((_) async => true);
      
      // 加载初始规则
      await viewModel.loadRules();
      expect(viewModel.rules.first.enabled, true);
      
      // 执行测试 - 禁用规则
      await viewModel.toggleRuleEnabled('test-rule');
      
      // 验证结果
      expect(viewModel.rules.first.enabled, false);
      verify(mockStorage.setItem('routing_rules', any)).called(1);
      
      // 重置mock计数器
      reset(mockStorage);
      when(mockStorage.setItem('routing_rules', any))
          .thenAnswer((_) async => true);
      
      // 执行测试 - 重新启用规则
      await viewModel.toggleRuleEnabled('test-rule');
      
      // 验证结果
      expect(viewModel.rules.first.enabled, true);
      verify(mockStorage.setItem('routing_rules', any)).called(1);
    });
    
    test('导入导出路由规则测试', () async {
      // 准备测试数据
      final rules = [
        RoutingRule(
          tag: 'rule1',
          domain: ['example.com'],
          ip: [],
          outboundTag: 'proxy',
          enabled: true
        ),
        RoutingRule(
          tag: 'rule2',
          domain: [],
          ip: ['192.168.1.1'],
          outboundTag: 'direct',
          enabled: true
        ),
      ];
      
      // 配置Mock行为
      when(mockStorage.getItem('routing_rules'))
          .thenAnswer((_) async => []);
      when(mockStorage.setItem('routing_rules', any))
          .thenAnswer((_) async => true);
      
      // 加载初始空规则列表
      await viewModel.loadRules();
      expect(viewModel.rules.isEmpty, true);
      
      // 执行测试 - 导入规则
      final jsonStr = '[{"tag":"rule1","type":"field","domain":["example.com"],"ip":[],"outboundTag":"proxy","enabled":true},{"tag":"rule2","type":"field","domain":[],"ip":["192.168.1.1"],"outboundTag":"direct","enabled":true}]';
      
      // 手动解析JSON并添加规则
      final List<dynamic> ruleJsonList = jsonDecode(jsonStr);
      for (var ruleJson in ruleJsonList) {
        final rule = RoutingRule.fromJson(ruleJson as Map<String, dynamic>);
        await viewModel.saveRule(rule);
      }
      
      // 验证结果
      expect(viewModel.rules.length, 2);
      expect(viewModel.rules[0].tag, 'rule1');
      expect(viewModel.rules[1].tag, 'rule2');
      verify(mockStorage.setItem('routing_rules', any)).called(rules.length);
      
      // 执行测试 - 导出规则（手动构建JSON）
      final exportedJson = jsonEncode(viewModel.rules.map((r) => r.toJson()).toList());
      
      // 验证结果
      expect(exportedJson, isNotNull);
      expect(exportedJson.contains('"tag":"rule1"'), true);
      expect(exportedJson.contains('"tag":"rule2"'), true);
    });
  });
}