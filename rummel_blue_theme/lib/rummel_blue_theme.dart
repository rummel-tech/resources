/// Rummel Blue Theme Package
///
/// Unified theme and design system for all Rummel applications:
/// - Workout Planner
/// - Meal Planner
/// - Home Manager
/// - Vehicle Manager
///
/// This package provides:
/// - Material 3 themes (light and dark)
/// - Brand colors from design tokens
/// - Typography scale
/// - Spacing and sizing constants
/// - Shared asset paths
///
/// Usage:
/// ```dart
/// import 'package:rummel_blue_theme/rummel_blue_theme.dart';
///
/// MaterialApp(
///   theme: RummelBlueTheme.light(),
///   darkTheme: RummelBlueTheme.dark(),
///   // ...
/// );
/// ```
library rummel_blue_theme;

// Export all public APIs
export 'src/colors/rummel_blue_colors.dart';
export 'src/typography/rummel_blue_typography.dart';
export 'src/spacing/rummel_blue_spacing.dart';
export 'src/theme/rummel_blue_theme.dart';
export 'src/assets/rummel_blue_assets.dart';
