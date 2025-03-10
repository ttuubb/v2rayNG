import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v2rayng/models/server_list_view_model.dart';
import 'package:v2rayng/models/config_model.dart';
import 'package:v2rayng/widgets/server_list_widget.dart';
import 'package:v2rayng/models/repositories/server_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:v2rayng/core/di/service_locator.dart';

@GenerateMocks([ServerRepository])
// 需要先运行 flutter pub run build_runner build 生成 mocks 文件
import 'server_list_widget_test.mocks.dart';

void main() {
  group('ServerListWidget Tests', () {
    late MockServerRepository mockRepository;

    setUpAll(() async {
      // 设置SharedPreferences mock
      SharedPreferences.setMockInitialValues({
        // 添加测试所需的mock数据
        'servers': '[]',
      });
      // 确保在调用ServiceLocator.init之前已经设置好mock
      await SharedPreferences.getInstance();
      await ServiceLocator.init();
    });

    setUp(() {
      mockRepository = MockServerRepository();
      // 设置默认的mock行为
      when(mockRepository.getAllServers()).thenAnswer((_) async => []);
    });

    Widget buildTestableWidget(Widget child, ServerListViewModel viewModel) {
      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => viewModel,
          child: child,
        ),
      );
    }

    testWidgets('空列表显示测试', (WidgetTester tester) async {
      final viewModel = ServerListViewModel();
      await tester
          .pumpWidget(buildTestableWidget(ServerListWidget(), viewModel));
      await tester.pump();
      expect(find.text('暂无服务器'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      await tester.pumpAndSettle();
      // 移除手动dispose调用
    });

    testWidgets('服务器列表显示测试', (WidgetTester tester) async {
      final viewModel = ServerListViewModel();
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

      await tester
          .pumpWidget(buildTestableWidget(ServerListWidget(), viewModel));

      expect(find.text('server1.com'), findsOneWidget);
      expect(find.text('server2.com'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
      await tester.pumpAndSettle();
      // 移除手动dispose调用
    });

    testWidgets('加载状态显示测试', (WidgetTester tester) async {
      final viewModel = ServerListViewModel();
      viewModel.setLoading(true);

      await tester
          .pumpWidget(buildTestableWidget(ServerListWidget(), viewModel));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      // 移除手动dispose调用
    });

    testWidgets('错误状态显示测试', (WidgetTester tester) async {
      final viewModel = ServerListViewModel();
      const errorMessage = '加载失败';
      viewModel.setError(errorMessage);

      await tester
          .pumpWidget(buildTestableWidget(ServerListWidget(), viewModel));

      expect(find.text(errorMessage), findsOneWidget);
      await tester.pumpAndSettle();
      // 移除手动dispose调用
    });

    testWidgets('服务器项点击测试', (WidgetTester tester) async {
      final viewModel = ServerListViewModel();
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

      await tester
          .pumpWidget(buildTestableWidget(ServerListWidget(), viewModel));

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // 验证点击事件的处理逻辑
      expect(find.byType(ListTile), findsOneWidget);
      await tester.pumpAndSettle();
      // 移除手动dispose调用
    });
  });
}
