import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/services/storage_service.dart';

final themeNotifierProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
      final storage = ref.watch(storageServiceProvider);
      return ThemeModeNotifier(storage);
    });

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storage;

  ThemeModeNotifier(this._storage) : super(ThemeMode.light) {
    final savedTheme = _storage.getThemeMode();
    if (savedTheme != 'light') {
      _storage.setThemeMode('light');
    }
    state = ThemeMode.light;
  }

  void toggleTheme() {
    state = ThemeMode.light;
    _storage.setThemeMode('light');
  }
}
