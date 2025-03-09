import 'dart:async';
import 'package:http/http.dart' as http;

/// HTTP服务类
/// 提供基本的HTTP请求功能，包括GET和POST请求
class HttpService {
  final http.Client client;

  /// 构造函数
  /// [client] HTTP客户端实例
  HttpService({required this.client});

  /// 执行GET请求
  /// [url] 请求URL
  /// [headers] 请求头
  /// 返回HTTP响应
  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    try {
      return await client.get(
        Uri.parse(url),
        headers: headers,
      );
    } on TimeoutException catch (e) {
      throw TimeoutException('请求超时: $e');
    } catch (e) {
      throw Exception('网络请求失败: $e');
    }
  }

  /// 执行POST请求
  /// [url] 请求URL
  /// [body] 请求体
  /// [headers] 请求头
  /// 返回HTTP响应
  Future<http.Response> post(String url, dynamic body, {Map<String, String>? headers}) async {
    try {
      return await client.post(
        Uri.parse(url),
        body: body,
        headers: headers ?? {'Content-Type': 'application/json'},
      );
    } on TimeoutException catch (e) {
      throw TimeoutException('请求超时: $e');
    } catch (e) {
      throw Exception('网络请求失败: $e');
    }
  }

  /// 执行带超时的请求
  /// [request] 请求函数
  /// [timeout] 超时时间
  /// 返回HTTP响应
  Future<http.Response> withTimeout(Future<http.Response> Function() request, Duration timeout) async {
    try {
      return await request().timeout(timeout);
    } on TimeoutException {
      throw TimeoutException('请求超时，超过了 ${timeout.inSeconds} 秒');
    }
  }
}