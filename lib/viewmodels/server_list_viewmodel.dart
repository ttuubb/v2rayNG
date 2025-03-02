import 'package:flutter/foundation.dart';
import '../models/server_config.dart';
import '../models/repositories/server_repository.dart';

class ServerListViewModel extends ChangeNotifier {
  final ServerRepository _repository;
  
  List<ServerConfig> _servers = [];
  bool _isLoading = false;
  String? _error;
  ServerConfig? _currentServer;
  bool _isConnected = false;
  
  ServerListViewModel(this._repository);
  
  List<ServerConfig> get servers => _servers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ServerConfig? get currentServer => _currentServer;
  bool get isConnected => _isConnected;
  
  Future<void> loadServers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _servers = await _repository.getAllServers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 添加服务器
  Future<void> addServer(ServerConfig server) async {
    try {
      await _repository.addServer(server);
      await loadServers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // 保存服务器（用于测试）
  Future<void> saveServer(ServerConfig server) async {
    try {
      await _repository.saveServer(server);
      await loadServers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // 更新服务器
  Future<void> updateServer(String serverId, ServerConfig server) async {
    try {
      final updatedServer = server.copyWith(id: serverId);
      await _repository.updateServer(updatedServer);
      await loadServers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> toggleServerStatus(ServerConfig server) async {
    try {
      final updatedServer = ServerConfig(
        id: server.id,
        name: server.name,
        address: server.address,
        port: server.port,
        protocol: server.protocol,
        settings: server.settings,
        enabled: !server.enabled,
        latency: server.latency,
      );
      
      await _repository.updateServer(updatedServer);
      await loadServers();
      notifyListeners(); // 确保状态变更后通知监听器
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> deleteServer(String serverId) async {
    try {
      await _repository.deleteServer(serverId);
      await loadServers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // 批量删除服务器
  Future<void> deleteServers(List<String> serverIds) async {
    try {
      for (final id in serverIds) {
        await _repository.deleteServer(id);
      }
      await loadServers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // 批量导入服务器
  Future<void> importServers(List<ServerConfig> servers) async {
    try {
      for (final server in servers) {
        await _repository.addServer(server);
      }
      await loadServers();
      notifyListeners(); // 确保批量操作后通知监听器
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // 连接服务器
  Future<void> connectServer(String serverId) async {
    try {
      final server = _servers.firstWhere((s) => s.id == serverId);
      _currentServer = server;
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // 断开服务器连接
  Future<void> disconnectServer() async {
    _currentServer = null;
    _isConnected = false;
    notifyListeners();
  }
}