import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added
import 'package:readlyit/features/articles/data/models/article_model.dart';
import 'package:readlyit/features/articles/presentation/providers/article_providers.dart'; // Added
// import 'package:url_launcher/url_launcher.dart';

class ArticleViewScreen extends ConsumerWidget { // Changed to ConsumerWidget
  final ArticleModel article;

  const ArticleViewScreen({super.key, required this.article});

  // Future<void> _launchURL(String url) async {
  //   final uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     // Handle error: could not launch URL
  //     print('Could not launch $url'); // Replace with user-friendly error
  //   }
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    // Watch the specific article for live updates (e.g., after content is fetched)
    // This assumes you might have a provider that can give a single article,
    // or that articlesListProvider will update and HomeScreen will pass the new article object.
    // For simplicity, we'll rely on HomeScreen passing the updated article if it re-navigates
    // or if the parent list updates the specific article instance.
    // A more robust way is to watch an article-specific provider.
    // Let's get the latest version of this article from the list provider.
    final articlesState = ref.watch(articlesListProvider);
    final currentArticle = articlesState.asData?.value.firstWhere(
      (a) => a.id == article.id,
      orElse: () => article, // Fallback to initial article if not found (should not happen if list is up-to-date)
    ) ?? article;


    return Scaffold(
      appBar: AppBar(
        title: Text(currentArticle.title, overflow: TextOverflow.ellipsis),
      ),
      body: Center( // Center the content
        child: ConstrainedBox( // Constrain its width
          constraints: const BoxConstraints(maxWidth: 800), // Max width for readability
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  currentArticle.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                GestureDetector(
                  // onTap: () => _launchURL(currentArticle.url),
                  child: Text(
                    currentArticle.url,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Saved: ${currentArticle.savedAt.toLocal().toString().substring(0, 16)}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                if (currentArticle.source != null && currentArticle.source!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Source: ${currentArticle.source}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                const Divider(height: 32.0),
                if (currentArticle.content == null || currentArticle.content!.isEmpty || currentArticle.content == "Fetching..." || currentArticle.content == "Failed to fetch.")
                  Column(
                    children: [
                      if (currentArticle.content == "Fetching...")
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16),
                              Text("Fetching content..."), // Replace with localized string
                            ],
                          ),
                        )
                      else if (currentArticle.content == "Failed to fetch.")
                         Padding(
                           padding: const EdgeInsets.symmetric(vertical: 16.0),
                           child: Text(
                             'Failed to fetch content. Please try again.', // Replace with localized string
                             style: TextStyle(color: Theme.of(context).colorScheme.error),
                           ),
                         )
                      else
                        const Text(
                          'Full article content has not been fetched yet.', // Replace with localized string
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Fetch Full Article'), // Replace with localized string
                        // Disable button if content is currently being fetched
                        onPressed: currentArticle.content == "Fetching..." ? null : () {
                          // Show loading indicator while fetching
                          // The optimistic update in the notifier will handle "Fetching..."
                          ref.read(articlesListProvider.notifier).fetchAndStoreArticleContent(currentArticle.id, currentArticle.url)
                            .catchError((e, stackTrace) { // Catch error here to show SnackBar if needed
                               print("Error caught in UI: $e, Stack: $stackTrace");
                               // The notifier's catchError already tries to update the article content to "Failed to fetch."
                               // and reloads. If that specific UI update isn't enough, show a SnackBar.
                               if (mounted(context)) { // Check if widget is still in the tree
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error fetching content: ${e.toString().replaceFirst("Exception: ", "")}')), // Replace with localized string
                                  );
                               }
                            });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                // TODO: If content is HTML, use flutter_html to render it. For now, display as text.
                // Only display content if it's not a special state string
                if (currentArticle.content != null && currentArticle.content != "Fetching..." && currentArticle.content != "Failed to fetch.")
                  Text(
                    currentArticle.content ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to check if the widget is still mounted, for use in async callbacks
  bool mounted(BuildContext context) {
    try {
      // Attempt to access a property that would throw if not mounted,
      // but without causing side effects or relying on internal Flutter details.
      // Accessing `context.widget` is safe.
      // ignore: unnecessary_null_comparison
      return context.widget != null;
    } catch (e) {
      return false;
    }
  }
}
