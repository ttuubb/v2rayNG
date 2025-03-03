import 'dart:async';
import '../event_bus.dart';
import '../../models/traffic_stats.dart';
import '../../models/traffic_history.dart';
import './local_storage.dart';
import '../events/app_events.dart';

/// 流量统计服务接口
abstract class TrafficService {
  /// 获取当前流量统计
  TrafficStats? getCurrentStats(String? serverId);

  /// 获取历史流量统计
  Future<List<TrafficHistory>> getTrafficHistory(String serverId);

  /// 获取指定周期的历史流量统计
  Future<List<TrafficHistory>> getTrafficHistoryByPeriod(String serverId, String period);

  /// 记录流量统计
  Future<void> recordTrafficStats(TrafficStats stats);

  /// 清除指定服务器的历史流量统计
  Future<void> clearTrafficHistory(String serverId);

  /// 清除所有历史流量统计
  Future<void> clearAllTrafficHistory();

  /// 获取流量统计流
  Stream<TrafficStats> get trafficStatsStream;

  /// 开始监控流量
  void startMonitoring(String serverId);

  /// 停止监控流量
  void stopMonitoring();
}

/// 流量统计服务实现
class TrafficServiceImpl implements TrafficService {
  final EventBus _eventBus;
  final LocalStorage _storage;
  final _trafficStatsController = StreamController<TrafficStats>.broadcast();
  
  TrafficStats? _currentStats;
  Timer? _aggregationTimer;
  StreamSubscription? _trafficSubscription;
  
  // 临时存储实时流量数据
  int _tempUploadBytes = 0;
  int _tempDownloadBytes = 0;
  int _lastTotalUpload = 0;
  int _lastTotalDownload = 0;
  String? _currentServerId;

  TrafficServiceImpl(this._eventBus, this._storage);

  @override
  TrafficStats? getCurrentStats(String? serverId) {
    if (serverId != null && _currentStats?.serverId != serverId) {
      return null;
    }
    return _currentStats;
  }

  @override
  Future<List<TrafficHistory>> getTrafficHistory(String serverId) async {
    try {
      final data = await _storage.getItem('traffic_history_$serverId');
      if (data != null) {
        return (data as List)
            .map((json) => TrafficHistory.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<TrafficHistory>> getTrafficHistoryByPeriod(String serverId, String period) async {
    final allHistory = await getTrafficHistory(serverId);
    return allHistory.where((history) => history.period == period).toList();
  }

  @override
  Future<void> recordTrafficStats(TrafficStats stats) async {
    // 更新当前统计
    _currentStats = stats;
    _trafficStatsController.add(stats);
    
    // 保存到历史记录
    await _saveToHistory(stats);
  }

  Future<void> _saveToHistory(TrafficStats stats) async {
    if (stats.serverId == null) return;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisHour = DateTime(now.year, now.month, now.day, now.hour);
    
    // 获取现有历史记录
    final history = await getTrafficHistory(stats.serverId!);
    
    // 更新或创建每日记录
    await _updatePeriodHistory(history, stats, today, 'day', stats.serverId!);
    
    // 更新或创建每小时记录
    await _updatePeriodHistory(history, stats, thisHour, 'hour', stats.serverId!);
  }

  Future<void> _updatePeriodHistory(
    List<TrafficHistory> history,
    TrafficStats stats,
    DateTime periodStart,
    String periodType,
    String serverId,
  ) async {
    // 查找现有记录
    final existingIndex = history.indexWhere((h) =>
        h.period == periodType &&
        h.startTime.year == periodStart.year &&
        h.startTime.month == periodStart.month &&
        h.startTime.day == periodStart.day &&
        (periodType != 'hour' || h.startTime.hour == periodStart.hour));
    
    if (existingIndex >= 0) {
      // 更新现有记录
      final existing = history[existingIndex];
      final updated = TrafficHistory(
        serverId: serverId,
        startTime: existing.startTime,
        endTime: DateTime.now(),
        uploadTotal: stats.totalUpload,
        downloadTotal: stats.totalDownload,
        period: periodType,
        details: existing.details,
      );
      history[existingIndex] = updated;
    } else {
      // 创建新记录
      final newHistory = TrafficHistory(
        serverId: serverId,
        startTime: periodStart,
        endTime: DateTime.now(),
        uploadTotal: stats.totalUpload,
        downloadTotal: stats.totalDownload,
        period: periodType,
      );
      history.add(newHistory);
    }
    
    // 保存更新后的历史记录
    await _storage.setItem('traffic_history_$serverId', history.map((h) => h.toJson()).toList());
  }

  @override
  Future<void> clearTrafficHistory(String serverId) async {
    await _storage.removeItem('traffic_history_$serverId');
  }

  @override
  Future<void> clearAllTrafficHistory() async {
    // 获取所有键
    final keys = await _storage.getItem('all_keys') ?? [];
    
    // 删除所有流量历史记录
    for (var key in keys) {
      if (key.toString().startsWith('traffic_history_')) {
        await _storage.removeItem(key);
      }
    }
  }

  @override
  Stream<TrafficStats> get trafficStatsStream => _trafficStatsController.stream;

  @override
  void startMonitoring(String serverId) {
    stopMonitoring(); // 确保先停止之前的监控
    
    _currentServerId = serverId;
    _lastTotalUpload = 0;
    _lastTotalDownload = 0;
    
    // 订阅流量事件
    _trafficSubscription = _eventBus.on<TrafficStatsEvent>().listen((event) {
      if (event.serverId == serverId) {
        _tempUploadBytes += event.upBytes;
        _tempDownloadBytes += event.downBytes;
      }
    });
    
    // 定时聚合和发布流量统计
    _aggregationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _aggregateAndPublishStats();
    });
  }

  void _aggregateAndPublishStats() {
    if (_currentServerId == null) return;
    
    // 计算速度 (bytes/s)
    final uploadSpeed = _tempUploadBytes.toDouble();
    final downloadSpeed = _tempDownloadBytes.toDouble();
    
    // 更新总流量
    _lastTotalUpload += _tempUploadBytes;
    _lastTotalDownload += _tempDownloadBytes;
    
    // 创建流量统计对象
    final stats = TrafficStats(
      uploadSpeed: uploadSpeed,
      downloadSpeed: downloadSpeed,
      totalUpload: _lastTotalUpload,
      totalDownload: _lastTotalDownload,
      timestamp: DateTime.now(),
      serverId: _currentServerId,
    );
    
    // 发布流量统计
    _currentStats = stats;
    _trafficStatsController.add(stats);
    
    // 发送应用事件
    _eventBus.emit(TrafficStatsUpdatedEvent(
      uploadSpeed: uploadSpeed,
      downloadSpeed: downloadSpeed,
      totalUpload: _lastTotalUpload,
      totalDownload: _lastTotalDownload,
    ));
    
    // 重置临时计数器
    _tempUploadBytes = 0;
    _tempDownloadBytes = 0;
    
    // 每分钟保存一次历史记录
    if (DateTime.now().second == 0) {
      recordTrafficStats(stats);
    }
  }

  @override
  void stopMonitoring() {
    _trafficSubscription?.cancel();
    _trafficSubscription = null;
    _aggregationTimer?.cancel();
    _aggregationTimer = null;
    _currentServerId = null;
  }

  /// 释放资源
  void dispose() {
    stopMonitoring();
    _trafficStatsController.close();
  }
}