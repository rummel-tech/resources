# Rummel Blue Theme

Unified theme package for all Rummel applications, providing consistent Material 3 theming, design tokens, and shared assets.

## Applications Using This Theme

- **Workout Planner** - AI-powered fitness coaching
- **Meal Planner** - Weekly meal planning and nutrition
- **Home Manager** - Task management and goal tracking
- **Vehicle Manager** - Vehicle maintenance and fuel tracking

## Features

- 🎨 **Material 3 Themes** - Light and dark themes using ColorScheme.fromSeed
- 🎯 **Design Tokens** - Colors, typography, and spacing from JSON design system
- 📦 **Shared Assets** - Centralized logos, icons, and images
- 🔒 **Type Safety** - Compile-time constants for colors, spacing, and asset paths
- 🔄 **Hot Reload** - Works seamlessly in development
- 📱 **Cross-Platform** - Web, iOS, Android support

## Installation

### As Path Dependency (Development)

```yaml
dependencies:
  rummel_blue_theme:
    path: ../../../resources/rummel_blue_theme
```

### As Git Dependency (Production)

```yaml
dependencies:
  rummel_blue_theme:
    git:
      url: https://github.com/srummel/resources.git
      path: rummel_blue_theme
      ref: main
```

## Usage

### Basic Theme Setup

```dart
import 'package:flutter/material.dart';
import 'package:rummel_blue_theme/rummel_blue_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Rummel App',
      theme: RummelBlueTheme.light(),
      darkTheme: RummelBlueTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
```

### Using Colors

```dart
import 'package:rummel_blue_theme/rummel_blue_theme.dart';

Container(
  color: RummelBlueColors.primary500,
  child: Text(
    'Hello',
    style: TextStyle(color: RummelBlueColors.white),
  ),
)
```

### Using Typography

```dart
import 'package:rummel_blue_theme/rummel_blue_theme.dart';

Text(
  'Headline',
  style: RummelBlueTypography.headlineLarge,
)

// Or use from Theme
Text(
  'Body',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

### Using Spacing

```dart
import 'package:rummel_blue_theme/rummel_blue_theme.dart';

Padding(
  padding: EdgeInsets.all(RummelBlueSpacing.base),
  child: Column(
    spacing: RummelBlueSpacing.md,
    children: [...],
  ),
)

Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(RummelBlueSpacing.radiusMd),
  ),
)
```

### Using Assets

```dart
import 'package:rummel_blue_theme/rummel_blue_theme.dart';

// Using Image widget
Image.asset(RummelBlueAssets.logosPrimary)

// Using as decoration
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage(RummelBlueAssets.imagesBackgroundPattern),
    ),
  ),
)
```

## Design System

### Color Palette

Based on `/design-system/colors/palette.json`

**Primary (Athletic Blue)**
- `primary50` through `primary900`
- Main brand color: `primary500` (#2196F3)

**Secondary (Energy Orange)**
- `secondary50` through `secondary900`
- Accent color: `secondary500` (#FF9800)

**Semantic Colors**
- Success (Green): `success50`, `success500`, `success900`
- Warning (Yellow): `warning50`, `warning500`, `warning900`
- Error (Red): `error50` through `error900`
- Info (Blue): `info50`, `info500`, `info900`

**Neutrals**
- `white`, `neutral50` through `neutral900`, `black`

### Typography Scale

Based on `/design-system/typography/scale.json`

Material Design 3 type scale:
- **Display**: Large headings (displayLarge, displayMedium, displaySmall)
- **Headline**: Section headings (headlineLarge, headlineMedium, headlineSmall)
- **Title**: Subsection titles (titleLarge, titleMedium, titleSmall)
- **Body**: Main content (bodyLarge, bodyMedium, bodySmall)
- **Label**: UI labels (labelLarge, labelMedium, labelSmall)

### Spacing Scale

Based on `/design-system/spacing/tokens.json`

**Base Scale (4px unit)**
- `xs` (4px), `sm` (8px), `md` (12px), `base` (16px)
- `lg` (24px), `xl` (32px), `xxl` (48px), `xxxl` (64px)

**Semantic Spacing**
- Component padding: small, medium, large
- Card padding: compact, default, comfortable
- Screen margins: mobile, tablet, desktop
- Gaps: tight, normal, relaxed, loose

**Border Radius**
- `radiusNone` (0px) through `radiusFull` (9999px)

**Icon Sizes**
- `iconXs` (16px) through `iconXl` (48px)

## Asset Structure

```
assets/
├── logos/
│   ├── logo_primary.svg
│   ├── logo_white.svg
│   ├── logo_icon.svg
│   └── app_icons/
│       ├── workout_planner_icon.svg
│       ├── meal_planner_icon.svg
│       ├── home_manager_icon.svg
│       └── vehicle_manager_icon.svg
├── icons/
│   ├── fitness/
│   ├── nutrition/
│   ├── home/
│   └── vehicle/
└── images/
    ├── onboarding/
    ├── placeholders/
    └── backgrounds/
```

## Customization

### App-Specific Overrides

While the base theme ensures consistency, apps can customize specific aspects:

```dart
final customTheme = RummelBlueTheme.light().copyWith(
  // Override specific properties
  appBarTheme: RummelBlueTheme.light().appBarTheme.copyWith(
    backgroundColor: RummelBlueColors.secondary500,
  ),
);
```

### Theme Extensions

Create app-specific theme extensions:

```dart
extension WorkoutThemeExtension on ThemeData {
  Color get restDayColor => RummelBlueColors.success500;
  Color get trainingDayColor => RummelBlueColors.primary500;
}

// Usage
final color = Theme.of(context).restDayColor;
```

## Development

### Updating Design Tokens

1. Edit JSON files in `/design-system/`
2. Regenerate Dart classes (if using generator)
3. Test changes in all apps
4. Commit and push

### Adding Assets

1. Add asset files to appropriate directory in `assets/`
2. Update `RummelBlueAssets` class with new constants
3. Ensure `pubspec.yaml` includes the asset directory
4. Test asset loading in apps

## Testing

Test the theme in each application:

```bash
# Test in workout-planner
cd workout-planner/applications/frontend/apps/mobile_app
flutter run -d chrome

# Test in meal-planner
cd meal-planner/frontend/app/meals_app
flutter run -d chrome

# Test in home-manager
cd home-manager/frontend/app/home_app
flutter run -d chrome

# Test in vehicle-manager
cd vehicle-manager/frontend/app/vehicle_app
flutter run -d chrome
```

## Version History

### 1.0.0 (Initial Release)
- Material 3 light and dark themes
- Complete color palette from design tokens
- Typography scale (Material Design 3)
- Spacing and sizing constants
- Asset path constants
- Support for all 4 Rummel applications

## Contributing

When making changes to this shared theme:

1. Consider impact on all 4 applications
2. Test changes in all apps before committing
3. Update documentation
4. Follow semantic versioning
5. Coordinate with other developers

## License

Proprietary - For use only in Rummel applications.

---

**Maintained by**: Shawn Rummel
**Last Updated**: 2025-11-21
