import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/traffic_viewmodel.dart';
import '../models/traffic_history.dart';

class TrafficPage extends StatefulWidget {
  final String serverId;

  const TrafficPage({Key? key, required this.serverId}) : super(key: key);

  @override
  _TrafficPageState createState() => _TrafficPageState();
}

class _TrafficPageState extends State<TrafficPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'day';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 加载流量数据
    Future.microtask(() {
      final viewModel = context.read<TrafficViewModel>();
      viewModel.loadTrafficHistory(widget.serverId);
      viewModel.startMonitoring(widget.serverId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    context.read<TrafficViewModel>().stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('流量统计'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '实时流量'),
            Tab(text: '历史统计'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRealtimeTrafficTab(),
          _buildHistoryTrafficTab(),
        ],
      ),
    );
  }

  Widget _buildRealtimeTrafficTab() {
    return Consumer<TrafficViewModel>(
      builder: (context, viewModel, child) {
        final stats = viewModel.currentStats;
        
        if (stats == null) {
          return const Center(child: Text('暂无流量数据'));
        }
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrafficCard(
                title: '上传速度',
                value: _formatSpeed(stats.uploadSpeed),
                icon: Icons.upload,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildTrafficCard(
                title: '下载速度',
                value: _formatSpeed(stats.downloadSpeed),
                icon: Icons.download,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildTrafficCard(
                title: '总上传流量',
                value: _formatBytes(stats.totalUpload),
                icon: Icons.cloud_upload,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildTrafficCard(
                title: '总下载流量',
                value: _formatBytes(stats.totalDownload),
                icon: Icons.cloud_download,
                color: Colors.purple,
              ),
              const SizedBox(height: 24),
              Text(
                '最后更新: ${stats.timestamp.toString().substring(0, 19)}',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTrafficTab() {
    return Consumer<TrafficViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(child: Text('错误: ${viewModel.error}'));
        }

        if (viewModel.history.isEmpty) {
          return const Center(child: Text('暂无历史数据'));
        }

        // 按周期筛选数据
        final filteredHistory = viewModel.history
            .where((h) => h.period == _selectedPeriod)
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'hour', label: Text('小时')),
                  ButtonSegment(value: 'day', label: Text('天')),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _selectedPeriod = selection.first;
                  });
                },
              ),
            ),
            Expanded(
              child: filteredHistory.isEmpty
                  ? const Center(child: Text('所选周期暂无数据'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildTrafficChart(filteredHistory),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('总上传: ${_formatBytes(_calculateTotalUpload(filteredHistory))}'),
                  Text('总下载: ${_formatBytes(_calculateTotalDownload(filteredHistory))}'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrafficCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficChart(List<TrafficHistory> history) {
    // 按时间排序
    history.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // 准备图表数据
    final uploadSpots = history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.uploadTotal / 1024 / 1024); // MB
    }).toList();
    
    final downloadSpots = history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.downloadTotal / 1024 / 1024); // MB
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < history.length) {
                  final date = history[value.toInt()].startTime;
                  return _selectedPeriod == 'hour'
                      ? Text('${date.hour}:00')
                      : Text('${date.month}/${date.day}');
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()} MB');
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: uploadSpots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
          ),
          LineChartBarData(
            spots: downloadSpots,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < history.length) {
                  final isUpload = spot.barIndex == 0;
                  final date = history[index].startTime;
                  final dateStr = _selectedPeriod == 'hour'
                      ? '${date.hour}:00'
                      : '${date.month}/${date.day}';
                  return LineTooltipItem(
                    '${isUpload ? "上传" : "下载"}: ${spot.y.toStringAsFixed(2)} MB\n$dateStr',
                    TextStyle(color: Colors.white),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.toStringAsFixed(2)} B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(2)} KB/s';
    } else if (bytesPerSecond < 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / 1024 / 1024).toStringAsFixed(2)} MB/s';
    } else {
      return '${(bytesPerSecond / 1024 / 1024 / 1024).toStringAsFixed(2)} GB/s';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
    }
  }

  int _calculateTotalUpload(List<TrafficHistory> history) {
    return history.isEmpty ? 0 : history.last.uploadTotal;
  }

  int _calculateTotalDownload(List<TrafficHistory> history) {
    return history.isEmpty ? 0 : history.last.downloadTotal;
  }
}