import 'dart:convert';
import '../../server_config.dart';
import 'subscription_link_parser.dart';

/// Shadowsocks链接解析器
/// 
/// 用于解析Shadowsocks协议的链接
class ShadowsocksLinkParser implements SubscriptionLinkParser {
  @override
  bool canParse(String link) {
    return link.startsWith('ss://');
  }
  
  @override
  ServerConfig? parse(String link) {
    if (!canParse(link)) return null;
    
    try {
      // ss://base64(method:password)@host:port#name
      String ssLink = link.substring(5); // 移除 'ss://'
      
      // 处理名称部分
      String name = 'Shadowsocks Server';
      if (ssLink.contains('#')) {
        final parts = ssLink.split('#');
        ssLink = parts[0];
        if (parts.length > 1) {
          name = Uri.decodeComponent(parts[1]);
        }
      }
      
      // 解析用户信息和服务器地址
      final atIndex = ssLink.indexOf('@');
      if (atIndex == -1) {
        throw Exception('Invalid Shadowsocks link format');
      }
      
      final userInfoBase64 = ssLink.substring(0, atIndex);
      final serverPart = ssLink.substring(atIndex + 1);
      
      // 解码用户信息
      String userInfo;
      try {
        userInfo = utf8.decode(base64.decode(userInfoBase64));
      } catch (e) {
        // 如果解码失败，尝试URL解码
        userInfo = Uri.decodeComponent(userInfoBase64);
      }
      
      final methodPwdParts = userInfo.split(':');
      if (methodPwdParts.length != 2) {
        throw Exception('Invalid Shadowsocks user info format');
      }
      
      final method = methodPwdParts[0];
      final password = methodPwdParts[1];
      
      // 解析服务器地址和端口
      final serverParts = serverPart.split(':');
      if (serverParts.length != 2) {
        throw Exception('Invalid Shadowsocks server format');
      }
      
      final host = serverParts[0];
      final port = int.tryParse(serverParts[1]);
      
      if (port == null) {
        throw Exception('Invalid Shadowsocks port');
      }
      
      return ServerConfig(
        name: name,
        address: host,
        port: port,
        protocol: 'shadowsocks',
        settings: {
          'method': method,
          'password': password,
        },
      );
    } catch (e) {
      print('解析Shadowsocks链接失败: ${e.toString()}');
      return null;
    }
  }
}