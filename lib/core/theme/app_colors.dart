import 'package:flutter/material.dart';

class AppColors {
  // PayPulse Marka Renkleri
  static const Color primaryGreen = Color(0xFF10B981); // Emerald / Vurgu Yeşili
  static const Color primaryTeal = Color(0xFF0D9488); // Vurgu Turkuazı
  static const Color darkNavy = Color(0xFF0D1F2D); // Koyu Lacivert
  static const Color darkGreen = Color(0xFF12353C); // Koyu Yeşil Kart Rengi

  // Ana Kart Gradyanı (#0D1F2D -> #12353C)
  static const LinearGradient heroCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1F2D), Color(0xFF12353C)],
  );

  // Finansal Durum Renkleri
  static const Color incomeGreen = Color(0xFF10B981); // Gelen (+) Bakiye
  static const Color expenseRed = Color(0xFFEF4444); // Giden (-) Bakiye
  static const Color warningOrange = Color(0xFFF59E0B); // Limit Uyarısı
  static const Color infoBlue = Color(0xFF3B82F6); // Bilgi & FAST
}

class AppLightColors {
  // Surface colors
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceDim = Color(0xFFE2E8F0);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F5F9);
  static const Color surfaceContainer = Color(0xFFE2E8F0);
  static const Color surfaceContainerHigh = Color(0xFFCBD5E1);
  static const Color surfaceContainerHighest = Color(0xFF94A3B8);

  // Text colors
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color inverseSurface = Color(0xFF1E293B);
  static const Color inverseOnSurface = Color(0xFFF8FAFC);

  // Primary colors
  static const Color primary = Color(0xFF10B981);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD1FAE5);
  static const Color onPrimaryContainer = Color(0xFF065F46);
  static const Color inversePrimary = Color(0xFF6EE7B7);

  // Secondary colors
  static const Color secondary = Color(0xFF0D9488);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color onSecondaryContainer = Color(0xFF115E59);

  // Tertiary colors
  static const Color tertiary = Color(0xFF0D1F2D);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFE0F2FE);
  static const Color onTertiaryContainer = Color(0xFF0369A1);

  // Error colors
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  // Other colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color onBackground = Color(0xFF0F172A);
  static const Color outline = Color(0xFFCBD5E1);
  static const Color outlineVariant = Color(0xFFE2E8F0);
  static const Color surfaceTint = Color(0xFF10B981);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Fixed colors
  static const Color primaryFixed = Color(0xFFD1FAE5);
  static const Color primaryFixedDim = Color(0xFFA7F3D0);
  static const Color onPrimaryFixed = Color(0xFF064E3B);
  static const Color onPrimaryFixedVariant = Color(0xFF065F46);

  static const Color secondaryFixed = Color(0xFFCCFBF1);
  static const Color secondaryFixedDim = Color(0xFF99F6E4);
  static const Color onSecondaryFixed = Color(0xFF134E4A);
  static const Color onSecondaryFixedVariant = Color(0xFF115E59);

  static const Color tertiaryFixed = Color(0xFFE0F2FE);
  static const Color tertiaryFixedDim = Color(0xFFBAE6FD);
  static const Color onTertiaryFixed = Color(0xFF0C4A6E);
  static const Color onTertiaryFixedVariant = Color(0xFF0369A1);
}

class AppDarkColors {
  // Surface colors
  static const Color surface = Color(0xFF0B131B);
  static const Color surfaceDim = Color(0xFF0B131B);
  static const Color surfaceBright = Color(0xFF1E293B);
  static const Color surfaceContainerLowest = Color(0xFF070D12);
  static const Color surfaceContainerLow = Color(0xFF0F172A);
  static const Color surfaceContainer = Color(0xFF1E293B);
  static const Color surfaceContainerHigh = Color(0xFF334155);
  static const Color surfaceContainerHighest = Color(0xFF475569);

  // Text colors
  static const Color onSurface = Color(0xFFF8FAFC);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);
  static const Color inverseSurface = Color(0xFFF8FAFC);
  static const Color inverseOnSurface = Color(0xFF0F172A);

  // Primary colors
  static const Color primary = Color(0xFF10B981);
  static const Color onPrimary = Color(0xFF022C22);
  static const Color primaryContainer = Color(0xFF065F46);
  static const Color onPrimaryContainer = Color(0xFFD1FAE5);
  static const Color inversePrimary = Color(0xFF059669);

  // Secondary colors
  static const Color secondary = Color(0xFF2DD4BF);
  static const Color onSecondary = Color(0xFF042F2C);
  static const Color secondaryContainer = Color(0xFF115E59);
  static const Color onSecondaryContainer = Color(0xFFCCFBF1);

  // Tertiary colors
  static const Color tertiary = Color(0xFF38BDF8);
  static const Color onTertiary = Color(0xFF082F49);
  static const Color tertiaryContainer = Color(0xFF0369A1);
  static const Color onTertiaryContainer = Color(0xFFE0F2FE);

  // Error colors
  static const Color error = Color(0xFFF87171);
  static const Color onError = Color(0xFF450A0A);
  static const Color errorContainer = Color(0xFF7F1D1D);
  static const Color onErrorContainer = Color(0xFFFEE2E2);

  // Other colors
  static const Color background = Color(0xFF070D12);
  static const Color onBackground = Color(0xFFF8FAFC);
  static const Color outline = Color(0xFF475569);
  static const Color outlineVariant = Color(0xFF1E293B);
  static const Color surfaceTint = Color(0xFF10B981);
  static const Color surfaceVariant = Color(0xFF1E293B);

  // Fixed colors
  static const Color primaryFixed = Color(0xFFD1FAE5);
  static const Color primaryFixedDim = Color(0xFFA7F3D0);
  static const Color onPrimaryFixed = Color(0xFF064E3B);
  static const Color onPrimaryFixedVariant = Color(0xFF065F46);

  static const Color secondaryFixed = Color(0xFFCCFBF1);
  static const Color secondaryFixedDim = Color(0xFF99F6E4);
  static const Color onSecondaryFixed = Color(0xFF134E4A);
  static const Color onSecondaryFixedVariant = Color(0xFF115E59);

  static const Color tertiaryFixed = Color(0xFFE0F2FE);
  static const Color tertiaryFixedDim = Color(0xFFBAE6FD);
  static const Color onTertiaryFixed = Color(0xFF0C4A6E);
  static const Color onTertiaryFixedVariant = Color(0xFF0369A1);
}
