/// 全局常量定义

// 网络相关常量
class NetworkConstants {
  static const int MAX_RETRY_COUNT = 3;
  static const int CONNECTION_TIMEOUT = 30000; // 毫秒
  static const String DEFAULT_USER_AGENT = 'v2rayNG/flutter';
}

// 缓存相关常量
class CacheConstants {
  static const String SERVER_CONFIG_KEY = 'server_configs';
  static const String ROUTING_RULES_KEY = 'routing_rules';
  static const Duration CACHE_DURATION = Duration(days: 7);
}

// UI相关常量
class UIConstants {
  static const double LIST_ITEM_HEIGHT = 72.0;
  static const double ICON_SIZE = 24.0;
  static const Duration ANIMATION_DURATION = Duration(milliseconds: 300);
}