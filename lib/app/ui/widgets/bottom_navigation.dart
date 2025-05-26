import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For potential state later

// Example: Provider to manage the selected index if needed globally or across complex UI
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class CustomBottomNavigation extends ConsumerWidget { // Changed to ConsumerWidget
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return BottomNavigationBar(
      elevation: 2.0, // Add some elevation
      type: BottomNavigationBarType.fixed, // Good for 2-3 items, shows labels
      // selectedItemColor: Theme.of(context).colorScheme.primary, // Example: Use primary color for selected
      // unselectedItemColor: Colors.grey[600],
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined), // Changed icon
          activeIcon: Icon(Icons.article), // Icon when active
          label: 'Articles', // Replace with localized string
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings', // Replace with localized string
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(bottomNavIndexProvider.notifier).state = index;
        // TODO: Implement actual navigation based on index
        // For now, just show a SnackBar
        String pageName = index == 0 ? "Articles" : "Settings";
        ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove previous snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigated to $pageName (Placeholder)')), // Replace with localized string
        );
      },
    );
  }
}
