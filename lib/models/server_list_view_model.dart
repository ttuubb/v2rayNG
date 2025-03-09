import 'package:flutter/foundation.dart';
import 'package:v2rayng/models/config_model.dart';

/// 服务器列表视图模型
/// 用于管理服务器列表和相关状态
class ServerListViewModel extends ChangeNotifier {
  /// 服务器列表
  List<ConfigModel> _servers = [];
  
  /// 加载状态
  bool _isLoading = false;
  
  /// 错误信息
  String? _error;
  
  /// 获取服务器列表
  List<ConfigModel> get servers => _servers;
  
  /// 获取加载状态
  bool get isLoading => _isLoading;
  
  /// 获取错误信息
  String? get error => _error;
  
  /// 添加服务器
  void addServer(ConfigModel server) {
    _servers.add(server);
    notifyListeners();
  }
  
  /// 删除服务器
  void removeServer(int index) {
    if (index >= 0 && index < _servers.length) {
      _servers.removeAt(index);
      notifyListeners();
    }
  }
  
  /// 更新服务器
  void updateServer(int index, ConfigModel server) {
    if (index >= 0 && index < _servers.length) {
      _servers[index] = server;
      notifyListeners();
    }
  }
  
  /// 设置加载状态
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// 设置错误信息
  void setError(String message) {
    _error = message;
    notifyListeners();
  }
  
  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// 批量设置服务器
  void setServers(List<ConfigModel> servers) {
    _servers = List.from(servers);
    notifyListeners();
  }
}