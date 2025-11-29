import 'package:flutter/material.dart';

/// Typography scale based on the shared design system
/// Source: /design-system/typography/scale.json
/// Following Material Design 3 type scale
///
/// Used across all Rummel applications for consistent text styling
class RummelBlueTypography {
  // Display styles - Large headings
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    height: 1.12, // 64px line height
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    height: 1.16, // 52px line height
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    height: 1.22, // 44px line height
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    height: 1.25, // 40px line height
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    height: 1.29, // 36px line height
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    height: 1.33, // 32px line height
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    height: 1.27, // 28px line height
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    height: 1.5, // 24px line height
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    height: 1.43, // 20px line height
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    height: 1.43, // 20px line height
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    height: 1.33, // 16px line height
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    height: 1.45, // 16px line height
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5, // 24px line height
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.43, // 20px line height
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 1.33, // 16px line height
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
}
