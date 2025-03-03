import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../server_config.dart';

// 抽象接口定义
abstract class ServerRepositoryInterface {
  Future<List<ServerConfig>> getAllServers();
  Future<void> addServer(ServerConfig server);
  Future<void> updateServer(ServerConfig server);
  Future<void> deleteServer(String serverId);
}

class ServerRepository implements ServerRepositoryInterface {
  static const String _storageKey = 'server_configs';
  final SharedPreferences _prefs;

  ServerRepository(this._prefs);

  @override
  Future<List<ServerConfig>> getAllServers() async {
    final String? jsonStr = _prefs.getString(_storageKey);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((json) => ServerConfig.fromJson(json)).toList();
  }

  @override
  Future<void> addServer(ServerConfig server) async {
    final servers = await getAllServers();
    
    // 检查是否存在重复的服务器配置
    final isDuplicate = servers.any((s) => 
      s.address == server.address && 
      s.port == server.port && 
      s.protocol == server.protocol
    );
    
    if (isDuplicate) {
      throw Exception('Cannot add duplicate server configuration');
    }
    
    servers.add(server);
    await saveAllServers(servers);
  }

  @override
  Future<void> updateServer(ServerConfig server) async {
    final servers = await getAllServers();
    final index = servers.indexWhere((s) => s.id == server.id);
    
    if (index >= 0) {
      servers[index] = server;
      await saveAllServers(servers);
    }
  }

  Future<void> saveServer(ServerConfig server) async {
    final servers = await getAllServers();
    final index = servers.indexWhere((s) => s.id == server.id);
    
    if (index >= 0) {
      servers[index] = server;
    } else {
      servers.add(server);
    }

    await saveAllServers(servers);
  }

  @override
  Future<void> deleteServer(String serverId) async {
    final servers = await getAllServers();
    servers.removeWhere((server) => server.id == serverId);
    await saveAllServers(servers);
  }

  Future<void> saveAllServers(List<ServerConfig> servers) async {
    final jsonList = servers.map((server) => server.toJson()).toList();
    await _prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> clearAllServers() async {
    await _prefs.remove(_storageKey);
  }
}