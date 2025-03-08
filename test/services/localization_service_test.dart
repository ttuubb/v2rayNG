import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/services/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalizationService Tests', () {
    late LocalizationService localizationService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      localizationService = LocalizationService(prefs: prefs);
    });

    test('初始语言测试', () {
      expect(localizationService.currentLocale, equals('en'));
    });

    test('切换语言测试', () {
      // 切换到中文
      localizationService.setLocale('zh');
      expect(localizationService.currentLocale, equals('zh'));

      // 切换到英文
      localizationService.setLocale('en');
      expect(localizationService.currentLocale, equals('en'));
    });

    test('语言持久化测试', () async {
      // 设置中文
      localizationService.setLocale('zh');

      // 创建新的LocalizationService实例，验证设置是否被保存
      final newLocalizationService = LocalizationService(prefs: prefs);
      expect(newLocalizationService.currentLocale, equals('zh'));
    });

    test('无效语言代码测试', () {
      // 尝试设置无效的语言代码
      expect(
        () => localizationService.setLocale('invalid'),
        throwsArgumentError,
      );
    });

    test('语言监听器测试', () {
      int callCount = 0;
      String? lastLocale;

      localizationService.addListener((locale) {
        callCount++;
        lastLocale = locale;
      });

      // 切换语言并验证监听器是否被调用
      localizationService.setLocale('zh');
      expect(callCount, equals(1));
      expect(lastLocale, equals('zh'));

      localizationService.setLocale('en');
      expect(callCount, equals(2));
      expect(lastLocale, equals('en'));
    });

    test('移除语言监听器测试', () {
      int callCount = 0;
      void listener(String locale) => callCount++;

      localizationService.addListener(listener);
      localizationService.setLocale('zh');
      expect(callCount, equals(1));

      // 移除监听器
      localizationService.removeListener(listener);
      localizationService.setLocale('en');
      expect(callCount, equals(1));
    });
  });
}