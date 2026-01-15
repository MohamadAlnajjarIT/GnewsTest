import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsDataHandler {
  // API configuration
  static const String _apiEndpoint = 'https://gnews.io/api/v4';
  final String _accessToken = '56fad0005d54d692b51cda24360dc009';
  
  // Fetch multiple articles
  Future<List<Map<String, dynamic>>> getNewsItems(int itemCount) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiEndpoint/top-headlines?lang=en&max=$itemCount&apikey=$_accessToken'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> articles = jsonResponse['articles'] ?? [];
        return articles.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Network request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }
  
  // Search articles using keywords
  Future<List<Map<String, dynamic>>> searchByText(String searchText) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiEndpoint/search?q=$searchText&lang=en&max=20&apikey=$_accessToken'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> articles = jsonResponse['articles'] ?? [];
        return articles.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Search failed with status: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }
  
  // Look for specific article by its title
  Future<Map<String, dynamic>?> findArticleWithTitle(String targetTitle) async {
    try {
      // Search broadly first
      final results = await searchByText(targetTitle);
      
      // Try exact match
      for (var article in results) {
        final String title = article['title']?.toString().toLowerCase() ?? '';
        if (title.contains(targetTitle.toLowerCase())) {
          return article;
        }
      }
      
      // Try partial match
      for (var article in results) {
        final String title = article['title']?.toString().toLowerCase() ?? '';
        final String searchLower = targetTitle.toLowerCase();
        
        // Check for significant overlap
        if (title.contains(searchLower) || searchLower.contains(title)) {
          return article;
        }
      }
      
      return null;
    } catch (error) {
      return null;
    }
  }
  
  // Find articles from specific author/publisher
  Future<List<Map<String, dynamic>>> findArticlesBySource(String sourceName) async {
    try {
      // Search for the source name
      final allResults = await searchByText(sourceName);
      final List<Map<String, dynamic>> filtered = [];
      
      for (var article in allResults) {
        final sourceInfo = article['source'];
        final authorInfo = article['author']?.toString().toLowerCase() ?? '';
        
        // Check source name
        if (sourceInfo is Map) {
          final String source = sourceInfo['name']?.toString().toLowerCase() ?? '';
          if (source.contains(sourceName.toLowerCase())) {
            filtered.add(article);
            continue;
          }
        }
        
        // Check author field
        if (authorInfo.contains(sourceName.toLowerCase())) {
          filtered.add(article);
        }
      }
      
      return filtered;
    } catch (error) {
      return [];
    }
  }
}
