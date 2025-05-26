import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlyit/app/app_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readlyit/app/ui/theme/theme_providers.dart';
import 'package:readlyit/l10n/language_providers.dart';
import 'package:readlyit/l10n/app_localizations.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => ThemeModeNotifier(prefs)),
        seedColorProvider.overrideWith((ref) => SeedColorNotifier(prefs)),
        languageProvider.overrideWith((ref) => LanguageNotifier(prefs)),
      ],
      child: const AppWidget(),
    ),
  );
}
