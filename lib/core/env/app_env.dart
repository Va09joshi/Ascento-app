import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';

enum Environment {
  development,
  production,
}

class AppEnv {
  final String envName;
  final String apiBaseUrl;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;
  final bool enableLogging;

  AppEnv({
    required this.envName,
    required this.apiBaseUrl,
    required this.connectTimeoutMs,
    required this.receiveTimeoutMs,
    required this.enableLogging,
  });

  static AppEnv? _instance;
  static AppEnv get instance {
    if (_instance == null) {
      throw Exception('Environment not initialized. Call AppEnv.initialize() first.');
    }
    return _instance!;
  }

  static Future<void> initialize(Environment environment) async {
    final String configPath = environment == Environment.development
        ? 'assets/env/development.json'
        : 'assets/env/production.json';

    AppLogger.info('Initializing environment from: $configPath');
    try {
      final String content = await rootBundle.loadString(configPath);
      final Map<String, dynamic> data = jsonDecode(content);

      _instance = AppEnv(
        envName: data['envName'] ?? 'unknown',
        apiBaseUrl: data['apiBaseUrl'] ?? '',
        connectTimeoutMs: data['connectTimeoutMs'] ?? 10000,
        receiveTimeoutMs: data['receiveTimeoutMs'] ?? 10000,
        enableLogging: data['enableLogging'] ?? true,
      );
      AppLogger.info('Environment successfully loaded: ${_instance!.envName}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load environment configuration', e, stackTrace);
      _instance = AppEnv(
        envName: 'fallback',
        apiBaseUrl: 'http://10.0.2.2:3000/api/v1',
        connectTimeoutMs: 10000,
        receiveTimeoutMs: 10000,
        enableLogging: true,
      );
    }
  }
}

// Provider for Env config so feature classes can easily inject it
final envProvider = Provider<AppEnv>((ref) {
  return AppEnv.instance;
});
