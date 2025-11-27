import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity State - internet bağlantısı durumunu tutar
class ConnectivityState {
  final bool isConnected;
  final ConnectivityResult connectivityResult;
  final DateTime lastChecked;

  ConnectivityState({
    this.isConnected = false,
    this.connectivityResult = ConnectivityResult.none,
    DateTime? lastChecked,
  }) : lastChecked = lastChecked ?? DateTime.now();

  ConnectivityState copyWith({
    bool? isConnected,
    ConnectivityResult? connectivityResult,
    DateTime? lastChecked,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      connectivityResult: connectivityResult ?? this.connectivityResult,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectivityState &&
           other.isConnected == isConnected &&
           other.connectivityResult == connectivityResult;
  }

  @override
  int get hashCode {
    return isConnected.hashCode ^ 
           connectivityResult.hashCode ^ 
           lastChecked.hashCode;
  }

  @override
  String toString() {
    return 'ConnectivityState(isConnected: $isConnected, '
           'connectivityResult: $connectivityResult, '
           'lastChecked: $lastChecked)';
  }
}

/// Connectivity StateNotifier - internet bağlantısını izler
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final Connectivity _connectivity;

  ConnectivityNotifier(this._connectivity) : super(ConnectivityState()) {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectivityStatus);
  }

  /// İlk bağlantı durumunu kontrol eder
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(result);
    } catch (e) {
      print('Connectivity initialization error: $e');
      state = state.copyWith(
        isConnected: false,
        connectivityResult: ConnectivityResult.none,
        lastChecked: DateTime.now(),
      );
    }
  }

  /// Bağlantı durumunu günceller
  void _updateConnectivityStatus(ConnectivityResult result) {
    final isConnected = result != ConnectivityResult.none;

    state = state.copyWith(
      isConnected: isConnected,
      connectivityResult: result,
      lastChecked: DateTime.now(),
    );

    print('Connectivity changed: $result (connected: $isConnected)');
  }

  /// Manuel olarak bağlantı durumunu kontrol et
  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(result);
    } catch (e) {
      print('Manual connectivity check error: $e');
    }
  }

  /// Network erişilebilirlik testi
  Future<bool> testNetworkAccess() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }
}

/// Global connectivity provider
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier(Connectivity());
});

/// Convenience provider for checking if connected
final isConnectedProvider = Provider<bool>((ref) {
  final connectivityState = ref.watch(connectivityProvider);
  return connectivityState.isConnected;
});

/// Network connectivity utility functions
class ConnectivityUtils {
  static bool isNetworkAvailable(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }
  
  static String getConnectionTypeString(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobil';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.none:
        return 'Bağlantı Yok';
      default:
        return 'Bilinmeyen';
    }
  }
}