# ReadLyit - Read it Later App

ReadLyit is a "Read it Later" application for Android, iOS, and macOS, built with Flutter. It allows users to save articles, web pages, and other content for later reading.

## Features

*   **Cross-Platform:** Supports Android, iOS, and macOS.
*   **Local First Storage:** Articles are primarily stored locally on the device using SQLite.
*   **Article Content Fetching:** Fetches the main content of articles for an improved offline reading experience using HTML parsing.
*   **Pocket Import:** Easily import your existing articles from Pocket (requires one-time authentication).
*   **iCloud Synchronization (iOS & macOS):** Dart interface for iCloud synchronization is implemented. Native (Swift/Objective-C) CloudKit implementation is required by the developer to enable this feature. (Android sync functionality is planned for a future release).
*   **Settings Screen:** Configure application preferences, including:
    *   Theme mode selection (Light, Dark, System).
    *   Primary theme color selection.
    *   In-app language selection (e.g., English, Chinese).
    *   Pocket account management (status, logout, connect).
    *   Information on system font size settings.
*   **Modern UI/UX:**
    *   Beautiful and intuitive user interface.
    *   Adaptive layouts for optimal viewing on different screen sizes, including responsive List/Grid view for articles.
    *   Support for dynamic type for improved accessibility (developer testing recommended).
*   **State Management:** Uses Riverpod for robust and maintainable state management.
*   **Performance:** Designed for responsiveness and smooth performance.
*   **Testing:** Includes widget tests for key UI components. (Comprehensive UI automation test coverage is planned).
*   **Localization:** Default interface in Chinese, with English language support.

## Project Structure

```
readlyit/
├── android/                      # Android specific files
├── ios/                          # iOS specific files
├── lib/                          # Dart code
│   ├── app/                      # Application-wide widgets, routing, themes
│   │   ├── ui/                   # UI specific components (screens, widgets)
│   │   └── ...
│   ├── core/                     # Core utilities, services (e.g., database, API clients)
│   │   └── services/
│   ├── features/                 # Feature modules (e.g., articles, settings)
│   │   └── articles/
│   │       ├── data/             # Data layer (models, sources, repositories)
│   │       │   ├── datasources/  # Local and remote data sources
│   │       │   ├── models/       # Data models
│   │       │   └── repositories/ # Repositories
│   │       ├── domain/           # Domain layer (entities, use cases - if using Clean Architecture)
│   │       └── presentation/     # Presentation layer (providers, screens, widgets specific to feature)
│   │           ├── providers/    # Riverpod providers
│   │           ├── screens/      # Feature screens
│   │           └── widgets/      # Feature-specific widgets
│   ├── l10n/                     # Localization files
│   └── main.dart                 # Main application entry point
├── macos/                        # macOS specific files
├── test/                         # Automated tests
│   ├── core/
│   ├── features/
│   └── ui/
├── .gitignore
├── pubspec.yaml                  # Project dependencies and metadata
└── README.md
```

## Getting Started

**(To be updated with detailed build and run instructions for each platform)**

### Required Setup

Before running the application, some platform-specific and API key configurations are necessary:

#### 1. Pocket Integration Setup
To enable importing articles from Pocket, you need to:
1.  Obtain a **Consumer Key** from the [Pocket Developer API site](https://getpocket.com/developer/).
2.  Open the file `lib/features/articles/data/datasources/remote/pocket_service.dart`.
3.  Replace the placeholder string `'YOUR_POCKET_CONSUMER_KEY_HERE'` with your actual Pocket Consumer Key.
4.  Configure the custom URL scheme `readlyit://pocket-auth` for the OAuth callback. Detailed instructions for Android (`AndroidManifest.xml`), iOS (`Info.plist`), and macOS (`Info.plist`) are provided as comments at the end of the `lib/app/app_widget.dart` file.

#### 2. iCloud Synchronization Setup (for iOS/macOS Developers)
The application includes a Dart interface (`ICloudService`) for synchronizing articles using iCloud on iOS and macOS. To enable this:
1.  You will need to implement the native Swift/Objective-C methods that are called by the `ICloudService` platform channel. These methods will handle the actual CloudKit operations (saving, fetching, deleting records, etc.).
2.  Configure iCloud capabilities for your app in Xcode, including setting up a CloudKit container and appropriate entitlements.

#### 3. Code Generation (if applicable)
If you modify files that require code generation (e.g., for Riverpod providers with `@riverpod` annotations, or for Mockito mocks in tests), run the following command:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
This is necessary, for example, after creating or updating mock definitions for tests.

## Development Guidelines

*   **Code Style:** Follow the official [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines.
*   **State Management:** Utilize Riverpod for state management. Clearly define providers and their scope.
*   **Immutability:** Prefer immutable data structures where possible, especially for state objects.
*   **Error Handling:** Implement robust error handling, especially for network requests and data parsing.
*   **Testing:** Write unit, widget, and integration tests for your features.
*   **Localization:** Ensure all user-facing strings are localized using Flutter's internationalization support. Add new keys to `lib/l10n/app_en.arb` (and other language files like `app_zh.arb`).
*   **Commit Messages:** Follow conventional commit message formats (e.g., `feat: Add new article saving feature`).
*   **README Updates:** Keep this README updated with any new features, setup steps, or important architectural changes.

## Contributing
(To be added - guidelines for contributing to the project)

## License
MIT
