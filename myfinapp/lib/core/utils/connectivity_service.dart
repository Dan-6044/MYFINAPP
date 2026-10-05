import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._();

  ConnectivityService._();

  late final Connectivity _connectivity;

  Future<void> initialize() async {
    _connectivity = Connectivity();
  }

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.any((c) => c != ConnectivityResult.none);
  }
}
