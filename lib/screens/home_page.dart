import 'package:flutter/material.dart';
import 'package:news_reader_app/models/news_item.dart';
import 'package:news_reader_app/services/api_handler.dart';
import 'package:news_reader_app/widgets/article_tile.dart';
import 'package:news_reader_app/widgets/search_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsDataHandler _apiService = NewsDataHandler();
  final RefreshController _refreshController = RefreshController();
  final TextEditingController _countInputController = TextEditingController();
  
  List<NewsArticle> _currentArticles = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _itemLimit = 10;

  @override
  void initState() {
    super.initState();
    _countInputController.text = _itemLimit.toString();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final articlesData = await _apiService.getNewsItems(_itemLimit);
      final articles = articlesData.map((data) => NewsArticle.fromJson(data)).toList();
      
      setState(() {
        _currentArticles = articles;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load news: $error';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _refreshContent() async {
    try {
      final articlesData = await _apiService.getNewsItems(_itemLimit);
      final articles = articlesData.map((data) => NewsArticle.fromJson(data)).toList();
      
      setState(() {
        _currentArticles = articles;
      });
      _refreshController.refreshCompleted();
    } catch (error) {
      _refreshController.refreshFailed();
    }
  }
  
  void _updateItemLimit() {
    final input = _countInputController.text;
    final parsed = int.tryParse(input);
    
    if (parsed != null && parsed > 0 && parsed <= 50) {
      setState(() {
        _itemLimit = parsed;
      });
      _loadInitialData();
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a number between 1 and 50'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showSearchScreen() {
    showDialog(
      context: context,
      builder: (context) => const SearchDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'News Reader',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchScreen,
            tooltip: 'Search articles',
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Controls section
          _buildControlsPanel(),
          
          // Content section
          Expanded(
            child: _buildContentSection(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlsPanel() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _countInputController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Articles to show',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _updateItemLimit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                child: const Text('Update'),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ElevatedButton.icon(
            onPressed: _loadInitialData,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Refresh News Feed'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContentSection() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading latest news...'),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (_currentArticles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No articles found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _refreshContent,
      header: const ClassicHeader(
        idleText: 'Pull to refresh',
        releaseText: 'Release to refresh',
        refreshingText: 'Loading...',
        completeText: 'Refresh complete',
        failedText: 'Refresh failed',
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _currentArticles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final article = _currentArticles[index];
          return ArticleTile(articleData: article);
        },
      ),
    );
  }
}
