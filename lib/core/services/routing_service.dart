import 'dart:async';
import '../event_bus.dart';
import '../../models/routing_rule.dart';
import './local_storage.dart';

/// 路由规则服务接口
/// 负责管理V2ray的路由规则，包括规则的增删改查、导入导出、
/// 启用禁用等功能，以及规则冲突检测和事件通知
abstract class RoutingService {
  /// 获取所有路由规则
  /// 返回系统中配置的所有路由规则列表
  Future<List<RoutingRule>> getAllRules();

  /// 获取启用的路由规则
  /// 返回当前已启用的路由规则列表
  Future<List<RoutingRule>> getEnabledRules();

  /// 保存路由规则
  /// 
  /// [rule] 要保存的路由规则对象
  /// 如果规则已存在则更新，否则新增
  Future<void> saveRule(RoutingRule rule);

  /// 删除路由规则
  /// 
  /// [tag] 要删除的规则标识
  Future<void> deleteRule(String tag);

  /// 启用/禁用路由规则
  /// 
  /// [tag] 规则标识
  /// [enabled] 是否启用
  Future<void> toggleRuleStatus(String tag, bool enabled);

  /// 导入路由规则
  /// 
  /// [rules] 要导入的规则列表
  /// [overwrite] 是否覆盖已存在的规则
  /// 返回成功导入的规则数量
  Future<int> importRules(List<RoutingRule> rules, bool overwrite);

  /// 导出路由规则
  /// 将当前所有路由规则导出为JSON格式
  Future<List<Map<String, dynamic>>> exportRules();

  /// 检查规则冲突
  /// 
  /// [rule] 要检查的规则
  /// [existingRules] 已存在的规则列表
  /// 返回与给定规则存在冲突的规则列表
  List<RoutingRule> checkRuleConflicts(RoutingRule rule, List<RoutingRule> existingRules);

  /// 获取路由规则变更流
  /// 用于监听规则变更事件
  Stream<RoutingRuleEvent> get ruleEventStream;
}

/// 路由规则服务实现类
class RoutingServiceImpl implements RoutingService {
  /// 事件总线，用于发布全局事件
  final EventBus _eventBus;
  /// 本地存储服务，用于持久化规则数据
  final LocalStorage _storage;
  /// 规则事件控制器，用于发布规则相关事件
  final _ruleEventController = StreamController<RoutingRuleEvent>.broadcast();

  RoutingServiceImpl(this._eventBus, this._storage);

  @override
  Future<List<RoutingRule>> getAllRules() async {
    try {
      // 从本地存储获取规则数据
      final data = await _storage.getItem('routing_rules');
      if (data != null) {
        // 将JSON数据转换为RoutingRule对象列表
        return (data as List)
            .map((json) => RoutingRule.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      // 发生错误时返回空列表
      return [];
    }
  }

  @override
  Future<List<RoutingRule>> getEnabledRules() async {
    // 获取所有规则并过滤出已启用的规则
    final allRules = await getAllRules();
    return allRules.where((rule) => rule.enabled).toList();
  }

  @override
  Future<void> saveRule(RoutingRule rule) async {
    final rules = await getAllRules();
    final index = rules.indexWhere((r) => r.tag == rule.tag);
    
    if (index >= 0) {
      // 更新现有规则
      rules[index] = rule;
      _ruleEventController.add(RoutingRuleUpdatedEvent(rule));
    } else {
      // 添加新规则
      rules.add(rule);
      _ruleEventController.add(RoutingRuleAddedEvent(rule));
    }
    
    // 保存规则到本地存储
    await _storage.setItem('routing_rules', rules.map((r) => r.toJson()).toList());
    
    // 发送全局规则变更事件
    _eventBus.emit(RoutingRulesChangedEvent(rules));
  }

  @override
  Future<void> deleteRule(String tag) async {
    final rules = await getAllRules();
    final index = rules.indexWhere((r) => r.tag == tag);
    
    if (index >= 0) {
      // 删除指定规则
      final deletedRule = rules.removeAt(index);
      // 更新本地存储
      await _storage.setItem('routing_rules', rules.map((r) => r.toJson()).toList());
      
      // 发送规则删除事件
      _ruleEventController.add(RoutingRuleDeletedEvent(deletedRule));
      
      // 发送全局规则变更事件
      _eventBus.emit(RoutingRulesChangedEvent(rules));
    }
  }

  @override
  Future<void> toggleRuleStatus(String tag, bool enabled) async {
    final rules = await getAllRules();
    final index = rules.indexWhere((r) => r.tag == tag);
    
    if (index >= 0) {
      final rule = rules[index];
      final updatedRule = rule.copyWith(enabled: enabled);
      rules[index] = updatedRule;
      
      await _storage.setItem('routing_rules', rules.map((r) => r.toJson()).toList());
      
      _ruleEventController.add(RoutingRuleUpdatedEvent(updatedRule));
      
      // 发送应用事件
      _eventBus.emit(RoutingRulesChangedEvent(rules));
    }
  }

  @override
  Future<int> importRules(List<RoutingRule> newRules, bool overwrite) async {
    final existingRules = await getAllRules();
    int importedCount = 0;
    
    for (final newRule in newRules) {
      final index = existingRules.indexWhere((r) => r.tag == newRule.tag);
      
      if (index >= 0) {
        if (overwrite) {
          existingRules[index] = newRule;
          importedCount++;
        }
      } else {
        existingRules.add(newRule);
        importedCount++;
      }
    }
    
    if (importedCount > 0) {
      await _storage.setItem('routing_rules', existingRules.map((r) => r.toJson()).toList());
      
      _ruleEventController.add(RoutingRulesImportedEvent(importedCount));
      
      // 发送应用事件
      _eventBus.emit(RoutingRulesChangedEvent(existingRules));
    }
    
    return importedCount;
  }

  @override
  Future<List<Map<String, dynamic>>> exportRules() async {
    final rules = await getAllRules();
    return rules.map((r) => r.toJson()).toList();
  }

  @override
  List<RoutingRule> checkRuleConflicts(RoutingRule rule, List<RoutingRule> existingRules) {
    final conflicts = <RoutingRule>[];
    
    for (final existing in existingRules) {
      if (existing.tag == rule.tag) continue; // 跳过自身
      
      // 检查域名冲突
      final hasDomainConflict = rule.domain.any((domain) => existing.domain.contains(domain));
      
      // 检查IP冲突
      final hasIpConflict = rule.ip.any((ip) => existing.ip.contains(ip));
      
      if (hasDomainConflict || hasIpConflict) {
        conflicts.add(existing);
      }
    }
    
    return conflicts;
  }

  @override
  Stream<RoutingRuleEvent> get ruleEventStream => _ruleEventController.stream;

  /// 释放资源
  void dispose() {
    _ruleEventController.close();
  }
}

/// 路由规则事件基类
abstract class RoutingRuleEvent {}

/// 路由规则添加事件
class RoutingRuleAddedEvent extends RoutingRuleEvent {
  final RoutingRule rule;
  
  RoutingRuleAddedEvent(this.rule);
}

/// 路由规则更新事件
class RoutingRuleUpdatedEvent extends RoutingRuleEvent {
  final RoutingRule rule;
  
  RoutingRuleUpdatedEvent(this.rule);
}

/// 路由规则删除事件
class RoutingRuleDeletedEvent extends RoutingRuleEvent {
  final RoutingRule rule;
  
  RoutingRuleDeletedEvent(this.rule);
}

/// 路由规则导入事件
class RoutingRulesImportedEvent extends RoutingRuleEvent {
  final int count;
  
  RoutingRulesImportedEvent(this.count);
}

/// 路由规则变更事件（应用级事件）
class RoutingRulesChangedEvent {
  final List<RoutingRule> rules;
  
  RoutingRulesChangedEvent(this.rules);
}