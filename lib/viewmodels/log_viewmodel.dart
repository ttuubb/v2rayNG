import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/services/log_service.dart';
import '../core/event_bus.dart';

/// 日志视图模型类
/// 用于管理和展示应用程序的日志数据，支持日志过滤和实时更新
class LogViewModel extends ChangeNotifier {
  final LogService _logService;
  final EventBus _eventBus;
  StreamSubscription? _logSubscription;
  
  /// 存储日志条目列表
  List<LogEntry> _logs = [];
  
  /// 是否正在加载数据
  bool _isLoading = false;
  
  /// 错误信息
  String? _error;
  
  /// 日志级别过滤器
  LogLevel _filterLevel = LogLevel.debug;
  
  /// 日志标签过滤器
  String? _filterTag;
  
  /// 构造函数
  /// 初始化日志服务和事件总线，并设置日志更新和清除的事件监听
  LogViewModel(this._logService, this._eventBus) {
    // 订阅日志更新事件
    _logSubscription = _logService.logStream.listen((entry) {
      if (_shouldAddLog(entry)) {
        _logs.add(entry);
        notifyListeners();
      }
    });
    
    // 订阅日志清除事件
    _eventBus.on<LogsClearedEvent>().listen((_) {
      _logs = [];
      notifyListeners();
    });
  }
  
  /// 获取日志列表
  List<LogEntry> get logs => _logs;
  
  /// 获取加载状态
  bool get isLoading => _isLoading;
  
  /// 获取错误信息
  String? get error => _error;
  
  /// 获取当前日志级别过滤器
  LogLevel get filterLevel => _filterLevel;
  
  /// 获取当前标签过滤器
  String? get filterTag => _filterTag;
  
  /// 加载日志数据
  /// 从日志服务获取所有日志并应用当前的过滤器
  Future<void> loadLogs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _logs = await _logService.getLogs();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 设置日志级别过滤器
  void setLevelFilter(LogLevel level) {
    _filterLevel = level;
    _applyFilters();
    notifyListeners();
  }
  
  // 设置标签过滤器
  void setTagFilter(String? tag) {
    _filterTag = tag;
    _applyFilters();
    notifyListeners();
  }
  
  // 清除过滤器
  void clearFilters() {
    _filterLevel = LogLevel.debug;
    _filterTag = null;
    loadLogs();
  }
  
  // 清除日志
  Future<void> clearLogs() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _logService.clearLogs();
      _logs = [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 导出日志
  Future<String> exportLogs() async {
    try {
      final file = await _logService.exportLogs();
      return file.path;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
  
  // 应用过滤器
  void _applyFilters() async {
    if (_filterTag != null) {
      _logs = await _logService.getLogsByTag(_filterTag!);
    } else {
      _logs = await _logService.getLogs();
    }
    
    // 应用级别过滤
    _logs = _logs.where((log) => log.level.index >= _filterLevel.index).toList();
  }
  
  // 检查日志是否应该被添加（基于当前过滤器）
  bool _shouldAddLog(LogEntry entry) {
    if (entry.level.index < _filterLevel.index) return false;
    if (_filterTag != null && entry.tag != _filterTag) return false;
    return true;
  }
  
  @override
  void dispose() {
    _logSubscription?.cancel();
    super.dispose();
  }
}