import '../../models/server_config.dart';

abstract class AppEvent {}

class V2RayStatusChangedEvent extends AppEvent {
  final bool isRunning;
  final ServerConfig? activeServer;
  final String? errorMessage;
  
  V2RayStatusChangedEvent({
    required this.isRunning,
    this.activeServer,
    this.errorMessage,
  });
}

class ConnectionStatusChangedEvent extends AppEvent {
  final bool isConnected;
  final int latency;
  
  ConnectionStatusChangedEvent({
    required this.isConnected,
    required this.latency,
  });
}

/// 流量统计更新事件
class TrafficStatsUpdatedEvent extends AppEvent {
  final double uploadSpeed;
  final double downloadSpeed;
  final int totalUpload;
  final int totalDownload;
  
  TrafficStatsUpdatedEvent({
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.totalUpload,
    required this.totalDownload,
  });
}

/// 日志清除事件
class LogsClearedEvent extends AppEvent {}

/// 服务器连接状态变更事件
class ServerConnectionStatusChangedEvent extends AppEvent {
  final String serverId;
  final bool isConnected;
  final String? errorMessage;
  
  ServerConnectionStatusChangedEvent({
    required this.serverId,
    required this.isConnected,
    this.errorMessage,
  });
}

/// 订阅更新事件
class SubscriptionUpdatedEvent extends AppEvent {
  final String subscriptionId;
  final int serverCount;
  final bool success;
  final String? errorMessage;
  
  SubscriptionUpdatedEvent({
    required this.subscriptionId,
    required this.serverCount,
    required this.success,
    this.errorMessage,
  });
}

/// 配置导入事件
class ConfigImportedEvent extends AppEvent {
  final int serverCount;
  final bool success;
  final String? errorMessage;
  
  ConfigImportedEvent({
    required this.serverCount,
    required this.success,
    this.errorMessage,
  });
}