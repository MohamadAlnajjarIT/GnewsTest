class NewsArticle {
  final String id;
  final String headline;
  final String summary;
  final String? detailedContent;
  final String articleUrl;
  final String? imageUrl;
  final DateTime publishedDate;
  final NewsSource? origin;
  final String? writer;

  NewsArticle({
    required this.id,
    required this.headline,
    required this.summary,
    this.detailedContent,
    required this.articleUrl,
    this.imageUrl,
    required this.publishedDate,
    this.origin,
    this.writer,
  });

  // Create from JSON data
  factory NewsArticle.fromJson(Map<String, dynamic> jsonData) {
    // Generate unique ID from title and date
    final String title = jsonData['title'] ?? 'Untitled';
    final String date = jsonData['publishedAt'] ?? '';
    final String uniqueId = '${title.hashCode}_${date.hashCode}';
    
    // Parse publication date
    DateTime publicationDate;
    try {
      publicationDate = DateTime.parse(date);
    } catch (e) {
      publicationDate = DateTime.now();
    }
    
    // Parse source information
    NewsSource? newsSource;
    if (jsonData['source'] is Map) {
      final sourceData = jsonData['source'] as Map<String, dynamic>;
      newsSource = NewsSource(
        name: sourceData['name']?.toString(),
        website: sourceData['url']?.toString(),
      );
    }
    
    return NewsArticle(
      id: uniqueId,
      headline: title,
      summary: jsonData['description'] ?? 'No description available',
      detailedContent: jsonData['content']?.toString(),
      articleUrl: jsonData['url'] ?? '',
      imageUrl: jsonData['image']?.toString(),
      publishedDate: publicationDate,
      origin: newsSource,
      writer: jsonData['author']?.toString(),
    );
  }
  
  // Format date for display
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(publishedDate);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${publishedDate.day}/${publishedDate.month}/${publishedDate.year}';
    }
  }
  
  // Check if article has valid image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}

class NewsSource {
  final String? name;
  final String? website;
  
  const NewsSource({this.name, this.website});
}
