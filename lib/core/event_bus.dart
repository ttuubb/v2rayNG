import 'dart:async';

/// 事件总线类
/// 用于实现应用内的事件发布/订阅机制，支持多种事件类型的分发和处理
class EventBus {
  /// 单例实例
  static final EventBus _instance = EventBus._internal();
  
  /// 工厂构造函数，返回单例实例
  factory EventBus() => _instance;
  
  /// 私有构造函数，用于创建单例
  EventBus._internal();

  /// 事件流控制器映射表，key为事件类型，value为对应的流控制器
  final _streamControllers = <Type, StreamController<dynamic>>{};

  /// 发送事件
  /// [event] 要发送的事件对象
  void emit<T>(T event) {
    if (!_streamControllers.containsKey(T)) {
      _streamControllers[T] = StreamController<T>.broadcast();
    }
    _streamControllers[T]?.add(event);
  }

  /// 发送事件的别名方法
  /// [event] 要发送的事件对象
  void fire<T>(T event) {
    emit(event);
  }

  /// 订阅指定类型的事件流
  /// 返回可以监听的事件流
  Stream<T> on<T>() {
    if (!_streamControllers.containsKey(T)) {
      _streamControllers[T] = StreamController<T>.broadcast();
    }
    return _streamControllers[T]?.stream as Stream<T>;
  }

  /// 释放所有事件流
  void dispose() {
    for (var controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }
}

/// 服务器状态变更事件
/// 用于通知服务器启用状态的变化
class ServerStatusChangedEvent {
  /// 服务器ID
  final String serverId;
  
  /// 是否启用
  final bool isEnabled;

  ServerStatusChangedEvent(this.serverId, this.isEnabled);
}

/// 订阅更新事件
/// 用于通知订阅源更新的结果
class SubscriptionUpdatedEvent {
  /// 订阅地址
  final String url;
  
  /// 是否更新成功
  final bool success;
  
  /// 错误信息，更新失败时包含错误详情
  final String? error;

  SubscriptionUpdatedEvent(this.url, this.success, {this.error});
}

/// 流量统计事件
/// 用于通知服务器流量使用情况的变化
class TrafficStatsEvent {
  /// 服务器ID
  final String serverId;
  
  /// 上传字节数
  final int upBytes;
  
  /// 下载字节数
  final int downBytes;

  TrafficStatsEvent(this.serverId, this.upBytes, this.downBytes);
}