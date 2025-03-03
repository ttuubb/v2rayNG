/// 流量统计模型类
/// 用于实时统计和记录V2Ray服务器的流量使用情况，包括上传下载速度和总流量
class TrafficStats {
  /// 当前上传速度（字节/秒）
  final double uploadSpeed;
  
  /// 当前下载速度（字节/秒）
  final double downloadSpeed;
  
  /// 累计上传总流量（字节）
  final int totalUpload;
  
  /// 累计下载总流量（字节）
  final int totalDownload;
  
  /// 统计数据的时间戳
  final DateTime timestamp;
  
  /// 关联的服务器ID，可选
  final String? serverId;

  /// 构造函数
  /// [uploadSpeed] 当前上传速度
  /// [downloadSpeed] 当前下载速度
  /// [totalUpload] 累计上传流量
  /// [totalDownload] 累计下载流量
  /// [timestamp] 统计时间
  /// [serverId] 服务器ID
  TrafficStats({
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.totalUpload,
    required this.totalDownload,
    required this.timestamp,
    this.serverId,
  });

  /// 从JSON数据创建流量统计实例
  factory TrafficStats.fromJson(Map<String, dynamic> json) {
    return TrafficStats(
      uploadSpeed: json['uploadSpeed'] as double,
      downloadSpeed: json['downloadSpeed'] as double,
      totalUpload: json['totalUpload'] as int,
      totalDownload: json['totalDownload'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      serverId: json['serverId'] as String?,
    );
  }

  /// 将流量统计数据转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'uploadSpeed': uploadSpeed,
      'downloadSpeed': downloadSpeed,
      'totalUpload': totalUpload,
      'totalDownload': totalDownload,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'serverId': serverId,
    };
  }

  /// 创建当前统计数据的副本，可选择性地更新部分字段
  TrafficStats copyWith({
    double? uploadSpeed,
    double? downloadSpeed,
    int? totalUpload,
    int? totalDownload,
    DateTime? timestamp,
    String? serverId,
  }) {
    return TrafficStats(
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      totalUpload: totalUpload ?? this.totalUpload,
      totalDownload: totalDownload ?? this.totalDownload,
      timestamp: timestamp ?? this.timestamp,
      serverId: serverId ?? this.serverId,
    );
  }
}