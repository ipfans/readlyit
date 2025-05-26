import 'package:flutter/material.dart';
import 'package:readlyit/app/ui/screens/home_screen.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadLyit',
      themeMode: ThemeMode.system, // Respect system light/dark mode
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blueAccent, // Keep this or change
        // Example: Customize further
        // appBarTheme: const AppBarTheme(
        //   backgroundColor: Colors.blueAccent,
        //   foregroundColor: Colors.white,
        //   elevation: 0,
        // ),
        // floatingActionButtonTheme: FloatingActionButtonThemeData(
        //   backgroundColor: Colors.blueAccent[700],
        //   foregroundColor: Colors.white,
        // ),
        // cardTheme: CardTheme(
        //   elevation: 0.5,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(8.0),
        //     side: BorderSide(color: Colors.grey.shade300, width: 0.5)
        //   )
        // )
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blueAccent, // Seed for dark theme generation
        // Example: Customize dark theme further if needed
        // appBarTheme: AppBarTheme(
        //   backgroundColor: Colors.grey[900],
        // ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false, // Optional: remove debug banner
      // ... localization delegates etc.
    );
  }
}
