class NewsModel {
  final String newsId;
  final String title;
  final String summary;
  final String body;
  final String category;
  final String source;
  final String imageUrl;
  final String sourceUrl;
  final String? publishedAt;
  final bool isFeatured;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  NewsModel({
    required this.newsId,
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    required this.source,
    required this.imageUrl,
    required this.sourceUrl,
    this.publishedAt,
    required this.isFeatured,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      newsId: json['newsId'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      body: json['body'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      source: json['source'] ?? '',
      imageUrl: (json['imageUrl'] != null && json['imageUrl'].toString().contains('example.com'))
          ? 'https://picsum.photos/seed/${json['newsId'] ?? 'news'}/600/400'
          : (json['imageUrl'] ?? ''),
      sourceUrl: json['sourceUrl'] ?? '',
      publishedAt: json['publishedAt'],
      isFeatured: json['isFeatured'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newsId': newsId,
      'title': title,
      'summary': summary,
      'body': body,
      'category': category,
      'source': source,
      'imageUrl': imageUrl,
      'sourceUrl': sourceUrl,
      'publishedAt': publishedAt,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
