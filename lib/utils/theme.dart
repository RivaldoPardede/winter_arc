import 'package:flutter/material.dart';

class AppTheme {
  // Winter Arc Color Palette
  static const Color primaryBlue = Color(0xFF1E3A8A); // Deep winter blue
  static const Color accentIce = Color(0xFF60A5FA); // Ice blue
  static const Color darkNavy = Color(0xFF0F172A); // Dark navy
  static const Color snowWhite = Color(0xFFF8FAFC); // Snow white
  static const Color steelGray = Color(0xFF475569); // Steel gray
  static const Color successGreen = Color(0xFF10B981); // Success/Progress
  static const Color warningOrange = Color(0xFFF59E0B); // Warning
  static const Color errorRed = Color(0xFFEF4444); // Error

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentIce,
        surface: snowWhite,
        error: errorRed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: snowWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: snowWhite,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: snowWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentIce,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: steelGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkNavy,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkNavy,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkNavy,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: steelGray,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: steelGray,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentIce,
        primary: accentIce,
        secondary: primaryBlue,
        surface: darkNavy,
        error: errorRed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkNavy,
        foregroundColor: snowWhite,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF1E293B),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentIce,
          foregroundColor: darkNavy,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentIce,
        foregroundColor: darkNavy,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedItemColor: accentIce,
        unselectedItemColor: steelGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
