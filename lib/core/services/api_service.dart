import 'dart:io';
import 'dart:convert';

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

  @override
  Future<String> fetchSubscription(String url) async {
    try {
      // 使用HttpClient处理自签名证书
      final httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        // 读取响应内容
        final contents = await response.transform(utf8.decoder).join();
        return contents;
      } else {
        // 请求失败，抛出异常
        throw Exception('Failed to fetch subscription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch subscription: ${e.toString()}');
    }
  }

  @override
  Future<bool> testConnection(String address, int port) async {
    try {
      // 尝试建立Socket连接
      final socket = await Socket.connect(address, port,
          timeout: const Duration(seconds: 5));

      // 连接成功，关闭Socket
      socket.destroy();
      return true;
    } catch (e) {
      // 连接失败
      return false;
    }
  }
}
