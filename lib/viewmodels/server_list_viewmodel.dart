import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/server_config.dart';
import '../models/repositories/server_repository.dart';

/// 服务器列表视图模型类
/// 用于管理和展示V2Ray服务器列表，支持服务器的增删改查和连接状态管理
class ServerListViewModel extends ChangeNotifier {
  final ServerRepository _repository;

  /// 服务器配置列表
  List<ServerConfig> _servers = [];

  /// 是否正在加载数据
  bool _isLoading = false;

  /// 错误信息
  String? _error;

  /// 当前选中的服务器
  ServerConfig? _currentServer;

  /// 是否已连接到服务器
  bool _isConnected = false;

  /// 用于防抖的计时器
  Timer? _debounceTimer;

  /// 缓存过期时间
  static const Duration _cacheExpiration = Duration(minutes: 30);

  /// 最后一次缓存更新时间
  DateTime _lastCacheUpdate = DateTime.now();

  /// 构造函数
  /// [_repository] 服务器仓库实例
  ServerListViewModel(this._repository);

  /// 获取服务器列表
  List<ServerConfig> get servers => _servers;

  /// 获取加载状态
  bool get isLoading => _isLoading;

  /// 获取错误信息
  String? get error => _error;

  /// 获取当前选中的服务器
  ServerConfig? get currentServer => _currentServer;

  /// 获取连接状态
  bool get isConnected => _isConnected;

  /// 加载所有服务器配置
  Future<void> loadServers() async {
    // 检查缓存是否过期
    if (DateTime.now().difference(_lastCacheUpdate) < _cacheExpiration) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _servers = await _repository.getAllServers();
      _lastCacheUpdate = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 添加新服务器
  /// [server] 要添加的服务器配置
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
    // 使用防抖处理频繁的状态切换
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
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
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    });
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
