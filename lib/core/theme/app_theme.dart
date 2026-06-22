import 'package:flutter/material.dart';
import 'light_theme.dart' as lt;
import 'dark_theme.dart' as dt;

/// Container for the application's central design system.
/// Delegates theme generation to [lt.lightTheme] and [dt.darkTheme].
class AppTheme {
  // Brand Colors (kept static for backward-compatible reference and quick utilities)
  static const Color primary = Color(0xFF6366F1); // Electric Indigo
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF09090B);
  static const Color surfaceLight = Color(0xFFF4F4F5); // Zinc 100
  static const Color surfaceDark = Color(0xFF18181B); // Zinc 900
  static const Color textLight = Color(0xFF09090B);
  static const Color textDark = Color(0xFFFAFAFA);

  /// Getter for the light theme configuration.
  static ThemeData get lightTheme => lt.lightTheme;

  /// Getter for the dark theme configuration.
  static ThemeData get darkTheme => dt.darkTheme;
}
