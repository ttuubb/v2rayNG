// 该文件定义了应用中的所有事件类，用于在不同模块之间传递状态变化。
// 每个事件类都继承自 `AppEvent`，并通过构造函数携带相关的状态数据。

import '../../models/server_config.dart';

/// 基础事件类，所有事件都需要继承此类
abstract class AppEvent {}

/// V2Ray 状态变更事件
/// 触发场景：当 V2Ray 核心服务的状态发生变化时（启动、停止或出错）。
class V2RayStatusChangedEvent extends AppEvent {
  /// 是否正在运行
  final bool isRunning;

  /// 当前激活的服务器配置（可选）
  final ServerConfig? activeServer;

  /// 错误信息（可选）
  final String? errorMessage;
  
  V2RayStatusChangedEvent({
    required this.isRunning,
    this.activeServer,
    this.errorMessage,
  });
}

/// 连接状态变更事件
/// 触发场景：当设备与服务器的连接状态发生变化时（连接成功或断开）。
class ConnectionStatusChangedEvent extends AppEvent {
  /// 是否已连接
  final bool isConnected;

  /// 当前连接的延迟（单位：毫秒）
  final int latency;
  
  ConnectionStatusChangedEvent({
    required this.isConnected,
    required this.latency,
  });
}

/// 流量统计更新事件
/// 触发场景：当流量统计信息更新时（如上传/下载速度、总流量）。
class TrafficStatsUpdatedEvent extends AppEvent {
  /// 当前上传速度（单位：KB/s）
  final double uploadSpeed;

  /// 当前下载速度（单位：KB/s）
  final double downloadSpeed;

  /// 总上传流量（单位：字节）
  final int totalUpload;

  /// 总下载流量（单位：字节）
  final int totalDownload;
  
  TrafficStatsUpdatedEvent({
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.totalUpload,
    required this.totalDownload,
  });
}

/// 日志清除事件
/// 触发场景：当用户手动清除日志时。
class LogsClearedEvent extends AppEvent {}

/// 服务器连接状态变更事件
/// 触发场景：当某个服务器的连接状态发生变化时（连接成功或失败）。
class ServerConnectionStatusChangedEvent extends AppEvent {
  /// 服务器唯一标识符
  final String serverId;

  /// 是否已连接
  final bool isConnected;

  /// 错误信息（可选）
  final String? errorMessage;
  
  ServerConnectionStatusChangedEvent({
    required this.serverId,
    required this.isConnected,
    this.errorMessage,
  });
}

/// 订阅更新事件
/// 触发场景：当订阅更新操作完成时（成功或失败）。
class SubscriptionUpdatedEvent extends AppEvent {
  /// 订阅唯一标识符
  final String subscriptionId;

  /// 更新后包含的服务器数量
  final int serverCount;

  /// 更新是否成功
  final bool success;

  /// 错误信息（可选）
  final String? errorMessage;
  
  SubscriptionUpdatedEvent({
    required this.subscriptionId,
    required this.serverCount,
    required this.success,
    this.errorMessage,
  });
}

/// 配置导入事件
/// 触发场景：当用户导入配置文件时（成功或失败）。
class ConfigImportedEvent extends AppEvent {
  /// 导入的服务器数量
  final int serverCount;

  /// 导入是否成功
  final bool success;

  /// 错误信息（可选）
  final String? errorMessage;
  
  ConfigImportedEvent({
    required this.serverCount,
    required this.success,
    this.errorMessage,
  });
}