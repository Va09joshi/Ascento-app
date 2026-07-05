import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/app.dart';
import 'package:ascento_abacus/core/di/dependency_injection.dart';
import 'package:ascento_abacus/core/env/app_env.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/services/storage_service.dart';

void main() async {
  try {
    // 1. Run core pre-boot services initializer (Development environment by default)
    final sharedPrefs = await DependencyInjection.init(Environment.development);

    // 2. Start responsive Flutter app inside Riverpod scope
    runApp(
      ProviderScope(
        overrides: [
          // Override the SharedPreferences provider with the pre-loaded instance
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const MyApp(),
      ),
    );
  } catch (error, stackTrace) {
    AppLogger.error('Critical crash during Ascento Abacus boot sequence!', error, stackTrace);
    
    // Recovery layout in case of absolute initialization failure
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Boot Error',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to initialize local services: ${error.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
