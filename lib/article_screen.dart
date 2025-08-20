import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import Article class from main.dart to avoid duplication
import 'main.dart';

class ArticleScreen extends StatefulWidget {
  final Article article;

  const ArticleScreen({super.key, required this.article});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  String? _articleContent;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchArticleContent();
  }

  Future<void> _fetchArticleContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Extract the actual URL from the skimfeed redirect URL
      final actualUrl = _extractActualUrl(widget.article.url);
      
      final response = await http.get(
        Uri.parse(actualUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        },
      );

      if (response.statusCode == 200) {
        // For now, show a placeholder content since HTML parsing is complex
        String content = _extractBasicContent(response.body);
        
        setState(() {
          _articleContent = content;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load article content (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading article: $e';
        _isLoading = false;
      });
    }
  }

  String _extractActualUrl(String skimfeedUrl) {
    // Extract the actual URL from skimfeed redirect URLs
    if (skimfeedUrl.contains('skimfeed.com/r.php')) {
      final uri = Uri.parse(skimfeedUrl);
      final uParam = uri.queryParameters['u'];
      if (uParam != null) {
        return Uri.decodeComponent(uParam);
      }
    }
    return skimfeedUrl;
  }

  String _extractBasicContent(String htmlContent) {
    // Simple text extraction without HTML parsing
    // Remove HTML tags and clean up the content
    String content = htmlContent
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .replaceAll(RegExp(r'\n\s*\n'), '\n\n') // Clean up multiple newlines
        .trim();
    
    // Limit content length for better performance
    if (content.length > 2000) {
      content = content.substring(0, 2000) + '...';
    }
    
    return content.isEmpty ? 'Content not available' : content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          style: const TextStyle(fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchArticleContent,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () {
              // Open in external browser
              // You can add url_launcher here if needed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening: ${widget.article.url}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading article...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading article',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchArticleContent,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_articleContent == null || _articleContent!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No content available'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article title
          Text(
            widget.article.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Article content
          Text(
            _articleContent!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Source link
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Source: ${widget.article.url}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
