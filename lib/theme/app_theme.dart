import 'package:flutter/material.dart';

class AppColors {
  // BSNL-ish palette (you can tweak these)
  static const Color primaryBlue = Color(0xFF005BAB); // deep blue
  static const Color accentYellow = Color(0xFFF2A900); // golden yellow
  static const Color background = Color(0xFFF5F7FA); // light grey background
  static const Color textDark = Color(0xFF222222);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryBlue,
      onPrimary: Colors.white,
      secondary: AppColors.accentYellow,
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      background: AppColors.background,
      onBackground: AppColors.textDark,
      surface: Colors.white,
      onSurface: AppColors.textDark,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
    ),

    scaffoldBackgroundColor: AppColors.background,

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        side: const BorderSide(color: AppColors.primaryBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textDark),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textDark),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textDark),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    ),
  );
}
