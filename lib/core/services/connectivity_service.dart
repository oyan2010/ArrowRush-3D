import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/app_config.dart';

/// Checks connectivity status based on AppConfig.requiresInternet setting.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Check if internet is available when required.
  Future<bool> isNetworkAvailable() async {
    if (!AppConfig.requiresInternet) {
      return true; // App allows offline play by default
    }

    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none)) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
