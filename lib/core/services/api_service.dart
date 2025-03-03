import 'dart:io';
import 'package:http/http.dart' as http;

/// API服务接口
/// 提供订阅获取和连接测试等网络相关功能
abstract class ApiService {
  /// 获取订阅内容
  /// 
  /// [url] 订阅地址
  /// 返回订阅内容字符串
  /// 如果获取失败则抛出异常
  Future<String> fetchSubscription(String url);

  /// 测试服务器连接
  /// 
  /// [address] 服务器地址
  /// [port] 服务器端口
  /// 返回连接是否成功
  Future<bool> testConnection(String address, int port);
}

/// API服务实现类
class ApiServiceImpl implements ApiService {
  /// HTTP客户端实例
  final http.Client _client = http.Client();

  @override
  Future<String> fetchSubscription(String url) async {
    try {
      // 发送GET请求获取订阅内容
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        // 请求失败，抛出异常
        throw Exception('Failed to fetch subscription: ${response.statusCode}');
      }
    } catch (e) {
      // 网络错误，抛出异常
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<bool> testConnection(String address, int port) async {
    try {
      // 尝试建立Socket连接
      final socket = await Socket.connect(address, port, timeout: Duration(seconds: 5));
      await socket.close();
      return true;
    } catch (e) {
      // 连接失败返回false
      return false;
    }
  }

  /// 释放资源
  /// 
  /// 关闭HTTP客户端连接
  void dispose() {
    _client.close();
  }
}