import 'package:flutter/foundation.dart';

@immutable
class Article {
  final String id;
  final String url;
  final String title;
  final String? content; // Full content, might be large
  final DateTime savedAt;
  final bool isRead;
  final String? source; // e.g., "Pocket", "manual"
  final String? excerpt; // Short summary

  const Article({
    required this.id,
    required this.url,
    required this.title,
    this.content,
    required this.savedAt,
    this.isRead = false,
    this.source,
    this.excerpt,
  });

  // For easy comparison and debugging
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          url == other.url &&
          title == other.title &&
          content == other.content &&
          savedAt == other.savedAt &&
          isRead == other.isRead &&
          source == other.source &&
          excerpt == other.excerpt;

  @override
  int get hashCode =>
      id.hashCode ^
      url.hashCode ^
      title.hashCode ^
      content.hashCode ^
      savedAt.hashCode ^
      isRead.hashCode ^
      source.hashCode ^
      excerpt.hashCode;

  Article copyWith({
    String? id,
    String? url,
    String? title,
    String? content,
    DateTime? savedAt,
    bool? isRead,
    String? source,
    String? excerpt,
    bool setContentToNull = false, // To explicitly set content to null
    bool setSourceToNull = false,
    bool setExcerptToNull = false,
  }) {
    return Article(
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
