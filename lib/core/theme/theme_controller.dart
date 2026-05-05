import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // Observable for current theme mode
  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved theme or use system theme if not saved
    isDarkMode.value = _loadThemeFromBox() ?? Get.isPlatformDarkMode;
  }

  /// Get the ThemeMode based on current state
  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  /// Load theme from local storage
  bool? _loadThemeFromBox() => _box.read(_key);

  /// Save theme to local storage
  void _saveThemeToBox(bool isDark) => _box.write(_key, isDark);

  /// Switch Theme and save to local storage
  void switchTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(themeMode);
    _saveThemeToBox(isDarkMode.value);
  }
}
