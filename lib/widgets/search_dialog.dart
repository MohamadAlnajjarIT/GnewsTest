import 'package:flutter/material.dart';
import 'package:news_reader_app/services/api_handler.dart';
import 'package:news_reader_app/models/news_item.dart';
import 'package:news_reader_app/widgets/article_tile.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final NewsDataHandler _apiService = NewsDataHandler();
  final TextEditingController _searchInputController = TextEditingController();
  
  List<NewsArticle> _searchResults = [];
  bool _searching = false;
  String _activeTab = 'keyword'; // 'keyword', 'title', 'author'
  String? _lastError;

  void _executeSearch() async {
    if (_searchInputController.text.isEmpty) return;
    
    setState(() {
      _searching = true;
      _lastError = null;
    });
    
    try {
      List<NewsArticle> results = [];
      
      if (_activeTab == 'keyword') {
        // Keyword search
        final data = await _apiService.searchByText(_searchInputController.text);
        results = data.map((item) => NewsArticle.fromJson(item)).toList();
      } 
      else if (_activeTab == 'title') {
        // Title search
        final article = await _apiService.findArticleWithTitle(_searchInputController.text);
        if (article != null) {
          results = [NewsArticle.fromJson(article)];
        }
      } 
      else if (_activeTab == 'author') {
        // Author search
        final data = await _apiService.findArticlesBySource(_searchInputController.text);
        results = data.map((item) => NewsArticle.fromJson(item)).toList();
      }
      
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    } catch (error) {
      setState(() {
        _lastError = 'Search failed: $error';
        _searching = false;
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Text(
                    'Search News',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Search tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabButton('keyword', 'Keywords'),
                  const SizedBox(width: 8),
                  _buildTabButton('title', 'Title'),
                  const SizedBox(width: 8),
                  _buildTabButton('author', 'Author'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Search input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchInputController,
                      decoration: InputDecoration(
                        hintText: _getHintText(),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchInputController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        ),
                      ),
                      onSubmitted: (_) => _executeSearch(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _executeSearch,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Results section
            Expanded(
              child: _buildResultsSection(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTabButton(String tabId, String label) {
    final bool isActive = _activeTab == tabId;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTab = tabId;
            _searchResults = [];
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[50] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? Colors.blue : Colors.grey[300],
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.blue[800] : Colors.grey[700],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _getHintText() {
    switch (_activeTab) {
      case 'title':
        return 'Enter exact article title...';
      case 'author':
        return 'Enter author or publisher name...';
      default:
        return 'Enter search keywords...';
    }
  }
  
  Widget _buildResultsSection() {
    if (_searching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }
    
    if (_lastError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _lastError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_searchInputController.text.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Enter search terms above',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No ${_activeTab == 'title' ? 'article with that title' : _activeTab == 'author' ? 'articles by that author' : 'matching articles'} found',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ArticleTile(articleData: _searchResults[index]),
        );
      },
    );
  }
}
