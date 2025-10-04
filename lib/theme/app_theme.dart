import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryBlue = Color(0xFF1A3A6B);
  static const Color vibrantTeal = Color(0xFF2EC4B6);
  static const Color energeticOrange = Color(0xFFFF9F1C);
  
  // Supporting colors
  static const Color lightMint = Color(0xFFBCE8E3); // Darkened from 0xFFE4F9F5
  static const Color softWhite = Color(0xFFF7F9FB);
  static const Color lightGray = Color(0xFFE8ECF2);
  static const Color darkGray = Color(0xFF4A5568);
  
  // Status colors
  static const Color successGreen = Color(0xFF38B2AC);
  static const Color warningAmber = Color(0xFFED8936);
  static const Color errorRed = Color(0xFFE53E3E);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.softWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.vibrantTeal,
        tertiary: AppColors.energeticOrange,
        background: AppColors.softWhite,
        error: AppColors.errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.vibrantTeal),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.vibrantTeal,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold, 
          color: AppColors.primaryBlue
        ),
        bodyLarge: TextStyle(color: AppColors.darkGray),
        bodyMedium: TextStyle(color: AppColors.darkGray),
      ),
      useMaterial3: true,
    );
  }
}