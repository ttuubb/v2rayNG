import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:v2rayng/core/di/service_locator.dart';
import 'package:v2rayng/viewmodels/server_list_viewmodel.dart';
import 'package:v2rayng/viewmodels/subscription_viewmodel.dart';
import 'package:v2rayng/models/server_config.dart';
import 'package:v2rayng/models/subscription.dart';

/// 性能测试框架
/// 用于测试应用中各个功能模块的性能表现
class PerformanceTestFramework {
  /// 测量函数执行时间
  static Future<PerformanceResult> measureExecutionTime(
    Future<void> Function() testFunction,
    {String? description}
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      await testFunction();
      stopwatch.stop();
      
      return PerformanceResult(
        executionTimeMs: stopwatch.elapsedMilliseconds,
        description: description,
        success: true,
      );
    } catch (e) {
      stopwatch.stop();
      return PerformanceResult(
        executionTimeMs: stopwatch.elapsedMilliseconds,
        description: description,
        success: false,
        error: e.toString(),
      );
    }
  }
  
  /// 测量内存使用情况
  /// 注意：这是一个简化的实现，实际应用中可能需要更复杂的内存分析工具
  static Future<MemoryUsageResult> measureMemoryUsage(
    Future<void> Function() testFunction,
    {String? description}
  ) async {
    // 在实际应用中，这里应该使用平台特定的内存分析工具
    // 这里仅作为示例实现
    final beforeMemory = 0; // 占位，实际实现需要平台特定API
    
    try {
      await testFunction();
      
      final afterMemory = 0; // 占位，实际实现需要平台特定API
      final memoryDelta = afterMemory - beforeMemory;
      
      return MemoryUsageResult(
        memoryUsageBytes: memoryDelta,
        description: description,
        success: true,
      );
    } catch (e) {
      return MemoryUsageResult(
        memoryUsageBytes: 0,
        description: description,
        success: false,
        error: e.toString(),
      );
    }
  }
}

/// 性能测试结果基类
class BasePerformanceResult {
  final String? description;
  final bool success;
  final String? error;
  
  BasePerformanceResult({
    this.description,
    required this.success,
    this.error,
  });
  
  @override
  String toString() {
    final status = success ? 'SUCCESS' : 'FAILED';
    final desc = description != null ? '[$description]' : '';
    final errorMsg = error != null ? '\nError: $error' : '';
    
    return '$status $desc$errorMsg';
  }
}

/// 执行时间测试结果
class PerformanceResult extends BasePerformanceResult {
  final int executionTimeMs;
  
  PerformanceResult({
    required this.executionTimeMs,
    String? description,
    required bool success,
    String? error,
  }) : super(description: description, success: success, error: error);
  
  @override
  String toString() {
    return '${super.toString()}\nExecution time: $executionTimeMs ms';
  }
}

/// 内存使用测试结果
class MemoryUsageResult extends BasePerformanceResult {
  final int memoryUsageBytes;
  
  MemoryUsageResult({
    required this.memoryUsageBytes,
    String? description,
    required bool success,
    String? error,
  }) : super(description: description, success: success, error: error);
  
  @override
  String toString() {
    return '${super.toString()}\nMemory usage: $memoryUsageBytes bytes';
  }
}