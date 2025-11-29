import 'package:flutter/material.dart';

/// Rummel Blue brand colors based on the shared design system
/// Source: /design-system/colors/palette.json
///
/// This color palette is used across all Rummel applications:
/// - Workout Planner
/// - Meal Planner
/// - Home Manager
/// - Vehicle Manager
class RummelBlueColors {
  // Primary - Athletic Blue
  static const Color primary50 = Color(0xFFE3F2FD);
  static const Color primary100 = Color(0xFFBBDEFB);
  static const Color primary200 = Color(0xFF90CAF9);
  static const Color primary300 = Color(0xFF64B5F6);
  static const Color primary400 = Color(0xFF42A5F5);
  static const Color primary500 = Color(0xFF2196F3);
  static const Color primary600 = Color(0xFF1E88E5);
  static const Color primary700 = Color(0xFF1976D2);
  static const Color primary800 = Color(0xFF1565C0);
  static const Color primary900 = Color(0xFF0D47A1);

  // Secondary - Energy Orange
  static const Color secondary50 = Color(0xFFFFF3E0);
  static const Color secondary100 = Color(0xFFFFE0B2);
  static const Color secondary200 = Color(0xFFFFCC80);
  static const Color secondary300 = Color(0xFFFFB74D);
  static const Color secondary400 = Color(0xFFFFA726);
  static const Color secondary500 = Color(0xFFFF9800);
  static const Color secondary600 = Color(0xFFFB8C00);
  static const Color secondary700 = Color(0xFFF57C00);
  static const Color secondary800 = Color(0xFFEF6C00);
  static const Color secondary900 = Color(0xFFE65100);

  // Semantic Colors - Success (Fitness Green)
  static const Color success50 = Color(0xFFE8F5E9);
  static const Color success500 = Color(0xFF4CAF50);
  static const Color success900 = Color(0xFF1B5E20);

  // Semantic Colors - Warning (Caution Yellow)
  static const Color warning50 = Color(0xFFFFF8E1);
  static const Color warning500 = Color(0xFFFFC107);
  static const Color warning900 = Color(0xFFF57F17);

  // Semantic Colors - Error (Alert Red)
  static const Color error50 = Color(0xFFFFEBEE);
  static const Color error100 = Color(0xFFFFCDD2);
  static const Color error400 = Color(0xFFEF5350);
  static const Color error500 = Color(0xFFF44336);
  static const Color error700 = Color(0xFFD32F2F);
  static const Color error900 = Color(0xFFB71C1C);

  // Semantic Colors - Info
  static const Color info50 = Color(0xFFE1F5FE);
  static const Color info500 = Color(0xFF03A9F4);
  static const Color info900 = Color(0xFF01579B);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);
  static const Color black = Color(0xFF000000);

  // Primary MaterialColor swatch for ThemeData
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF2196F3,
    <int, Color>{
      50: primary50,
      100: primary100,
      200: primary200,
      300: primary300,
      400: primary400,
      500: primary500,
      600: primary600,
      700: primary700,
      800: primary800,
      900: primary900,
    },
  );

  // Secondary MaterialColor swatch for ThemeData
  static const MaterialColor secondarySwatch = MaterialColor(
    0xFFFF9800,
    <int, Color>{
      50: secondary50,
      100: secondary100,
      200: secondary200,
      300: secondary300,
      400: secondary400,
      500: secondary500,
      600: secondary600,
      700: secondary700,
      800: secondary800,
      900: secondary900,
    },
  );
}
