import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/repositories/server_repository.dart';
import '../../viewmodels/server_list_viewmodel.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    // Repository registrations
    final prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<ServerRepository>(ServerRepository(prefs));
    
    // ViewModel registrations
    getIt.registerFactory<ServerListViewModel>(
      () => ServerListViewModel(getIt<ServerRepository>()),
    );
  }
}