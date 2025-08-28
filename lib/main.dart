import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'article_screen.dart';
import 'splash_screen.dart';
import 'theme.dart';

void main() => runApp(const SkimpulseApp());

class SkimpulseApp extends StatelessWidget {
  const SkimpulseApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Skimpulse",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AppWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onSplashComplete: _onSplashComplete);
    }
    return const HotScreen();
  }
}

class Article {
  final String title;
  final String url;
  
  Article({required this.title, required this.url});
  
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class HotScreen extends StatefulWidget {
  const HotScreen({super.key});

  @override
  State<HotScreen> createState() => _HotScreenState();
}

class _HotScreenState extends State<HotScreen> {
  late Future<List<Article>> future;
  int _retryCount = 0;
  static const int maxRetries = 3;

  @override
  void initState() {
    super.initState();
    future = fetchArticlesWithRetry();
  }

  String _getApiUrl() {
    const String productionApiUrl = 'https://api-deploy-9so9.onrender.com';
    const String customApiUrl = String.fromEnvironment('API_URL');
    
    if (customApiUrl.isNotEmpty) {
      return '$customApiUrl/api/skimfeed';
    }
    
    return '$productionApiUrl/api/skimfeed';
  }

  Future<List<Article>> fetchArticlesWithRetry() async {
    _retryCount = 0;
    return _fetchWithRetry();
  }

  Future<List<Article>> _fetchWithRetry() async {
    while (_retryCount < maxRetries) {
      try {
        return await fetchArticles();
      } catch (e) {
        _retryCount++;
        
        if (_retryCount >= maxRetries) {
          throw Exception('Failed after $_retryCount attempts. Please check your connection and try again.');
        }
        
        // Wait longer between retries for Render's sleep mode
        await Future.delayed(Duration(seconds: _retryCount * 2));
      }
    }
    throw Exception('Unexpected error in retry logic');
  }

  Future<List<Article>> fetchArticles() async {
    try {
      final apiUrl = _getApiUrl();
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['articles'] is List) {
          final List<dynamic> articlesList = data['articles'] as List;
          final articles = articlesList
              .map((article) => Article.fromJson(article))
              .toList();
          return articles;
        } else {
          throw Exception('Invalid response format: ${data.toString()}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Request timed out. Please check your internet connection.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Network error. Please check your internet connection.');
      } else {
        throw Exception('Failed to load articles: $e');
      }
    }
  }

  Future<void> _openArticle(Article article) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Skimpulse"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                future = fetchArticlesWithRetry();
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue.withOpacity(0.05),
              AppTheme.primaryYellow.withOpacity(0.03),
              AppTheme.primaryBlue.withOpacity(0.08),
              AppTheme.lightBlue.withOpacity(0.04),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: FutureBuilder<List<Article>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final article = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      article.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      article.url,
                                          style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _openArticle(article),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            final isFinalError = _retryCount >= maxRetries;
            
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24.0),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFinalError ? Icons.error_outline : Icons.cloud_off,
                      size: 64,
                      color: isFinalError 
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isFinalError ? 'Something Went Wrong' : 'Connection Error',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isFinalError 
                          ? 'We\'re having trouble connecting to our servers.'
                          : 'Unable to load articles from the server.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!isFinalError) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Attempt $_retryCount of $maxRetries',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          future = fetchArticlesWithRetry();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(isFinalError ? 'Try Again' : 'Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
        ),
      ),
    );
  }
}
