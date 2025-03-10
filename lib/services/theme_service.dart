import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'app_theme_dark_mode';
  final SharedPreferences prefs;
  final List<Function(bool)> _listeners = [];

  ThemeService({required this.prefs});

  // 获取当前主题模式
  bool get isDarkMode => prefs.getBool(_themeKey) ?? false;

  // 设置主题模式
  void setDarkMode(bool isDark) {
    prefs.setBool(_themeKey, isDark);

    // 通知监听器
    for (var listener in _listeners) {
      listener(isDark);
    }
  }

  // 添加主题变化监听器
  void addListener(Function(bool) listener) {
    _listeners.add(listener);
  }

  // 移除主题变化监听器
  void removeListener(Function(bool) listener) {
    _listeners.remove(listener);
  }
}
