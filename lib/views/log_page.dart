import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/log_viewmodel.dart';
import '../core/services/log_service.dart';

/// 日志页面组件
/// 用于显示应用程序的日志信息，支持日志过滤、导出和清除功能
/// 使用Provider模式进行状态管理，通过LogViewModel处理日志相关的业务逻辑
class LogPage extends StatefulWidget {
  const LogPage({Key? key}) : super(key: key);
  
  @override
  _LogPageState createState() => _LogPageState();
}

/// 日志页面状态类
/// 维护页面的状态数据，包括选中的日志标签和日志级别
class _LogPageState extends State<LogPage> {
  /// 当前选中的日志标签
  String? _selectedTag;
  
  /// 当前选中的日志级别
  LogLevel _selectedLevel = LogLevel.debug;
  
  @override
  void initState() {
    super.initState();
    // 在微任务队列中加载日志数据，避免在构建过程中调用setState
    Future.microtask(() {
      context.read<LogViewModel>().loadLogs();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志'),
        actions: [
          // 日志筛选按钮
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          // 日志导出按钮
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportLogs,
          ),
          // 清除日志按钮
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmClearLogs,
          ),
        ],
      ),
      // 使用Consumer监听LogViewModel的状态变化
      body: Consumer<LogViewModel>(
        builder: (context, viewModel, child) {
          // 显示加载状态
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
  
          // 显示错误信息
          if (viewModel.error != null) {
            return Center(child: Text('错误: ${viewModel.error}'));
          }
  
          // 显示空状态
          if (viewModel.logs.isEmpty) {
            return const Center(child: Text('暂无日志'));
          }
  
          // 使用ListView.builder高效构建日志列表
          return ListView.builder(
            itemCount: viewModel.logs.length,
            itemBuilder: (context, index) {
              // 倒序显示日志，最新的日志显示在顶部
              final log = viewModel.logs[viewModel.logs.length - 1 - index];
              return LogEntryTile(log: log);
            },
          );
        },
      ),
    );
  }
  
  /// 显示日志筛选对话框
  /// 允许用户选择日志级别和标签进行过滤
  void _showFilterDialog() {
    final viewModel = context.read<LogViewModel>();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('筛选日志'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('日志级别:'),
                  // 日志级别下拉选择框
                  DropdownButton<LogLevel>(
                    value: _selectedLevel,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLevel = value;
                        });
                      }
                    },
                    items: LogLevel.values.map((level) {
                      return DropdownMenuItem<LogLevel>(
                        value: level,
                        child: Text(level.toString().split('.').last.toUpperCase()),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('标签:'),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: '输入标签名称',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedTag = value.isEmpty ? null : value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    viewModel.clearFilters();
                  },
                  child: const Text('清除筛选'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    viewModel.setLevelFilter(_selectedLevel);
                    if (_selectedTag != null) {
                      viewModel.setTagFilter(_selectedTag);
                    }
                  },
                  child: const Text('应用'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _exportLogs() async {
    final viewModel = context.read<LogViewModel>();
    try {
      final path = await viewModel.exportLogs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('日志已导出到: $path')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败: $e')),
      );
    }
  }
  
  void _confirmClearLogs() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清除日志'),
          content: const Text('确定要清除所有日志吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<LogViewModel>().clearLogs();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}

class LogEntryTile extends StatelessWidget {
  final LogEntry log;
  const LogEntryTile({Key? key, required this.log}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        log.message,
        style: TextStyle(
          color: _getLogLevelColor(log.level),
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '${log.timestamp.toString().substring(0, 19)} ${log.tag != null ? "[${log.tag}]" : ""}',
        style: TextStyle(fontSize: 12),
      ),
      children: [
        if (log.details != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(log.details!),
          ),
      ],
    );
  }
  Color _getLogLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}