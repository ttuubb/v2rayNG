import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v2rayng/models/server_list_view_model.dart';
import 'package:v2rayng/models/config_model.dart';

/// 服务器列表组件
/// 用于显示服务器列表，支持加载状态、错误状态和空列表状态
class ServerListWidget extends StatelessWidget {
  const ServerListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ServerListViewModel>(context);

    // 显示加载状态
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 显示错误状态
    if (viewModel.error != null) {
      return Center(
        child: Text(viewModel.error!),
      );
    }

    // 显示服务器列表
    return Material(
      child: ListView.builder(
        itemCount: viewModel.servers.isEmpty ? 1 : viewModel.servers.length,
        itemBuilder: (context, index) {
          // 显示空列表提示
          if (viewModel.servers.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('暂无服务器'),
              ),
            );
          }

          // 显示服务器项
          final server = viewModel.servers[index];
          return ListTile(
            title: Text(server.address),
            subtitle: Text('${server.protocol} - ${server.port}'),
            trailing: Icon(
              Icons.circle,
              color: Colors.green,
              size: 12,
            ),
            onTap: () {
              // 处理服务器项点击事件
              // 这里可以添加选择服务器的逻辑
            },
          );
        },
      ),
    );
  }
}
