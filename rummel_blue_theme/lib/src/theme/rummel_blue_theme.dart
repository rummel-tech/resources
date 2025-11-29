import 'package:flutter/material.dart';
import '../colors/rummel_blue_colors.dart';
import '../typography/rummel_blue_typography.dart';
import '../spacing/rummel_blue_spacing.dart';

/// Main theme configuration for all Rummel applications
///
/// Provides unified Material 3 themes that ensure consistent
/// look and feel across:
/// - Workout Planner
/// - Meal Planner
/// - Home Manager
/// - Vehicle Manager
class RummelBlueTheme {
  /// Light theme configuration
  static ThemeData light() {
    // Use ColorScheme.fromSeed for Material 3 consistency
    final scheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: RummelBlueColors.primary500,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        centerTitle: false,
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 1,
        margin: const EdgeInsets.symmetric(
          vertical: RummelBlueSpacing.gapNormal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
        ),
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: RummelBlueTypography.displayLarge,
        displayMedium: RummelBlueTypography.displayMedium,
        displaySmall: RummelBlueTypography.displaySmall,
        headlineLarge: RummelBlueTypography.headlineLarge,
        headlineMedium: RummelBlueTypography.headlineMedium,
        headlineSmall: RummelBlueTypography.headlineSmall,
        titleLarge: RummelBlueTypography.titleLarge,
        titleMedium: RummelBlueTypography.titleMedium,
        titleSmall: RummelBlueTypography.titleSmall,
        labelLarge: RummelBlueTypography.labelLarge,
        labelMedium: RummelBlueTypography.labelMedium,
        labelSmall: RummelBlueTypography.labelSmall,
        bodyLarge: RummelBlueTypography.bodyLarge,
        bodyMedium: RummelBlueTypography.bodyMedium,
        bodySmall: RummelBlueTypography.bodySmall,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: RummelBlueSpacing.lg,
            vertical: RummelBlueSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: RummelBlueSpacing.base,
            vertical: RummelBlueSpacing.sm,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          padding: const EdgeInsets.symmetric(
            horizontal: RummelBlueSpacing.lg,
            vertical: RummelBlueSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
          ),
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceVariant,
        selectedColor: scheme.primaryContainer,
        labelStyle: RummelBlueTypography.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: RummelBlueSpacing.md,
          vertical: RummelBlueSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RummelBlueColors.neutral100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RummelBlueSpacing.base,
          vertical: RummelBlueSpacing.md,
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: RummelBlueColors.neutral300,
        thickness: 1,
        space: RummelBlueSpacing.base,
      ),

      // Icon theme
      iconTheme: IconThemeData(
        size: RummelBlueSpacing.iconMd,
        color: scheme.onSurface,
      ),

      // FloatingActionButton theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusXl),
        ),
      ),

      // BottomNavigationBar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: RummelBlueColors.neutral600,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: RummelBlueColors.neutral800,
        contentTextStyle: RummelBlueTypography.bodyMedium.copyWith(
          color: RummelBlueColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusLg),
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData dark() {
    // Use ColorScheme.fromSeed for Material 3 consistency
    final scheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: RummelBlueColors.primary500,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        centerTitle: false,
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.symmetric(
          vertical: RummelBlueSpacing.gapNormal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
        ),
      ),

      // Typography (same as light)
      textTheme: TextTheme(
        displayLarge: RummelBlueTypography.displayLarge,
        displayMedium: RummelBlueTypography.displayMedium,
        displaySmall: RummelBlueTypography.displaySmall,
        headlineLarge: RummelBlueTypography.headlineLarge,
        headlineMedium: RummelBlueTypography.headlineMedium,
        headlineSmall: RummelBlueTypography.headlineSmall,
        titleLarge: RummelBlueTypography.titleLarge,
        titleMedium: RummelBlueTypography.titleMedium,
        titleSmall: RummelBlueTypography.titleSmall,
        labelLarge: RummelBlueTypography.labelLarge,
        labelMedium: RummelBlueTypography.labelMedium,
        labelSmall: RummelBlueTypography.labelSmall,
        bodyLarge: RummelBlueTypography.bodyLarge,
        bodyMedium: RummelBlueTypography.bodyMedium,
        bodySmall: RummelBlueTypography.bodySmall,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: RummelBlueSpacing.lg,
            vertical: RummelBlueSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
          ),
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceVariant,
        selectedColor: scheme.primaryContainer,
        labelStyle: RummelBlueTypography.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: RummelBlueSpacing.md,
          vertical: RummelBlueSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
        ),
      ),

      // BottomNavigationBar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: RummelBlueColors.neutral400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
