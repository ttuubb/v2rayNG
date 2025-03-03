import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/event_bus.dart';
import '../core/events/app_events.dart';
import '../models/traffic_history.dart';
import '../core/services/traffic_service.dart';
import '../models/traffic_stats.dart';

/// 流量监控视图模型
/// 
/// 负责管理和展示实时流量统计数据以及历史流量记录
/// 通过事件总线接收流量更新事件，并通知UI更新显示
class TrafficViewModel extends ChangeNotifier {
  /// 流量服务实例，用于获取流量数据
  final TrafficService _trafficService;
  /// 事件总线实例，用于接收流量更新事件
  final EventBus _eventBus;
  /// 事件订阅对象
  StreamSubscription? _subscription;
  
  /// 当前流量统计数据
  TrafficStats? _currentStats;
  /// 历史流量记录列表
  List<TrafficHistory> _history = [];
  /// 是否正在加载数据
  bool _isLoading = false;
  /// 错误信息
  String? _error;
  /// 当前监控的服务器ID
  String? _monitoringServerId;
  
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
  
  /// 获取当前流量统计数据
  TrafficStats? get currentStats => _currentStats;
  /// 获取历史流量记录列表
  List<TrafficHistory> get history => _history;
  /// 获取加载状态
  bool get isLoading => _isLoading;
  /// 获取错误信息
  String? get error => _error;
  
  /// 开始监控指定服务器的流量
  /// 
  /// [serverId] 要监控的服务器ID
  /// 如果当前已在监控其他服务器，会先停止之前的监控
  void startMonitoring(String serverId) {
    if (_monitoringServerId != serverId) {
      stopMonitoring();
      _monitoringServerId = serverId;
      _trafficService.startMonitoring(serverId);
    }
  }
  
  /// 停止流量监控
  /// 
  /// 取消事件订阅并清除当前监控的服务器ID
  void stopMonitoring() {
    if (_monitoringServerId != null) {
      _trafficService.stopMonitoring();
      _monitoringServerId = null;
    }
    _subscription?.cancel();
    _subscription = null;
  }
  
  /// 加载指定服务器的历史流量数据
  /// 
  /// [serverId] 服务器ID
  /// 加载过程中会更新isLoading状态
  /// 如果发生错误会设置error信息
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
  
  /// 清除指定服务器的历史流量数据
  /// 
  /// [serverId] 服务器ID
  /// 清除成功后会更新本地历史记录列表
  /// 如果发生错误会设置error信息
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
  
  /// 保存流量历史记录
  /// 
  /// [record] 要保存的流量记录
  /// 将记录添加到本地列表并通知UI更新
  Future<void> saveTrafficHistory(TrafficHistory record) async {
    try {
      _history.add(record);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}