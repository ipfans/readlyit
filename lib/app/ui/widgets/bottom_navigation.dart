import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For potential state later
import 'package:readlyit/l10n/app_localizations.dart'; // Import for localization

// Example: Provider to manage the selected index if needed globally or across complex UI
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class CustomBottomNavigation extends ConsumerWidget { // Changed to ConsumerWidget
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final L10n = AppLocalizations.of(context)!; // For easier access

    return BottomNavigationBar(
      elevation: 2.0, // Add some elevation
      type: BottomNavigationBarType.fixed, // Good for 2-3 items, shows labels
      selectedItemColor: Theme.of(context).colorScheme.primary, // Use primary color for selected
      unselectedItemColor: Colors.grey[600], // Example: A bit muted for unselected
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.article_outlined), // Changed icon
          activeIcon: const Icon(Icons.article), // Icon when active
          label: L10n.bottomNavArticles, // Localized
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: L10n.bottomNavSettings, // Localized
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(bottomNavIndexProvider.notifier).state = index;
      },
    );
  }
}
