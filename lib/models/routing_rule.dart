class RoutingRule {
  final String tag;
  final String type; // 'field'
  final List<String> domain;
  final List<String> ip;
  final String outboundTag;
  final bool enabled;

  RoutingRule({
    required this.tag,
    this.type = 'field',
    this.domain = const [],
    this.ip = const [],
    required this.outboundTag,
    this.enabled = true,
  });

  factory RoutingRule.fromJson(Map<String, dynamic> json) {
    return RoutingRule(
      tag: json['tag'] as String,
      type: json['type'] as String? ?? 'field',
      domain: (json['domain'] as List<dynamic>?)?.cast<String>() ?? [],
      ip: (json['ip'] as List<dynamic>?)?.cast<String>() ?? [],
      outboundTag: json['outboundTag'] as String,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'type': type,
      'domain': domain,
      'ip': ip,
      'outboundTag': outboundTag,
      'enabled': enabled,
    };
  }

  RoutingRule copyWith({
    String? tag,
    String? type,
    List<String>? domain,
    List<String>? ip,
    String? outboundTag,
    bool? enabled,
  }) {
    return RoutingRule(
      tag: tag ?? this.tag,
      type: type ?? this.type,
      domain: domain ?? this.domain,
      ip: ip ?? this.ip,
      outboundTag: outboundTag ?? this.outboundTag,
      enabled: enabled ?? this.enabled,
    );
  }
}