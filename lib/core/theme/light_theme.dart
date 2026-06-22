import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized light theme configuration for the application.
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: const Color(0xFF6366F1),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6366F1),
    brightness: Brightness.light,
    surface: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF09090B),
    primary: const Color(0xFF6366F1),
    onPrimary: Colors.white,
    secondary: const Color(0xFF71717A),
    onSecondary: Colors.white,
    surfaceContainerHighest: const Color(0xFFF4F4F5),
  ),
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
    displayLarge: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF09090B),
    ),
    bodyLarge: const TextStyle(color: Color(0xFF09090B)),
    bodyMedium: const TextStyle(color: Color(0xFF71717A)),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFFFFF),
    foregroundColor: Color(0xFF09090B),
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFFF4F4F5),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF4F4F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFFFFFFFF),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF09090B),
    ),
    contentTextStyle: GoogleFonts.outfit(
      fontSize: 16,
      color: const Color(0xFF09090B),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFFFFFFF),
    selectedItemColor: Color(0xFF6366F1),
    unselectedItemColor: Color(0xFF71717A),
    elevation: 8,
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE4E4E7),
    thickness: 1,
    space: 1,
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: GoogleFonts.outfit(color: const Color(0xFF09090B)),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  ),
);
