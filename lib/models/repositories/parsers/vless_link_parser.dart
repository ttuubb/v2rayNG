import '../../server_config.dart';
import 'subscription_link_parser.dart';

/// VLESS链接解析器
/// 
/// 用于解析VLESS协议的链接
class VlessLinkParser implements SubscriptionLinkParser {
  @override
  bool canParse(String link) {
    return link.startsWith('vless://');
  }
  
  @override
  ServerConfig? parse(String link) {
    if (!canParse(link)) return null;
    
    try {
      // vless://uuid@address:port?params=value#name
      final uri = Uri.parse(link);
      final userInfo = uri.userInfo;
      final host = uri.host;
      final port = uri.port;
      final name = Uri.decodeComponent(uri.fragment);
      
      if (userInfo.isEmpty || host.isEmpty || port == 0) {
        throw Exception('Invalid VLESS link format');
      }
      
      // 解析查询参数
      final params = uri.queryParameters;
      final security = params['security'] ?? 'none';
      final network = params['type'] ?? 'tcp';
      
      return ServerConfig(
        name: name.isNotEmpty ? name : 'VLESS Server',
        address: host,
        port: port,
        protocol: 'vless',
        settings: {
          'id': userInfo,
          'security': security,
          'network': network,
          'path': params['path'] ?? '',
          'host': params['host'] ?? '',
        },
      );
    } catch (e) {
      print('解析VLESS链接失败: ${e.toString()}');
      return null;
    }
  }
}