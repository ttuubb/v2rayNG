class TrafficHistory {
  final String serverId;
  final DateTime startTime;
  final DateTime endTime;
  final int uploadTotal;
  final int downloadTotal;
  final String period; // 'minute', 'hour', 'day'
  final Map<String, dynamic>? details; // 存储更细粒度的统计数据

  // 添加timestamp属性，用于兼容现有代码
  DateTime get timestamp => endTime;
  
  // 添加uploadBytes和downloadBytes属性，用于兼容现有代码
  int get uploadBytes => uploadTotal;
  int get downloadBytes => downloadTotal;

  TrafficHistory({
    required this.serverId,
    required this.startTime,
    required this.endTime,
    required this.uploadTotal,
    required this.downloadTotal,
    required this.period,
    this.details,
  });

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