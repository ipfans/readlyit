import 'dart:async';
import 'dart:convert'; // For JSON encoding/decoding if sending complex data as string
import 'dart:io' show Platform; // For checking platform

import 'package:flutter/services.dart';
import 'package:readlyit/features/articles/data/models/article_model.dart';

class ICloudService {
  // IMPORTANT: Replace 'com.example.readlyit' with your actual application's bundle ID prefix.
  static const MethodChannel _channel = MethodChannel('com.example.readlyit/icloud');

  // StreamController for real-time updates from iCloud (optional, advanced)
  // final _iCloudArticlesStreamController = StreamController<List<ArticleModel>>.broadcast();
  // Stream<List<ArticleModel>> get iCloudArticlesStream => _iCloudArticlesStreamController.stream;

  ICloudService() {
    // Optional: Listen for calls from native to Dart, if native needs to push updates
    // _channel.setMethodCallHandler(_handleNativeMethodCall);
    // Note: If you enable _handleNativeMethodCall, ensure it's a top-level function or static method
    // if your ICloudService instance might be recreated.
  }

  // Example of how you might handle calls from native code to Dart.
  // Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
  //   switch (call.method) {
  //     case "iCloudDataChanged":
  //       // This would be called by native code when iCloud data changes
  //       // Potentially fetch new data or signal the app to refresh
  //       print("[ICloudService_Dart] Native code signaled iCloudDataChanged with arguments: ${call.arguments}");
  //       // Example: Force a refresh or emit an event via the stream
  //       // _iCloudArticlesStreamController.add(await fetchArticlesFromCloud());
  //       // Or, more simply, notify another part of your app to trigger a refresh.
  //       break;
  //     default:
  //       print('[ICloudService_Dart] Unknown method call from native: ${call.method}');
  //   }
  // }

  Future<void> initialize() async {
    if (!(Platform.isIOS || Platform.isMacOS)) return;
    try {
      await _channel.invokeMethod('initialize');
      print('[ICloudService_Dart] iCloud initialization method called on native side.');
    } on PlatformException catch (e) {
      print('[ICloudService_Dart] Error initializing iCloud: ${e.message}');
      // Depending on your app's needs, you might want to rethrow or handle this.
    }
  }

  Future<void> syncArticleToCloud(ArticleModel article) async {
    if (!(Platform.isIOS || Platform.isMacOS)) return;
    try {
      final String articleJson = jsonEncode(article.toJson());
      await _channel.invokeMethod('syncArticle', {'articleJson': articleJson});
      print('[ICloudService_Dart] syncArticleToCloud called for article: ${article.id}');
    } on PlatformException catch (e) {
      print('[ICloudService_Dart] Error syncing article ${article.id} to iCloud: ${e.message}');
      throw Exception('Failed to sync article to iCloud: ${e.message}');
    }
  }

  Future<void> deleteArticleFromCloud(String articleId) async {
    if (!(Platform.isIOS || Platform.isMacOS)) return;
    try {
      await _channel.invokeMethod('deleteArticle', {'articleId': articleId});
      print('[ICloudService_Dart] deleteArticleFromCloud called for article ID: $articleId');
    } on PlatformException catch (e) {
      print('[ICloudService_Dart] Error deleting article $articleId from iCloud: ${e.message}');
      throw Exception('Failed to delete article from iCloud: ${e.message}');
    }
  }

  Future<List<ArticleModel>> fetchArticlesFromCloud() async {
    if (!(Platform.isIOS || Platform.isMacOS)) return [];
    try {
      // The native side should return a List of Strings, where each string is a JSON representation of an ArticleModel.
      final List<dynamic>? result = await _channel.invokeListMethod<dynamic>('fetchArticles');
      print('[ICloudService_Dart] fetchArticlesFromCloud called. Received ${result?.length ?? 0} items.');
      if (result != null) {
        return result.map((data) {
          if (data is String) { // Expecting JSON strings from native
            return ArticleModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
          } else if (data is Map) { // Less ideal, but handle if native sends Map<dynamic, dynamic>
             return ArticleModel.fromJson(Map<String, dynamic>.from(data));
          }
          print('[ICloudService_Dart] Unexpected data type from native for article: ${data.runtimeType}, data: $data');
          throw Exception('Unexpected data type from native for article: ${data.runtimeType}');
        }).toList();
      }
      return [];
    } on PlatformException catch (e) {
      print('[ICloudService_Dart] Error fetching articles from iCloud: ${e.message}');
      // Depending on your error handling strategy, you might want to:
      // - return []; (as is)
      // - throw e;
      // - throw CustomException('Failed to fetch articles from iCloud: ${e.message}');
      return []; 
    } catch (e) {
      print('[ICloudService_Dart] Error processing fetched articles: $e');
      throw Exception('Failed to process articles from iCloud: $e');
    }
  }
  
  // This is a conceptual placeholder. True conflict resolution is complex.
  // It might involve native UI or more sophisticated merging logic based on timestamps.
  ArticleModel resolveConflict(ArticleModel localArticle, ArticleModel cloudArticle) {
    print('[ICloudService_Dart] Resolving conflict for article ID: ${localArticle.id}');
    // Basic strategy: last write wins (most recent savedAt or a dedicated modifiedAt timestamp)
    // This assumes 'savedAt' is updated upon any modification.
    // If not, a separate 'modifiedAt' field that's updated on every change is better.
    // Ensure both dates are in UTC for fair comparison if they come from different timezones.
    final localSavedAt = localArticle.savedAt.toUtc();
    final cloudSavedAt = cloudArticle.savedAt.toUtc();

    if (cloudSavedAt.isAfter(localSavedAt)) {
      print('[ICloudService_Dart] Conflict resolved: Cloud version is newer for article ${localArticle.id}.');
      return cloudArticle;
    } else if (localSavedAt.isAfter(cloudSavedAt)) {
      print('[ICloudService_Dart] Conflict resolved: Local version is newer for article ${localArticle.id}.');
      return localArticle;
    } else {
      // Timestamps are identical. Choose one consistently, e.g., local.
      // Or, if content differs, flag as a genuine conflict needing user intervention or deeper merge.
      print('[ICloudService_Dart] Conflict resolved: Timestamps are identical for ${localArticle.id}. Defaulting to local.');
      return localArticle; 
    }
  }

  Future<void> updateLastSyncTimestamp() async {
    if (!(Platform.isIOS || Platform.isMacOS)) return;
    try {
      final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch; // Use UTC for consistency
      await _channel.invokeMethod('updateLastSyncTimestamp', {'timestamp': timestamp});
      print('[ICloudService_Dart] updateLastSyncTimestamp called with UTC: $timestamp');
    } on PlatformException catch (e) {
      print('[ICloudService_Dart] Error updating last sync timestamp: ${e.message}');
    }
  }

  Future<DateTime?> getLastSyncTimestamp() async {
    if (!(Platform.isIOS || Platform.isMacOS)) return null;
    try {
      final int? timestamp = await _channel.invokeMethod<int>('getLastSyncTimestamp');
      print('[ICloudService_Dart] getLastSyncTimestamp called. Received: $timestamp');
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true); // Assume timestamp from native is UTC
      }
      return null;
    } on PlatformException catch (e) {
      print('[ICloudService_Dart] Error getting last sync timestamp: ${e.message}');
      return null;
    }
  }

  Future<void> triggerRemoteChangeCheck() async {
    if (!(Platform.isIOS || Platform.isMacOS)) return;
    try {
      await _channel.invokeMethod('triggerRemoteChangeCheck');
      print('[ICloudService_Dart] triggerRemoteChangeCheck called on native side.');
    } on PlatformException catch (e) {
      print('[ICloudService_Dart] Error triggering remote change check: ${e.message}');
    }
  }
}

// Reminder: This Dart code is only one half of the iCloud synchronization solution.
// You will need to implement the corresponding native Swift/Objective-C (for iOS/macOS)
// code to handle these method calls, interact with iCloud (e.g., CloudKit or iCloud Documents),
// and manage data storage and synchronization on the native side.

// The ICloudServiceProvider in article_providers.dart should provide this service.
// Ensure the provider calls `service.initialize()` upon creation.
// Example from article_providers.dart (ensure this is how you have it):
// final iCloudServiceProvider = Provider<ICloudService>((ref) {
//   final service = ICloudService();
//   // It's good practice to initialize the service when it's first created.
//   // This could also be done lazily if initialization is heavy or needs context.
//   service.initialize(); 
//   return service;
// });
