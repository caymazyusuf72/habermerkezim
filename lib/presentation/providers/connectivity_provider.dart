import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';

/// Connectivity State - internet bağlantısı durumunu tutar
class ConnectivityState {
  final bool isConnected;
  final List<ConnectivityResult> connectivityResults;
  final DateTime lastChecked;

  ConnectivityState({
    this.isConnected = false,
    this.connectivityResults = const [ConnectivityResult.none],
    DateTime? lastChecked,
  }) : lastChecked = lastChecked ?? DateTime.now();

  ConnectivityState copyWith({
    bool? isConnected,
    List<ConnectivityResult>? connectivityResults,
    DateTime? lastChecked,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      connectivityResults: connectivityResults ?? this.connectivityResults,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  // Primary connectivity result (first in list)
  ConnectivityResult get primaryResult => connectivityResults.first;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectivityState &&
        other.isConnected == isConnected &&
        other.connectivityResults.toString() == connectivityResults.toString();
  }

  @override
  int get hashCode {
    return isConnected.hashCode ^
        connectivityResults.hashCode ^
        lastChecked.hashCode;
  }

  @override
  String toString() {
    return 'ConnectivityState(isConnected: $isConnected, '
        'connectivityResults: $connectivityResults, '
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
      final results = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(results);
    } catch (e) {
      debugPrint('Connectivity initialization error: $e');
      state = state.copyWith(
        isConnected: false,
        connectivityResults: [ConnectivityResult.none],
        lastChecked: DateTime.now(),
      );
    }
  }

  /// Bağlantı durumunu günceller
  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    final isConnected =
        !results.contains(ConnectivityResult.none) && results.isNotEmpty;

    state = state.copyWith(
      isConnected: isConnected,
      connectivityResults: results,
      lastChecked: DateTime.now(),
    );

    debugPrint('Connectivity changed: $results (connected: $isConnected)');
  }

  /// Manuel olarak bağlantı durumunu kontrol et
  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(results);
    } catch (e) {
      debugPrint('Manual connectivity check error: $e');
    }
  }

  /// Network erişilebilirlik testi
  Future<bool> testNetworkAccess() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none) && results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Global connectivity provider
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
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
