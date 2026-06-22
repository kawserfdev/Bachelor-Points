import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/service_providers.dart';

/// Repository interface to load and save current ThemeMode.
abstract class ThemeRepository {
  /// Persists the selected ThemeMode to local storage.
  Future<void> saveThemeMode(ThemeMode mode);

  /// Retrieves the persisted ThemeMode from local storage.
  /// Defaults to [ThemeMode.system] if none is saved.
  ThemeMode getThemeMode();
}

/// Implementation of [ThemeRepository] leveraging the existing [StorageService].
class ThemeRepositoryImpl implements ThemeRepository {
  final Ref _ref;
  static const String _themeKey = 'app_theme_mode';

  ThemeRepositoryImpl(this._ref);

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    final storageService = _ref.read(storageServiceProvider);
    storageService.writeData(_themeKey, mode.name);
  }

  @override
  ThemeMode getThemeMode() {
    final storageService = _ref.read(storageServiceProvider);
    final modeName = storageService.readData<String>(_themeKey);

    if (modeName == null) {
      return ThemeMode.system;
    }

    return ThemeMode.values.firstWhere(
      (e) => e.name == modeName,
      orElse: () => ThemeMode.system,
    );
  }
}

/// Riverpod provider for [ThemeRepository].
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepositoryImpl(ref);
});
