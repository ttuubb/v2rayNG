/// 流量历史记录模型类
/// 用于记录和统计V2Ray服务器的流量使用情况，支持不同时间粒度的统计
class TrafficHistory {
  /// 服务器ID，关联到具体的服务器配置
  final String serverId;
  
  /// 统计开始时间
  final DateTime startTime;
  
  /// 统计结束时间
  final DateTime endTime;
  
  /// 总上传流量（字节）
  final int uploadTotal;
  
  /// 总下载流量（字节）
  final int downloadTotal;
  
  /// 统计周期（'minute'分钟, 'hour'小时, 'day'天）
  final String period;
  
  /// 详细统计数据，可存储更细粒度的流量信息
  final Map<String, dynamic>? details;

  /// 兼容属性：获取结束时间
  /// 用于保持与旧版本代码的兼容性
  DateTime get timestamp => endTime;
  
  /// 兼容属性：获取上传流量
  /// 用于保持与旧版本代码的兼容性
  int get uploadBytes => uploadTotal;
  
  /// 兼容属性：获取下载流量
  /// 用于保持与旧版本代码的兼容性
  int get downloadBytes => downloadTotal;

  /// 构造函数
  /// [serverId] 服务器ID
  /// [startTime] 统计开始时间
  /// [endTime] 统计结束时间
  /// [uploadTotal] 总上传流量
  /// [downloadTotal] 总下载流量
  /// [period] 统计周期
  /// [details] 详细统计数据
  TrafficHistory({
    required this.serverId,
    required this.startTime,
    required this.endTime,
    required this.uploadTotal,
    required this.downloadTotal,
    required this.period,
    this.details,
  });

  /// 从JSON数据创建流量历史记录实例
  factory TrafficHistory.fromJson(Map<String, dynamic> json) {
    return TrafficHistory(
      serverId: json['serverId'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int),
      uploadTotal: json['uploadTotal'] as int,
      downloadTotal: json['downloadTotal'] as int,
      period: json['period'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  /// 将流量历史记录转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'serverId': serverId,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'uploadTotal': uploadTotal,
      'downloadTotal': downloadTotal,
      'period': period,
      'details': details,
    };
  }

  /// 创建当前记录的副本，可选择性地更新部分字段
  TrafficHistory copyWith({
    String? serverId,
    DateTime? startTime,
    DateTime? endTime,
    int? uploadTotal,
    int? downloadTotal,
    String? period,
    Map<String, dynamic>? details,
  }) {
    return TrafficHistory(
      serverId: serverId ?? this.serverId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      uploadTotal: uploadTotal ?? this.uploadTotal,
      downloadTotal: downloadTotal ?? this.downloadTotal,
      period: period ?? this.period,
      details: details ?? this.details,
    );
  }
}