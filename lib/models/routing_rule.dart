/// 路由规则模型类
/// 用于定义V2Ray的路由规则，支持基于域名和IP的路由分流
class RoutingRule {
  /// 规则标签，用于唯一标识一条路由规则
  final String tag;
  
  /// 规则类型，目前固定为'field'
  final String type;
  
  /// 域名列表，支持通配符和正则表达式
  final List<String> domain;
  
  /// IP地址列表，支持CIDR格式
  final List<String> ip;
  
  /// 出站标签，指定符合条件的流量使用哪个出站连接
  final String outboundTag;
  
  /// 规则是否启用
  final bool enabled;

  /// 构造函数
  /// [tag] 规则标签
  /// [type] 规则类型，默认为'field'
  /// [domain] 域名列表，默认为空列表
  /// [ip] IP地址列表，默认为空列表
  /// [outboundTag] 出站标签
  /// [enabled] 是否启用，默认为true
  RoutingRule({
    required this.tag,
    this.type = 'field',
    this.domain = const [],
    this.ip = const [],
    required this.outboundTag,
    this.enabled = true,
  });

  /// 从JSON数据创建路由规则实例
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

  /// 将路由规则转换为JSON格式
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

  /// 创建当前规则的副本，可选择性地更新部分字段
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