import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// App Colors - Optimized professional palette with better contrast
class AppColors {
  // Primary palette - Modern blues with depth
  static const Color primaryColor = Color(0xFF2E7EF0);
  static const Color primaryDark = Color(0xFF1E5FBF);
  static const Color primaryLight = Color(0xFF5BA3FF);
  
  // Secondary & accent colors
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color accentColor = Color(0xFFFBB040);
  static const Color tertiaryColor = Color(0xFF10B981);
  
  // Status colors
  static const Color successColor = Color(0xFF06D6A0);
  static const Color errorColor = Color(0xFFEF476F);
  static const Color warningColor = Color(0xFFFF8A3D);
  static const Color infoColor = Color(0xFF118AB2);
  
  // Backgrounds with subtle gradients
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  
  // Text colors optimized for WCAG AA
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF64748B);
}

class AppTheme {
  // Optimized color palette with better depth
  static const Color primaryBlue = Color(0xFF2E7EF0);
  static const Color accentYellow = Color(0xFFFBB040);
  static const Color secondaryPurple = Color(0xFF7C3AED);
  static const Color tertiaryGreen = Color(0xFF10B981);
  
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF0F172A);
  
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFFF1F5F9);
  
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
  
  // Gradient colors for surfaces
  static const Color gradientStart = Color(0xFFFDFDFD);
  static const Color gradientEnd = Color(0xFFF5F7FA);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryPurple,
      tertiary: tertiaryGreen,
      surface: cardLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: primaryBlue),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    scaffoldBackgroundColor: backgroundLight,
    shadowColor: primaryBlue.withAlpha(30),
    dividerColor: textDark.withAlpha(20),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardLight,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Color(0xFF64748B),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryBlue,
      secondary: secondaryPurple,
      tertiary: tertiaryGreen,
      surface: cardDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textLight,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: primaryBlue),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    scaffoldBackgroundColor: backgroundDark,
    shadowColor: primaryBlue.withAlpha(30),
    dividerColor: textLight.withAlpha(20),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Color(0xFF94A3B8),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF334155),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF475569)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
  );
}