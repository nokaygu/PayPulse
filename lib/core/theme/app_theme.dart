import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  /// Global Tema Yönetimi (Açık, Koyu, Sistem)
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDark => themeModeNotifier.value == ThemeMode.dark;

  static void setThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }

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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF63E6BE),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF0F172A)
                : const Color(0xFF64748B),
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E293B),
        indicatorColor: AppColors.primaryTeal.withValues(alpha: 0.35),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : const Color(0xFF94A3B8),
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppDarkColors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppDarkColors.outlineVariant),
        ),
      ),
    );
  }
}
