import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlyit/features/articles/data/models/article_model.dart';
import 'package:readlyit/features/articles/presentation/providers/article_providers.dart';
import 'package:readlyit/features/articles/presentation/screens/article_view_screen.dart'; // Add this import
import 'package:readlyit/app/ui/widgets/app_bar.dart' as custom_widgets;
import 'package:readlyit/app/ui/widgets/bottom_navigation.dart' as custom_widgets;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showAddArticleDialog(BuildContext context, WidgetRef ref) {
    final urlController = TextEditingController();
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Article'), // Replace with localized string
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(hintText: 'Enter article URL'), // Replace with localized string
                keyboardType: TextInputType.url,
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Enter title (optional)'), // Replace with localized string
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'), // Replace with localized string
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Save'), // Replace with localized string
              onPressed: () {
                final url = urlController.text;
                final title = titleController.text.isNotEmpty ? titleController.text : url;

                if (url.isNotEmpty) {
                  final newArticle = ArticleModel.create(
                    url: url,
                    title: title,
                  );
                  ref.read(articlesListProvider.notifier).addArticle(newArticle);
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('URL cannot be empty.')), // Replace with localized string
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteArticle(BuildContext context, WidgetRef ref, ArticleModel article) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Article?'), // Replace with localized string
          content: Text('Are you sure you want to delete "${article.title}"?'), // Replace with localized string
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'), // Replace with localized string
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'), // Replace with localized string
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                ref.read(articlesListProvider.notifier).deleteArticle(article.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  // ... (_showAddArticleDialog, _confirmDeleteArticle remain the same)

  void _initiatePocketImport(BuildContext context, WidgetRef ref) {
    // For now, just a placeholder. Later, this will call the PocketService.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pocket Import Initiated (Placeholder)')), // Replace with localized string
    );
    // Example of how it might look later:
    // ref.read(pocketServiceProvider).authenticateAndFetchArticles().then((success) {
    //   if (success) {
    //     ref.read(articlesListProvider.notifier).refresh();
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Pocket articles imported!')),
    //     );
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Pocket import failed.')),
    //     );
    //   }
    // });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsyncValue = ref.watch(articlesListProvider);

    return Scaffold(
      appBar: custom_widgets.CustomAppBar(
        titleText: 'ReadLyit Articles', // Replace with localized string
        onPocketImport: () => _initiatePocketImport(context, ref), // Pass the callback
      ),
      body: articlesAsyncValue.when(
        data: (articles) {
          if (articles.isEmpty) {
            return const Center(child: Text('No articles saved yet. Add one!')); // Replace with localized string
          }
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              // Determine padding based on screen width
              final horizontalPadding = MediaQuery.of(context).size.width > 600 ? 32.0 : 16.0;

              return Padding( // Add padding around ListTile
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4.0),
                child: Card( // Wrap ListTile in a Card for better visual separation
                  elevation: 0.5,
                  margin: const EdgeInsets.symmetric(vertical: 4.0), // Consistent margin for card
                  child: ListTile(
                    leading: Checkbox(
                      value: article.isRead,
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          ref.read(articlesListProvider.notifier).toggleReadStatus(article.id, newValue);
                        }
                      },
                    ),
                    title: Text(
                      article.title,
                      style: TextStyle(
                        decoration: article.isRead ? TextDecoration.lineThrough : null,
                        color: article.isRead ? Colors.grey[600] : null, // Adjusted grey for readability
                      ),
                    ),
                    subtitle: Text(article.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      tooltip: 'Delete Article', // Replace with localized string
                      onPressed: () => _confirmDeleteArticle(context, ref, article),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleViewScreen(article: article),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading articles: $error'), // Replace with localized string
              ElevatedButton(
                onPressed: () => ref.read(articlesListProvider.notifier).refresh(),
                child: const Text('Retry'), // Replace with localized string
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddArticleDialog(context, ref),
        tooltip: 'Add Article', // Replace with localized string
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const custom_widgets.CustomBottomNavigation(),
    );
  }
}
