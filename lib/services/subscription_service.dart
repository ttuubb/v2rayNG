import 'package:http/http.dart' as http;
import 'package:v2rayng/models/subscription_model.dart';

class SubscriptionResult {
  final bool isSuccess;
  final List<String>? data;
  final String? error;

  SubscriptionResult({
    required this.isSuccess,
    this.data,
    this.error,
  });
}

class SubscriptionService {
  final http.Client httpClient;

  SubscriptionService({required this.httpClient});

  Future<SubscriptionResult> updateSubscription(
      SubscriptionModel subscription) async {
    try {
      final response = await httpClient.get(Uri.parse(subscription.url));

      if (response.statusCode != 200) {
        return SubscriptionResult(
          isSuccess: false,
          error: '服务器错误: ${response.statusCode}',
        );
      }

      // 简单验证响应内容是否包含有效的订阅数据
      final content = response.body;
      if (!content.contains('vmess://')) {
        return SubscriptionResult(
          isSuccess: false,
          error: '无效的订阅内容',
        );
      }

      // 解析订阅内容，提取服务器配置
      final List<String> servers =
          content.split('\n').where((line) => line.trim().isNotEmpty).toList();

      return SubscriptionResult(
        isSuccess: true,
        data: servers,
      );
    } catch (e) {
      return SubscriptionResult(
        isSuccess: false,
        error: '更新订阅失败: $e',
      );
    }
  }
}
