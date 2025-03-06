import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/server_list_viewmodel.dart';
import '../viewmodels/subscription_viewmodel.dart';
import '../models/server_config.dart';
import 'package:v2rayng/views/server_detail_page.dart';
import 'subscription_page.dart';

/// 服务器列表页面
/// 显示所有配置的代理服务器，支持添加、编辑、删除和启用/禁用服务器
/// 使用Provider模式进行状态管理，通过ServerListViewModel处理服务器相关的业务逻辑
class ServerListPage extends StatefulWidget {
  const ServerListPage({Key? key}) : super(key: key);
  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

/// 服务器列表页面状态类
/// 维护服务器列表的状态和用户交互逻辑
class _ServerListPageState extends State<ServerListPage> {
  @override
  void initState() {
    super.initState();
    // 在微任务队列中加载服务器列表数据，避免在构建过程中调用setState
    Future.microtask(() =>
        Provider.of<ServerListViewModel>(context, listen: false).loadServers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务器列表'),
        actions: [
          // 订阅管理按钮
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPage(),
                ),
              );
            },
          ),
          // 刷新订阅按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<SubscriptionViewModel>(context, listen: false)
                  .refreshSubscriptions();
            },
          ),
          // 添加新服务器按钮
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServerDetailPage(),
                ),
              );
            },
          ),
        ],
      ),
      // 使用Consumer监听ServerListViewModel的状态变化
      body: Consumer<ServerListViewModel>(
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
          if (viewModel.servers.isEmpty) {
            return const Center(child: Text('没有服务器配置，请添加新服务器'));
          }

          // 使用ListView.builder高效构建服务器列表
          return ListView.builder(
            itemCount: viewModel.servers.length,
            itemBuilder: (context, index) {
              final server = viewModel.servers[index];
              return ServerListItem(
                server: server,
                onToggle: () => viewModel.toggleServerStatus(server),
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServerDetailPage(server: server),
                    ),
                  );
                },
                onDelete: () =>
                    _showDeleteConfirmation(context, viewModel, server),
              );
            },
          );
        },
      ),
    );
  }

  /// 显示删除确认对话框
  /// 提示用户确认是否要删除选中的服务器
  void _showDeleteConfirmation(BuildContext context,
      ServerListViewModel viewModel, ServerConfig server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除服务器'),
        content: Text('确定要删除服务器 "${server.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteServer(server.name);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 服务器列表项组件
/// 用于显示单个服务器的信息卡片，包含服务器状态、基本信息和操作按钮
class ServerListItem extends StatelessWidget {
  /// 服务器配置信息
  final ServerConfig server;

  /// 切换服务器启用状态的回调函数
  final VoidCallback onToggle;

  /// 编辑服务器配置的回调函数
  final VoidCallback onEdit;

  /// 删除服务器的回调函数
  final VoidCallback onDelete;

  const ServerListItem({
    Key? key,
    required this.server,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.cloud,
          color: server.enabled ? Theme.of(context).primaryColor : Colors.grey,
        ),
        title: Text(server.name),
        subtitle: Text('${server.protocol} - ${server.address}:${server.port}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [],
        ),
      ),
    );
  }
}
