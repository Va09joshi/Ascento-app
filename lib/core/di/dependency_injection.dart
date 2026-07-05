import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ascento_abacus/core/env/app_env.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';

class DependencyInjection {
  DependencyInjection._();

  /// Pre-initializes all system essentials: Storage, Env config, Bindings, and Loggers.
  /// Returns the loaded SharedPreferences instance to inject into the Riverpod ProviderScope.
  static Future<SharedPreferences> init(Environment environment) async {
    // 1. Ensure Flutter bindings are active
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Initialize Logging
    AppLogger.info('--- Initializing Ascento Abacus Services ---');

    // 3. Load Environment Configuration
    await AppEnv.initialize(environment);

    // 4. Pre-load Local Storage
    AppLogger.info('Initializing SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    AppLogger.info('SharedPreferences successfully loaded.');

    return prefs;
  }
}
