import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/server_list_viewmodel.dart';
import '../models/server_config.dart';
import '../core/di/service_locator.dart';
import 'package:v2rayng/views/server_detail_page.dart';

class ServerListPage extends StatefulWidget {
  const ServerListPage({Key? key}) : super(key: key);

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  @override
  void initState() {
    super.initState();
    // 加载服务器列表数据
    Future.microtask(() =>
        Provider.of<ServerListViewModel>(context, listen: false).loadServers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务器列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // 修复第35行左右的代码
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
      body: Consumer<ServerListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('错误: ${viewModel.error}'));
          }

          if (viewModel.servers.isEmpty) {
            return const Center(child: Text('没有服务器配置，请添加新服务器'));
          }

          return ListView.builder(
            itemCount: viewModel.servers.length,
            itemBuilder: (context, index) {
              final server = viewModel.servers[index];
              return ServerListItem(
                server: server,
                onToggle: () => viewModel.toggleServerStatus(server),
                onEdit: () {
                  // 修复第67行左右的代码
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServerDetailPage(server: server),
                    ),
                  );
                },
                onDelete: () => _showDeleteConfirmation(context, viewModel, server),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ServerListViewModel viewModel, ServerConfig server) {
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

class ServerListItem extends StatelessWidget {
  final ServerConfig server;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
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
          children: [
            Switch(
              value: server.enabled,
              onChanged: (_) => onToggle(),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}