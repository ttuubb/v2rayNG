import 'package:flutter/material.dart';
import 'package:v2rayng/core/di/service_locator.dart';
import 'package:v2rayng/core/services/theme_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDarkMode = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initThemeMode();
  }

  Future<void> _initThemeMode() async {
    final themeService = getIt<ThemeService>();
    final isDark = await themeService.isDarkMode();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeService = getIt<ThemeService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('V2rayNG'),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () async {
              await themeService.toggleTheme();
              final isDark = await themeService.isDarkMode();
              setState(() {
                _isDarkMode = isDark;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.vpn_lock,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'V2rayNG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('设置'),
              onTap: () {
                // TODO: 导航到设置页面
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('关于'),
              onTap: () {
                // TODO: 导航到关于页面
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          Center(child: Text('服务器列表')),
          Center(child: Text('订阅管理')),
          Center(child: Text('路由规则')),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list),
            label: '服务器',
          ),
          NavigationDestination(
            icon: Icon(Icons.subscriptions),
            label: '订阅',
          ),
          NavigationDestination(
            icon: Icon(Icons.route),
            label: '路由',
          ),
        ],
      ),
    );
  }
}
