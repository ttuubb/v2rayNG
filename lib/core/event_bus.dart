import 'dart:async';

class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final _streamControllers = <Type, StreamController<dynamic>>{};

  void emit<T>(T event) {
    if (!_streamControllers.containsKey(T)) {
      _streamControllers[T] = StreamController<T>.broadcast();
    }
    _streamControllers[T]?.add(event);
  }

  void fire<T>(T event) {
    emit(event);
  }

  Stream<T> on<T>() {
    if (!_streamControllers.containsKey(T)) {
      _streamControllers[T] = StreamController<T>.broadcast();
    }
    return _streamControllers[T]?.stream as Stream<T>;
  }

  void dispose() {
    for (var controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }
}

// 事件定义
class ServerStatusChangedEvent {
  final String serverId;
  final bool isEnabled;

  ServerStatusChangedEvent(this.serverId, this.isEnabled);
}

class SubscriptionUpdatedEvent {
  final String url;
  final bool success;
  final String? error;

  SubscriptionUpdatedEvent(this.url, this.success, {this.error});
}

class TrafficStatsEvent {
  final String serverId;
  final int upBytes;
  final int downBytes;

  TrafficStatsEvent(this.serverId, this.upBytes, this.downBytes);
}