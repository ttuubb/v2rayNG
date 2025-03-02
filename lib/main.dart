import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'viewmodels/server_list_viewmodel.dart';
import 'views/server_list_page.dart';
import 'views/server_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ServerListViewModel>(
          create: (_) => getIt<ServerListViewModel>(),
        ),
      ],
      child: MaterialApp(
        title: 'V2rayNG',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark().copyWith(
          useMaterial3: true,
        ),
        home: const HomePage(),
        routes: {
          '/serverList': (context) => const ServerListPage(),
          '/serverDetail': (context) => const ServerDetailPage(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('V2rayNG'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('欢迎使用 V2rayNG', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServerListPage(),
                  ),
                );
              },
              child: const Text('服务器列表'),
            ),
          ],
        ),
      ),
    );
  }
}