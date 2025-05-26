import 'package:flutter/material.dart'; // For Locale
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readlyit/l10n/app_localizations.dart'; // To access supportedLocales

const String _languageCodeKey = 'app_language_code';

// Notifier for Locale
class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier(this._prefs)
    : super(AppLocalizations.supportedLocales.first) {
    // Default to first supported locale (e.g., 'zh')
    _loadLanguage();
  }
  final SharedPreferences _prefs;

  void _loadLanguage() {
    final languageCode = _prefs.getString(_languageCodeKey);
    if (languageCode != null && languageCode.isNotEmpty) {
      final selectedLocale = Locale(languageCode);
      // Ensure the loaded locale is actually supported by the app
      if (AppLocalizations.supportedLocales.contains(selectedLocale)) {
        state = selectedLocale;
        return;
      }
    }
    // If no stored language or stored is invalid, try to match system language
    // This part is tricky as system locale might not be fully available until MaterialApp is built.
    // For simplicity, if nothing is stored or valid, we default to the first supported locale.
    // A more advanced approach could involve WidgetsBinding.instance.platformDispatcher.locale
    // BUT that's more complex for initial load before MaterialApp.
    // Defaulting to the first supported (e.g. Chinese) is fine for now.
    // state = AppLocalizations.supportedLocales.first; // Already set by super
  }

  Future<void> setLanguage(Locale locale) async {
    // Ensure the locale is supported before setting
    if (AppLocalizations.supportedLocales.contains(locale)) {
      state = locale;
      await _prefs.setString(_languageCodeKey, locale.languageCode);
    } else {
      print("Attempted to set unsupported locale: $locale");
    }
  }

  // Helper to get a list of supported locales with their display names (optional)
  // This would typically involve mapping language codes to full names.
  // For now, just providing the locales.
  List<Locale> get supportedLocales =>
      AppLocalizations.supportedLocales.toList();
}

// Provider for LanguageNotifier
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  // This will be overridden in main.dart after SharedPreferences is initialized
  throw UnimplementedError(
    'SharedPreferences not initialized for languageProvider',
  );
});

// Helper to get a list of AppLocalizations.supportedLocales for UI
List<Locale> get availableAppLocales => AppLocalizations.supportedLocales;
