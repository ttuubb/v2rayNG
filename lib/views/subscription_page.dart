import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/subscription_viewmodel.dart';
import '../models/subscription.dart';

/// 订阅管理页面
/// 用于管理V2Ray服务器订阅源，支持添加、编辑、删除和更新订阅
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  void initState() {
    super.initState();
    // 在页面初始化时加载订阅列表
    Future.microtask(() =>
        Provider.of<SubscriptionViewModel>(context, listen: false).loadSubscriptions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅管理'),
        actions: [
          // 添加新订阅按钮
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showSubscriptionDialog(context),
          ),
        ],
      ),
      body: Consumer<SubscriptionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('错误：${viewModel.error}'));
          }

          if (viewModel.subscriptions.isEmpty) {
            return const Center(child: Text('暂无订阅，点击右上角添加'));
          }

          return ListView.builder(
            itemCount: viewModel.subscriptions.length,
            itemBuilder: (context, index) {
              final subscription = viewModel.subscriptions[index];
              return _buildSubscriptionItem(context, subscription, viewModel);
            },
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionItem(BuildContext context, Subscription subscription, SubscriptionViewModel viewModel) {
    return ListTile(
      title: Text(subscription.name),
      subtitle: Text(subscription.url),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 更新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: subscription.isUpdating
                ? null
                : () => viewModel.updateSubscription(subscription.id),
          ),
          // 编辑按钮
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showSubscriptionDialog(context, subscription),
          ),
          // 删除按钮
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, subscription, viewModel),
          ),
        ],
      ),
    );
  }

  Future<void> _showSubscriptionDialog(BuildContext context, [Subscription? subscription]) async {
    final nameController = TextEditingController(text: subscription?.name ?? '');
    final urlController = TextEditingController(text: subscription?.url ?? '');
    final autoUpdate = ValueNotifier<bool>(subscription?.autoUpdate ?? true);
    final updateInterval = ValueNotifier<int>(subscription?.updateInterval ?? 24);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(subscription == null ? '添加订阅' : '编辑订阅'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '订阅名称'),
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: '订阅地址'),
              ),
              StatefulBuilder(
                builder: (context, setState) => CheckboxListTile(
                  title: const Text('自动更新'),
                  value: autoUpdate.value,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => autoUpdate.value = value);
                    }
                  },
                ),
              ),
              if (autoUpdate.value)
                TextFormField(
                  initialValue: updateInterval.value.toString(),
                  decoration: const InputDecoration(labelText: '更新间隔（小时）'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final interval = int.tryParse(value);
                    if (interval != null && interval > 0) {
                      updateInterval.value = interval;
                    }
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final viewModel = context.read<SubscriptionViewModel>();
              final name = nameController.text.trim();
              final url = urlController.text.trim();

              if (name.isEmpty || url.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写完整信息')),
                );
                return;
              }

              if (subscription != null) {
                // 更新现有订阅
                viewModel.updateSubscriptionConfig(
                  subscription.id,
                  name: name,
                  url: url,
                  autoUpdate: autoUpdate.value,
                  updateInterval: updateInterval.value,
                );
              } else {
                // 添加新订阅
                final newSubscription = Subscription(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  url: url,
                  autoUpdate: autoUpdate.value,
                  updateInterval: updateInterval.value,
                  isUpdating: false,
                  lastUpdateTime: null,
                  lastError: null
                );
                viewModel.addSubscription(newSubscription);
              }

              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Subscription subscription, SubscriptionViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除订阅'),
        content: Text('确定要删除订阅「${subscription.name}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      viewModel.deleteSubscription(subscription.id);
    }
  }
}