import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readlyit/features/articles/data/models/article_model.dart';
// Required for uni_links
import 'package:uni_links/uni_links.dart'; 
import 'package:flutter/services.dart'; // For PlatformException

// Define your Pocket consumer key here.
// IMPORTANT: In a real app, this should NOT be hardcoded directly in source code.
// Consider fetching it from a secure configuration file or environment variable at build time.
const String _consumerKey = 'YOUR_POCKET_CONSUMER_KEY_HERE'; 
// Define your redirect URI, this should match what you've configured in your Pocket app settings.
// This will be used for the OAuth callback.
const String _redirectUri = 'readlyit://pocket-auth'; 

class PocketService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'pocket_access_token';
  static const String _requestTokenKey = 'pocket_request_token';

  PocketService({Dio? dio, FlutterSecureStorage? secureStorage})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://getpocket.com/v3')),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<bool> isAuthenticated() async {
    // Placeholder: Check if an access token exists.
    // return await _secureStorage.containsKey(key: _accessTokenKey);
    final token = await _secureStorage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  // Step 1: Obtain a request token from Pocket
  Future<String?> obtainRequestToken() async {
    // Placeholder: Implement Pocket API call to get a request token.
    // POST to /oauth/request with consumer_key and redirect_uri
    // Store the received request token securely.
    // Return the request token or null on failure.
    print('PocketService: Obtaining request token...');
    try {
      final response = await _dio.post('/oauth/request', data: {
        'consumer_key': _consumerKey,
        'redirect_uri': _redirectUri,
      });
      if (response.statusCode == 200 && response.data != null) {
        final code = response.data['code'] as String?;
        if (code != null) {
          await _secureStorage.write(key: _requestTokenKey, value: code);
          print('PocketService: Request token obtained and stored: $code');
          return code;
        }
      }
      print('PocketService: Failed to obtain request token. Status: ${response.statusCode}, Data: ${response.data}');
      return null;
    } catch (e) {
      print('PocketService: Error obtaining request token: $e');
      return null;
    }
  }

  // Step 2: Redirect user to Pocket for authorization
  // The URL is: https://getpocket.com/auth/authorize?request_token=YOUR_REQUEST_TOKEN&redirect_uri=YOUR_REDIRECT_URI
  // This should be launched using url_launcher. The app needs to handle the callback via uni_links.
  String getAuthorizationUrl(String requestToken) {
    // Placeholder: Construct the authorization URL.
    return 'https://getpocket.com/auth/authorize?request_token=$requestToken&redirect_uri=${Uri.encodeComponent(_redirectUri)}';
  }

  // Step 3: Convert the approved request token into an access token
  Future<bool> obtainAccessToken() async {
    // Placeholder: Implement Pocket API call to convert request token to access token.
    // This is called after the user authorizes the app and is redirected back.
    // The request token is retrieved from storage.
    // POST to /oauth/authorize with consumer_key and the (request) code.
    // Store the received access token securely.
    // Return true on success, false on failure.
    print('PocketService: Obtaining access token...');
    final requestToken = await _secureStorage.read(key: _requestTokenKey);
    if (requestToken == null) {
      print('PocketService: No request token found to obtain access token.');
      return false;
    }

    try {
      final response = await _dio.post('/oauth/authorize', data: {
        'consumer_key': _consumerKey,
        'code': requestToken,
      });

      if (response.statusCode == 200 && response.data != null) {
        final accessToken = response.data['access_token'] as String?;
        // final username = response.data['username'] as String?; // Also available
        if (accessToken != null) {
          await _secureStorage.write(key: _accessTokenKey, value: accessToken);
          await _secureStorage.delete(key: _requestTokenKey); // Clean up request token
          print('PocketService: Access token obtained and stored.');
          return true;
        }
      }
      print('PocketService: Failed to obtain access token. Status: ${response.statusCode}, Data: ${response.data}');
      return false;
    } catch (e) {
      print('PocketService: Error obtaining access token: $e');
      return false;
    }
  }

  // Step 4: Fetch articles from Pocket
  Future<List<ArticleModel>> fetchArticles({
    String state = 'unread', // 'unread', 'archive', or 'all'
    String sort = 'newest', // 'newest', 'oldest', 'title', or 'site'
    String contentType = 'article', // 'article', 'video', or 'image'
    int count = 30, // Number of items to retrieve
    int offset = 0, // Offset for pagination
  }) async {
    // Placeholder: Implement Pocket API call to fetch articles.
    // POST to /get with consumer_key, access_token, and other parameters.
    // Transform the response into a List<ArticleModel>.
    // Return the list of articles or an empty list on failure.
    print('PocketService: Fetching articles...');
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    if (accessToken == null) {
      print('PocketService: No access token found. Cannot fetch articles.');
      return [];
    }

    try {
      final response = await _dio.post('/get', data: {
        'consumer_key': _consumerKey,
        'access_token': accessToken,
        'state': state,
        'sort': sort,
        'contentType': contentType,
        'detailType': 'complete', // 'simple' or 'complete' for more details
        'count': count,
        'offset': offset,
      });

      if (response.statusCode == 200 && response.data != null) {
        final list = response.data['list'] as Map<String, dynamic>?;
        if (list == null || list.isEmpty) {
          print('PocketService: No articles found or empty list returned.');
          return [];
        }

        final articles = <ArticleModel>[];
        list.forEach((key, value) {
          final item = value as Map<String, dynamic>;
          // Pocket API returns resolved_url or given_url.
          // resolved_title or given_title.
          // excerpt is often available.
          // time_added is a Unix timestamp.
          articles.add(
            ArticleModel.create( // Using create will generate a new UUID, which is good for local storage
              url: item['resolved_url'] ?? item['given_url'] ?? 'unknown_url',
              title: item['resolved_title'] ?? item['given_title'] ?? 'Untitled',
              excerpt: item['excerpt'] as String?,
              // content: item['content'] as String?, // Pocket's 'content' is not the full article usually
              source: 'Pocket',
              // savedAt: item['time_added'] != null
              //     ? DateTime.fromMillisecondsSinceEpoch((int.tryParse(item['time_added'].toString()) ?? 0) * 1000)
              //     : DateTime.now(), // ArticleModel.create generates savedAt
            ),
          );
        });
        print('PocketService: Fetched ${articles.length} articles.');
        return articles;
      }
      print('PocketService: Failed to fetch articles. Status: ${response.statusCode}, Data: ${response.data}');
      return [];
    } catch (e) {
      print('PocketService: Error fetching articles: $e');
      return [];
    }
  }

  Future<void> logout() async {
    // Placeholder: Clear stored access token.
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _requestTokenKey);
    print('PocketService: User logged out, tokens cleared.');
  }
}

// It's good practice to also define a provider for this service in your Riverpod setup.
// This would typically go in `article_providers.dart` or a dedicated `service_providers.dart`.
// Example (would be in a providers file):
// final pocketServiceProvider = Provider<PocketService>((ref) {
//   return PocketService();
// });
