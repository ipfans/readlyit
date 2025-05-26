import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser; // For HTML parsing
import 'package:html/dom.dart' as html_dom;     // For DOM manipulation (Element, Document)

class ArticleContentFetcherService {
  final Dio _dio;

  ArticleContentFetcherService({Dio? dio})
      : _dio = dio ?? Dio();

  Future<String> fetchContent(String url) async {
    try {
      print('[ArticleContentFetcherService] Fetching content for URL: $url');
      final response = await _dio.get(url, options: Options(
        // Follow redirects
        followRedirects: true,
        maxRedirects: 5,
        // Set a reasonable timeout
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          // Some websites might block requests without a common user-agent
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
          'accept-language': 'en-US,en;q=0.9',
        }
      ));

      if (response.statusCode == 200 && response.data != null) {
        print('[ArticleContentFetcherService] Successfully fetched HTML. Status: ${response.statusCode}');
        return _extractMainContent(response.data.toString(), url);
      } else {
        print('[ArticleContentFetcherService] Failed to fetch HTML. Status: ${response.statusCode}');
        throw Exception('Failed to fetch article HTML: Status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio specific errors (timeout, connection error, etc.)
      print('[ArticleContentFetcherService] DioError fetching content: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
        throw Exception('Network timeout when fetching article: ${e.message}');
      } else if (e.type == DioExceptionType.unknown) { // Was DioErrorType.other before Dio 5.x
         throw Exception('Network error when fetching article: ${e.message}');
      }
      throw Exception('Error fetching article: ${e.message}');
    } 
    catch (e) {
      print('[ArticleContentFetcherService] Error fetching content: $e');
      throw Exception('Failed to fetch or parse article content: ${e.toString()}');
    }
  }

  String _extractMainContent(String htmlString, String url) {
    print('[ArticleContentFetcherService] Extracting main content...');
    final document = html_parser.parse(htmlString);

    // 1. Try common semantic tags
    html_dom.Element? articleElement = document.querySelector('article');
    if (articleElement != null) {
      print('[ArticleContentFetcherService] Found <article> tag.');
      return _cleanHtml(articleElement.innerHtml, url);
    }

    // 2. Try common ID selectors
    const commonIds = ['content', 'main-content', 'article-body', 'entry-content', 'post-content', 'main'];
    for (String id in commonIds) {
      html_dom.Element? elementById = document.getElementById(id);
      if (elementById != null) {
        print('[ArticleContentFetcherService] Found element with ID: #$id');
        return _cleanHtml(elementById.innerHtml, url);
      }
    }
    
    // 3. Try common class names (more prone to false positives, use with caution or more specific selectors)
    // Example: document.querySelector('.post-body') or similar.
    // For now, keeping it simple. A more robust solution might involve libraries like Readability.js (dart ports are rare/experimental)
    // or more complex heuristics (text density, link density).

    // 4. Fallback: If no specific main content area is found, return a significant portion of the body.
    // This is a very basic fallback and might include unwanted elements.
    // We try to find the largest text block.
    html_dom.Element? body = document.body;
    if (body != null) {
        print('[ArticleContentFetcherService] No specific content tags found, attempting to find largest text block in body.');
        // A simple heuristic: find the element with the most direct text content.
        // This is very naive. A better approach would be to score elements based on text length,
        // link density, etc.
        html_dom.Element? bestCandidate = body;
        int maxTextLength = 0;

        void findBestCandidate(html_dom.Element element) {
            String directText = element.nodes.whereType<html_dom.Text>().map((t) => t.text.trim()).join(' ');
            if (directText.length > maxTextLength) {
                // Penalize elements that are typically not main content
                if (!['nav', 'header', 'footer', 'aside', 'script', 'style'].contains(element.localName)) {
                     maxTextLength = directText.length;
                     bestCandidate = element;
                }
            }
            element.children.forEach(findBestCandidate);
        }
        // findBestCandidate(body); // This recursive search might be too broad or inefficient for initial implementation
        // For now, let's just return the body's innerHTML if no better candidate is found via tags/IDs.
        // This is likely to include navigation, ads, etc. but it's a starting point.
        // A better fallback would be to implement a simplified readability-like algorithm.
        // For now, we return the full body if other selectors fail.
        // This means ArticleViewScreen *must* use flutter_html to make sense of it.
        print('[ArticleContentFetcherService] Fallback: Returning entire body content. Needs improvement.');
        return _cleanHtml(body.innerHtml, url);
    }

    print('[ArticleContentFetcherService] Could not extract meaningful content, returning empty string.');
    return ''; // Fallback if body is null or no content found
  }

  // Basic cleaning and resolving relative URLs.
  String _cleanHtml(String htmlContent, String baseUrl) {
    final document = html_parser.parse(htmlContent);

    // Remove script and style tags
    document.querySelectorAll('script, style, noscript, iframe, nav, footer, aside, header').forEach((element) {
      element.remove();
    });
    
    // Optional: Remove comments
    // document.nodes.whereType<html_dom.Comment>().forEach((comment) => comment.remove());

    // Resolve relative URLs for images and links
    final baseUri = Uri.parse(baseUrl);
    document.querySelectorAll('a[href]').forEach((element) {
      final href = element.attributes['href'];
      if (href != null && href.isNotEmpty) {
        try {
          element.attributes['href'] = baseUri.resolve(href).toString();
        } catch (e) {
          print("Error resolving URL for <a> tag: $href, Error: $e");
        }
      }
    });
    document.querySelectorAll('img[src]').forEach((element) {
      final src = element.attributes['src'];
      if (src != null && src.isNotEmpty) {
         try {
          element.attributes['src'] = baseUri.resolve(src).toString();
        } catch (e) {
          print("Error resolving URL for <img> tag: $src, Error: $e");
        }
      }
    });
    
    // Optional: Add target="_blank" to all links to open in external browser if rendered in a webview
    // document.querySelectorAll('a[href]').forEach((element) {
    //   element.attributes['target'] = '_blank';
    // });

    return document.body?.innerHtml ?? ''; // Return cleaned innerHTML of the body of the parsed fragment
  }

}
