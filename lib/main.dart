import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlyit/app/app_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import your new theme providers file
import 'package:readlyit/app/ui/theme/theme_providers.dart';
// Import language providers
import 'package:readlyit/l10n/language_providers.dart';


Future<void> main() async { // Make main async
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => ThemeModeNotifier(prefs)),
        seedColorProvider.overrideWith((ref) => SeedColorNotifier(prefs)),
        languageProvider.overrideWith((ref) => LanguageNotifier(prefs)), // Add this override
      ],
      child: const AppWidget(),
    ),
  );
}
