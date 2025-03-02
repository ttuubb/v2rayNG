import 'dart:async';
import 'dart:io';
import '../../models/server_config.dart';
import '../event_bus.dart';

abstract class V2rayService {
  Future<void> start(ServerConfig config);
  Future<void> stop();
  Future<bool> isRunning();
  Stream<TrafficStatsEvent> get trafficStats;
}

class V2rayServiceImpl implements V2rayService {
  Process? _process;
  final _eventBus = EventBus();
  Timer? _statsTimer;
  
  @override
  Future<void> start(ServerConfig config) async {
    if (await isRunning()) {
      await stop();
    }
    
    try {
      // 生成配置文件
      final configJson = config.toV2rayConfig();
      final configFile = File('config.json');
      await configFile.writeAsString(configJson);
      
      // 启动 V2Ray 进程
      _process = await Process.start(
        'v2ray',
        ['--config', configFile.path],
      );
      
      // 启动流量统计
      _startTrafficStats(config.id);
      
      // 发送状态变更事件
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
    _statsTimer = Timer.periodic(Duration(seconds: 1), (_) {
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