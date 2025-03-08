import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用级状态管理Provider
/// 负责管理应用全局状态，如主题、语言、网络状态等
class AppStateProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  
  // 网络状态
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  // 主题模式
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  
  // 语言设置
  Locale _locale = const Locale('zh', 'CN');
  Locale get locale => _locale;
  
  AppStateProvider(this._prefs) {
    _loadPersistedState();
  }
  
  /// 加载持久化的状态
  Future<void> _loadPersistedState() async {
    _themeMode = ThemeMode.values[_prefs.getInt('themeMode') ?? 0];
    final languageCode = _prefs.getString('languageCode') ?? 'zh';
    final countryCode = _prefs.getString('countryCode') ?? 'CN';
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }
  
  /// 更新网络连接状态
  void updateConnectionState(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      notifyListeners();
    }
  }
  
  /// 切换主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _prefs.setInt('themeMode', mode.index);
      notifyListeners();
    }
  }
  
  /// 设置语言
  Future<void> setLocale(Locale locale) async {
    if (_locale != locale) {
      _locale = locale;
      await _prefs.setString('languageCode', locale.languageCode);
      await _prefs.setString('countryCode', locale.countryCode ?? '');
      notifyListeners();
    }
  }
}