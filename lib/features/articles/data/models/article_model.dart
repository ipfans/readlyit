import 'package:readlyit/features/articles/domain/entities/article.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.url,
    required super.title,
    super.content,
    required super.savedAt,
    super.isRead = false,
    super.source,
    super.excerpt,
  });

  // Factory constructor to create a new ArticleModel with a generated ID
  factory ArticleModel.create({
    required String url,
    required String title,
    String? content,
    String? source,
    String? excerpt,
  }) {
    return ArticleModel(
      id: _uuid.v4(),
      url: url,
      title: title,
      content: content,
      savedAt: DateTime.now(),
      source: source,
      excerpt: excerpt,
    );
  }

  // Convert Article entity to ArticleModel
  factory ArticleModel.fromEntity(Article entity) {
    return ArticleModel(
      id: entity.id,
      url: entity.url,
      title: entity.title,
      content: entity.content,
      savedAt: entity.savedAt,
      isRead: entity.isRead,
      source: entity.source,
      excerpt: entity.excerpt,
    );
  }

  // Convert ArticleModel to Article entity (already achieved by inheritance)
  // Article toEntity() => this; // Or Article(...) if you need to reconstruct

  // Convert ArticleModel to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'content': content,
      'savedAt': savedAt.toIso8601String(), // Store as ISO 8601 string
      'isRead': isRead ? 1 : 0, // Store boolean as integer (0 or 1)
      'source': source,
      'excerpt': excerpt,
    };
  }

  // Create ArticleModel from JSON (map from database)
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      savedAt: DateTime.parse(json['savedAt'] as String),
      isRead: (json['isRead'] as int) == 1,
      source: json['source'] as String?,
      excerpt: json['excerpt'] as String?,
    );
  }

  // Override copyWith to ensure it returns ArticleModel
  @override
  ArticleModel copyWith({
    String? id,
    String? url,
    String? title,
    String? content,
    DateTime? savedAt,
    bool? isRead,
    String? source,
    String? excerpt,
    bool setContentToNull = false,
    bool setSourceToNull = false,
    bool setExcerptToNull = false,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      content: setContentToNull ? null : content ?? this.content,
      savedAt: savedAt ?? this.savedAt,
      isRead: isRead ?? this.isRead,
      source: setSourceToNull ? null : source ?? this.source,
      excerpt: setExcerptToNull ? null : excerpt ?? this.excerpt,
    );
  }
}
