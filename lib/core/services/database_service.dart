import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readlyit/features/articles/data/models/article_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const String _dbName = 'readlyit.db';
  static const int _dbVersion = 1;
  static const String _articlesTable = 'articles';

  // Singleton instance
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_articlesTable (
        id TEXT PRIMARY KEY,
        url TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        savedAt TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0, -- 0 for false, 1 for true
        source TEXT,
        excerpt TEXT
      )
    ''');
  }

  // Insert an article
  Future<int> addArticle(ArticleModel article) async {
    final db = await database;
    return await db.insert(
      _articlesTable,
      article.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if ID already exists
    );
  }

  // Get a single article by ID
  Future<ArticleModel?> getArticle(String id) async {
    final db = await database;
    final maps = await db.query(
      _articlesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ArticleModel.fromJson(maps.first);
    }
    return null;
  }

  // Get all articles, ordered by savedAt descending (newest first)
  Future<List<ArticleModel>> getAllArticles() async {
    final db = await database;
    final maps = await db.query(
      _articlesTable,
      orderBy: 'savedAt DESC',
    );
    return maps.map((json) => ArticleModel.fromJson(json)).toList();
  }

  // Update an article
  Future<int> updateArticle(ArticleModel article) async {
    final db = await database;
    return await db.update(
      _articlesTable,
      article.toJson(),
      where: 'id = ?',
      whereArgs: [article.id],
    );
  }

  // Delete an article by ID
  Future<int> deleteArticle(String id) async {
    final db = await database;
    return await db.delete(
      _articlesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Toggle read status
  Future<int> toggleReadStatus(String id, bool isRead) async {
    final db = await database;
    return await db.update(
      _articlesTable,
      {'isRead': isRead ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all articles (for development/testing or user request)
  Future<int> clearAllArticles() async {
    final db = await database;
    return await db.delete(_articlesTable);
  }

  // Close the database (optional, as sqflite handles this, but good for explicit control)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null; // Reset the static instance
  }
}
