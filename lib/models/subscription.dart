import 'package:uuid/uuid.dart';

/// 订阅配置模型类
/// 用于管理V2Ray服务器订阅源的配置信息和更新状态
class Subscription {
  /// 订阅的唯一标识符
  final String id;

  /// 订阅名称
  final String name;

  /// 订阅地址URL
  final String url;

  /// 是否启用自动更新
  final bool autoUpdate;

  /// 自动更新时间间隔（小时）
  final int updateInterval;

  /// 最后一次更新时间
  DateTime? lastUpdateTime;

  /// 最后一次更新时的错误信息
  String? lastError;

  /// 是否正在更新中
  bool isUpdating;
  
  /// 构造函数
  /// [id] 可选，如果未提供则自动生成UUID
  /// [name] 订阅名称
  /// [url] 订阅地址
  /// [autoUpdate] 是否自动更新，默认为true
  /// [updateInterval] 更新间隔，默认24小时
  /// [lastUpdateTime] 最后更新时间
  /// [lastError] 最后错误信息
  /// [isUpdating] 是否更新中，默认false
  Subscription({
    String? id,
    required this.name,
    required this.url,
    this.autoUpdate = true,
    this.updateInterval = 24,
    this.lastUpdateTime,
    this.lastError,
    this.isUpdating = false,
  }) : id = id ?? const Uuid().v4();
  
  /// 从JSON数据创建订阅实例
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      autoUpdate: json['autoUpdate'] as bool? ?? true,
      updateInterval: json['updateInterval'] as int? ?? 24,
      lastUpdateTime: json['lastUpdateTime'] != null
          ? DateTime.parse(json['lastUpdateTime'] as String)
          : null,
      lastError: json['lastError'] as String?,
      isUpdating: false,
    );
  }
  
  /// 将订阅配置转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'autoUpdate': autoUpdate,
      'updateInterval': updateInterval,
      'lastUpdateTime': lastUpdateTime?.toIso8601String(),
      'lastError': lastError,
    };
  }
  
  // 创建更新后的实例
  Subscription copyWith({
    String? name,
    String? url,
    bool? autoUpdate,
    int? updateInterval,
    DateTime? lastUpdateTime,
    String? lastError,
    bool? isUpdating,
  }) {
    return Subscription(
      id: id,
      name: name ?? this.name,
      url: url ?? this.url,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      updateInterval: updateInterval ?? this.updateInterval,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      lastError: lastError ?? this.lastError,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}