// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ReadlyIt';

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get addArticleTitle => 'Add New Article';

  @override
  String get deleteArticleTitle => 'Delete Article?';

  @override
  String get enterArticleUrlHint => 'Enter article URL';

  @override
  String get enterArticleTitleHint => 'Enter title (optional)';

  @override
  String confirmDeleteArticleContent(String articleTitle) {
    return 'Are you sure you want to delete \"$articleTitle\"?';
  }

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get errorUrlCannotBeEmpty => 'URL cannot be empty.';

  @override
  String get articlesListEmpty => 'No articles saved yet. Add one!';

  @override
  String errorLoadingArticles(Object error) {
    return 'Error loading articles: $error';
  }

  @override
  String get buttonRetry => 'Retry';

  @override
  String get tooltipAddArticle => 'Add Article';

  @override
  String get tooltipDeleteArticle => 'Delete Article';

  @override
  String get homeScreenTitle => 'My Articles';

  @override
  String get fetchingContentText => 'Fetching content...';

  @override
  String get failedToFetchContentText =>
      'Failed to fetch content. Please try again.';

  @override
  String get contentNotFetchedYetText =>
      'Full article content has not been fetched yet.';

  @override
  String get buttonFetchFullArticle => 'Fetch Full Article';

  @override
  String errorCouldNotLaunchUrl(String url) {
    return 'Could not launch URL: $url. Invalid URL or no app to handle it.';
  }

  @override
  String errorCouldNotLaunchUrlGeneral(Object error) {
    return 'Could not launch URL: $error';
  }

  @override
  String errorFetchingContent(String errorMessage) {
    return 'Error fetching content: $errorMessage';
  }

  @override
  String get fetchedContentEmpty => 'Fetched content is empty.';

  @override
  String get tooltipPocketOptions => 'Pocket Options';

  @override
  String get tooltipConnectToPocket => 'Connect to Pocket';

  @override
  String get tooltipPocketAuthError => 'Pocket Auth Error. Tap to retry.';

  @override
  String get menuItemSyncPocketArticles => 'Sync Pocket Articles';

  @override
  String get menuItemLogoutFromPocket => 'Logout from Pocket';

  @override
  String get syncingPocketArticles => 'Syncing Pocket articles...';

  @override
  String pocketSyncFailed(Object error) {
    return 'Pocket Sync Failed: $error';
  }

  @override
  String get pocketSyncSuccessful => 'Pocket Sync Successful!';

  @override
  String get loggedOutFromPocket => 'Logged out from Pocket.';

  @override
  String get bottomNavArticles => 'Articles';

  @override
  String get bottomNavSettings => 'Settings';

  @override
  String navigatedToPagePlaceholder(String pageName) {
    return 'Navigated to $pageName (Placeholder)';
  }

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsAppearanceCurrentSystem =>
      'Currently following system theme.';

  @override
  String get settingsPocketTitle => 'Pocket Integration';

  @override
  String get settingsPocketStatusAuthenticated => 'Authenticated with Pocket';

  @override
  String get settingsPocketLogoutButton => 'Logout';

  @override
  String get settingsPocketStatusNotAuthenticated => 'Not connected to Pocket';

  @override
  String get settingsPocketLoginPrompt =>
      'Please use the \'Connect to Pocket\' option in the app bar on the main screen.';

  @override
  String get settingsPocketStatusError => 'Error checking Pocket status.';

  @override
  String get settingsICloudSyncTitle => 'iCloud Sync (iOS/macOS)';

  @override
  String get settingsICloudSyncStatusPlaceholder =>
      'Sync status will be shown here.';

  @override
  String get pocketImportInProgress => 'Pocket import in progress...';

  @override
  String get pocketImportSuccessNoArticles =>
      'Pocket sync successful. No new articles found.';

  @override
  String pocketImportSuccessArticles(int count) {
    return 'Pocket sync successful. Imported $count new articles.';
  }

  @override
  String get pocketAuthSuccessImportStarting =>
      'Pocket authentication successful! Starting article import...';
}
