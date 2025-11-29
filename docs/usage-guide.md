# Design System Usage Guide

This guide provides practical examples and best practices for using the Workout Planner design system.

## Getting Started

### For Developers

1. **Clone the repository** (if using as submodule):
   ```bash
   git submodule add git@github.com:srummel/resources.git resources
   ```

2. **Reference design tokens** in your code by parsing the JSON files or creating constants

3. **Follow the integration guides**:
   - Flutter: See `docs/flutter-integration.md`
   - Web: Reference assets directly from GitHub or clone locally

### For Designers

1. **Use the color palette** defined in `design-system/colors/palette.json`
2. **Follow the typography scale** in `design-system/typography/scale.json`
3. **Apply spacing tokens** from `design-system/spacing/tokens.json`
4. **Review brand guidelines** in `docs/brand-guidelines.md`

## Design Token Structure

All design tokens are stored as JSON for cross-platform compatibility.

### Colors (`design-system/colors/palette.json`)

```json
{
  "brand": {
    "primary": { "500": "#2196F3", ... },
    "secondary": { "500": "#FF9800", ... }
  },
  "semantic": {
    "success": { "500": "#4CAF50" },
    "warning": { "500": "#FFC107" },
    "error": { "500": "#F44336" },
    "info": { "500": "#03A9F4" }
  },
  "neutral": { ... }
}
```

**Usage Examples:**
- Primary button: `brand.primary.500`
- Hover state: `brand.primary.700`
- Disabled state: `neutral.400`
- Success message: `semantic.success.500`

### Typography (`design-system/typography/scale.json`)

**Usage by Content Type:**
- Screen titles: `headline.large` or `headline.medium`
- Section headers: `title.large`
- Card titles: `title.medium`
- Body text: `body.large` (desktop), `body.medium` (mobile)
- Button labels: `label.large`
- Captions: `body.small` or `label.small`

### Spacing (`design-system/spacing/tokens.json`)

**Usage Guidelines:**
- Component padding: Use `semantic.componentPadding`
- Screen margins: Use `semantic.screenMargin`
- Gaps between elements: Use `semantic.gap`
- Custom spacing: Use `scale` values (xs, sm, md, base, lg, xl)

## Component Examples

### Buttons

**Primary Button:**
- Background: `brand.primary.500`
- Text: `neutral.white`
- Typography: `label.large` (14px, medium weight)
- Padding: `componentPadding.medium` (16px)
- Border radius: `borderRadius.md` (8px)
- Min height: 48px (for mobile touch targets)

**Secondary Button:**
- Background: `brand.secondary.500`
- Text: `neutral.white`
- Same typography and spacing as primary

**Text Button:**
- Background: transparent
- Text: `brand.primary.500`
- Same typography as primary
- Padding: `componentPadding.small` (8px)

### Cards

**Standard Card:**
- Background: `neutral.white` (light mode), `neutral.800` (dark mode)
- Padding: `cardPadding.default` (16px)
- Border radius: `borderRadius.lg` (12px)
- Shadow: subtle elevation
- Gap between content: `gap.normal` (8px)

**Compact Card:**
- Padding: `cardPadding.compact` (12px)
- Border radius: `borderRadius.md` (8px)
- Use for lists or dense layouts

### Forms

**Text Input:**
- Height: 56px
- Padding: 16px horizontal
- Border radius: `borderRadius.md` (8px)
- Border: 1px solid `neutral.300`
- Focus border: 2px solid `brand.primary.500`
- Typography: `body.large`

**Label:**
- Typography: `label.medium` or `body.small`
- Color: `neutral.700`
- Spacing above input: `gap.tight` (4px)

### Lists

**List Item:**
- Min height: 56px (single line), 72px (two-line)
- Padding: 16px horizontal
- Gap between icon and text: `gap.normal` (8px)
- Icon size: `iconSizes.md` (24px)
- Primary text: `body.large`
- Secondary text: `body.small` with `neutral.600`

## Color Usage Best Practices

### Do's

✓ Use semantic colors for their intended purpose (error for errors, success for confirmations)
✓ Use the full color scale for interactive states (hover, pressed, disabled)
✓ Maintain sufficient contrast for text readability (4.5:1 minimum)
✓ Test colors in both light and dark modes
✓ Use neutral colors for text and backgrounds

### Don'ts

✗ Don't use semantic colors decoratively (e.g., don't use error red for a delete button unless it's destructive)
✗ Don't hardcode color values - always reference the palette
✗ Don't create new colors without adding them to the design system
✗ Don't use bright colors on bright backgrounds
✗ Don't rely on color alone to convey information (accessibility)

## Typography Best Practices

### Do's

✓ Use the type scale consistently across the application
✓ Maintain proper text hierarchy (display > headline > title > body)
✓ Use medium weight for emphasis, regular for body text
✓ Ensure proper line height for readability (1.4-1.6 for body text)
✓ Use sentence case for most UI text

### Don'ts

✗ Don't create custom font sizes outside the scale
✗ Don't use ALL CAPS for long text
✗ Don't use italic for emphasis (use medium weight instead)
✗ Don't use multiple font families
✗ Don't shrink text below 12px for body content

## Spacing Best Practices

### Do's

✓ Use the 4px base unit for all spacing
✓ Use semantic spacing tokens when available
✓ Maintain consistent spacing within similar components
✓ Use larger spacing to create visual hierarchy
✓ Respect platform-specific spacing (mobile vs. desktop)

### Don'ts

✗ Don't use arbitrary spacing values (e.g., 13px, 19px)
✗ Don't create cramped layouts - give elements room to breathe
✗ Don't forget touch target sizes on mobile (minimum 44×44px)
✗ Don't use the same spacing for all gaps

## Responsive Design

### Breakpoints

- **Mobile**: < 768px
- **Tablet**: 768px - 1024px
- **Desktop**: > 1024px

### Responsive Spacing

```
Mobile:   screenMargin.mobile (16px)
Tablet:   screenMargin.tablet (24px)
Desktop:  screenMargin.desktop (32px)
```

### Responsive Typography

Adjust type scale based on screen size:
- Mobile: Smaller variants (headline.small, body.medium)
- Desktop: Larger variants (headline.large, body.large)

## Accessibility Checklist

- [ ] Color contrast meets WCAG AA standards
- [ ] Text is readable at 200% zoom
- [ ] Interactive elements have 44×44px minimum touch targets (mobile)
- [ ] Focus indicators are clearly visible
- [ ] Color is not the only means of conveying information
- [ ] All images have alt text
- [ ] Form inputs have associated labels

## Adding New Assets

### Process

1. **Create asset** following brand guidelines
2. **Export in appropriate formats**:
   - Logos: SVG + PNG (@1x, @2x, @3x for mobile)
   - Icons: SVG preferred
   - Images: WebP or PNG, optimize file size
3. **Name descriptively**: Use lowercase with hyphens (e.g., `workout-icon-active.svg`)
4. **Place in appropriate directory**
5. **Update documentation** if needed
6. **Commit and push** to repository

### File Naming Conventions

- Logos: `logo-[variant]-[size].ext` (e.g., `logo-primary-large.svg`)
- Icons: `[name]-icon-[state].ext` (e.g., `heart-icon-filled.svg`)
- Images: `[description]-[size].ext` (e.g., `hero-image-mobile.webp`)

## Version Control

This design system uses semantic versioning for major releases:
- **Major**: Breaking changes (e.g., color value changes, token renames)
- **Minor**: New additions (e.g., new colors, new components)
- **Patch**: Documentation updates, bug fixes

Check the repository tags for version history.

## Support

For questions or issues with the design system:
1. Check existing documentation
2. Review brand guidelines
3. Contact the design team
4. Open an issue in the repository
