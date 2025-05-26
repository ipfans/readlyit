// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '阅';

  @override
  String get helloWorld => '你好，世界！';

  @override
  String get addArticleTitle => '添加新文章';

  @override
  String get deleteArticleTitle => '删除文章？';

  @override
  String get enterArticleUrlHint => '输入文章链接';

  @override
  String get enterArticleTitleHint => '输入标题（可选）';

  @override
  String confirmDeleteArticleContent(String articleTitle) {
    return '您确定要删除“$articleTitle”吗？';
  }

  @override
  String get buttonCancel => '取消';

  @override
  String get buttonSave => '保存';

  @override
  String get buttonDelete => '删除';

  @override
  String get errorUrlCannotBeEmpty => '链接不能为空。';

  @override
  String get articlesListEmpty => '还没有保存的文章。去添加一篇吧！';

  @override
  String errorLoadingArticles(Object error) {
    return '加载文章出错：$error';
  }

  @override
  String get buttonRetry => '重试';

  @override
  String get tooltipAddArticle => '添加文章';

  @override
  String get tooltipDeleteArticle => '删除文章';

  @override
  String get homeScreenTitle => '我的文章';

  @override
  String get fetchingContentText => '正在获取内容...';

  @override
  String get failedToFetchContentText => '获取内容失败，请重试。';

  @override
  String get contentNotFetchedYetText => '尚未获取全文内容。';

  @override
  String get buttonFetchFullArticle => '获取全文';

  @override
  String errorCouldNotLaunchUrl(String url) {
    return '无法启动URL链接：$url。链接无效或没有应用可以处理它。';
  }

  @override
  String errorCouldNotLaunchUrlGeneral(Object error) {
    return '无法启动URL链接：$error';
  }

  @override
  String errorFetchingContent(String errorMessage) {
    return '获取内容时发生错误：$errorMessage';
  }

  @override
  String get fetchedContentEmpty => '获取到的内容为空。';

  @override
  String get tooltipPocketOptions => 'Pocket选项';

  @override
  String get tooltipConnectToPocket => '连接到Pocket';

  @override
  String get tooltipPocketAuthError => 'Pocket授权错误';

  @override
  String get menuItemSyncPocketArticles => '同步Pocket文章';

  @override
  String get menuItemLogoutFromPocket => '从Pocket注销';

  @override
  String get syncingPocketArticles => '正在同步Pocket文章...';

  @override
  String pocketSyncFailed(Object error) {
    return 'Pocket同步失败：$error';
  }

  @override
  String get pocketSyncSuccessful => 'Pocket同步成功！';

  @override
  String get loggedOutFromPocket => '已从Pocket注销。';

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
