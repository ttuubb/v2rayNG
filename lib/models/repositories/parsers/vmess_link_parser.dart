import 'dart:convert';
import '../../server_config.dart';
import 'subscription_link_parser.dart';

/// VMess链接解析器
/// 
/// 用于解析VMess协议的链接
class VmessLinkParser implements SubscriptionLinkParser {
  @override
  bool canParse(String link) {
    return link.startsWith('vmess://');
  }
  
  @override
  ServerConfig? parse(String link) {
    if (!canParse(link)) return null;
    
    try {
      // 移除协议前缀并进行Base64解码
      final base64Str = link.substring(8);
      final jsonStr = utf8.decode(base64.decode(base64Str));
      final Map<String, dynamic> vmessConfig = json.decode(jsonStr);
      
      // 提取必要的配置信息
      final String name = vmessConfig['ps'] ?? vmessConfig['name'] ?? 'VMess Server';
      final String? address = vmessConfig['add'];
      final int? port = int.tryParse(vmessConfig['port'].toString());
      final String? id = vmessConfig['id']; // UUID
      final int? alterId = int.tryParse(vmessConfig['aid'].toString()) ?? 0;
      final String network = vmessConfig['net'] ?? 'tcp';
      final String security = vmessConfig['tls'] == 'tls' ? 'tls' : 'none';
      
      if (address == null || port == null || id == null) {
        throw Exception('Missing required VMess parameters');
      }
      
      // 创建服务器配置
      return ServerConfig(
        name: name,
        address: address,
        port: port,
        protocol: 'vmess',
        settings: {
          'id': id,
          'alterId': alterId,
          'security': 'auto',
          'network': network,
          'tls': security,
          // 其他可选参数
          'path': vmessConfig['path'] ?? '',
          'host': vmessConfig['host'] ?? '',
          'type': vmessConfig['type'] ?? '',
        },
      );
    } catch (e) {
      print('解析VMess链接失败: ${e.toString()}');
      return null;
    }
  }
}