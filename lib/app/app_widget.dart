import 'dart:async'; // For StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
// import 'package:readlyit/app/ui/screens/home_screen.dart'; // Remove this
import 'package:readlyit/app/ui/screens/main_navigation_screen.dart'; // Add this
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Imports for uni_links
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

// Import your providers
import 'package:readlyit/features/articles/presentation/providers/article_providers.dart';
// Import theme providers
import 'package:readlyit/app/ui/theme/theme_providers.dart';
// Import language provider
import 'package:readlyit/l10n/language_providers.dart';


class AppWidget extends ConsumerStatefulWidget { 
  const AppWidget({super.key});

  @override
  ConsumerState<AppWidget> createState() => _AppWidgetState(); 
}

class _AppWidgetState extends ConsumerState<AppWidget> { 
  StreamSubscription? _subUniLinks;

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  @override
  void dispose() {
    _subUniLinks?.cancel();
    super.dispose();
  }

  Future<void> _initUniLinks() async {
    try {
      // Listen to incoming links when the app is already running
      _subUniLinks = uriLinkStream.listen((Uri? uri) {
        if (uri != null && mounted) {
          _handleIncomingLink(uri);
        }
      }, onError: (err) {
        if (mounted) {
          print('uni_links: Error listening to link stream: $err');
          // Optionally show a toast/snackbar
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text('Error receiving app link: $err')),
          );
        }
      });

      // Check for initial link if the app was opened by a link
      final initialUri = await getInitialUri();
      if (initialUri != null && mounted) {
        _handleIncomingLink(initialUri);
      }
    } on PlatformException catch (e) {
      print('uni_links: Failed to get initial URI: $e');
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Error processing initial app link: ${e.message}')),
        );
      }
    } catch (e) {
      print('uni_links: An unexpected error occurred: $e');
       if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('An unexpected error occurred with app links: $e')),
        );
      }
    }
  }

  void _handleIncomingLink(Uri uri) {
    print('uni_links: Received incoming URI: $uri');
    // Check if this is the Pocket auth callback
    if (uri.scheme == 'readlyit' && uri.host == 'pocket-auth') {
      // `context` here is from _AppWidgetState, which should have AppLocalizations in scope
      final L10n = AppLocalizations.of(context)!; 
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context); // Use maybeOf for safety
      
      // Show initial SnackBar indicating auth success and import starting
      scaffoldMessenger?.showSnackBar(
        SnackBar(content: Text(L10n.pocketAuthSuccessImportStarting)),
      );

      ref.read(articlesListProvider.notifier)
          .completePocketAuthenticationAndFetchArticles()
          .then((errorMessage) {
        if (mounted) { 
          // Re-fetch L10n in case context changed, though unlikely for this specific callback structure
          // final currentL10n = AppLocalizations.of(context)!; 
          if (errorMessage != null) {
            print('Pocket auth callback: Error - $errorMessage');
            scaffoldMessenger?.showSnackBar(
              SnackBar(content: Text(L10n.pocketSyncFailed(errorMessage))), 
            );
          } else {
            print('Pocket auth callback: Success!');
            scaffoldMessenger?.showSnackBar(
              SnackBar(content: Text(L10n.pocketSyncSuccessful)), // Using consistent success message
            );
            ref.invalidate(pocketIsAuthenticatedProvider);
          }
        }
      }).catchError((e) {
        print('Pocket auth callback: Error calling completePocketAuthenticationAndFetchArticles: $e');
        if (mounted) {
           // final currentL10n = AppLocalizations.of(context)!;
          scaffoldMessenger?.showSnackBar(
              SnackBar(content: Text(L10n.pocketSyncFailed(e.toString()))) // Use localized error
          );
        }
      });
    } else {
      print('uni_links: Received URI is not for Pocket auth: $uri');
    }
  }

  @override
  Widget build(BuildContext context) { // WidgetRef is available via `ref` member in ConsumerState
    final currentThemeMode = ref.watch(themeModeProvider);
    final currentSeedColor = ref.watch(seedColorProvider);
    final currentLocale = ref.watch(languageProvider); // Watch the language provider

    return MaterialApp(
      // title: 'ReadLyit', // Replaced by onGenerateTitle
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle, // Better for localization

      themeMode: currentThemeMode.currentMaterialThemeMode, // Use the getter
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: currentSeedColor.color, // Use selected seed color
        // Add other common light theme customizations if any
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: currentSeedColor.color, // Use selected seed color for dark theme too
        // Add other common dark theme customizations if any
      ),
      locale: currentLocale, // Set the app's locale
      home: const MainNavigationScreen(), 
      localizationsDelegates: AppLocalizations.localizationsDelegates, 
      supportedLocales: AppLocalizations.supportedLocales,     
      debugShowCheckedModeBanner: false,
    );
  }
}

// PLATFORM SETUP FOR UNI_LINKS (Custom URL Scheme: readlyit://pocket-auth)
//
// **Android:**
// Add the following intent-filter to your <activity> tag in `android/app/src/main/AndroidManifest.xml`:
// <!-- Within the <application> tag, find your <activity> tag -->
// <!-- The android:name for the activity should be ".MainActivity" or your custom one -->
// <activity ...>
//   <!-- Existing intent-filters, if any -->
//   <intent-filter>
//     <action android:name="android.intent.action.VIEW" />
//     <category android:name="android.intent.category.DEFAULT" />
//     <category android:name="android.intent.category.BROWSABLE" />
//     <data android:scheme="readlyit" android:host="pocket-auth" />
//   </intent-filter>
// </activity>
//
// **iOS:**
// Add the following to your `ios/Runner/Info.plist` file:
// <key>CFBundleURLTypes</key>
// <array>
//   <dict>
//     <key>CFBundleTypeRole</key>
//     <string>Editor</string>
//     <key>CFBundleURLName</key>
//     <string>com.example.readlyit</string> <!-- IMPORTANT: Use your actual bundle ID -->
//     <key>CFBundleURLSchemes</key>
//     <array>
//       <string>readlyit</string>
//     </array>
//   </dict>
// </array>
//
// **macOS:**
// Add the following to your `macos/Runner/Info.plist` file:
// <key>CFBundleURLTypes</key>
// <array>
//   <dict>
//     <key>CFBundleTypeRole</key>
//     <string>Editor</string>
//     <key>CFBundleURLName</key>
//     <string>com.example.readlyit</string> <!-- IMPORTANT: Use your actual bundle ID -->
//     <key>CFBundleURLSchemes</key>
//     <array>
//       <string>readlyit</string>
//     </array>
//   </dict>
// </array>
//
// Make sure to replace "com.example.readlyit" with your actual application's bundle ID 
// in the iOS and macOS Info.plist files.
// The host "pocket-auth" is specified in the Android <data> tag. 
// For iOS/macOS, the scheme 'readlyit' is registered, and the Dart code
// `_handleIncomingLink` further filters by checking `uri.host == 'pocket-auth'`.
//
// After adding these configurations, you may need to rebuild your app for the changes to take effect.
// For Android, ensure your `android/app/build.gradle` has `minSdkVersion 19` or higher for uni_links.
// Check the uni_links package documentation for the most up-to-date setup instructions.
