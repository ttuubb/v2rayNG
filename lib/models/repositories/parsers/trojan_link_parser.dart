import '../../server_config.dart';
import 'subscription_link_parser.dart';

/// Trojan链接解析器
/// 
/// 用于解析Trojan协议的链接
class TrojanLinkParser implements SubscriptionLinkParser {
  @override
  bool canParse(String link) {
    return link.startsWith('trojan://');
  }
  
  @override
  ServerConfig? parse(String link) {
    if (!canParse(link)) return null;
    
    try {
      // trojan://password@host:port?params=value#name
      final uri = Uri.parse(link);
      final password = uri.userInfo;
      final host = uri.host;
      final port = uri.port;
      final name = Uri.decodeComponent(uri.fragment);
      
      if (password.isEmpty || host.isEmpty || port == 0) {
        throw Exception('Invalid Trojan link format');
      }
      
      // 解析查询参数
      final params = uri.queryParameters;
      final security = params['security'] ?? 'tls';
      
      return ServerConfig(
        name: name.isNotEmpty ? name : 'Trojan Server',
        address: host,
        port: port,
        protocol: 'trojan',
        settings: {
          'password': password,
          'security': security,
          'sni': params['sni'] ?? host,
        },
      );
    } catch (e) {
      print('解析Trojan链接失败: ${e.toString()}');
      return null;
    }
  }
}