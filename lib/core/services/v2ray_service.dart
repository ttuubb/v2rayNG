import 'dart:async';
import 'dart:io';
import '../../models/server_config.dart';
import '../event_bus.dart';

/// V2Ray服务接口
/// 提供V2Ray进程的启动、停止和状态监控功能
abstract class V2rayService {
  /// 启动V2Ray服务
  /// 
  /// [config] V2Ray服务器配置
  /// 如果服务已在运行，会先停止当前服务再启动新服务
  Future<void> start(ServerConfig config);

  /// 停止V2Ray服务
  /// 停止当前运行的V2Ray进程
  Future<void> stop();

  /// 检查V2Ray服务是否正在运行
  /// 返回服务运行状态
  Future<bool> isRunning();

  /// 获取流量统计数据流
  /// 用于实时监控服务器流量情况
  Stream<TrafficStatsEvent> get trafficStats;
}

/// V2Ray服务实现类
class V2rayServiceImpl implements V2rayService {
  /// V2Ray进程实例
  Process? _process;
  
  /// 事件总线实例，用于发送服务状态变更事件
  final _eventBus = EventBus();
  
  /// 流量统计定时器
  Timer? _statsTimer;
  
  @override
  Future<void> start(ServerConfig config) async {
    // 如果服务已在运行，先停止当前服务
    if (await isRunning()) {
      await stop();
    }
    
    try {
      // 生成V2Ray配置文件
      final configJson = config.toV2rayConfig();
      final configFile = File('config.json');
      await configFile.writeAsString(configJson);
      
      // 启动V2Ray进程
      _process = await Process.start(
        'v2ray',
        ['--config', configFile.path],
      );
      
      // 启动流量统计监控
      _startTrafficStats(config.id);
      
      // 发送服务启动事件
      _eventBus.emit(ServerStatusChangedEvent(config.id, true));
    } catch (e) {
      throw Exception('Failed to start V2Ray: $e');
    }
  }
  
  @override
  Future<void> stop() async {
    _statsTimer?.cancel();
    _statsTimer = null;
    
    if (_process != null) {
      _process!.kill();
      await _process!.exitCode;
      _process = null;
    }
  }
  
  @override
  Future<bool> isRunning() async {
    if (_process == null) return false;
    try {
      return await _process!.exitCode.then((_) => false).catchError((_) => true);
    } catch (e) {
      return false;
    }
  }
  
  void _startTrafficStats(String serverId) {
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // 模拟获取流量统计
      _eventBus.emit(TrafficStatsEvent(
        serverId,
        1024,  // upBytes
        2048,  // downBytes
      ));
    });
  }
  
  @override
  Stream<TrafficStatsEvent> get trafficStats => _eventBus.on<TrafficStatsEvent>();
  
  void dispose() {
    stop();
  }
}