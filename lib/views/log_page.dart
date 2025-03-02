import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/log_viewmodel.dart';
import '../core/services/log_service.dart';

class LogPage extends StatefulWidget {
  const LogPage({Key? key}) : super(key: key);

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  String? _selectedTag;
  LogLevel _selectedLevel = LogLevel.debug;

  @override
  void initState() {
    super.initState();
    // 加载日志数据
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
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmClearLogs,
          ),
        ],
      ),
      body: Consumer<LogViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('错误: ${viewModel.error}'));
          }

          if (viewModel.logs.isEmpty) {
            return const Center(child: Text('暂无日志'));
          }

          return ListView.builder(
            itemCount: viewModel.logs.length,
            itemBuilder: (context, index) {
              final log = viewModel.logs[viewModel.logs.length - 1 - index]; // 倒序显示
              return LogEntryTile(log: log);
            },
          );
        },
      ),
    );
  }

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