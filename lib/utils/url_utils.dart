import 'dart:convert';

/// URL工具类
/// 提供URL解析、编码解码、查询参数处理等功能
class UrlUtils {
  /// 解析URL
  /// [url] URL字符串
  /// 返回解析后的Uri对象
  static Uri parseUrl(String url) {
    try {
      final uri = Uri.parse(url);
      // 验证URI的基本结构
      if (uri.scheme.isEmpty && !url.startsWith('//')) {
        throw FormatException('无效的URL格式: $url');
      }
      return uri;
    } catch (e) {
      throw FormatException('无效的URL格式: $url');
    }
  }

  /// URL编码组件
  /// [value] 需要编码的字符串
  /// 返回编码后的字符串
  static String encodeComponent(String value) {
    String encoded = Uri.encodeComponent(value);
    // 确保感叹号被编码
    encoded = encoded.replaceAll('!', '%21');
    return encoded;
  }

  /// URL解码组件
  /// [value] 需要解码的字符串
  /// 返回解码后的字符串
  static String decodeComponent(String value) {
    return Uri.decodeComponent(value);
  }

  /// 解析查询字符串
  /// [queryString] 查询字符串
  /// 返回解析后的Map
  static Map<String, String> parseQueryString(String queryString) {
    if (queryString.isEmpty) {
      return {};
    }

    final result = <String, String>{};
    final pairs = queryString.split('&');

    for (var pair in pairs) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        result[parts[0]] = parts[1];
      }
    }

    return result;
  }

  /// 解码查询参数
  /// [query] 查询字符串
  /// 返回解码后的Map
  static Map<String, String> decodeQuery(String query) {
    final params = parseQueryString(query);
    final decodedParams = <String, String>{};

    params.forEach((key, value) {
      decodedParams[key] = decodeComponent(value);
    });

    return decodedParams;
  }

  /// 构建URL
  /// [parts] URL各部分
  /// 返回构建的URL字符串
  static String buildUrl(Map<String, String> parts) {
    final scheme = parts['scheme'] ?? 'http';
    final host = parts['host'] ?? '';
    final port = parts['port'];
    final path = parts['path'] ?? '';
    final query = parts['query'];

    var url = '$scheme://$host';

    if (port != null && port.isNotEmpty) {
      url += ':$port';
    }

    if (path.isNotEmpty) {
      if (!path.startsWith('/')) {
        url += '/';
      }
      url += path;
    }

    if (query != null && query.isNotEmpty) {
      url += '?$query';
    }

    return url;
  }
}
