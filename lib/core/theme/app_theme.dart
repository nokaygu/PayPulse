import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppLightColors.primary,
            brightness: Brightness.light,
          ).copyWith(
            primary: AppLightColors.primary,
            onPrimary: AppLightColors.onPrimary,
            primaryContainer: AppLightColors.primaryContainer,
            onPrimaryContainer: AppLightColors.onPrimaryContainer,
            secondary: AppLightColors.secondary,
            onSecondary: AppLightColors.onSecondary,
            secondaryContainer: AppLightColors.secondaryContainer,
            onSecondaryContainer: AppLightColors.onSecondaryContainer,
            tertiary: AppLightColors.tertiary,
            onTertiary: AppLightColors.onTertiary,
            tertiaryContainer: AppLightColors.tertiaryContainer,
            onTertiaryContainer: AppLightColors.onTertiaryContainer,
            error: AppLightColors.error,
            onError: AppLightColors.onError,
            errorContainer: AppLightColors.errorContainer,
            onErrorContainer: AppLightColors.onErrorContainer,
            surface: AppLightColors.surface,
            onSurface: AppLightColors.onSurface,
            onSurfaceVariant: AppLightColors.onSurfaceVariant,
            outline: AppLightColors.outline,
            outlineVariant: AppLightColors.outlineVariant,
            surfaceTint: AppLightColors.surfaceTint,
            inverseSurface: AppLightColors.inverseSurface,
            onInverseSurface: AppLightColors.inverseOnSurface,
            inversePrimary: AppLightColors.inversePrimary,
          ),
      scaffoldBackgroundColor: AppLightColors.background,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppLightColors.surface,
        foregroundColor: AppLightColors.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppLightColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppLightColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppLightColors.primary,
          foregroundColor: AppLightColors.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppDarkColors.primary,
            brightness: Brightness.dark,
          ).copyWith(
            primary: AppDarkColors.primary,
            onPrimary: AppDarkColors.onPrimary,
            primaryContainer: AppDarkColors.primaryContainer,
            onPrimaryContainer: AppDarkColors.onPrimaryContainer,
            secondary: AppDarkColors.secondary,
            onSecondary: AppDarkColors.onSecondary,
            secondaryContainer: AppDarkColors.secondaryContainer,
            onSecondaryContainer: AppDarkColors.onSecondaryContainer,
            tertiary: AppDarkColors.tertiary,
            onTertiary: AppDarkColors.onTertiary,
            tertiaryContainer: AppDarkColors.tertiaryContainer,
            onTertiaryContainer: AppDarkColors.onTertiaryContainer,
            error: AppDarkColors.error,
            onError: AppDarkColors.onError,
            errorContainer: AppDarkColors.errorContainer,
            onErrorContainer: AppDarkColors.onErrorContainer,
            surface: AppDarkColors.surface,
            onSurface: AppDarkColors.onSurface,
            onSurfaceVariant: AppDarkColors.onSurfaceVariant,
            outline: AppDarkColors.outline,
            outlineVariant: AppDarkColors.outlineVariant,
            surfaceTint: AppDarkColors.surfaceTint,
            inverseSurface: AppDarkColors.inverseSurface,
            onInverseSurface: AppDarkColors.inverseOnSurface,
            inversePrimary: AppDarkColors.inversePrimary,
          ),
      scaffoldBackgroundColor: AppDarkColors.background,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppDarkColors.surface,
        foregroundColor: AppDarkColors.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppDarkColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppDarkColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDarkColors.primary,
          foregroundColor: AppDarkColors.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
