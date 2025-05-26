// import 'dart:io'; // Required for Platform.isIOS/isMacOS checks
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlyit/core/services/database_service.dart';
import 'package:readlyit/features/articles/data/datasources/remote/pocket_service.dart';
import 'package:readlyit/features/articles/data/datasources/remote/icloud_service.dart';
import 'package:readlyit/features/articles/data/datasources/remote/article_content_fetcher_service.dart'; // Add this import
import 'package:readlyit/features/articles/data/models/article_model.dart';

// 1. Provider for DatabaseService
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

// 2. StateNotifier for managing the list of articles
class ArticlesListNotifier extends StateNotifier<AsyncValue<List<ArticleModel>>> {
  final DatabaseService _databaseService;
  // final ICloudService? _iCloudService; // Made nullable, only available on iOS/macOS
  final Ref _ref; // Keep a reference to Ref to read other providers

  ArticlesListNotifier(this._databaseService, this._ref /*, this._iCloudService*/)
      : super(const AsyncValue.loading()) {
    _loadArticles();
    // if (_iCloudService != null) {
    //   _listenToCloudChanges(); // Conceptual: Start listening to iCloud changes
    // }
  }

  ICloudService? get _iCloudService {
    // Dynamically get iCloudService only if on relevant platform and enabled
    // For placeholder, we assume it's always available if provider is used.
    // In real app: check Platform.isIOS || Platform.isMacOS
    try {
      return _ref.read(iCloudServiceProvider);
    } catch (e) {
      // Provider not available or other error
      print('[ArticlesListNotifier] iCloudService not available: $e');
      return null;
    }
  }

  Future<void> _loadArticles() async {
    try {
      state = const AsyncValue.loading();
      final articles = await _databaseService.getAllArticles();
      state = AsyncValue.data(articles);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addArticle(ArticleModel article) async {
    try {
      await _databaseService.addArticle(article); // Local save
      await _loadArticles(); // Refresh UI

      // Sync to iCloud (iOS/macOS only, and if enabled)
      // if (Platform.isIOS || Platform.isMacOS) { // Requires dart:io
      if (_iCloudService != null) {
        await _iCloudService!.syncArticleToCloud(article);
      }
      // }
      print('[ArticlesListNotifier] Article ${article.id} added, conceptual iCloud sync call.');
    } catch (e, s) {
      // Optionally update state to reflect error for this specific operation
      // For now, just logging or rethrowing if _loadArticles handles error state
      print('Error adding article: $e, Stack: $s'); // Replace with proper logging
      await _loadArticles(); // Still try to reload state
    }
  }

  Future<void> deleteArticle(String articleId) async {
    try {
      await _databaseService.deleteArticle(articleId); // Local delete
      await _loadArticles(); // Refresh UI

      // Sync deletion to iCloud
      // if (Platform.isIOS || Platform.isMacOS) {
      if (_iCloudService != null) {
        await _iCloudService!.deleteArticleFromCloud(articleId);
      }
      // }
      print('[ArticlesListNotifier] Article $articleId deleted, conceptual iCloud sync call.');
    } catch (e, s) {
      print('Error deleting article: $e, Stack: $s');
      await _loadArticles();
    }
  }

  Future<void> updateArticle(ArticleModel article) async {
    try {
      await _databaseService.updateArticle(article);
      await _loadArticles(); // Refresh the list

      // Sync update to iCloud
      // if (Platform.isIOS || Platform.isMacOS) {
      if (_iCloudService != null) {
        await _iCloudService!.syncArticleToCloud(article); // syncArticleToCloud can also handle updates
      }
      // }
      print('[ArticlesListNotifier] Article ${article.id} updated, conceptual iCloud sync call.');
    } catch (e, s) {
      print('Error updating article: $e, Stack: $s');
      await _loadArticles();
    }
  }

  Future<void> toggleReadStatus(String articleId, bool isRead) async {
    try {
      // Optimistic update: update UI first, then DB
      ArticleModel? updatedArticle;
      state = state.whenData((articles) {
        return articles.map((article) {
          if (article.id == articleId) {
            updatedArticle = article.copyWith(isRead: isRead);
            return updatedArticle!;
          }
          return article;
        }).toList();
      });
      await _databaseService.toggleReadStatus(articleId, isRead);

      // Sync toggle to iCloud
      // if (Platform.isIOS || Platform.isMacOS && updatedArticle != null) {
      if (_iCloudService != null && updatedArticle != null) {
        await _iCloudService!.syncArticleToCloud(updatedArticle!);
      }
      // }
      print('[ArticlesListNotifier] Article $articleId read status toggled, conceptual iCloud sync call.');
      // If DB operation fails, we might need to roll back the optimistic update
      // or just reload from DB which will correct it.
      await _loadArticles(); // Refresh to ensure consistency
    } catch (e, s) {
      print('Error toggling read status: $e, Stack: $s');
      // Attempt to reload to revert optimistic update on error
      await _loadArticles();
    }
  }

  Future<void> refresh() async {
    await _loadArticles();
    // Optionally trigger a manual cloud sync on refresh
    // await synchronizeWithCloud();
  }

  // This method would be called after PocketService successfully fetches articles
  Future<void> addImportedArticles(List<ArticleModel> pocketArticles) async {
    try {
      for (final article in pocketArticles) {
        final articleWithNewLabelAndNewId = ArticleModel.create(
          url: article.url,
          title: article.title,
          content: article.content,
          excerpt: article.excerpt,
          source: 'Pocket',
        );
        await _databaseService.addArticle(articleWithNewLabelAndNewId);
        // Conceptually, imported articles should also be synced to iCloud if enabled
        // if (Platform.isIOS || Platform.isMacOS) {
        if (_iCloudService != null) {
          await _iCloudService!.syncArticleToCloud(articleWithNewLabelAndNewId);
        }
        // }
      }
      await _loadArticles();
      print('[ArticlesListNotifier] Imported articles added and conceptually synced to iCloud.');
    } catch (e, s) {
      print('Error adding imported articles: $e, Stack: $s');
      await _loadArticles();
    }
  }

  // Method to handle incoming changes from iCloud (this is the hard part)
  Future<void> synchronizeWithCloud() async {
    print('[ArticlesListNotifier] Starting conceptual full synchronization with iCloud...');
    // if (!(Platform.isIOS || Platform.isMacOS)) return;
    if (_iCloudService == null) {
      print('[ArticlesListNotifier] iCloud service not available, skipping sync.');
      return;
    }

    state = const AsyncValue.loading(); // Indicate sync in progress

    try {
      final localArticles = await _databaseService.getAllArticles();
      final cloudArticles = await _iCloudService!.fetchArticlesFromCloud();
      // final lastCloudSync = await _iCloudService.getLastSyncTimestamp(); // For more advanced sync

      // This requires a robust 2-way sync logic:
      // 1. Get local articles modified since lastCloudSync.
      // 2. Get cloud articles modified since lastCloudSync (needs server-side timestamp or diffing).
      // 3. Identify new, modified, deleted items on both sides.
      // 4. Resolve conflicts (e.g., using `_iCloudService.resolveConflict`).
      //    - Local new, Cloud doesn't have -> Add to Cloud
      //    - Cloud new, Local doesn't have -> Add to Local
      //    - Both modified -> Resolve conflict, then update both
      //    - Local deleted, Cloud has -> Delete from Cloud
      //    - Cloud deleted, Local has -> Delete from Local

      // Simplified placeholder: merge based on ID, cloud wins for conflicts for now
      Map<String, ArticleModel> localArticlesMap = {for (var a in localArticles) a.id: a};
      Map<String, ArticleModel> cloudArticlesMap = {for (var a in cloudArticles) a.id: a};
      Set<String> allIds = {...localArticlesMap.keys, ...cloudArticlesMap.keys};

      for (String id in allIds) {
        ArticleModel? local = localArticlesMap[id];
        ArticleModel? cloud = cloudArticlesMap[id];

        if (local == null && cloud != null) { // New in cloud
          await _databaseService.addArticle(cloud);
        } else if (local != null && cloud == null) { // New locally (or deleted in cloud)
          await _iCloudService!.syncArticleToCloud(local); // Sync local to cloud
        } else if (local != null && cloud != null) { // Exists in both
          // This is where proper conflict resolution based on timestamps or content is needed
          // For this placeholder, if they are different, assume cloud is "more recent"
          // A real implementation needs a 'modifiedAt' field or better diffing.
          if (local.hashCode != cloud.hashCode) { // Basic check, not robust
             final resolved = _iCloudService!.resolveConflict(local, cloud); // Use defined strategy
             await _databaseService.updateArticle(resolved); // Update local
             if (resolved.id == cloud.id && resolved.hashCode != cloud.hashCode) { // If resolved is different from original cloud
                await _iCloudService!.syncArticleToCloud(resolved); // Sync resolved back to cloud
             } else if (resolved.id == local.id && resolved.hashCode != local.hashCode) {
                // if local was chosen and it was different, it's already in local db.
             }
          }
        }
      }
      // For items deleted locally but still in cloud (if not handled by `local != null && cloud == null` logic above)
      // and items deleted in cloud but still local. A more robust sync would track deletions.

      await _loadArticles(); // Refresh UI from local DB
      await _iCloudService!.updateLastSyncTimestamp();
      print('[ArticlesListNotifier] Conceptual full synchronization with iCloud finished.');
    } catch (e, s) {
      print('[ArticlesListNotifier] Error during iCloud synchronization: $e, Stack: $s');
      state = AsyncValue.error(e, s); // Update state to reflect error
    }
  }

  // Consider listening to iCloudService.iCloudArticlesStream for real-time updates
  // StreamSubscription? _iCloudSubscription;
  // void _listenToCloudChanges() {
  //   if (_iCloudService == null) return;
  //   _iCloudSubscription?.cancel(); // Cancel previous subscription
  //   _iCloudSubscription = _iCloudService!.iCloudArticlesStream.listen((cloudArticles) {
  //     print('[ArticlesListNotifier] Received conceptual update from iCloud stream.');
  //     // Trigger merge/synchronization logic here
  //     synchronizeWithCloud(); // Or a more targeted update
  //   }, onError: (error) {
  //     print('[ArticlesListNotifier] Error in iCloud stream: $error');
  //   });
  // }

  // @override
  // void dispose() {
  //   _iCloudSubscription?.cancel();
  //   super.dispose();
  // }

  Future<void> fetchAndStoreArticleContent(String articleId, String url) async {
    state = state.whenData((articles) { // Optionally set specific article to loading state
        return articles.map((a) => a.id == articleId ? a.copyWith(content: "Fetching...") : a).toList();
    });

    try {
      final fetcherService = _ref.read(articleContentFetcherServiceProvider);
      final fetchedContent = await fetcherService.fetchContent(url);

      final existingArticle = await _databaseService.getArticle(articleId);
      if (existingArticle != null) {
        final updatedArticle = existingArticle.copyWith(content: fetchedContent);
        await _databaseService.updateArticle(updatedArticle);
        await _loadArticles(); // Reload all articles to update the UI
      } else {
        // Handle case where article might have been deleted in the meantime
        print('[ArticlesListNotifier] Article $articleId not found to store fetched content.');
        await _loadArticles(); // Still refresh list
      }
    } catch (e, s) {
      print('[ArticlesListNotifier] Error fetching or storing article content: $e, Stack: $s');
      // Revert content or show error specific to the article
      final existingArticle = await _databaseService.getArticle(articleId);
      if (existingArticle != null && existingArticle.content == "Fetching...") {
         await _databaseService.updateArticle(existingArticle.copyWith(content: "Failed to fetch."));
      }
      await _loadArticles(); // Reload to revert optimistic update or show error
      // Re-throw the exception to be caught by the UI if needed
      throw Exception('Failed to fetch and store content: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }
}

// 3. StateNotifierProvider for ArticlesListNotifier
final articlesListProvider =
    StateNotifierProvider<ArticlesListNotifier, AsyncValue<List<ArticleModel>>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  // final pocketService = ref.watch(pocketServiceProvider); // If you were passing it
  // final iCloudService = ref.watch(iCloudServiceProvider); // If you were passing it
  return ArticlesListNotifier(databaseService, ref /*, pocketService, iCloudService */);
});

// 4. Provider for PocketService
final pocketServiceProvider = Provider<PocketService>((ref) {
  return PocketService();
});

// 5. Provider for ICloudService
final iCloudServiceProvider = Provider<ICloudService>((ref) {
  final service = ICloudService();
  service.initialize();
  return service;
});

// 6. Provider for ArticleContentFetcherService
final articleContentFetcherServiceProvider = Provider<ArticleContentFetcherService>((ref) {
  return ArticleContentFetcherService();
});

// Example of a FamilyProvider if we need to fetch a single article by ID
// final articleProvider = FutureProvider.family<ArticleModel?, String>((ref, id) async {
//   final databaseService = ref.watch(databaseServiceProvider);
//   return databaseService.getArticle(id);
// });
