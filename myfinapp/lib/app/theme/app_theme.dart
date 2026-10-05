import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryOrange = Color(0xFFF4793A);
  static const Color _secondaryPeach = Color(0xFFFBBF7A);
  static const Color _backgroundCream = Color(0xFFFFF8F3);
  static const Color _surfaceWhite = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF3D2C2C);
  static const Color _textSecondary = Color(0xFF8C7B7B);
  static const Color _errorRed = Color(0xFFE04057);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _primaryOrange,
        onPrimary: _surfaceWhite,
        secondary: _secondaryPeach,
        onSecondary: _textDark,
        error: _errorRed,
        onError: _surfaceWhite,
        surface: _surfaceWhite,
        onSurface: _textDark,
        outline: Color(0xFFE8DDD6),
      ),
      scaffoldBackgroundColor: _backgroundCream,
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceWhite,
        foregroundColor: _textDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFF0E6DC)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryOrange,
          foregroundColor: _surfaceWhite,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textDark,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5EBE0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _textSecondary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: _primaryOrange,
        onPrimary: _surfaceWhite,
        secondary: _secondaryPeach,
        onSecondary: _textDark,
        error: _errorRed,
        onError: _surfaceWhite,
        surface: Color(0xFF1C1614),
        onSurface: Color(0xFFF5EBE0),
        outline: Color(0xFF3D2C2C),
      ),
      scaffoldBackgroundColor: const Color(0xFF120E0C),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1614),
        foregroundColor: Color(0xFFF5EBE0),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1C1614),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF3D2C2C)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryOrange,
          foregroundColor: _surfaceWhite,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF5EBE0),
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A1F1B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFBFA9A9),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
