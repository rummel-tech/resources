# Workout Planner - Visual Assets & Design System

This repository contains all visual assets and design system specifications for the Workout Planner application ecosystem.

## Repository Structure

```
resources/
├── design-system/          # Design tokens and specifications
│   ├── colors/            # Color palette definitions
│   ├── typography/        # Typography scale and font specifications
│   ├── spacing/           # Spacing and sizing tokens
│   └── components/        # Component specifications
├── assets/                # Visual assets
│   ├── logos/            # Logo variations (SVG, PNG)
│   ├── icons/            # Custom icons
│   ├── images/           # Images and illustrations
│   └── fonts/            # Custom fonts (if any)
└── docs/                  # Documentation
    ├── brand-guidelines.md
    ├── usage-guide.md
    └── flutter-integration.md
```

## Design System Principles

### Brand Colors
- **Primary**: Athletic Blue - Used for primary actions and brand identity
- **Secondary**: Energy Orange - Used for accents and secondary actions
- **Success**: Fitness Green - Used for positive feedback and achievements
- **Warning**: Caution Yellow - Used for warnings and alerts
- **Error**: Alert Red - Used for errors and critical information
- **Neutral**: Grayscale palette for text and backgrounds

### Typography
- **Heading Font**: System default (platform-specific)
- **Body Font**: System default for optimal readability
- **Scale**: Following Material Design type scale

### Spacing
- Base unit: 4px
- Scale: 4, 8, 12, 16, 24, 32, 48, 64px

## Using This Design System

### Flutter Applications

Add this repository as a git submodule or reference assets via URLs:

```yaml
# pubspec.yaml
flutter:
  assets:
    - https://raw.githubusercontent.com/srummel/resources/main/assets/logos/logo.png
```

Or use as submodule:
```bash
git submodule add git@github.com:srummel/resources.git resources
```

### Web Applications

Reference assets directly from GitHub:
```html
<img src="https://raw.githubusercontent.com/srummel/resources/main/assets/logos/logo.png" alt="Workout Planner Logo">
```

## Contributing

When adding or updating visual assets:
1. Follow the established directory structure
2. Use descriptive file names
3. Include both SVG and PNG versions for logos/icons
4. Update relevant documentation
5. Maintain consistency with design system principles

## License

All assets in this repository are proprietary and for use only in Workout Planner applications.