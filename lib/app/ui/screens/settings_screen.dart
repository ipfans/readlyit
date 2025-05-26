import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlyit/features/articles/presentation/providers/article_providers.dart';
import 'package:readlyit/app/ui/theme/theme_providers.dart'; 
import 'package:readlyit/l10n/language_providers.dart';    
import 'package:readlyit/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Helper to get display name for AppThemeMode
  String _appThemeModeName(AppThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case AppThemeMode.system:
        return l10n.settingsThemeModeSystem;
      case AppThemeMode.light:
        return l10n.settingsThemeModeLight;
      case AppThemeMode.dark:
        return l10n.settingsThemeModeDark;
    }
  }
  
  // Helper to get display name for Locale
  String _localeName(Locale locale, AppLocalizations l10n) {
     if (locale.languageCode == 'en') return l10n.languageNameEn;
     if (locale.languageCode == 'zh') return l10n.languageNameZh;
     return locale.toLanguageTag(); // Fallback
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pocketAuthAsync = ref.watch(pocketIsAuthenticatedProvider);
    final currentThemeMode = ref.watch(themeModeProvider);
    final currentSeedColor = ref.watch(seedColorProvider);
    final currentLocale = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bottomNavSettings),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjusted vertical padding
            child: Text(l10n.settingsAppearanceTitle, style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            title: Text(l10n.settingsThemeModeTitle),
            trailing: DropdownButton<AppThemeMode>(
              value: currentThemeMode,
              items: AppThemeMode.values.map((AppThemeMode mode) {
                return DropdownMenuItem<AppThemeMode>(
                  value: mode,
                  child: Text(_appThemeModeName(mode, l10n)),
                );
              }).toList(),
              onChanged: (AppThemeMode? newValue) {
                if (newValue != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(newValue);
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n.settingsThemeColorTitle),
            trailing: DropdownButton<AppColorSeed>(
              value: currentSeedColor,
              items: availableSeedColors.map((AppColorSeed seed) {
                return DropdownMenuItem<AppColorSeed>(
                  value: seed,
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: seed.color, size: 16),
                      const SizedBox(width: 8),
                      Text(seed.label), 
                    ],
                  ),
                );
              }).toList(),
              onChanged: (AppColorSeed? newValue) {
                if (newValue != null) {
                  ref.read(seedColorProvider.notifier).setSeedColor(newValue);
                }
              },
            ),
          ),
          const Divider(),

          // --- Language Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(l10n.settingsLanguageTitle, style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            title: Text(l10n.settingsLanguageTitle), 
            trailing: DropdownButton<Locale>(
              value: currentLocale,
              items: availableAppLocales.map((Locale locale) { 
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(_localeName(locale, l10n)),
                );
              }).toList(),
              onChanged: (Locale? newValue) {
                if (newValue != null) {
                  ref.read(languageProvider.notifier).setLanguage(newValue);
                }
              },
            ),
          ),
          const Divider(),

          // --- Font Settings Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(l10n.settingsFontSettingsTitle, style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
            child: Text(
              l10n.settingsFontSettingsDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(l10n.settingsPocketTitle, style: Theme.of(context).textTheme.titleMedium),
          ),
          pocketAuthAsync.when(
            data: (isAuthenticated) {
              if (isAuthenticated) {
                return ListTile(
                  title: Text(l10n.settingsPocketStatusAuthenticated),
                  trailing: ElevatedButton(
                    child: Text(l10n.settingsPocketLogoutButton),
                    onPressed: () async {
                      await ref.read(articlesListProvider.notifier).logoutFromPocket();
                      ref.invalidate(pocketIsAuthenticatedProvider);
                      if (context.mounted) { 
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.loggedOutFromPocket)),
                        );
                      }
                    },
                  ),
                );
              } else {
                return ListTile(
                  leading: const SizedBox(width: 40), // Indent retained as per provided snippet
                  title: Text(l10n.settingsPocketStatusNotAuthenticated),
                  trailing: ElevatedButton(
                    child: Text(l10n.tooltipConnectToPocket), 
                    onPressed: () async { 
                      final articlesNotifier = ref.read(articlesListProvider.notifier);
                      final scaffoldMessenger = ScaffoldMessenger.of(context); 
                      final l10n_for_async = AppLocalizations.of(context)!; 

                      final errorMessage = await articlesNotifier.initiatePocketAuthentication();

                      if (scaffoldMessenger.mounted) { 
                         if (errorMessage != null) {
                             scaffoldMessenger.showSnackBar(
                               SnackBar(content: Text(l10n_for_async.pocketSyncFailed(errorMessage))),
                             );
                         } else {
                             scaffoldMessenger.showSnackBar(
                               SnackBar(content: Text(l10n_for_async.settingsPocketAuthRedirectPrompt)),
                             );
                         }
                      }
                    },
                  ),
                );
              }
            },
            loading: () => const ListTile(leading: SizedBox(width:40), title: Center(child: CircularProgressIndicator())),
            error: (err, stack) => ListTile( 
              leading: const SizedBox(width: 40), // Indent retained
              title: Text(l10n.settingsPocketStatusError),
              subtitle: Text(err.toString()),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(l10n.settingsICloudSyncTitle, style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
             padding: const EdgeInsets.only(left: 16.0, right: 16.0, top:8.0, bottom: 16.0),
             child: Text(
               l10n.settingsICloudSyncStatusPlaceholder,
               style: Theme.of(context).textTheme.bodyMedium,
             ),
          ),
        ],
      ),
    );
  }
}
