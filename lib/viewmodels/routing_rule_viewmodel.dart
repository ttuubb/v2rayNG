import 'package:flutter/foundation.dart';
import '../models/routing_rule.dart';
import '../core/services/local_storage.dart';

/// 路由规则视图模型
/// 
/// 负责管理和维护应用的路由规则列表
/// 提供规则的增删改查、启用禁用、排序等功能
/// 使用本地存储持久化规则数据
class RoutingRuleViewModel extends ChangeNotifier {
  /// 本地存储服务实例
  final LocalStorage _storage;
  /// 路由规则列表
  List<RoutingRule> _rules = [];
  /// 是否正在加载数据
  bool _isLoading = false;
  /// 错误信息
  String? _error;

  RoutingRuleViewModel(this._storage);

  /// 获取路由规则列表
  List<RoutingRule> get rules => _rules;
  /// 获取加载状态
  bool get isLoading => _isLoading;
  /// 获取错误信息
  String? get error => _error;

  /// 加载所有路由规则
  /// 
  /// 从本地存储中读取规则数据并反序列化
  /// 加载过程中会更新isLoading状态
  /// 如果发生错误会设置error信息
  Future<void> loadRules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _storage.getItem('routing_rules');
      if (data != null) {
        _rules = (data as List)
            .map((json) => RoutingRule.fromJson(json))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 保存路由规则
  /// 
  /// [rule] 要保存的规则对象
  /// 如果规则已存在则更新，否则添加新规则
  /// 保存后会更新本地存储
  Future<void> saveRule(RoutingRule rule) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final index = _rules.indexWhere((r) => r.tag == rule.tag);
      if (index >= 0) {
        _rules[index] = rule;
      } else {
        _rules.add(rule);
      }
      await _storage.setItem('routing_rules', _rules.map((e) => e.toJson()).toList());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 删除路由规则
  /// 
  /// [tag] 要删除的规则标识
  /// 从列表中移除指定规则并更新本地存储
  Future<void> deleteRule(String tag) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rules.removeWhere((r) => r.tag == tag);
      await _storage.setItem('routing_rules', _rules.map((e) => e.toJson()).toList());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 更新规则启用状态
  /// 
  /// [tag] 要更新的规则标识
  /// 切换指定规则的启用/禁用状态
  Future<void> toggleRuleEnabled(String tag) async {
    final index = _rules.indexWhere((r) => r.tag == tag);
    if (index >= 0) {
      final rule = _rules[index];
      await saveRule(rule.copyWith(enabled: !rule.enabled));
    }
  }

  /// 重新排序规则
  /// 
  /// [oldIndex] 规则原始位置
  /// [newIndex] 规则目标位置
  /// 调整规则列表顺序并更新本地存储
  Future<void> reorderRules(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final rule = _rules.removeAt(oldIndex);
    _rules.insert(newIndex, rule);
    await _storage.setItem('routing_rules', _rules.map((e) => e.toJson()).toList());
    notifyListeners();
  }
}