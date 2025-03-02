import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../event_bus.dart';

/// 日志级别枚举
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 日志条目模型
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final String? details;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.details,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      level: LogLevel.values[json['level'] as int],
      message: json['message'] as String,
      tag: json['tag'] as String?,
      details: json['details'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'level': level.index,
      'message': message,
      'tag': tag,
      'details': details,
    };
  }

  @override
  String toString() {
    final levelStr = level.toString().split('.').last.toUpperCase();
    final tagStr = tag != null ? '[$tag] ' : '';
    return '${timestamp.toIso8601String()} $levelStr: $tagStr$message';
  }
}

/// 日志服务接口
abstract class LogService {
  /// 记录调试级别日志
  void debug(String message, {String? tag, String? details});

  /// 记录信息级别日志
  void info(String message, {String? tag, String? details});

  /// 记录警告级别日志
  void warning(String message, {String? tag, String? details});

  /// 记录错误级别日志
  void error(String message, {String? tag, String? details});

  /// 获取所有日志
  Future<List<LogEntry>> getLogs();

  /// 获取指定级别的日志
  Future<List<LogEntry>> getLogsByLevel(LogLevel level);

  /// 获取指定标签的日志
  Future<List<LogEntry>> getLogsByTag(String tag);

  /// 清除所有日志
  Future<void> clearLogs();

  /// 导出日志到文件
  Future<File> exportLogs();

  /// 设置最大日志条目数
  void setMaxEntries(int maxEntries);

  /// 获取日志流
  Stream<LogEntry> get logStream;
}

/// 日志服务实现
class LogServiceImpl implements LogService {
  final EventBus _eventBus;
  final List<LogEntry> _logs = [];
  final _logStreamController = StreamController<LogEntry>.broadcast();
  int _maxEntries = 1000;
  LogLevel _minLevel = LogLevel.debug;

  LogServiceImpl(this._eventBus);

  @override
  void debug(String message, {String? tag, String? details}) {
    _log(LogLevel.debug, message, tag: tag, details: details);
  }

  @override
  void info(String message, {String? tag, String? details}) {
    _log(LogLevel.info, message, tag: tag, details: details);
  }

  @override
  void warning(String message, {String? tag, String? details}) {
    _log(LogLevel.warning, message, tag: tag, details: details);
  }

  @override
  void error(String message, {String? tag, String? details}) {
    _log(LogLevel.error, message, tag: tag, details: details);
  }

  void _log(LogLevel level, String message, {String? tag, String? details}) {
    if (level.index < _minLevel.index) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      details: details,
    );

    _logs.add(entry);
    _logStreamController.add(entry);

    // 发送日志事件
    _eventBus.emit(LogEntryAddedEvent(entry));

    // 限制日志条目数量
    if (_logs.length > _maxEntries) {
      _logs.removeAt(0);
    }
  }

  @override
  Future<List<LogEntry>> getLogs() async {
    return List.unmodifiable(_logs);
  }

  @override
  Future<List<LogEntry>> getLogsByLevel(LogLevel level) async {
    return _logs.where((log) => log.level == level).toList();
  }

  @override
  Future<List<LogEntry>> getLogsByTag(String tag) async {
    return _logs.where((log) => log.tag == tag).toList();
  }

  @override
  Future<void> clearLogs() async {
    _logs.clear();
    _eventBus.emit(LogsClearedEvent());
  }

  @override
  Future<File> exportLogs() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/v2rayng_logs_$timestamp.txt');

    final buffer = StringBuffer();
    for (var log in _logs) {
      buffer.writeln(log.toString());
    }

    await file.writeAsString(buffer.toString());
    return file;
  }

  @override
  void setMaxEntries(int maxEntries) {
    _maxEntries = maxEntries;
    if (_logs.length > _maxEntries) {
      _logs.removeRange(0, _logs.length - _maxEntries);
    }
  }

  /// 设置最小日志级别
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  @override
  Stream<LogEntry> get logStream => _logStreamController.stream;

  /// 释放资源
  void dispose() {
    _logStreamController.close();
  }
}

/// 日志添加事件
class LogEntryAddedEvent {
  final LogEntry entry;

  LogEntryAddedEvent(this.entry);
}

/// 日志清除事件
class LogsClearedEvent {}