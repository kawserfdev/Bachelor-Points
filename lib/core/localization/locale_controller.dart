import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_storage/get_storage.dart';

class LocaleController extends StateNotifier<Locale> {
  final _storage = GetStorage();
  static const _storageKey = 'selected_locale';

  LocaleController() : super(const Locale('en')) {
    _loadLocale();
  }

  void _loadLocale() {
    final languageCode = _storage.read<String>(_storageKey);
    if (languageCode != null) {
      state = Locale(languageCode);
    } else {
      state = const Locale('en');
    }
  }

  void setLocale(Locale locale) {
    if (state == locale) return;
    state = locale;
    _storage.write(_storageKey, locale.languageCode);
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});