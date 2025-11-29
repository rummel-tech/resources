# Flutter Integration Guide

This guide explains how to integrate the Workout Planner design system into Flutter applications.

## Setup

### Option 1: Git Submodule (Recommended)

Add this repository as a git submodule to your Flutter project:

```bash
cd /path/to/your/flutter/app
git submodule add git@github.com:srummel/resources.git resources
git submodule update --init --recursive
```

### Option 2: Direct Reference

Reference assets directly from GitHub raw URLs (not recommended for production).

## Consuming Design Tokens

### Colors

Parse the `design-system/colors/palette.json` file and generate Flutter Color constants:

```dart
// lib/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlue700 = Color(0xFF1976D2);
  static const Color secondaryOrange = Color(0xFFFF9800);
  static const Color secondaryOrange700 = Color(0xFFF57C00);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF03A9F4);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color neutral500 = Color(0xFF9E9E9E);
}
```

### Typography

Create a TextTheme based on the typography scale:

```dart
// lib/theme/typography.dart
import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(fontSize: 57, height: 1.12, fontWeight: FontWeight.w400),
    displayMedium: TextStyle(fontSize: 45, height: 1.16, fontWeight: FontWeight.w400),
    displaySmall: TextStyle(fontSize: 36, height: 1.22, fontWeight: FontWeight.w400),

    headlineLarge: TextStyle(fontSize: 32, height: 1.25, fontWeight: FontWeight.w400),
    headlineMedium: TextStyle(fontSize: 28, height: 1.29, fontWeight: FontWeight.w400),
    headlineSmall: TextStyle(fontSize: 24, height: 1.33, fontWeight: FontWeight.w400),

    titleLarge: TextStyle(fontSize: 22, height: 1.27, fontWeight: FontWeight.w400),
    titleMedium: TextStyle(fontSize: 16, height: 1.50, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 14, height: 1.43, fontWeight: FontWeight.w500),

    bodyLarge: TextStyle(fontSize: 16, height: 1.50, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, height: 1.43, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, height: 1.33, fontWeight: FontWeight.w400),

    labelLarge: TextStyle(fontSize: 14, height: 1.43, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 12, height: 1.33, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 11, height: 1.45, fontWeight: FontWeight.w500),
  );
}
```

### Spacing

Create spacing constants:

```dart
// lib/theme/spacing.dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Border Radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;

  // Icon Sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
}
```

## Using Visual Assets

### Reference Assets in pubspec.yaml

```yaml
flutter:
  assets:
    - resources/assets/logos/
    - resources/assets/icons/
    - resources/assets/images/
```

### Load Assets in Code

```dart
// Using images
Image.asset('resources/assets/logos/logo.png')

// Using icons
Image.asset('resources/assets/icons/workout-icon.png', width: 24, height: 24)
```

## Creating a Complete Theme

Combine all design tokens into a single ThemeData:

```dart
// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryOrange,
      error: AppColors.error,
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onError: AppColors.white,
      onSurface: AppColors.black,
    ),
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.white,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryOrange,
      error: AppColors.error,
      surface: AppColors.neutral500,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onError: AppColors.white,
      onSurface: AppColors.white,
    ),
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.black,
  );
}
```

## Code Generation (Advanced)

For larger projects, consider creating a build script that automatically generates Dart code from JSON design tokens:

```dart
// tool/generate_design_tokens.dart
import 'dart:io';
import 'dart:convert';

void main() {
  final colorsJson = File('resources/design-system/colors/palette.json').readAsStringSync();
  final colors = jsonDecode(colorsJson);

  // Generate AppColors class from JSON
  final buffer = StringBuffer();
  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buffer.writeln('import \'package:flutter/material.dart\';');
  buffer.writeln('class AppColors {');

  // Parse and generate color constants...

  buffer.writeln('}');

  File('lib/theme/colors.dart').writeAsStringSync(buffer.toString());
}
```

Run the generator:
```bash
dart tool/generate_design_tokens.dart
```

## Best Practices

1. **Never hardcode colors** - Always reference AppColors constants
2. **Use semantic spacing** - Reference AppSpacing constants instead of raw values
3. **Respect the type scale** - Use TextTheme styles for all text
4. **Keep tokens in sync** - When design tokens update, regenerate Dart classes
5. **Prefer SVG for icons** - Use flutter_svg package for scalable icons
