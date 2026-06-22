import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_repository.dart';

/// Notifier class managing the application's [ThemeMode] state.
class ThemeController extends Notifier<ThemeMode> {
  late final ThemeRepository _repository;

  @override
  ThemeMode build() {
    _repository = ref.watch(themeRepositoryProvider);
    return _repository.getThemeMode();
  }

  /// Updates the current theme mode and persists the selection.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _repository.saveThemeMode(mode);
  }
}

/// Riverpod provider for the [ThemeController], exposing the active [ThemeMode].
final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);
