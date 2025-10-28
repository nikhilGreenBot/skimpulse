import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode {
  light,
  dark,
  colorful,
}

class AppTypography {
  // Primary font family for headlines and important text
  static TextStyle get primaryFontHeadline => GoogleFonts.montserrat();

  // Secondary font family for body text and UI elements
  static TextStyle get secondaryFontBody => GoogleFonts.inter();

  // Tertiary font family for special cases
  static TextStyle get tertiaryFontSpecial => GoogleFonts.sourceSans3();

  // Headline styles
  static TextStyle get headline1 => GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get headline2 => GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get headline3 => GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
      );

  static TextStyle get headline4 => GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      );

  // Body text styles
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.1,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.2,
      );

  // Article title styles
  static TextStyle get articleTitle => GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.1,
      );

  static TextStyle get articleSubtitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.1,
      );

  // UI element styles
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.3,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.3,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 1.0,
      );

  // App bar and navigation styles
  static TextStyle get appBarTitle => GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
      );

  static TextStyle get bottomNavLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.2,
      );
}

class AppTheme {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color accentOrange = Color(0xFFFFA500);
  static const Color darkBlue = Color(0xFF2E5A8A);
  static const Color lightBlue = Color(0xFF7BB3F0);
  
  // Colorful theme colors
  static const Color vibrantPurple = Color(0xFF9C27B0);
  static const Color vibrantPink = Color(0xFFE91E63);
  static const Color vibrantGreen = Color(0xFF4CAF50);
  static const Color vibrantCyan = Color(0xFF00BCD4);
  static const Color vibrantRed = Color(0xFFF44336);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      primary: primaryBlue,
      secondary: primaryYellow,
      tertiary: accentOrange,
      surface: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ).copyWith(
      headlineLarge: AppTypography.headline1,
      headlineMedium: AppTypography.headline2,
      headlineSmall: AppTypography.headline3,
      titleLarge: AppTypography.headline4,
      titleMedium: AppTypography.articleTitle,
      titleSmall: AppTypography.articleSubtitle,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.caption,
      labelSmall: AppTypography.overline,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.appBarTitle.copyWith(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: primaryBlue),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      primary: primaryBlue,
      secondary: primaryYellow,
      tertiary: accentOrange,
      surface: const Color(0xFF1E1E1E),
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ).copyWith(
      headlineLarge: AppTypography.headline1,
      headlineMedium: AppTypography.headline2,
      headlineSmall: AppTypography.headline3,
      titleLarge: AppTypography.headline4,
      titleMedium: AppTypography.articleTitle,
      titleSmall: AppTypography.articleSubtitle,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.caption,
      labelSmall: AppTypography.overline,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.appBarTitle.copyWith(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF2A2A2A),
    ),
  );

  static ThemeData colorfulTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: vibrantPurple,
      brightness: Brightness.light,
      primary: vibrantPurple,
      secondary: vibrantPink,
      tertiary: vibrantCyan,
      surface: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ).copyWith(
      headlineLarge: AppTypography.headline1,
      headlineMedium: AppTypography.headline2,
      headlineSmall: AppTypography.headline3,
      titleLarge: AppTypography.headline4,
      titleMedium: AppTypography.articleTitle,
      titleSmall: AppTypography.articleSubtitle,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.caption,
      labelSmall: AppTypography.overline,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.appBarTitle.copyWith(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: vibrantPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
    ),
  );

  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.dark:
        return darkTheme;
      case AppThemeMode.colorful:
        return colorfulTheme;
    }
  }

  static String getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.colorful:
        return 'Colorful';
    }
  }

  static IconData getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.colorful:
        return Icons.palette;
    }
  }
}
