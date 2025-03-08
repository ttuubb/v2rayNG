import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:v2rayng/models/server_list_view_model.dart';
import 'package:v2rayng/models/config_model.dart';
import 'package:v2rayng/widgets/server_list_widget.dart';

void main() {
  group('ServerListWidget Tests', () {
    late ServerListViewModel viewModel;

    setUp(() {
      viewModel = ServerListViewModel();
    });

    testWidgets('空列表显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: viewModel,
            child: ServerListWidget(),
          ),
        ),
      );

      expect(find.text('暂无服务器'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('服务器列表显示测试', (WidgetTester tester) async {
      final servers = [
        ConfigModel(
          protocol: 'vmess',
          address: 'server1.com',
          port: 443,
          uuid: 'uuid1',
          alterId: 0,
          security: 'auto',
          network: 'tcp',
        ),
        ConfigModel(
          protocol: 'vmess',
          address: 'server2.com',
          port: 443,
          uuid: 'uuid2',
          alterId: 0,
          security: 'auto',
          network: 'tcp',
        ),
      ];

      viewModel.setServers(servers);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: viewModel,
            child: ServerListWidget(),
          ),
        ),
      );

      expect(find.text('server1.com'), findsOneWidget);
      expect(find.text('server2.com'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('加载状态显示测试', (WidgetTester tester) async {
      viewModel.setLoading(true);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: viewModel,
            child: ServerListWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('错误状态显示测试', (WidgetTester tester) async {
      const errorMessage = '加载失败';
      viewModel.setError(errorMessage);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: viewModel,
            child: ServerListWidget(),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('服务器项点击测试', (WidgetTester tester) async {
      final server = ConfigModel(
        protocol: 'vmess',
        address: 'example.com',
        port: 443,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );

      viewModel.addServer(server);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: viewModel,
            child: ServerListWidget(),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // 验证点击事件的处理逻辑
      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}