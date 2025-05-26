import 'dart:io' show Platform; // Required for Platform.isIOS/isMacOS checks
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart'; // For PlatformException regarding uni_links
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
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
    _loadArticles().then((_) { // Ensure _loadArticles completes before initial sync
      // Optional Enhancement: Initial Auto-Sync
      if (_iCloudService != null) { 
        print('[ArticlesListNotifier] Initializing: Triggering first iCloud sync.');
        synchronizeWithCloud().catchError((e, s) {
          print('[ArticlesListNotifier] Error during initial auto-sync: $e, Stack: $s');
          // state is already handled by synchronizeWithCloud if it errors,
          // or by _loadArticles if that failed.
        });
      }
    });
    // if (_iCloudService != null) {
    //   _listenToCloudChanges(); // Conceptual: Start listening to iCloud changes
    // }
  }

  ICloudService? get _iCloudService {
    if (Platform.isIOS || Platform.isMacOS) {
      try {
        return _ref.read(iCloudServiceProvider);
      } catch (e) {
        print('[ArticlesListNotifier] iCloudService could not be initialized or read: $e');
        return null;
      }
    }
    return null; // Not on iOS/macOS
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
    if (_iCloudService == null) {
      print('[ArticlesListNotifier] iCloud service not available or not on iOS/macOS, skipping sync.');
      // Optionally, refresh local articles if in a loading state from a previous attempt
      // if (state is AsyncLoading) await _loadArticles();
      return;
    }

    print('[ArticlesListNotifier] Starting full synchronization with iCloud...');
    state = const AsyncValue.loading(); // Indicate sync in progress

    try {
      // 1. Fetch local and cloud articles
      final List<ArticleModel> localArticles = await _databaseService.getAllArticles();
      final List<ArticleModel> cloudArticles = await _iCloudService!.fetchArticlesFromCloud();
      // Consider fetching last sync timestamp for delta sync (more advanced)
      // final DateTime? lastSyncTime = await _iCloudService!.getLastSyncTimestamp();

      final Map<String, ArticleModel> localArticlesMap = {for (var a in localArticles) a.id: a};
      final Map<String, ArticleModel> cloudArticlesMap = {for (var a in cloudArticles) a.id: a};
      final Set<String> allIds = {...localArticlesMap.keys, ...cloudArticlesMap.keys};

      List<Future<void>> syncOperations = [];

      for (String id in allIds) {
        ArticleModel? local = localArticlesMap[id];
        ArticleModel? cloud = cloudArticlesMap[id];

        if (local == null && cloud != null) {
          // Article exists in Cloud, but not locally: Add to local
          print('[SYNC] Article $id new from cloud. Adding locally.');
          syncOperations.add(_databaseService.addArticle(cloud));
        } else if (local != null && cloud == null) {
          // Article exists locally, but not in Cloud: Add to Cloud
          // This could also mean it was deleted from another device.
          // A more robust sync would use tombstones or explicit delete flags.
          // For now, assume local additions should be synced.
          print('[SYNC] Article $id new locally. Syncing to cloud.');
          syncOperations.add(_iCloudService!.syncArticleToCloud(local));
        } else if (local != null && cloud != null) {
          // Article exists in both. Compare and resolve.
          // A proper 'modifiedAt' timestamp is crucial here. 'savedAt' might not always reflect modifications.
          // Using hashCode is a basic check for any difference.
          if (local.hashCode != cloud.hashCode) { // Simple diff check
            ArticleModel resolved = _iCloudService!.resolveConflict(local, cloud);
            print('[SYNC] Article $id conflict. Resolved. Winner: ${resolved == local ? "local" : "cloud"}');
            
            // Update local if resolved is different from local
            if (resolved.hashCode != local.hashCode) {
               print('[SYNC] Updating local article $id with resolved version.');
               syncOperations.add(_databaseService.updateArticle(resolved));
            }
            // Sync to cloud if resolved is different from cloud (or if local was chosen and it's "newer")
            // This ensures the resolved version is propagated.
            // If resolved is identical to cloud, this call might be redundant but safe.
            // If resolved is identical to local (and local was chosen), this syncs local's state.
            print('[SYNC] Syncing resolved article $id back to cloud (if necessary).');
            syncOperations.add(_iCloudService!.syncArticleToCloud(resolved));
          }
        }
      }
      
      // Wait for all database and cloud operations to complete
      await Future.wait(syncOperations);

      // After sync, update the last sync timestamp
      await _iCloudService!.updateLastSyncTimestamp();
      
      print('[ArticlesListNotifier] Full synchronization with iCloud finished.');

    } catch (e, s) {
      print('[ArticlesListNotifier] Error during iCloud synchronization: $e, Stack: $s');
      state = AsyncValue.error(e, s); // Update state to reflect error
      return; // Exit early on error
    }
    
    // Finally, reload articles from local DB to reflect all changes
    await _loadArticles();
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

  // --- Pocket Integration Methods ---

  Future<String?> initiatePocketAuthentication() async {
    // Returns an error message string if failed, null if successful in launching URL
    final pocketService = _ref.read(pocketServiceProvider);
    try {
      final requestToken = await pocketService.obtainRequestToken();
      if (requestToken != null) {
        final authUrl = pocketService.getAuthorizationUrl(requestToken);
        final uri = Uri.parse(authUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return null; // Success in launching
        } else {
          print('[ArticlesListNotifier] Could not launch Pocket URL: $authUrl');
          return 'Could not launch Pocket authorization URL.';
        }
      } else {
        print('[ArticlesListNotifier] Failed to obtain Pocket request token.');
        return 'Failed to obtain Pocket request token.';
      }
    } catch (e) {
      print('[ArticlesListNotifier] Error during Pocket authentication initiation: $e');
      return 'An error occurred during Pocket authentication: ${e.toString()}';
    }
  }

  Future<String?> completePocketAuthenticationAndFetchArticles() async {
    // Returns an error message string if failed, null if successful
    final pocketService = _ref.read(pocketServiceProvider);
    try {
      final success = await pocketService.obtainAccessToken();
      if (success) {
        final articles = await pocketService.fetchArticles();
        // No need to check if articles.isNotEmpty here, addImportedArticles can handle empty list
        await addImportedArticles(articles); // Use existing method to add to DB and refresh UI
        print('[ArticlesListNotifier] Pocket authentication successful, ${articles.length} articles fetched.');
        return null; 
      } else {
        print('[ArticlesListNotifier] Failed to obtain Pocket access token.');
        return 'Failed to obtain Pocket access token.';
      }
    } catch (e) {
      print('[ArticlesListNotifier] Error completing Pocket authentication or fetching articles: $e');
      return 'An error occurred while finalizing Pocket setup: ${e.toString()}';
    }
  }

  Future<void> logoutFromPocket() async {
    final pocketService = _ref.read(pocketServiceProvider);
    await pocketService.logout();
    print('[ArticlesListNotifier] Logged out from Pocket.');
    // Consider if a UI refresh or clearing of Pocket-specific data is needed here.
    // For now, just logging out. If articles from Pocket are specially tagged or handled,
    // you might want to call _loadArticles() or filter them out.
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

// 7. Provider to check if Pocket user is authenticated
final pocketIsAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final pocketService = ref.watch(pocketServiceProvider);
  return await pocketService.isAuthenticated();
});

// Example of a FamilyProvider if we need to fetch a single article by ID
// final articleProvider = FutureProvider.family<ArticleModel?, String>((ref, id) async {
//   final databaseService = ref.watch(databaseServiceProvider);
//   return databaseService.getArticle(id);
// });
