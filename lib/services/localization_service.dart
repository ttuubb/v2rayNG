import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'app_language';
  final SharedPreferences prefs;
  final List<Function(String)> _listeners = [];

  // 支持的语言列表
  static const List<String> supportedLocales = ['en', 'zh', 'ja'];

  LocalizationService({required this.prefs});

  // 获取当前语言设置
  String get currentLocale => prefs.getString(_languageKey) ?? 'en';

  // 设置新的语言
  void setLocale(String locale) {
    if (!supportedLocales.contains(locale)) {
      throw ArgumentError('不支持的语言代码: $locale');
    }

    prefs.setString(_languageKey, locale);

    // 通知监听器
    for (var listener in _listeners) {
      listener(locale);
    }
  }

  // 添加语言变化监听器
  void addListener(Function(String) listener) {
    _listeners.add(listener);
  }

  // 移除语言变化监听器
  void removeListener(Function(String) listener) {
    _listeners.remove(listener);
  }
}
