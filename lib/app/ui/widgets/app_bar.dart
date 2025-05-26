import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import for localization
import 'package:readlyit/features/articles/presentation/providers/article_providers.dart'; // For pocketIsAuthenticatedProvider & articlesListProvider

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget { // Make it ConsumerWidget
  final String titleText;
  final VoidCallback? onPocketImport; // This will now be conditional based on auth state

  const CustomAppBar({
    super.key,
    required this.titleText,
    this.onPocketImport, // Keep for now, but its direct use might change
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Add WidgetRef
    final pocketAuthAsyncValue = ref.watch(pocketIsAuthenticatedProvider);
    // Cache ScaffoldMessenger if used multiple times, though here it's fine per action.
    // final scaffoldMessenger = ScaffoldMessenger.of(context); 

    return AppBar(
      title: Text(
        titleText,
        style: const TextStyle( // Consistent title style
          fontWeight: FontWeight.bold,
          // fontSize: 20, // Example: if you want to customize size
        ),
      ),
      elevation: 1.0, // Subtle elevation
      centerTitle: true, // Optional: center title
      actions: <Widget>[
        // Pocket integration actions
        pocketAuthAsyncValue.when(
          data: (isAuthenticated) {
            if (isAuthenticated) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.cloud_sync_outlined), // Or Icons.pocket or similar
                tooltip: AppLocalizations.of(context)!.tooltipPocketOptions,
                onSelected: (String choice) async {
                  final articlesNotifier = ref.read(articlesListProvider.notifier);
                  final scaffoldMessenger = ScaffoldMessenger.of(context); // Cache for use in async operations

                  if (choice == 'sync') {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.syncingPocketArticles)),
                    );
                    final error = await articlesNotifier.completePocketAuthenticationAndFetchArticles();
                    if (error != null) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.pocketSyncFailed(error.toString()))),
                      );
                    } else {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.pocketSyncSuccessful)),
                      );
                      // Optionally, you might want to refresh the main articles list
                      // ref.invalidate(articlesListProvider); // Or call a refresh method
                    }
                  } else if (choice == 'logout') {
                    await articlesNotifier.logoutFromPocket();
                    ref.invalidate(pocketIsAuthenticatedProvider); // Refresh the auth state provider
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.loggedOutFromPocket)),
                    );
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'sync',
                      child: Text(AppLocalizations.of(context)!.menuItemSyncPocketArticles),
                    ),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Text(AppLocalizations.of(context)!.menuItemLogoutFromPocket),
                    ),
                  ];
                },
              );
            } else {
              // Not authenticated, show connect button
              return IconButton(
                icon: const Icon(Icons.login_outlined), // Or a Pocket specific icon
                tooltip: AppLocalizations.of(context)!.tooltipConnectToPocket,
                onPressed: onPocketImport, // This is the callback from HomeScreen
              );
            }
          },
          loading: () => const Padding(
            padding: EdgeInsets.only(right: 16.0), // Ensure it's not too close to edge
            child: SizedBox(
              height: 24, // Adjust size to fit appbar
              width: 24,  // Adjust size to fit appbar
              child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white,), // Color for visibility on AppBar
            ),
          ),
          error: (err, stack) => IconButton(
            icon: const Icon(Icons.error_outline, color: Colors.orangeAccent), // Error color
            tooltip: AppLocalizations.of(context)!.tooltipPocketAuthError,
            onPressed: onPocketImport, // Allow retry by initiating the process again
          ),
        ),
        // Example: Add a settings icon button
        // IconButton(
        //   icon: const Icon(Icons.settings_outlined),
        //   tooltip: 'Settings', // Replace with localized string
        //   onPressed: () {
        //     // TODO: Navigate to settings screen or show settings options
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('Settings tapped (Placeholder)')),
        //     );
        //   },
        // ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
