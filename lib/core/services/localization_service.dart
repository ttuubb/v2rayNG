import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'app_language';
  final SharedPreferences _prefs;

  LocalizationService(this._prefs);

  // 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'), // 简体中文
    Locale('en', 'US'), // 英文
    Locale('ja', 'JP'), // 日文
  ];

  // 获取当前语言设置
  Locale getCurrentLocale() {
    final languageCode = _prefs.getString(_languageKey) ?? 'zh';
    final countryCode = _prefs.getString('${_languageKey}_country') ?? 'CN';
    return Locale(languageCode, countryCode);
  }

  // 设置新的语言
  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_languageKey, locale.languageCode);
    if (locale.countryCode != null) {
      await _prefs.setString('${_languageKey}_country', locale.countryCode!);
    }
  }

  // 获取语言名称
  String getLanguageName(Locale locale) {
    switch ('${locale.languageCode}_${locale.countryCode}') {
      case 'zh_CN':
        return '简体中文';
      case 'en_US':
        return 'English';
      case 'ja_JP':
        return '日本語';
      default:
        return '简体中文';
    }
  }

  // 判断是否支持该语言
  bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }

  // 获取默认语言
  Locale getDefaultLocale() {
    return const Locale('zh', 'CN');
  }
}