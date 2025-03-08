import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeService Tests', () {
    late ThemeService themeService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      themeService = ThemeService(prefs: prefs);
    });

    test('初始主题测试', () {
      expect(themeService.isDarkMode, isFalse);
    });

    test('切换主题测试', () {
      // 切换到深色模式
      themeService.setDarkMode(true);
      expect(themeService.isDarkMode, isTrue);

      // 切换回浅色模式
      themeService.setDarkMode(false);
      expect(themeService.isDarkMode, isFalse);
    });

    test('主题持久化测试', () async {
      // 设置深色模式
      themeService.setDarkMode(true);

      // 创建新的ThemeService实例，验证设置是否被保存
      final newThemeService = ThemeService(prefs: prefs);
      expect(newThemeService.isDarkMode, isTrue);
    });

    test('主题监听器测试', () {
      int callCount = 0;
      bool? lastValue;

      themeService.addListener((isDark) {
        callCount++;
        lastValue = isDark;
      });

      // 切换主题并验证监听器是否被调用
      themeService.setDarkMode(true);
      expect(callCount, equals(1));
      expect(lastValue, isTrue);

      themeService.setDarkMode(false);
      expect(callCount, equals(2));
      expect(lastValue, isFalse);
    });

    test('移除主题监听器测试', () {
      int callCount = 0;
      void listener(bool isDark) => callCount++;

      themeService.addListener(listener);
      themeService.setDarkMode(true);
      expect(callCount, equals(1));

      // 移除监听器
      themeService.removeListener(listener);
      themeService.setDarkMode(false);
      expect(callCount, equals(1));
    });
  });
}