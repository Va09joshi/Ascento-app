import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _keyThemeMode = 'theme_mode';
  static const String _keyOnboardingDone = 'onboarding_done';
  static const String _keyAbacusLevelsCompleted = 'levels_completed';
  static const String _keyAbacusTotalStars = 'total_stars';
  static const String _keyCurrentUser = 'cached_current_user';
  static const String _keyRememberMe = 'remember_me';

  // Dynamic getters/setters
  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Current User Session Caching
  UserModel? getCurrentUser() {
    final userJsonString = _prefs.getString(_keyCurrentUser);
    if (userJsonString == null || userJsonString.isEmpty) {
      return null;
    }
    try {
      final decodedJson = jsonDecode(userJsonString) as Map<String, dynamic>;
      return UserModel.fromJson(decodedJson);
    } catch (e, stack) {
      AppLogger.error('Failed to parse cached user session', e, stack);
      return null;
    }
  }

  Future<bool> setCurrentUser(UserModel user) async {
    AppLogger.info('Caching active user session: ${user.name} (${user.role.name})');
    final userJsonString = jsonEncode(user.toJson());
    return await _prefs.setString(_keyCurrentUser, userJsonString);
  }

  Future<bool> removeUser() async {
    AppLogger.warning('Clearing cached user session.');
    return await _prefs.remove(_keyCurrentUser);
  }

  // Theme mode: 'light', 'dark', 'system'
  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'light';
  }

  Future<bool> setThemeMode(String value) async {
    AppLogger.debug('Theme mode saved: $value');
    return await _prefs.setString(_keyThemeMode, value);
  }

  // Onboarding Done
  bool isOnboardingCompleted() {
    return _prefs.getBool(_keyOnboardingDone) ?? false;
  }

  Future<bool> setOnboardingCompleted(bool value) async {
    AppLogger.debug('Onboarding completed state saved: $value');
    return await _prefs.setBool(_keyOnboardingDone, value);
  }

  // Abacus Stats
  int getCompletedLevelsCount() {
    return _prefs.getInt(_keyAbacusLevelsCompleted) ?? 0;
  }

  Future<bool> setCompletedLevelsCount(int count) async {
    AppLogger.debug('Levels completed count saved: $count');
    return await _prefs.setInt(_keyAbacusLevelsCompleted, count);
  }

  // Total Stars
  int getTotalStars() {
    return _prefs.getInt(_keyAbacusTotalStars) ?? 0;
  }

  Future<bool> setTotalStars(int stars) async {
    AppLogger.debug('Total stars saved: $stars');
    return await _prefs.setInt(_keyAbacusTotalStars, stars);
  }

  // Remember Me
  bool getRememberMe() {
    return _prefs.getBool(_keyRememberMe) ?? false;
  }

  Future<bool> setRememberMe(bool value) async {
    AppLogger.debug('Remember Me flag saved: $value');
    return await _prefs.setBool(_keyRememberMe, value);
  }

  // Clear Storage
  Future<bool> clearAll() async {
    AppLogger.warning('Clearing all local preferences!');
    return await _prefs.clear();
  }
}

// Global shared preferences instances
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences has not been initialized. Must override in ProviderScope.');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});
