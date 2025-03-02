import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/event_bus.dart';
import '../core/events/app_events.dart';
import '../models/traffic_stats.dart';
import '../models/traffic_history.dart';
import '../core/services/traffic_service.dart';

class TrafficViewModel extends ChangeNotifier {
  final TrafficService _trafficService;
  final EventBus _eventBus;
  StreamSubscription? _subscription;
  
  TrafficStats? _currentStats;
  List<TrafficHistory> _history = [];
  bool _isLoading = false;
  String? _error;
  
  TrafficViewModel(this._trafficService, this._eventBus) {
    // 订阅流量统计更新事件
    _subscription = _eventBus.on<TrafficStatsUpdatedEvent>().listen((event) {
      _currentStats = TrafficStats(
        uploadSpeed: event.uploadSpeed,
        downloadSpeed: event.downloadSpeed,
        totalUpload: event.totalUpload,
        totalDownload: event.totalDownload,
        timestamp: DateTime.now(),
      );
      notifyListeners();
    });

    // 初始化一个默认的流量统计对象，确保currentStats不为null
    _currentStats = TrafficStats(
      uploadSpeed: 0.0,
      downloadSpeed: 0.0,
      totalUpload: 0,
      totalDownload: 0,
      timestamp: DateTime.now(),
    );
  }
  
  TrafficStats? get currentStats => _currentStats;
  List<TrafficHistory> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 加载历史流量数据
  Future<void> loadTrafficHistory(String serverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _history = await _trafficService.getTrafficHistory(serverId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 清除历史流量数据
  Future<void> clearTrafficHistory(String serverId) async {
    try {
      await _trafficService.clearTrafficHistory(serverId);
      _history.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 保存流量历史记录
  Future<void> saveTrafficHistory(TrafficHistory record) async {
    try {
      // 直接添加到本地列表，不调用不存在的服务方法
      _history.add(record);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 生成流量报告
  Future<Map<String, dynamic>> generateTrafficReport(String serverId, DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      final serverHistory = _history.where((record) =>
        record.serverId == serverId &&
        record.startTime.isAfter(startDate) &&
        record.endTime.isBefore(endDate)
      ).toList();

      final totalUpload = serverHistory.fold<int>(0, (sum, record) => sum + record.uploadTotal);
      final totalDownload = serverHistory.fold<int>(0, (sum, record) => sum + record.downloadTotal);

      return {
        'serverId': serverId,
        'startDate': startDate,
        'endDate': endDate,
        'totalUpload': totalUpload,
        'totalDownload': totalDownload,
        'recordCount': serverHistory.length
      };
    } catch (e) {
      _error = e.toString();
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 计算聚合流量数据
  Future<Map<String, int>> calculateAggregateTraffic() async {
    _isLoading = true;
    notifyListeners();

    try {
      final totalUpload = _history.fold<int>(0, (sum, record) => sum + record.uploadTotal);
      final totalDownload = _history.fold<int>(0, (sum, record) => sum + record.downloadTotal);

      return {
        'totalUpload': totalUpload,
        'totalDownload': totalDownload
      };
    } catch (e) {
      _error = e.toString();
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}