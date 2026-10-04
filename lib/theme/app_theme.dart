import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryPolish,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainerPolish,
        onPrimaryContainer: AppColors.onPrimaryContainerPolish,
        secondary: AppColors.secondaryPolish,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryContainerPolish,
        onSecondaryContainer: AppColors.onSecondaryContainerPolish,
        tertiary: AppColors.tertiaryPolish,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.tertiaryContainerPolish,
        onTertiaryContainer: AppColors.onTertiaryContainerPolish,
        error: AppColors.roseError,
        onError: Colors.white,
        errorContainer: AppColors.roseErrorContainer,
        onErrorContainer: AppColors.onRoseError,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        onSurfaceVariant: AppColors.lightOnSurfaceVariant,
        outline: AppColors.lightOutline,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.lightOnSurface,
          fontWeight: FontWeight.bold,
          fontSize: 21,
          letterSpacing: -0.3,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primaryContainerPolish,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: textTheme,
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData(brightness: Brightness.dark).textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryPolishLight,
        onPrimary: AppColors.onPrimaryContainerPolish,
        primaryContainer: AppColors.primaryPolishDark,
        onPrimaryContainer: AppColors.primaryContainerPolish,
        secondary: AppColors.secondaryPolishLight,
        onSecondary: AppColors.onSecondaryContainerPolish,
        secondaryContainer: AppColors.secondaryPolish,
        onSecondaryContainer: AppColors.secondaryContainerPolish,
        tertiary: AppColors.tertiaryPolishLight,
        onTertiary: AppColors.onTertiaryContainerPolish,
        tertiaryContainer: AppColors.tertiaryPolish,
        onTertiaryContainer: AppColors.tertiaryContainerPolish,
        error: AppColors.roseError,
        onError: Colors.white,
        errorContainer: AppColors.roseErrorContainer,
        onErrorContainer: AppColors.onRoseError,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        outline: AppColors.darkOutline,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.darkOnSurface,
          fontWeight: FontWeight.bold,
          fontSize: 21,
          letterSpacing: -0.3,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryPolishDark,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: textTheme,
    );
  }
}
