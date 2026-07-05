import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      if (results.isEmpty) return false;
      
      // If none is present, we have no active connection
      final hasConnection = !results.contains(ConnectivityResult.none);
      AppLogger.debug('Connection status checked: isConnected = $hasConnection');
      return hasConnection;
    } catch (e) {
      AppLogger.error('Failed to check connectivity', e);
      return false;
    }
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;
}

// Network Info provider
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkInfoImpl(connectivity);
});
