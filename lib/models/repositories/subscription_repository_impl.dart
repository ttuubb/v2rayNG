import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../subscription.dart';
import 'subscription_repository.dart';
import '../server_config.dart';
import '../../core/di/service_locator.dart';
import 'server_repository.dart';
import 'parsers/vmess_link_parser.dart';
import 'parsers/vless_link_parser.dart';
import 'parsers/shadowsocks_link_parser.dart';
import 'parsers/trojan_link_parser.dart';

// 实现SubscriptionRepository接口的类，用于管理订阅信息
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SharedPreferences _prefs;
  final String _subscriptionKey = 'subscriptions';
  final http.Client _httpClient;

  // 预初始化解析器列表，避免每次解析订阅内容时都创建新实例
  final List<dynamic> _parsers = [
    VmessLinkParser(),
    VlessLinkParser(),
    ShadowsocksLinkParser(),
    TrojanLinkParser(),
  ];

  SubscriptionRepositoryImpl(this._prefs, this._httpClient);

  // 获取所有订阅信息
  @override
  Future<List<Subscription>> getAllSubscriptions() async {
    final String? data = _prefs.getString(_subscriptionKey);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Subscription.fromJson(json)).toList();
  }

  // 根据ID获取特定订阅信息
  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    final subscriptions = await getAllSubscriptions();
    try {
      return subscriptions.firstWhere((sub) => sub.id == id);
    } catch (e) {
      // 如果找不到对应ID的订阅，返回null
      return null;
    }
  }

  // 添加新的订阅信息
  @override
  Future<void> addSubscription(Subscription subscription) async {
    final subscriptions = await getAllSubscriptions();
    subscriptions.add(subscription);
    await _saveSubscriptions(subscriptions);
  }

  // 更新特定ID的订阅信息
  @override
  Future<void> updateSubscription(Subscription subscription) async {
    final subscriptions = await getAllSubscriptions();
    final index = subscriptions.indexWhere((sub) => sub.id == subscription.id);
    if (index != -1) {
      subscriptions[index] = subscription;
      await _saveSubscriptions(subscriptions);
    }
  }

  // 删除特定ID的订阅信息，并清理关联的服务器配置
  @override
  Future<void> deleteSubscription(String id) async {
    final subscriptions = await getAllSubscriptions();
    subscriptions.removeWhere((sub) => sub.id == id);
    await _saveSubscriptions(subscriptions);

    // 清理该订阅关联的所有服务器配置
    final serverRepository = getIt<ServerRepository>();
    final servers = await serverRepository.getAllServers();
    for (final server in servers) {
      if (server.subscriptionId == id) {
        await serverRepository.deleteServer(server.id);
      }
    }
  }

  // 更新特定ID订阅的内容
  @override
  Future<void> updateSubscriptionContent(String id) async {
    final subscription = await getSubscriptionById(id);
    if (subscription == null) return;

    try {
      // 获取ServerRepository实例
      final serverRepository = getIt<ServerRepository>();

      // 获取当前订阅下的所有服务器
      final currentServers =
          await serverRepository.getServersBySubscriptionId(subscription.id);

      final response = await _httpClient.get(Uri.parse(subscription.url));
      if (response.statusCode == 200) {
        // 解析订阅内容，生成服务器配置列表
        final serverConfigs = await _parseSubscriptionContent(response.body);

        // 清除该订阅下的所有旧节点
        for (final server in currentServers) {
          await serverRepository.deleteServer(server.id);
        }

        // 获取所有现有服务器用于去重
        final existingServers = await serverRepository.getAllServers();

        for (final config in serverConfigs) {
          try {
            // 检查是否存在相同的服务器配置
            ServerConfig? existingServer;
            try {
              existingServer = existingServers.firstWhere((s) =>
                  s.address == config.address &&
                  s.port == config.port &&
                  s.protocol == config.protocol);
            } catch (e) {
              // 如果找不到匹配的服务器配置，existingServer将保持为null
              existingServer = null;
            }

            if (existingServer != null) {
              // 如果存在相同配置，则更新现有配置
              final updatedConfig = config.copyWith(id: existingServer.id);
              await serverRepository.updateServer(updatedConfig);
            } else {
              // 如果不存在相同配置，则添加新配置
              await serverRepository.addServer(config);
            }
          } catch (e) {
            // 记录错误但继续处理其他配置
            print('处理服务器配置失败: ${e.toString()}');
          }
        }

        // 更新订阅状态
        final updatedSubscription = subscription.copyWith(
            lastUpdateTime: DateTime.now(), lastError: null, isUpdating: false);
        await updateSubscription(updatedSubscription);
      } else {
        throw Exception(
            'Failed to update subscription: ${response.statusCode}');
      }
    } catch (e) {
      final updatedSubscription =
          subscription.copyWith(lastError: e.toString(), isUpdating: false);
      await updateSubscription(updatedSubscription);
      rethrow;
    }
  }

  // 导入订阅信息
  @override
  Future<void> importSubscriptions(String content) async {
    try {
      final List<dynamic> jsonList = json.decode(content);
      final List<Subscription> subscriptions =
          jsonList.map((json) => Subscription.fromJson(json)).toList();
      await _saveSubscriptions(subscriptions);
    } catch (e) {
      throw Exception('Invalid subscription format');
    }
  }

  // 导出所有订阅信息
  @override
  Future<String> exportSubscriptions() async {
    final subscriptions = await getAllSubscriptions();
    return json.encode(subscriptions.map((sub) => sub.toJson()).toList());
  }

  // 刷新所有订阅信息
  @override
  Future<void> refreshSubscriptions() async {
    final subscriptions = await getAllSubscriptions();
    for (final subscription in subscriptions) {
      try {
        // 更新订阅状态为正在更新
        final updatingSubscription = subscription.copyWith(isUpdating: true);
        await updateSubscription(updatingSubscription);

        await updateSubscriptionContent(subscription.id);
      } catch (e) {
        print('刷新订阅${subscription.name}失败: ${e.toString()}');
        // 更新订阅错误状态
        final failedSubscription = subscription.copyWith(
          isUpdating: false,
          lastError: e.toString(),
        );
        await updateSubscription(failedSubscription);
      }
    }
  }

  // 检查并自动更新订阅信息
  Future<void> checkAndAutoUpdate() async {
    final subscriptions = await getAllSubscriptions();
    for (final subscription in subscriptions) {
      if (!subscription.autoUpdate) continue;

      final lastUpdate = subscription.lastUpdateTime ?? DateTime.now();
      final hoursSinceUpdate = DateTime.now().difference(lastUpdate).inHours;

      if (hoursSinceUpdate >= subscription.updateInterval) {
        try {
          await updateSubscriptionContent(subscription.id);
        } catch (e) {
          // 错误已在updateSubscriptionContent中处理
          continue;
        }
      }
    }
  }

  // 清除特定ID订阅的错误信息
  @override
  Future<void> clearError(String id) async {
    final subscription = await getSubscriptionById(id);
    if (subscription != null) {
      final updatedSubscription = subscription.copyWith(lastError: null);
      await updateSubscription(updatedSubscription);
    }
  }

  // 获取特定ID订阅的最后更新时间
  @override
  Future<DateTime?> getLastUpdateTime(String id) async {
    final subscription = await getSubscriptionById(id);
    return subscription?.lastUpdateTime;
  }

  // 设置特定ID订阅的更新间隔
  @override
  Future<void> setUpdateInterval(String id, int hours) async {
    final subscription = await getSubscriptionById(id);
    if (subscription != null) {
      final updatedSubscription = subscription.copyWith(updateInterval: hours);
      await updateSubscription(updatedSubscription);
    }
  }

  // 设置特定ID订阅的自动更新状态
  @override
  Future<void> setAutoUpdate(String id, bool enabled) async {
    final subscription = await getSubscriptionById(id);
    if (subscription != null) {
      final updatedSubscription = subscription.copyWith(autoUpdate: enabled);
      await updateSubscription(updatedSubscription);
    }
  }

  // 保存订阅信息到SharedPreferences
  Future<void> _saveSubscriptions(List<Subscription> subscriptions) async {
    final String data =
        json.encode(subscriptions.map((sub) => sub.toJson()).toList());
    await _prefs.setString(_subscriptionKey, data);
  }

  /// 解析订阅内容，生成服务器配置列表
  ///
  /// [content] 订阅内容，可能是Base64编码的文本或普通文本
  /// 返回解析出的服务器配置列表
  Future<List<ServerConfig>> _parseSubscriptionContent(String content) async {
    List<ServerConfig> serverConfigs = [];

    // 尝试Base64解码
    String decodedContent;
    try {
      // 移除可能的空白字符
      final cleanContent = content.trim();
      decodedContent = utf8.decode(base64.decode(cleanContent));
    } catch (e) {
      // 如果Base64解码失败，则假设内容是普通文本
      decodedContent = content;
      print('Base64解码失败，使用原始内容: ${e.toString()}');
    }

    // 按行分割，每行可能是一个服务器配置
    final lines = decodedContent.split('\n');
    int successCount = 0;
    int failCount = 0;

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      bool parsed = false;
      try {
        // 使用解析器解析链接
        for (final parser in _parsers) {
          if (parser.canParse(trimmedLine)) {
            final serverConfig = parser.parse(trimmedLine);
            if (serverConfig != null) {
              serverConfigs.add(serverConfig);
              successCount++;
              parsed = true;
              break; // 找到合适的解析器后跳出循环
            }
          }
        }

        if (!parsed) {
          // 没有找到合适的解析器
          print('未找到合适的解析器: $trimmedLine');
          failCount++;
        }
      } catch (e) {
        print('解析服务器配置失败: ${e.toString()}');
        failCount++;
        // 继续解析下一行
        continue;
      }
    }

    print('订阅解析完成: 成功 $successCount 个, 失败 $failCount 个');
    return serverConfigs;
  }
}
