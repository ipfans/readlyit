# ReadLyit - Read it Later App

ReadLyit is a "Read it Later" application for Android, iOS, and macOS, built with Flutter. It allows users to save articles, web pages, and other content for later reading.

## Features

*   **Cross-Platform:** Supports Android, iOS, and macOS.
*   **Local First Storage:** Articles are primarily stored locally on the device using SQLite.
*   **iCloud Synchronization:** For iOS and macOS users, articles are seamlessly synchronized across devices using iCloud. (Android sync functionality is planned for a future release).
*   **Pocket Import:** Easily import your existing articles from Pocket.
*   **Modern UI/UX:**
    *   Beautiful and intuitive user interface.
    *   Adaptive layouts for optimal viewing on different screen sizes.
    *   Support for dynamic type for improved accessibility.
*   **State Management:** Uses Riverpod for robust and maintainable state management.
*   **Performance:** Designed for responsiveness and smooth performance.
*   **Testing:** Includes comprehensive UI automation test cases.
*   **Localization:** Default interface in Chinese.

## Project Structure

The project follows a feature-first architectural approach, with a clear separation of concerns:

```
lib/
├── app/                # Core application setup, global UI, navigation
│   ├── navigation/
│   └── ui/
│       ├── theme/
│       └── widgets/
├── core/               # Core utilities and services (e.g., database, API clients)
│   ├── services/
│   └── utils/
├── features/           # Feature-specific modules
│   └── articles/       # Example: Article management feature
│       ├── data/
│       │   ├── datasources/ # Local (SQLite) and Remote (iCloud, Pocket)
│       │   │   ├── local/
│       │   │   └── remote/
│       │   └── models/      # Data transfer objects
│       ├── domain/
│       │   ├── entities/    # Business objects
│       │   ├── repositories/ # Abstract repository interfaces
│       │   └── usecases/    # Application-specific business rules
│       └── presentation/
│           ├── providers/   # Riverpod providers for the feature
│           ├── screens/     # UI screens for the feature
│           └── widgets/     # Feature-specific widgets
├── l10n/               # Localization files
└── main.dart           # Main application entry point
```

## Getting Started

(To be updated with build and run instructions)

## Development Guidelines

*   **State Management:** Use Riverpod for all state management.
*   **Immutability:** Favor immutable data structures.
*   **Code Style:** Follow Dart best practices and the official Flutter lint rules.
*   **Testing:** Write unit tests for business logic and widget tests for UI components. Aim for comprehensive UI automation test coverage.
*   **Commits:** Follow conventional commit message formats.
