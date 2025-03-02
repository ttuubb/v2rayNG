import 'package:uuid/uuid.dart';

class Subscription {
  final String id;
  final String name;
  final String url;
  final bool autoUpdate;
  final int updateInterval; // 更新间隔（小时）
  DateTime? lastUpdateTime;
  String? lastError;
  bool isUpdating;
  
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
  
  // 从JSON创建实例
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
  
  // 转换为JSON
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