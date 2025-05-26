import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import for localization
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
          title: Text(AppLocalizations.of(dialogContext)!.addArticleTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: InputDecoration(hintText: AppLocalizations.of(dialogContext)!.enterArticleUrlHint),
                keyboardType: TextInputType.url,
              ),
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: AppLocalizations.of(dialogContext)!.enterArticleTitleHint),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(dialogContext)!.buttonCancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(dialogContext)!.buttonSave),
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
                  // Use the context from the HomeScreen build method for ScaffoldMessenger
                  // if dialogContext might be popped before SnackBar is shown.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.errorUrlCannotBeEmpty)),
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
          title: Text(AppLocalizations.of(dialogContext)!.deleteArticleTitle),
          content: Text(AppLocalizations.of(dialogContext)!.confirmDeleteArticleContent(article.title)),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(dialogContext)!.buttonCancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(dialogContext)!.buttonDelete),
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

  // Modify this method in HomeScreen
  void _initiatePocketImport(BuildContext context, WidgetRef ref) async { // Make it async
    final articlesNotifier = ref.read(articlesListProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context); // Cache ScaffoldMessenger

    // Show some immediate feedback
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Connecting to Pocket...')), // Replace with localized string
    );

    final errorMessage = await articlesNotifier.initiatePocketAuthentication();

    if (errorMessage != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Pocket Connection Failed: $errorMessage')), // Replace with localized string
      );
    } else {
      // On successful launch of URL, PocketService will handle the redirect.
      // Actual fetching of articles will happen after callback.
      // For now, just inform the user that they need to check their browser.
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please authorize with Pocket in your browser.')), // Replace with localized string
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsyncValue = ref.watch(articlesListProvider);

    return Scaffold(
      appBar: custom_widgets.CustomAppBar(
        titleText: AppLocalizations.of(context)!.homeScreenTitle, // Localized AppBar title
        onPocketImport: () => _initiatePocketImport(context, ref), // Pass the callback
      ),
      body: articlesAsyncValue.when(
        data: (articles) {
          if (articles.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.articlesListEmpty));
          }

          return LayoutBuilder( // Use LayoutBuilder
            builder: (context, constraints) {
              // Define a common item builder function to reduce duplication
              Widget articleItemBuilder(BuildContext context, ArticleModel article, bool isGridView) {
                return Card(
                  elevation: 0.5,
                  // Margin for GridView items can be handled by grid spacing or here
                  // Margin for ListView items is handled by Padding wrapper
                  margin: isGridView ? const EdgeInsets.all(4.0) : const EdgeInsets.symmetric(vertical: 4.0),
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
                        color: article.isRead ? Colors.grey[600] : null,
                      ),
                      maxLines: isGridView ? 3 : 2, // More lines for title in grid view
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                        article.url, 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      tooltip: AppLocalizations.of(context)!.tooltipDeleteArticle,
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
                );
              }

              if (constraints.maxWidth < 600) {
                // Phone layout: ListView
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Consolidated padding
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return articleItemBuilder(context, article, false);
                  },
                );
              } else {
                // Tablet/Desktop layout: GridView
                int crossAxisCount = (constraints.maxWidth < 900) ? 2 : 3;
                if (constraints.maxWidth < 350) crossAxisCount = 1; // Safety for very narrow desktop windows

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0), // Padding around the grid
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 2.8, // Adjust this value based on desired item height/width ratio
                    crossAxisSpacing: 12.0, // Spacing between items horizontally
                    mainAxisSpacing: 12.0,  // Spacing between items vertically
                  ),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return articleItemBuilder(context, article, true);
                  },
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.errorLoadingArticles(error.toString())),
              ElevatedButton(
                onPressed: () => ref.read(articlesListProvider.notifier).refresh(),
                child: Text(AppLocalizations.of(context)!.buttonRetry),
              )
            ],
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
              Text(AppLocalizations.of(context)!.errorLoadingArticles(error.toString())),
              ElevatedButton(
                onPressed: () => ref.read(articlesListProvider.notifier).refresh(),
                child: Text(AppLocalizations.of(context)!.buttonRetry),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddArticleDialog(context, ref),
        tooltip: AppLocalizations.of(context)!.tooltipAddArticle,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const custom_widgets.CustomBottomNavigation(),
    );
  }
}
