import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:v2rayng/core/di/service_locator.dart';
import 'package:v2rayng/core/providers/app_state_provider.dart';

class V2rayNGApp extends StatelessWidget {
  const V2rayNGApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => getIt<AppStateProvider>(),
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'V2rayNG',
            // 主题配置
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: appState.themeMode,

            // 国际化配置
            locale: appState.locale,
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // 路由配置
            initialRoute: '/',
            onGenerateRoute: (settings) {
              // TODO: 实现路由配置
              return null;
            },

            // 主题配置
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // 设置文字缩放
                  textScaleFactor: 1.0,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
