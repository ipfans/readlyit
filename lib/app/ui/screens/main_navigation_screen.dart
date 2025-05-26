import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlyit/app/ui/screens/home_screen.dart';
import 'package:readlyit/app/ui/screens/settings_screen.dart';
import 'package:readlyit/app/ui/widgets/bottom_navigation.dart'; // For bottomNavIndexProvider and CustomBottomNavigation
// Import other necessary providers or widgets if any, e.g. pocketIsImportingProvider for global progress
import 'package:readlyit/features/articles/presentation/providers/article_providers.dart';


class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Initialize PageController with the initial page from the provider
    _pageController = PageController(initialPage: ref.read(bottomNavIndexProvider));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const SettingsScreen(),
  ];

  void _onPageChanged(int index) {
    // This is called when PageView is swiped.
    // We update the bottomNavIndexProvider so the BottomNavigationBar reflects the change.
    ref.read(bottomNavIndexProvider.notifier).state = index;
  }

  // This will be called by CustomBottomNavigation's onTap
  // void _onNavigationItemSelected(int index) { // This function is not explicitly passed if CustomBottomNavigation directly updates the provider
  //    // Update the provider (which CustomBottomNavigation already does)
  //    // ref.read(bottomNavIndexProvider.notifier).state = index; // Already done by CustomBottomNavigation's onTap

  //    // Animate PageView to the selected page
  //    _pageController.animateToPage(
  //      index,
  //      duration: const Duration(milliseconds: 300),
  //      curve: Curves.easeInOut,
  //    );
  // }

  @override
  Widget build(BuildContext context) {
    // Listen to bottomNavIndexProvider to update PageController
    ref.listen<int>(bottomNavIndexProvider, (previous, next) {
      if (_pageController.hasClients && _pageController.page?.round() != next) {
        _pageController.animateToPage(
              next,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
          );
      }
    });
    
    final isPocketImporting = ref.watch(pocketIsImportingProvider);


    return Scaffold(
      // AppBar is now part of individual screens (HomeScreen, SettingsScreen)
      // Or, if a global AppBar is desired, it could be here,
      // dynamically changing title based on currentIndex.
      // For this app, HomeScreen and SettingsScreen define their own AppBars.

      body: Column( // To accommodate global LinearProgressIndicator
        children: [
          if (isPocketImporting) // Global import progress indicator
            LinearProgressIndicator(
              backgroundColor: Colors.transparent, 
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
              minHeight: 4,
            ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _screens,
              // physics: const NeverScrollableScrollPhysics(), // Optional: Disable swipe gesture
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(
        // Pass the item selection handler to CustomBottomNavigation
        // This requires CustomBottomNavigation to accept an optional callback.
        // For now, CustomBottomNavigation directly updates bottomNavIndexProvider.
        // And this MainNavigationScreen listens to that provider to switch pages.
        // This is a valid way to decouple them.
      ),
    );
  }
}
