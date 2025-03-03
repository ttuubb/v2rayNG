import '../../server_config.dart';

/// 订阅链接解析器接口
/// 
/// 定义了解析不同协议链接的标准接口
abstract class SubscriptionLinkParser {
  /// 检查是否支持解析该链接
  /// 
  /// [link] 待检查的链接
  /// 返回是否支持解析
  bool canParse(String link);
  
  /// 解析链接
  /// 
  /// [link] 待解析的链接
  /// 返回解析出的服务器配置，如果解析失败返回null
  ServerConfig? parse(String link);
}