// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/main.dart';
import 'package:v2rayng/views/server_list_page.dart';
import 'package:v2rayng/core/di/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    // 设置SharedPreferences的mock
    SharedPreferences.setMockInitialValues({});
    // 初始化依赖注入
    await ServiceLocator.init();
  });

  testWidgets('HomePage welcome text test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the welcome text is present
    expect(find.text('欢迎使用 V2rayNG'), findsOneWidget);
    expect(find.text('服务器列表'), findsOneWidget);

    // Tap the server list button and verify navigation
    await tester.tap(find.widgetWithText(ElevatedButton, '服务器列表'));
    await tester.pumpAndSettle();

    // Verify that we've navigated to the server list page
    expect(find.byType(ServerListPage), findsOneWidget);
  });
}
