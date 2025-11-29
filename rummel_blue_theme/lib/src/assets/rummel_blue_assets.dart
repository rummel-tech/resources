/// Asset path constants for all shared resources
///
/// Provides type-safe access to logos, icons, and images
/// used across all Rummel applications
///
/// ## Available Assets
///
/// ### Logos
/// - Primary logo (with text, color)
/// - White logo (for dark backgrounds)
/// - Icon only (no text)
/// - App-specific icons (Workout, Meal, Home, Vehicle)
///
/// ### Icons
/// Icon directories are available but empty. Add SVG icons as needed:
/// - fitness/ - Workout and exercise icons
/// - nutrition/ - Food and meal icons
/// - home/ - Task and household icons
/// - vehicle/ - Car and maintenance icons
///
/// ### Images
/// Image directories are available but empty. Add images as needed:
/// - onboarding/ - App onboarding screens
/// - placeholders/ - Default avatars and images
/// - backgrounds/ - Background patterns and images
class RummelBlueAssets {
  static const String _packageName = 'rummel_blue_theme';

  // === Logos (Available) ===

  /// Primary logo (full color with text - use on light backgrounds)
  static const String logosPrimary = 'packages/$_packageName/assets/logos/logo_primary.svg';

  /// White logo (with text - use on dark backgrounds)
  static const String logosWhite = 'packages/$_packageName/assets/logos/logo_white.svg';

  /// Logo icon only (no text - can use as app icon)
  static const String logosIcon = 'packages/$_packageName/assets/logos/logo_icon.svg';

  // === App-Specific Icons (Available) ===

  /// Workout Planner app icon (dumbbell design)
  static const String appIconWorkoutPlanner =
      'packages/$_packageName/assets/logos/app_icons/workout_planner_icon.svg';

  /// Meal Planner app icon (fork & knife design)
  static const String appIconMealPlanner =
      'packages/$_packageName/assets/logos/app_icons/meal_planner_icon.svg';

  /// Home Manager app icon (house design)
  static const String appIconHomeManager =
      'packages/$_packageName/assets/logos/app_icons/home_manager_icon.svg';

  /// Vehicle Manager app icon (car design)
  static const String appIconVehicleManager =
      'packages/$_packageName/assets/logos/app_icons/vehicle_manager_icon.svg';

  // === Icon Directories (Empty - Add Icons As Needed) ===
  // Example paths shown below - uncomment and update when icons are added

  // Fitness icons
  // static const String iconsFitnessWorkout = 'packages/$_packageName/assets/icons/fitness/workout.svg';
  // static const String iconsFitnessDumbbell = 'packages/$_packageName/assets/icons/fitness/dumbbell.svg';

  // Nutrition icons
  // static const String iconsNutritionMeal = 'packages/$_packageName/assets/icons/nutrition/meal.svg';
  // static const String iconsNutritionApple = 'packages/$_packageName/assets/icons/nutrition/apple.svg';

  // Home icons
  // static const String iconsHomeTask = 'packages/$_packageName/assets/icons/home/task.svg';
  // static const String iconsHomeClean = 'packages/$_packageName/assets/icons/home/clean.svg';

  // Vehicle icons
  // static const String iconsVehicleCar = 'packages/$_packageName/assets/icons/vehicle/car.svg';
  // static const String iconsVehicleMaintenance = 'packages/$_packageName/assets/icons/vehicle/maintenance.svg';

  // === Image Directories (Empty - Add Images As Needed) ===
  // Example paths shown below - uncomment and update when images are added

  // Onboarding
  // static const String imagesOnboardingWelcome =
  //     'packages/$_packageName/assets/images/onboarding/welcome.png';

  // Placeholders
  // static const String imagesPlaceholderAvatar =
  //     'packages/$_packageName/assets/images/placeholders/avatar.png';
  // static const String imagesPlaceholderImage =
  //     'packages/$_packageName/assets/images/placeholders/image.png';

  // Backgrounds
  // static const String imagesBackgroundPattern =
  //     'packages/$_packageName/assets/images/backgrounds/pattern.png';
}
