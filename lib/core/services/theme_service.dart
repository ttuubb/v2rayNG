import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题服务
class ThemeService {
  final SharedPreferences _prefs;
  static const String _darkModeKey = 'dark_mode';

  ThemeService(this._prefs);

  // 亮色主题
  ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      );

  // 暗色主题
  ThemeData get darkTheme => ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      );

  // 获取当前主题模式
  ThemeMode getThemeMode() {
    final isDark = _prefs.getBool(_darkModeKey) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // 切换主题
  Future<void> toggleTheme() async {
    final isDark = await isDarkMode();
    await setDarkMode(!isDark);
  }

  // 获取深色模式状态
  Future<bool> isDarkMode() async {
    return _prefs.getBool(_darkModeKey) ?? false;
  }

  // 设置深色模式状态
  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_darkModeKey, isDark);
  }
}
