import 'package:flutter/material.dart';

class AppTheme {
  // Winter Arc Premium Color Palette
  static const Color primaryDark = Color(0xFF0A192F); // Deep Midnight Blue
  static const Color surfaceDark = Color(0xFF112240); // Dark Slate
  static const Color accentCyan = Color(0xFF64FFDA); // Electric Cyan
  static const Color accentGold = Color(0xFFFFD700); // Champion Gold
  static const Color textLight = Color(0xFFE6F1FF); // Lightest Slate
  static const Color textDim = Color(0xFF8892B0); // Slate
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    // Keeping light theme simple but aligned, though Dark is preferred
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        primary: primaryDark,
        secondary: accentCyan,
        surface: Colors.white,
        error: errorRed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: accentCyan,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentCyan,
        primary: accentCyan,
        secondary: accentGold,
        surface: surfaceDark,
        error: errorRed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: primaryDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentCyan,
          foregroundColor: primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          elevation: 4,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentCyan,
        foregroundColor: primaryDark,
        elevation: 6,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accentCyan,
        unselectedItemColor: textDim,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF233554), // Slightly lighter than surface
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentCyan, width: 2),
        ),
        labelStyle: const TextStyle(color: textDim),
        hintStyle: TextStyle(color: textDim.withValues(alpha: 0.5)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textLight,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textDim,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textDim,
        ),
      ),
      iconTheme: const IconThemeData(color: accentCyan),
      dividerTheme: DividerThemeData(color: textDim.withValues(alpha: 0.2)),
    );
  }
}
