import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized dark theme configuration for the application.
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF961BFC),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF961BFC),
    brightness: Brightness.dark,
    surface: const Color(0xFF18181B),
    onSurface: const Color(0xFFFAFAFA),
    primary: const Color(0xFF961BFC),
    onPrimary: Colors.white,
    secondary: const Color(0xFFA1A1AA),
    onSecondary: Colors.black,
    surfaceContainerHighest: const Color(0xFF27272A),
  ),
  scaffoldBackgroundColor: const Color(0xFF09090B),
  textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
    displayLarge: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFFFAFAFA),
    ),
    bodyLarge: const TextStyle(color: Color(0xFFFAFAFA)),
    bodyMedium: const TextStyle(color: Color(0xFFA1A1AA)),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF09090B),
    foregroundColor: Color(0xFFFAFAFA),
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF18181B),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF18181B),
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
      borderSide: const BorderSide(color: Color(0xFF961BFC), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF961BFC),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF18181B),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFFAFAFA),
    ),
    contentTextStyle: GoogleFonts.outfit(
      fontSize: 16,
      color: const Color(0xFFFAFAFA),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF09090B),
    selectedItemColor: Color(0xFF961BFC),
    unselectedItemColor: Color(0xFFA1A1AA),
    elevation: 8,
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF27272A),
    thickness: 1,
    space: 1,
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: GoogleFonts.outfit(color: const Color(0xFFFAFAFA)),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xFF18181B)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  ),
);
