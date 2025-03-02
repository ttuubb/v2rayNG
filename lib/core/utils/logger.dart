import 'package:flutter/foundation.dart';

/// 日志工具类
class Logger {
  static const String _tag = 'V2rayNG';
  
  // 是否启用调试日志
  static bool _debugMode = false;
  
  /// 设置调试模式
  static void setDebugMode(bool enabled) {
    _debugMode = enabled;
  }
  
  /// 调试日志
  static void d(String message) {
    if (_debugMode) {
      debugPrint('$_tag/DEBUG: $message');
    }
  }
  
  /// 信息日志
  static void i(String message) {
    debugPrint('$_tag/INFO: $message');
  }
  
  /// 警告日志
  static void w(String message) {
    debugPrint('$_tag/WARN: $message');
  }
  
  /// 错误日志
  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('$_tag/ERROR: $message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }
}