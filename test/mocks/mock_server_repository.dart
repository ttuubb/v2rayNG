import 'package:v2rayng/models/repositories/server_repository.dart';
import 'package:v2rayng/models/server_config.dart';
import 'package:v2rayng/repositories/server_repository.dart' as repo;

class MockServerRepository implements ServerRepository {
  final List<ServerConfig> _servers = [];

  @override
  Future<List<ServerConfig>> getAllServers() async {
    return _servers;
  }

  @override
  Future<void> addServer(ServerConfig server) async {
    _servers.add(server);
  }

  @override
  Future<void> updateServer(ServerConfig server) async {
    final index = _servers.indexWhere((s) => s.id == server.id);
    if (index != -1) {
      _servers[index] = server;
    }
  }

  @override
  Future<void> deleteServer(String serverId) async {
    _servers.removeWhere((server) => server.id == serverId);
  }
  
  @override
  Future<void> saveServer(ServerConfig server) async {
    final index = _servers.indexWhere((s) => s.id == server.id);
    if (index >= 0) {
      _servers[index] = server;
    } else {
      _servers.add(server);
    }
  }
  
  @override
  Future<void> saveAllServers(List<ServerConfig> servers) async {
    _servers.clear();
    _servers.addAll(servers);
  }
  
  @override
  Future<void> clearAllServers() async {
    _servers.clear();
  }
  
  // 添加测试用的服务器
  void addTestServers(List<ServerConfig> servers) {
    _servers.addAll(servers);
  }
}