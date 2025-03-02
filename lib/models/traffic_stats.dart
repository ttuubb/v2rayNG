class TrafficStats {
  final double uploadSpeed; // 上传速度 (bytes/s)
  final double downloadSpeed; // 下载速度 (bytes/s)
  final int totalUpload; // 总上传流量 (bytes)
  final int totalDownload; // 总下载流量 (bytes)
  final DateTime timestamp; // 统计时间戳
  final String? serverId; // 服务器标识

  TrafficStats({
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.totalUpload,
    required this.totalDownload,
    required this.timestamp,
    this.serverId,
  });

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