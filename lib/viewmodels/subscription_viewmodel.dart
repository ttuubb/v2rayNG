import 'package:flutter/foundation.dart';
import '../models/subscription.dart';
import '../models/repositories/subscription_repository.dart';
import '../models/server_config.dart';

/// 订阅视图模型类
/// 用于管理V2Ray服务器订阅源，支持订阅的增删改查和自动更新
class SubscriptionViewModel extends ChangeNotifier {
  final SubscriptionRepository _repository;
  
  /// 订阅列表
  List<Subscription> _subscriptions = [];
  
  /// 是否正在加载数据
  bool _isLoading = false;
  
  /// 错误信息
  String? _error;
  
  /// 解析出的服务器配置列表
  List<ServerConfig> _parsedServers = [];
  
  /// 构造函数
  /// [_repository] 订阅仓库实例
  SubscriptionViewModel(this._repository);
  
  /// 获取订阅列表
  List<Subscription> get subscriptions => _subscriptions;
  
  /// 获取加载状态
  bool get isLoading => _isLoading;
  
  /// 获取错误信息
  String? get error => _error;
  
  /// 获取解析出的服务器列表
  List<ServerConfig> get parsedServers => _parsedServers;
  
  /// 加载所有订阅
  Future<void> loadSubscriptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _subscriptions = await _repository.getAllSubscriptions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 添加订阅
  /// [subscription] 要添加的订阅配置
  Future<void> addSubscription(Subscription subscription) async {
    try {
      await _repository.addSubscription(subscription);
      await loadSubscriptions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// 更新订阅
  /// [subscription] 要更新的订阅配置
  Future<void> updateSubscription(Subscription subscription) async {
    try {
      await _repository.updateSubscription(subscription);
      await loadSubscriptions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // 删除订阅
  Future<void> deleteSubscription(String id) async {
    try {
      await _repository.deleteSubscription(id);
      await loadSubscriptions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // 更新所有订阅内容
  Future<void> updateAllSubscriptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      for (var subscription in _subscriptions) {
        await _repository.updateSubscriptionContent(subscription.id);
      }
      await loadSubscriptions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 过滤订阅列表
  void filterSubscriptions(String keyword) {
    if (keyword.isEmpty) {
      loadSubscriptions();
      return;
    }
    
    try {
      final filteredSubscriptions = _subscriptions.where((subscription) =>
        subscription.name.toLowerCase().contains(keyword.toLowerCase()) ||
        subscription.url.toLowerCase().contains(keyword.toLowerCase())
      ).toList();
      
      _subscriptions = filteredSubscriptions;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 解析订阅内容
  Future<List<ServerConfig>> parseSubscriptionContent(String content) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // 解析订阅内容，生成服务器配置列表
      final lines = content.split('\n').where((line) => line.isNotEmpty).toList();
      
      // 模拟解析过程，生成服务器配置
      _parsedServers = List.generate(lines.length, (index) => ServerConfig(
        name: 'Server $index',
        address: 'server$index.example.com',
        port: 443,
        protocol: 'vmess',
        settings: {
          'id': 'test-uuid-$index',
          'security': 'auto'
        }
      ));
      
      return _parsedServers;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 导出订阅到文件
  Future<String> exportSubscriptionToFile(String subscriptionId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // 导出订阅内容
      final exportData = await _repository.exportSubscriptions();
      return exportData;
    } catch (e) {
      _error = e.toString();
      return '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}