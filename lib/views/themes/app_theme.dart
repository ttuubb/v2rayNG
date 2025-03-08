import 'package:flutter/material.dart';
import 'package:v2rayng/core/di/service_locator.dart';
import 'package:v2rayng/core/services/theme_service.dart';
import 'theme_constants.dart';

/// 应用主题管理
class AppTheme extends ChangeNotifier {
  final ThemeService _themeService = getIt<ThemeService>();

  // 当前主题模式
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // 初始化主题
  AppTheme() {
    _loadThemeMode();
  }

  // 加载主题模式
  Future<void> _loadThemeMode() async {
    _themeMode = _themeService.getThemeMode();
    notifyListeners();
  }

  // 切换主题模式
  Future<void> toggleThemeMode() async {
    await _themeService.toggleTheme();
    _themeMode = _themeService.getThemeMode();
    notifyListeners();
  }

  // 获取当前主题数据
  ThemeData get currentTheme => _themeMode == ThemeMode.dark
      ? ThemeConstants.darkTheme
      : ThemeConstants.lightTheme;
}
