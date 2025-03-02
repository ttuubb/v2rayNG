import 'dart:convert';

class ServerConfig {
  final String id;
  final String name;
  final String address;
  final int port;
  final String protocol; // vmess, vless, shadowsocks, trojan
  final Map<String, dynamic> settings;
  final bool enabled;
  double? latency;

  ServerConfig({
    String? id,
    required this.name,
    required this.address,
    required this.port,
    required this.protocol,
    required this.settings,
    this.enabled = true,
    this.latency,
  }) : this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString() {
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

  // 从JSON创建ServerConfig
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