import 'package:flutter/foundation.dart';
import '../models/server_config.dart';
import '../models/repositories/server_repository.dart';

class ServerDetailViewModel extends ChangeNotifier {
  final ServerRepository _repository;
  ServerConfig? _server;
  bool _isLoading = false;
  String? _error;

  ServerDetailViewModel(this._repository);

  // Getters
  ServerConfig? get server => _server;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 加载服务器配置
  void loadServer(ServerConfig server) {
    _server = server;
    notifyListeners();
  }

  // 创建新的服务器配置
  void createNewServer() {
    _server = ServerConfig(
      name: '',
      address: '',
      port: 443,
      protocol: 'vmess',
      settings: {},
    );
    notifyListeners();
  }

  // 保存服务器配置
  Future<bool> saveServer() async {
    if (_server == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.saveServer(_server!);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新服务器配置字段
  void updateServer({
    String? name,
    String? address,
    int? port,
    String? protocol,
    Map<String, dynamic>? settings,
    bool? enabled,
  }) {
    if (_server == null) return;

    _server = _server!.copyWith(
      name: name,
      address: address,
      port: port,
      protocol: protocol,
      settings: settings,
      enabled: enabled,
    );
    notifyListeners();
  }

  // 测试服务器连接
  Future<void> testConnection() async {
    if (_server == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: 实现服务器连接测试逻辑
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}