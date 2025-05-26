import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:readlyit/features/articles/presentation/providers/article_providers.dart'; // For Pocket & iCloud status/actions

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pocketAuthAsync = ref.watch(pocketIsAuthenticatedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bottomNavSettings), // Using existing localization key
      ),
      body: ListView(
        children: <Widget>[
          // --- Appearance Section ---
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.settingsAppearanceTitle??"Appearance"), // New key: settingsAppearanceTitle
            // subtitle: Text(l10n.settingsAppearanceSubtitle??"Change app theme (Light/Dark/System)"), // New key: settingsAppearanceSubtitle
            // onTap: () {
            //   // TODO: Implement theme selection dialog or navigation
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(content: Text('Theme settings coming soon!')),
            //   );
            // },
          ),
          // Example: Display current theme mode (read-only for now)
          // This requires a provider for current theme choice if user can change it in-app.
          // For now, we know AppWidget uses ThemeMode.system.
          Padding(
            padding: const EdgeInsets.only(left: 72.0, right: 16.0, bottom: 8.0), // Align with ListTile content
            child: Text(
              l10n.settingsAppearanceCurrentSystem??"Currently following system theme.", // New key: settingsAppearanceCurrentSystem
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const Divider(),

          // --- Pocket Integration Section ---
          ListTile(
            leading: const Icon(Icons.login_outlined), // Consider a Pocket specific icon
            title: Text(l10n.settingsPocketTitle??"Pocket Integration"), // New key: settingsPocketTitle
          ),
          pocketAuthAsync.when(
            data: (isAuthenticated) {
              if (isAuthenticated) {
                return ListTile(
                  leading: const SizedBox(width: 40), // Indent
                  title: Text(l10n.settingsPocketStatusAuthenticated??"Authenticated with Pocket"), // New key: settingsPocketStatusAuthenticated
                  // subtitle: Text("Username: ${pocketUsername}"), // TODO: Get username if available
                  trailing: ElevatedButton(
                    child: Text(l10n.settingsPocketLogoutButton??"Logout"), // New key: settingsPocketLogoutButton
                    onPressed: () async {
                      await ref.read(articlesListProvider.notifier).logoutFromPocket();
                      ref.invalidate(pocketIsAuthenticatedProvider); // Refresh auth state
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.loggedOutFromPocket)), // Existing key
                      );
                    },
                  ),
                );
              } else {
                return ListTile(
                  leading: const SizedBox(width: 40), // Indent
                  title: Text(l10n.settingsPocketStatusNotAuthenticated??"Not connected to Pocket"), // New key: settingsPocketStatusNotAuthenticated
                  trailing: ElevatedButton(
                    child: Text(l10n.tooltipConnectToPocket), // Existing key
                    onPressed: () {
                      // This should trigger the same flow as the AppBar button
                      // Need access to _initiatePocketImport from HomeScreen or replicate logic.
                      // For now, just a placeholder action.
                      // A better way would be to call a method on a provider that HomeScreen also uses.
                      // Or navigate back/show a dialog telling user to use AppBar button.
                      // For now:
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.settingsPocketLoginPrompt??"Please use the 'Connect to Pocket' option in the app bar on the main screen.")), // New key: settingsPocketLoginPrompt
                      );
                    },
                  ),
                );
              }
            },
            loading: () => const ListTile(
              leading: SizedBox(width: 40),
              title: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => ListTile(
              leading: const SizedBox(width: 40),
              title: Text(l10n.settingsPocketStatusError??"Error checking Pocket status."), // New key: settingsPocketStatusError
              subtitle: Text(err.toString()),
            ),
          ),
          const Divider(),

          // --- iCloud Sync Section (Informational) ---
          // This section should only be visible on iOS/macOS
          // if (Platform.isIOS || Platform.isMacOS) ... // Requires dart:io import
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: Text(l10n.settingsICloudSyncTitle??"iCloud Sync (iOS/macOS)"), // New key: settingsICloudSyncTitle
            // TODO: Add subtitle with last sync status/time if available from ICloudService
            // subtitle: Text("Last synced: ${_iCloudService?.lastSyncTime ?? 'Never'}"),
          ),
          // Example: Placeholder for actual sync status
          Padding(
            padding: const EdgeInsets.only(left: 72.0, right: 16.0, bottom: 8.0),
            child: Text(
              l10n.settingsICloudSyncStatusPlaceholder??"Sync status will be shown here.", // New key: settingsICloudSyncStatusPlaceholder
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // --- Other Potential Settings ---
          // const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.storage_outlined),
          //   title: Text(l10n.settingsManageStorageTitle??"Manage Storage"), // New key
          //   onTap: () { /* TODO */ },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.info_outline),
          //   title: Text(l10n.settingsAboutTitle??"About ReadlyIt"), // New key
          //   onTap: () { /* TODO: Show app version, licenses etc. */ },
          // ),
        ],
      ),
    );
  }
}
