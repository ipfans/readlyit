import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ReadlyIt'**
  String get appTitle;

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @addArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Article'**
  String get addArticleTitle;

  /// No description provided for @deleteArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Article?'**
  String get deleteArticleTitle;

  /// No description provided for @enterArticleUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Enter article URL'**
  String get enterArticleUrlHint;

  /// No description provided for @enterArticleTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter title (optional)'**
  String get enterArticleTitleHint;

  /// Confirmation message for deleting an article
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{articleTitle}\"?'**
  String confirmDeleteArticleContent(String articleTitle);

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @errorUrlCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'URL cannot be empty.'**
  String get errorUrlCannotBeEmpty;

  /// No description provided for @articlesListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No articles saved yet. Add one!'**
  String get articlesListEmpty;

  /// Error message when articles fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading articles: {error}'**
  String errorLoadingArticles(Object error);

  /// No description provided for @buttonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// No description provided for @tooltipAddArticle.
  ///
  /// In en, this message translates to:
  /// **'Add Article'**
  String get tooltipAddArticle;

  /// No description provided for @tooltipDeleteArticle.
  ///
  /// In en, this message translates to:
  /// **'Delete Article'**
  String get tooltipDeleteArticle;

  /// No description provided for @homeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Articles'**
  String get homeScreenTitle;

  /// No description provided for @fetchingContentText.
  ///
  /// In en, this message translates to:
  /// **'Fetching content...'**
  String get fetchingContentText;

  /// No description provided for @failedToFetchContentText.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch content. Please try again.'**
  String get failedToFetchContentText;

  /// No description provided for @contentNotFetchedYetText.
  ///
  /// In en, this message translates to:
  /// **'Full article content has not been fetched yet.'**
  String get contentNotFetchedYetText;

  /// No description provided for @buttonFetchFullArticle.
  ///
  /// In en, this message translates to:
  /// **'Fetch Full Article'**
  String get buttonFetchFullArticle;

  /// Error when URL launching fails due to invalid URL or no handler
  ///
  /// In en, this message translates to:
  /// **'Could not launch URL: {url}. Invalid URL or no app to handle it.'**
  String errorCouldNotLaunchUrl(String url);

  /// General error when URL launching fails
  ///
  /// In en, this message translates to:
  /// **'Could not launch URL: {error}'**
  String errorCouldNotLaunchUrlGeneral(Object error);

  /// Error when fetching article content fails
  ///
  /// In en, this message translates to:
  /// **'Error fetching content: {errorMessage}'**
  String errorFetchingContent(String errorMessage);

  /// No description provided for @fetchedContentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Fetched content is empty.'**
  String get fetchedContentEmpty;

  /// No description provided for @tooltipPocketOptions.
  ///
  /// In en, this message translates to:
  /// **'Pocket Options'**
  String get tooltipPocketOptions;

  /// No description provided for @tooltipConnectToPocket.
  ///
  /// In en, this message translates to:
  /// **'Connect to Pocket'**
  String get tooltipConnectToPocket;

  /// No description provided for @tooltipPocketAuthError.
  ///
  /// In en, this message translates to:
  /// **'Pocket Auth Error. Tap to retry.'**
  String get tooltipPocketAuthError;

  /// No description provided for @menuItemSyncPocketArticles.
  ///
  /// In en, this message translates to:
  /// **'Sync Pocket Articles'**
  String get menuItemSyncPocketArticles;

  /// No description provided for @menuItemLogoutFromPocket.
  ///
  /// In en, this message translates to:
  /// **'Logout from Pocket'**
  String get menuItemLogoutFromPocket;

  /// No description provided for @syncingPocketArticles.
  ///
  /// In en, this message translates to:
  /// **'Syncing Pocket articles...'**
  String get syncingPocketArticles;

  /// Error message when Pocket sync fails
  ///
  /// In en, this message translates to:
  /// **'Pocket Sync Failed: {error}'**
  String pocketSyncFailed(Object error);

  /// No description provided for @pocketSyncSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Pocket Sync Successful!'**
  String get pocketSyncSuccessful;

  /// No description provided for @loggedOutFromPocket.
  ///
  /// In en, this message translates to:
  /// **'Logged out from Pocket.'**
  String get loggedOutFromPocket;

  /// No description provided for @bottomNavArticles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get bottomNavArticles;

  /// No description provided for @bottomNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get bottomNavSettings;

  /// Placeholder message when navigating via bottom bar
  ///
  /// In en, this message translates to:
  /// **'Navigated to {pageName} (Placeholder)'**
  String navigatedToPagePlaceholder(String pageName);

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsAppearanceCurrentSystem.
  ///
  /// In en, this message translates to:
  /// **'Currently following system theme.'**
  String get settingsAppearanceCurrentSystem;

  /// No description provided for @settingsPocketTitle.
  ///
  /// In en, this message translates to:
  /// **'Pocket Integration'**
  String get settingsPocketTitle;

  /// No description provided for @settingsPocketStatusAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Authenticated with Pocket'**
  String get settingsPocketStatusAuthenticated;

  /// No description provided for @settingsPocketLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsPocketLogoutButton;

  /// No description provided for @settingsPocketStatusNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Not connected to Pocket'**
  String get settingsPocketStatusNotAuthenticated;

  /// No description provided for @settingsPocketLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please use the \'Connect to Pocket\' option in the app bar on the main screen.'**
  String get settingsPocketLoginPrompt;

  /// No description provided for @settingsPocketStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error checking Pocket status.'**
  String get settingsPocketStatusError;

  /// No description provided for @settingsICloudSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'iCloud Sync (iOS/macOS)'**
  String get settingsICloudSyncTitle;

  /// No description provided for @settingsICloudSyncStatusPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Sync status will be shown here.'**
  String get settingsICloudSyncStatusPlaceholder;

  /// No description provided for @pocketImportInProgress.
  ///
  /// In en, this message translates to:
  /// **'Pocket import in progress...'**
  String get pocketImportInProgress;

  /// No description provided for @pocketImportSuccessNoArticles.
  ///
  /// In en, this message translates to:
  /// **'Pocket sync successful. No new articles found.'**
  String get pocketImportSuccessNoArticles;

  /// Success message when Pocket articles are imported
  ///
  /// In en, this message translates to:
  /// **'Pocket sync successful. Imported {count} new articles.'**
  String pocketImportSuccessArticles(int count);

  /// No description provided for @pocketAuthSuccessImportStarting.
  ///
  /// In en, this message translates to:
  /// **'Pocket authentication successful! Starting article import...'**
  String get pocketAuthSuccessImportStarting;

  /// No description provided for @settingsThemeModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get settingsThemeModeTitle;

  /// No description provided for @settingsThemeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeModeSystem;

  /// No description provided for @settingsThemeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeModeLight;

  /// No description provided for @settingsThemeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeModeDark;

  /// No description provided for @settingsThemeColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get settingsThemeColorTitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @languageNameEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEn;

  /// No description provided for @languageNameZh.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageNameZh;

  /// No description provided for @settingsFontSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Font Settings'**
  String get settingsFontSettingsTitle;

  /// No description provided for @settingsFontSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'This app uses your device\'s system font size settings. You can adjust the font size in your phone\'s Display or Accessibility settings.'**
  String get settingsFontSettingsDescription;

  /// No description provided for @settingsPocketAuthRedirectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please authorize with Pocket in your browser. The app will continue once authorization is complete.'**
  String get settingsPocketAuthRedirectPrompt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
