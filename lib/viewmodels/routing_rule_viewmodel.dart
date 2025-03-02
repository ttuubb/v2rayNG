import 'package:flutter/foundation.dart';
import '../models/routing_rule.dart';
import '../core/services/local_storage.dart';

class RoutingRuleViewModel extends ChangeNotifier {
  final LocalStorage _storage;
  List<RoutingRule> _rules = [];
  bool _isLoading = false;
  String? _error;

  RoutingRuleViewModel(this._storage);

  // Getters
  List<RoutingRule> get rules => _rules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 加载所有路由规则
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

  // 保存路由规则
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

  // 删除路由规则
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

  // 更新规则启用状态
  Future<void> toggleRuleEnabled(String tag) async {
    final index = _rules.indexWhere((r) => r.tag == tag);
    if (index >= 0) {
      final rule = _rules[index];
      await saveRule(rule.copyWith(enabled: !rule.enabled));
    }
  }

  // 重新排序规则
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