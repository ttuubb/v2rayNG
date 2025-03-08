import 'package:flutter/material.dart';

/// 主题常量定义
class ThemeConstants {
  // 主题色
  static const MaterialColor primarySwatch = Colors.blue;
  
  // 亮色主题
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: primarySwatch,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      elevation: 1,
      centerTitle: true,
    ),
    cardTheme: const CardTheme(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  // 暗色主题
  static final ThemeData darkTheme = ThemeData(
    primarySwatch: primarySwatch,
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      elevation: 1,
      centerTitle: true,
    ),
    cardTheme: const CardTheme(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}