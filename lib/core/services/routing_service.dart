import 'dart:async';
import '../event_bus.dart';
import '../../models/routing_rule.dart';
import './local_storage.dart';

/// 路由规则服务接口
abstract class RoutingService {
  /// 获取所有路由规则
  Future<List<RoutingRule>> getAllRules();

  /// 获取启用的路由规则
  Future<List<RoutingRule>> getEnabledRules();

  /// 保存路由规则
  Future<void> saveRule(RoutingRule rule);

  /// 删除路由规则
  Future<void> deleteRule(String tag);

  /// 启用/禁用路由规则
  Future<void> toggleRuleStatus(String tag, bool enabled);

  /// 导入路由规则
  Future<int> importRules(List<RoutingRule> rules, bool overwrite);

  /// 导出路由规则
  Future<List<Map<String, dynamic>>> exportRules();

  /// 检查规则冲突
  List<RoutingRule> checkRuleConflicts(RoutingRule rule, List<RoutingRule> existingRules);

  /// 获取路由规则变更流
  Stream<RoutingRuleEvent> get ruleEventStream;
}

/// 路由规则服务实现
class RoutingServiceImpl implements RoutingService {
  final EventBus _eventBus;
  final LocalStorage _storage;
  final _ruleEventController = StreamController<RoutingRuleEvent>.broadcast();

  RoutingServiceImpl(this._eventBus, this._storage);

  @override
  Future<List<RoutingRule>> getAllRules() async {
    try {
      final data = await _storage.getItem('routing_rules');
      if (data != null) {
        return (data as List)
            .map((json) => RoutingRule.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<RoutingRule>> getEnabledRules() async {
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
    
    await _storage.setItem('routing_rules', rules.map((r) => r.toJson()).toList());
    
    // 发送应用事件
    _eventBus.emit(RoutingRulesChangedEvent(rules));
  }

  @override
  Future<void> deleteRule(String tag) async {
    final rules = await getAllRules();
    final index = rules.indexWhere((r) => r.tag == tag);
    
    if (index >= 0) {
      final deletedRule = rules.removeAt(index);
      await _storage.setItem('routing_rules', rules.map((r) => r.toJson()).toList());
      
      _ruleEventController.add(RoutingRuleDeletedEvent(deletedRule));
      
      // 发送应用事件
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