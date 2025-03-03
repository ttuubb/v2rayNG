import 'dart:convert';

/// 服务器配置模型类
/// 用于存储和管理V2Ray服务器的配置信息，支持多种代理协议
class ServerConfig {
  /// 服务器配置的唯一标识符
  final String id;
  
  /// 服务器名称
  final String name;
  
  /// 服务器地址（域名或IP）
  final String address;
  
  /// 服务器端口（1-65535）
  final int port;
  
  /// 代理协议类型（vmess, vless, shadowsocks, trojan）
  final String protocol;
  
  /// 协议特定的设置参数
  final Map<String, dynamic> settings;
  
  /// 服务器是否启用
  final bool enabled;
  
  /// 服务器延迟（毫秒），用于显示速度测试结果
  double? latency;

  /// 构造函数
  /// [id] 可选，如果未提供则使用当前时间戳
  /// [name] 服务器名称，不能为空
  /// [address] 服务器地址，不能为空
  /// [port] 端口号，范围1-65535
  /// [protocol] 代理协议类型，不能为空
  /// [settings] 协议特定的设置
  /// [enabled] 是否启用，默认为true
  /// [latency] 服务器延迟
  ServerConfig({
    String? id,
    required this.name,
    required this.address,
    required this.port,
    required this.protocol,
    required this.settings,
    this.enabled = true,
    this.latency,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString() {
    // 验证端口范围
    if (port < 1 || port > 65535) {
      throw ArgumentError('Port must be between 1 and 65535');
    }
    
    // 验证必填字段
    if (name.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    
    if (address.isEmpty) {
      throw ArgumentError('Address cannot be empty');
    }
    
    if (protocol.isEmpty) {
      throw ArgumentError('Protocol cannot be empty');
    }
  }
  
  /// 从JSON数据创建服务器配置实例
  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      port: json['port'] ?? 0,
      protocol: json['protocol'] ?? '',
      settings: json['settings'] ?? {},
      enabled: json['enabled'] ?? false,
      latency: json['latency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'port': port,
      'protocol': protocol,
      'settings': settings,
      'enabled': enabled,
    };
  }

  String toV2rayConfig() {
    final config = {
      'inbounds': [
        {
          'port': 1080,
          'protocol': 'socks',
          'settings': {
            'auth': 'noauth',
            'udp': true
          }
        }
      ],
      'outbounds': [
        {
          'protocol': protocol,
          'settings': settings,
          'streamSettings': {
            'network': 'tcp'
          }
        }
      ]
    };
    return jsonEncode(config);
  }

  ServerConfig copyWith({
    String? id,
    String? name,
    String? address,
    int? port,
    String? protocol,
    Map<String, dynamic>? settings,
    bool? enabled,
    double? latency,
  }) {
    return ServerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      port: port ?? this.port,
      protocol: protocol ?? this.protocol,
      settings: settings ?? this.settings,
      enabled: enabled ?? this.enabled,
      latency: latency ?? this.latency,
    );
  }
}