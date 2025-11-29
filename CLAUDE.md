# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is the centralized design system and visual assets repository for all Rummel applications. It contains:
- **rummel_blue_theme**: Flutter package providing unified Material 3 themes
- **design-system/**: JSON design tokens (colors, typography, spacing)
- **assets/**: Shared logos, icons, and images

Used by all 4 applications:
- Workout Planner
- Meal Planner
- Home Manager
- Vehicle Manager

## Repository Structure

```
resources/
├── rummel_blue_theme/      # Flutter theme package (NEW!)
│   ├── lib/
│   │   ├── rummel_blue_theme.dart          # Main export
│   │   └── src/
│   │       ├── colors/rummel_blue_colors.dart
│   │       ├── typography/rummel_blue_typography.dart
│   │       ├── spacing/rummel_blue_spacing.dart
│   │       ├── theme/rummel_blue_theme.dart
│   │       └── assets/rummel_blue_assets.dart
│   ├── assets/            # Shared assets for all apps
│   │   ├── logos/
│   │   ├── icons/
│   │   └── images/
│   ├── pubspec.yaml
│   └── README.md
├── design-system/          # JSON design tokens (source of truth)
│   ├── colors/palette.json
│   ├── typography/scale.json
│   └── spacing/tokens.json
├── assets/                # Legacy asset directories
└── docs/                  # Documentation
```

## Design System Architecture

### Color System (design-system/colors/palette.json)

The color palette is organized into three categories:

- **brand**: Primary (Athletic Blue) and Secondary (Energy Orange) brand colors with full Material Design scale (50-900)
- **semantic**: Success (green), Warning (yellow), Error (red), Info (blue) with key shades (50, 500, 900)
- **neutral**: Grayscale from white to black with full scale (50-900)

### Design Tokens

All design tokens are stored as JSON files to enable cross-platform consumption:
- Flutter applications can parse JSON and generate Dart classes
- Web applications can convert to CSS variables
- Backend services can reference for email templates, PDFs, etc.

Base spacing unit: 4px
Scale: 4, 8, 12, 16, 24, 32, 48, 64px

## Integration Patterns

### Flutter Applications

**Option 1: Git Submodule (Recommended)**
```bash
# From your Flutter app root
git submodule add git@github.com:srummel/resources.git resources
```

Then reference in pubspec.yaml:
```yaml
flutter:
  assets:
    - resources/assets/logos/
    - resources/assets/icons/
```

**Option 2: Direct URL Reference**
Reference assets directly from GitHub raw URLs in pubspec.yaml or code.

### Web Applications

Reference assets directly from GitHub:
```html
<img src="https://raw.githubusercontent.com/srummel/resources/main/assets/logos/logo.png" alt="Workout Planner Logo">
```

## Contributing Guidelines

When adding or updating visual assets:
1. Follow the established directory structure
2. Use descriptive file names (lowercase, hyphen-separated)
3. Include both SVG and PNG versions for logos/icons where applicable
4. Update relevant documentation in docs/
5. Maintain consistency with design system principles
6. Color values must remain in hex format for cross-platform compatibility

## License

All assets in this repository are proprietary and for use only in Workout Planner applications.
