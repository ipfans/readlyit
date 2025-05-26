import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- ThemeMode ---
const String _themeModeKey = 'app_theme_mode';

// Enum for our supported theme modes to map to ThemeMode
enum AppThemeMode { system, light, dark }

// Notifier for ThemeMode
class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier(this._prefs) : super(AppThemeMode.system) {
    _loadThemeMode();
  }
  final SharedPreferences _prefs;

  void _loadThemeMode() {
    final themeModeName = _prefs.getString(_themeModeKey);
    if (themeModeName != null) {
      try {
        state = AppThemeMode.values.firstWhere((e) => e.name == themeModeName);
      } catch (_) {
        state = AppThemeMode.system; // Default if stored value is invalid
      }
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    await _prefs.setString(_themeModeKey, mode.name);
  }

  ThemeMode get currentMaterialThemeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }
}

// Provider for ThemeModeNotifier
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  // This will be overridden in main.dart after SharedPreferences is initialized
  throw UnimplementedError('SharedPreferences not initialized for themeModeProvider');
});


// --- Seed Color ---
const String _seedColorKey = 'app_seed_color';

// Enum for predefined seed colors (or store int directly)
// For this example, let's use a list of predefined colors and store their string key.
enum AppColorSeed {
  blue('Blue', Colors.blueAccent), // Default
  green('Green', Colors.green),
  orange('Orange', Colors.orange),
  purple('Purple', Colors.purple);

  const AppColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

// Notifier for SeedColor
class SeedColorNotifier extends StateNotifier<AppColorSeed> {
  SeedColorNotifier(this._prefs) : super(AppColorSeed.blue) { // Default seed color
    _loadSeedColor();
  }
  final SharedPreferences _prefs;

  void _loadSeedColor() {
    final seedColorName = _prefs.getString(_seedColorKey);
    if (seedColorName != null) {
      try {
        state = AppColorSeed.values.firstWhere((e) => e.name == seedColorName);
      } catch (_) {
        state = AppColorSeed.blue; // Default if stored value is invalid
      }
    }
  }

  Future<void> setSeedColor(AppColorSeed colorSeed) async {
    state = colorSeed;
    await _prefs.setString(_seedColorKey, colorSeed.name);
  }
}

// Provider for SeedColorNotifier
final seedColorProvider = StateNotifierProvider<SeedColorNotifier, AppColorSeed>((ref) {
  // This will be overridden in main.dart
  throw UnimplementedError('SharedPreferences not initialized for seedColorProvider');
});

// Helper to get a list of all available seed colors for UI
List<AppColorSeed> get availableSeedColors => AppColorSeed.values.toList();
