import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// App Colors - Optimized professional palette with better contrast and depth
class AppColors {
  // Primary palette - Pastel peach/pink brand with depth variations
  static const Color primaryColor = Color(0xFFF6C6BB); // soft peach
  static const Color primaryDark = Color(0xFFDDAAA0);
  static const Color primaryLight = Color(0xFFFFEDEB);
  static const Color primaryExtraLight = Color(0xFFFFF6F4);
  
  // Secondary & accent colors (complementary)
  static const Color secondaryColor = Color(0xFFB7E3D8); // soft mint
  static const Color secondaryDark = Color(0xFF8FCABF);
  static const Color secondaryLight = Color(0xFFD8F3ED);
  
  static const Color accentColor = Color(0xFFFAD9B8); // warm yellow-beige
  static const Color accentDark = Color(0xFFE5C09D);
  static const Color accentLight = Color(0xFFFFEFDB);
  
  static const Color tertiaryColor = Color(0xFFBDA4F8); // soft lilac
  static const Color tertiaryDark = Color(0xFFA388E5);
  static const Color tertiaryLight = Color(0xFFE3D7FF);
  
  // Status colors with depth
  static const Color successColor = Color(0xFF06D6A0);
  static const Color successLight = Color(0xFF6FF5D0);
  static const Color errorColor = Color(0xFFEF476F);
  static const Color errorLight = Color(0xFFF98AA2);
  static const Color warningColor = Color(0xFFFF8A3D);
  static const Color warningLight = Color(0xFFFFB878);
  static const Color infoColor = Color(0xFF118AB2);
  static const Color infoLight = Color(0xFF5CB8D6);
  
  // Backgrounds with subtle gradients
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceElevated = Color(0xFF334155);
  
  // Text colors optimized for WCAG AA
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);
  
  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, tertiaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFFDFDFD), Color(0xFFF5F7FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient darkSurfaceGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  // Optimized color palette with better depth
  static const Color primaryBlue = Color(0xFF2E7EF0);
  // Brand pastel palette
  static const Color primaryPeach = Color(0xFFF6C6BB);
  static const Color primaryPeachDark = Color(0xFFDDAAA0);
  static const Color accentBeige = Color(0xFFFAD9B8);
  static const Color mintSoft = Color(0xFFB7E3D8);
  static const Color lilacSoft = Color(0xFFBDA4F8);
  
  static const Color backgroundLight = Color(0xFFFFFBFA); // very light warm
  static const Color backgroundDark = Color(0xFF0F172A);
  
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFFF1F5F9);
  
  static const Color cardLight = Color(0xFFFFFEFD); // tiny warm tint
  static const Color cardDark = Color(0xFF1E293B);
  
  // Gradient colors for surfaces
  static const Color gradientStart = Color(0xFFFDFDFD);
  static const Color gradientEnd = Color(0xFFF5F7FA);
  
  // Animation durations for theme transitions
  static const Duration themeTransitionDuration = Duration(milliseconds: 400);
  static const Curve themeTransitionCurve = Curves.easeInOutCubic;

  // Light Theme with enhanced styling
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryPeach,
      primaryContainer: Color(0xFFFFEDEB),
      secondary: mintSoft,
      secondaryContainer: Color(0xFFD8F3ED),
      tertiary: lilacSoft,
      tertiaryContainer: Color(0xFFE3D7FF),
      surface: cardLight,
      surfaceContainerHighest: Color(0xFFF5F7FA),
      onPrimary: Colors.white,
      onPrimaryContainer: textDark,
      onSecondary: Colors.white,
      onSecondaryContainer: textDark,
      onSurface: textDark,
      error: Color(0xFFEF476F),
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme.copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textDark,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 4,
      centerTitle: true,
      shadowColor: primaryPeach.withAlpha(20),
      titleTextStyle: GoogleFonts.poppins(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: textDark, size: 24),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 4,
      shadowColor: primaryPeach.withAlpha(25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPeach,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: primaryPeach.withAlpha(60),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withAlpha(30);
            }
            return null;
          },
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryPeach,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: textDark,
        highlightColor: primaryPeach.withAlpha(25),
        padding: const EdgeInsets.all(8),
      ),
    ),
    scaffoldBackgroundColor: backgroundLight,
    shadowColor: primaryPeach.withAlpha(30),
    dividerColor: textDark.withAlpha(20),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryPeach,
      foregroundColor: Colors.white,
      elevation: 6,
      highlightElevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardLight,
      selectedItemColor: primaryPeach,
      unselectedItemColor: Color(0xFF64748B),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryPeach.withAlpha(25),
      selectedColor: primaryPeach,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return primaryPeach;
          }
          return Colors.grey.shade400;
        },
      ),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return primaryPeach.withAlpha(128);
          }
          return Colors.grey.shade300;
        },
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryPeach,
      linearTrackColor: Color(0xFFFFEDEB),
      circularTrackColor: Color(0xFFFFEDEB),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryPeach, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF476F), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF476F), width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textDisabled,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textDark,
      contentTextStyle: GoogleFonts.inter(
        color: textLight,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardLight,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: textDark,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: cardLight,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );

  // Dark Theme with enhanced styling
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryPeach,
      primaryContainer: Color(0xFF4A2E2A),
      secondary: mintSoft,
      secondaryContainer: Color(0xFF2A3E38),
      tertiary: lilacSoft,
      tertiaryContainer: Color(0xFF3A2D4F),
      surface: cardDark,
      surfaceContainerHighest: Color(0xFF334155),
      onPrimary: Colors.white,
      onPrimaryContainer: textLight,
      onSecondary: Colors.white,
      onSecondaryContainer: textLight,
      onSurface: textLight,
      error: Color(0xFFEF476F),
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme.copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textLight,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textLight,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textLight,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textLight,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      scrolledUnderElevation: 4,
      centerTitle: true,
      shadowColor: Colors.black.withAlpha(40),
      titleTextStyle: GoogleFonts.poppins(
        color: textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: textLight, size: 24),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 4,
      shadowColor: Colors.black.withAlpha(60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPeach,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: primaryPeach.withAlpha(60),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withAlpha(30);
            }
            return null;
          },
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryPeach,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: textLight,
        highlightColor: primaryPeach.withAlpha(25),
        padding: const EdgeInsets.all(8),
      ),
    ),
    scaffoldBackgroundColor: backgroundDark,
    shadowColor: Colors.black.withAlpha(60),
    dividerColor: textLight.withAlpha(20),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryPeach,
      foregroundColor: Colors.white,
      elevation: 6,
      highlightElevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: primaryPeach,
      unselectedItemColor: Color(0xFF94A3B8),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryPeach.withAlpha(25),
      selectedColor: primaryPeach,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textLight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return primaryPeach;
          }
          return Colors.grey.shade600;
        },
      ),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return primaryPeach.withAlpha(128);
          }
          return Colors.grey.shade700;
        },
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryPeach,
      linearTrackColor: Color(0xFF334155),
      circularTrackColor: Color(0xFF334155),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF334155),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF475569), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryPeach, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF476F), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF476F), width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textDisabled,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textDisabled,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF334155),
      contentTextStyle: GoogleFonts.inter(
        color: textLight,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardDark,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: textLight,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: cardDark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}