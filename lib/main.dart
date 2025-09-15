import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'article_screen.dart';
import 'splash_screen.dart';
import 'theme.dart';
import 'widgets/panda_lightning_icon.dart';

enum SortOption {
  original,
  alphabetical,
  reverseAlphabetical,
  rankingHigh,
  rankingLow,
}

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
  final int? ranking;
  
  Article({
    required this.title, 
    required this.url,
    this.ranking,
  });
  
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      ranking: json['ranking'],
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
  
  // Sorting state
  SortOption _currentSort = SortOption.original;
  List<Article> _originalArticles = [];

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
          
          // Store original articles for sorting
          _originalArticles = List.from(articles);
          return _sortArticles(articles);
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

  List<Article> _sortArticles(List<Article> articles) {
    switch (_currentSort) {
      case SortOption.original:
        return List.from(_originalArticles);
      case SortOption.alphabetical:
        return List.from(articles)..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SortOption.reverseAlphabetical:
        return List.from(articles)..sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
      case SortOption.rankingHigh:
        return List.from(articles)..sort((a, b) {
          final aRank = a.ranking ?? 999;
          final bRank = b.ranking ?? 999;
          return aRank.compareTo(bRank); // Lower ranking number = higher priority
        });
      case SortOption.rankingLow:
        return List.from(articles)..sort((a, b) {
          final aRank = a.ranking ?? 0;
          final bRank = b.ranking ?? 0;
          return bRank.compareTo(aRank); // Higher ranking number = lower priority
        });
    }
  }

  void _onSortChanged(SortOption newSort) {
    setState(() {
      _currentSort = newSort;
      if (_originalArticles.isNotEmpty) {
        future = Future.value(_sortArticles(_originalArticles));
      }
    });
  }

  Future<void> _openArticle(Article article) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleScreen(article: article),
      ),
    );
  }

  String _formatDate(Article article) {
    // Show ranking if available, otherwise show a random date
    if (article.ranking != null) {
      return 'Rank #${article.ranking}';
    }
    
    // Fallback to random date if no ranking available
    final now = DateTime.now();
    final random = now.millisecondsSinceEpoch % 7;
    final date = now.subtract(Duration(days: random));
    
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PandaLightningIcon(size: 32),
            const SizedBox(width: 8),
            const Text("Skimpulse"),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort articles',
            onSelected: _onSortChanged,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<SortOption>(
                value: SortOption.original,
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 8),
                    Text('Original Order'),
                  ],
                ),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.alphabetical,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 20),
                    SizedBox(width: 8),
                    Text('A-Z'),
                  ],
                ),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.reverseAlphabetical,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 20, textDirection: TextDirection.rtl),
                    SizedBox(width: 8),
                    Text('Z-A'),
                  ],
                ),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.rankingHigh,
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 20),
                    SizedBox(width: 8),
                    Text('Top Ranking'),
                  ],
                ),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.rankingLow,
                child: Row(
                  children: [
                    Icon(Icons.trending_down, size: 20),
                    SizedBox(width: 8),
                    Text('Lower Ranking'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh articles',
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.15),
              AppTheme.lightBlue.withValues(alpha: 0.1),
              AppTheme.primaryYellow.withValues(alpha: 0.08),
              AppTheme.darkBlue.withValues(alpha: 0.12),
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
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
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.25),
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: AppTheme.darkBlue.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 0,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 0,
                        spreadRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryBlue,
                            AppTheme.darkBlue,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      article.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _formatDate(article),
                      style: TextStyle(
                        color: AppTheme.darkBlue.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => _openArticle(article),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.primaryBlue,
                      size: 16,
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
                      Colors.white.withValues(alpha: 0.98),
                      Colors.white.withValues(alpha: 0.95),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
