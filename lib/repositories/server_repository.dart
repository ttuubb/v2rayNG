import '../models/server_config.dart';

abstract class ServerRepository {
  Future<List<ServerConfig>> getAllServers();
  Future<void> addServer(ServerConfig server);
  Future<void> updateServer(ServerConfig server);
  Future<void> deleteServer(String serverId);
}