import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'article_screen.dart';
import 'splash_screen.dart';
import 'theme.dart';
import 'widgets/panda_lightning_icon.dart';
import 'widgets/ad_banner.dart';
import 'widgets/forced_update_dialog.dart';
import 'services/admob_service.dart';
import 'services/version_service.dart';

enum SortOption {
  original,
  alphabetical,
  reverseAlphabetical,
  rankingHigh,
  rankingLow,
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AdMob
  await AdMobService.initialize();
  
  runApp(const SkimpulseApp());
}

class SkimpulseApp extends StatefulWidget {
  const SkimpulseApp({super.key});

  @override
  State<SkimpulseApp> createState() => _SkimpulseAppState();
}

class _SkimpulseAppState extends State<SkimpulseApp> {
  AppThemeMode _currentTheme = AppThemeMode.light;

  void _changeTheme(AppThemeMode newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Skimpulse",
      theme: AppTheme.getTheme(_currentTheme),
      home: AppWrapper(onThemeChange: _changeTheme, currentTheme: _currentTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppWrapper extends StatefulWidget {
  final Function(AppThemeMode) onThemeChange;
  final AppThemeMode currentTheme;

  const AppWrapper({
    super.key,
    required this.onThemeChange,
    required this.currentTheme,
  });

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _showSplash = true;
  late Future<List<Article>> _preloadedFuture;
  late Future<VersionInfo?> _versionCheckFuture;
  VersionInfo? _versionInfo;
  bool _showUpdateDialog = false;

  @override
  void initState() {
    super.initState();
    // Check version first, then pre-fetch articles
    _checkVersionAndPreload();
  }

  Future<void> _checkVersionAndPreload() async {
    // Check version in parallel with preloading
    _versionCheckFuture = VersionService.checkVersion().catchError((e) => null);
    _preloadedFuture = _preloadArticles();
    
    // Wait for version check (don't block, let _onSplashComplete handle it)
    _versionCheckFuture.then((info) {
      _versionInfo = info;
      // Only set update dialog if splash is still showing
      if (mounted && _showSplash && info != null && 
          (info.forceUpdate || info.needsUpdate)) {
        setState(() {
          _showUpdateDialog = true;
        });
      }
    });
  }

  Future<List<Article>> _preloadArticles() async {
    // Minimum splash duration to show animations nicely
    final minimumSplashDuration = const Duration(milliseconds: 2800);
    // Maximum total timeout to prevent infinite waiting
    const maximumTimeout = Duration(seconds: 15);
    final startTime = DateTime.now();

    try {
      // Start fetching articles with timeout
      final articles = await _fetchArticlesWithRetry()
          .timeout(maximumTimeout, onTimeout: () {
        throw TimeoutException(
          'Request timed out after ${maximumTimeout.inSeconds} seconds',
          maximumTimeout,
        );
      });
      
      // Ensure minimum splash duration
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < minimumSplashDuration) {
        await Future.delayed(minimumSplashDuration - elapsed);
      }
      
      return articles;
    } catch (e) {
      // Even if fetch fails, wait for minimum splash duration (but don't exceed max)
      final elapsed = DateTime.now().difference(startTime);
      final remainingMinTime = minimumSplashDuration - elapsed;
      if (remainingMinTime > Duration.zero && 
          elapsed < maximumTimeout - const Duration(seconds: 1)) {
        await Future.delayed(remainingMinTime);
      }
      // Return empty list instead of throwing to allow app to continue
      // The main screen will show an error state
      return [];
    }
  }

  Future<List<Article>> _fetchArticlesWithRetry() async {
    int retryCount = 0;
    const maxRetries = 2; // Reduced from 3 to prevent long waits
    
    while (retryCount < maxRetries) {
      try {
        return await _fetchArticles();
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          // Return empty list instead of throwing to allow app to continue
          return [];
        }
        // Shorter delay between retries
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    return [];
  }

  Future<List<Article>> _fetchArticles() async {
    const String productionApiUrl = 'https://api-deploy-9so9.onrender.com';
    const String customApiUrl = String.fromEnvironment('API_URL');
    
    final apiUrl = customApiUrl.isNotEmpty 
        ? '$customApiUrl/api/skimfeed'
        : '$productionApiUrl/api/skimfeed';
    
    // Reduced timeout from 30s to 10s to fail faster
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['success'] == true && data['articles'] is List) {
        final List<dynamic> articlesList = data['articles'] as List;
        return articlesList
            .map((article) => Article.fromJson(article))
            .toList();
      } else {
        throw Exception('Invalid response format: ${data.toString()}');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  void _onSplashComplete() async {
    // Wait for data to be preloaded before transitioning (with timeout)
    try {
      await _preloadedFuture.timeout(
        const Duration(seconds: 2),
        onTimeout: () => <Article>[],
      );
    } catch (e) {
      // Even if data load fails, proceed to main screen to show error
    }
    
    // Wait for version check to complete (with timeout to prevent blocking)
    try {
      _versionInfo = await _versionCheckFuture.timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
    } catch (e) {
      // If version check fails or times out, allow app to continue
      _versionInfo = null;
    }
    
    // Don't proceed if forced update is required
    if (_versionInfo != null && 
        (_versionInfo!.forceUpdate || _versionInfo!.needsUpdate)) {
      if (mounted) {
        setState(() {
          _showUpdateDialog = true;
        });
      }
      // Still hide splash to show update dialog
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
      return;
    }
    
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show forced update dialog if needed
    if (_showUpdateDialog && _versionInfo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ForcedUpdateDialog(versionInfo: _versionInfo!),
          );
        }
      });
    }
    
    if (_showSplash) {
      return SplashScreen(onSplashComplete: _onSplashComplete);
    }
    return HotScreen(
      onThemeChange: widget.onThemeChange,
      currentTheme: widget.currentTheme,
      preloadedFuture: _preloadedFuture,
    );
  }
}

class Article {
  final String title;
  final String url;
  final int? ranking;
  final DateTime? publishedDate;
  
  Article({
    required this.title, 
    required this.url,
    this.ranking,
    this.publishedDate,
  });
  
  factory Article.fromJson(Map<String, dynamic> json) {
    DateTime? publishedDate;
    if (json['publishedDate'] != null) {
      if (json['publishedDate'] is String) {
        publishedDate = DateTime.tryParse(json['publishedDate']);
      } else if (json['publishedDate'] is int) {
        publishedDate = DateTime.fromMillisecondsSinceEpoch(json['publishedDate']);
      }
    }
    
    return Article(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      ranking: json['ranking'],
      publishedDate: publishedDate,
    );
  }
}

class HotScreen extends StatefulWidget {
  final Function(AppThemeMode) onThemeChange;
  final AppThemeMode currentTheme;
  final Future<List<Article>>? preloadedFuture;

  const HotScreen({
    super.key,
    required this.onThemeChange,
    required this.currentTheme,
    this.preloadedFuture,
  });

  @override
  State<HotScreen> createState() => _HotScreenState();
}

class _HotScreenState extends State<HotScreen> {
  late Future<List<Article>> future;
  int _retryCount = 0;
  static const int maxRetries = 3;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  
  // Sorting state
  final SortOption _currentSort = SortOption.original;
  List<Article> _originalArticles = [];

  @override
  void initState() {
    super.initState();
    // Use preloaded future if available, otherwise fetch
    if (widget.preloadedFuture != null) {
      // Check if preloaded data is empty (indicating failure), and retry if so
      future = _initializeFuture();
    } else {
      future = fetchArticlesWithRetry();
    }
  }

  Future<List<Article>> _initializeFuture() async {
    final articles = await widget.preloadedFuture!;
    if (articles.isEmpty) {
      // Preload failed, retry fetching
      return await fetchArticlesWithRetry();
    }
    return articles;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Set refreshing state immediately to show overlay
    if (mounted) {
      setState(() {
        _isRefreshing = true;
        _retryCount = 0;
      });
    }
    
    // Ensure UI updates immediately
    await Future.microtask(() {});
    
    try {
      final refreshedArticles = await fetchArticlesWithRetry();
      if (mounted) {
        setState(() {
          future = Future.value(refreshedArticles);
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          future = Future.error(e);
          _isRefreshing = false;
        });
      }
    }
  }

  void _refreshFromButton() {
    _handleRefresh();
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

  Future<void> _openArticle(Article article) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleScreen(article: article),
      ),
    );
  }

  String _formatDate(Article article) {
    if (article.publishedDate != null) {
      final date = article.publishedDate!;
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final day = date.day;
      final daySuffix = _getDaySuffix(day);
      final month = months[date.month - 1];
      final year = date.year;
      
      return '$month ${day}$daySuffix $year';
    }
    
    // Fallback if no date available - return empty string
    return '';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: widget.currentTheme == AppThemeMode.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness: widget.currentTheme == AppThemeMode.dark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.transparent),
            ),
          ),
          FutureBuilder<List<Article>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // If data is empty, treat it as an error
                if (snapshot.data!.isEmpty) {
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
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Articles Found',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Unable to load articles. Please try refreshing.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _isRefreshing ? null : _refreshFromButton,
                            icon: _isRefreshing 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Stack(
                  children: [
                    CustomScrollView(
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PandaLightningIcon(size: 32),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              "Skimpulse",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withValues(alpha: 0.85),
                      elevation: 0,
                      actions: [
                        IconButton(
                          icon: _isRefreshing 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          tooltip: 'Refresh articles',
                          onPressed: _isRefreshing ? null : _refreshFromButton,
                        ),
                      ],
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 100,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Calculate total items including ads and attribution
                            final articles = snapshot.data!;
                            final totalItems = articles.length + (articles.length ~/ 5);
                            final totalWithAttribution = totalItems + 1;
                            
                            if (index >= totalWithAttribution) return null;
                            
                            // Show attribution at the end
                            if (index == totalItems) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                child: Text(
                                  'Made with ❤️ by Nikhil Bastikar',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            
                            // Check if this position should show an ad
                            if (AdManager.shouldShowAd(index)) {
                              return TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 300 + (index * 50)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: AdBanner(
                                        adId: 'ad_$index',
                                        useAdMob: true,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            
                            // Calculate article index (accounting for ads)
                            final articleIndex = index - (index ~/ 6);
                            if (articleIndex >= articles.length) return null;
                            
                            final article = articles[articleIndex];
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 300 + (index * 100)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                      child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: _getArticleCardGradient(widget.currentTheme),
                                        border: Border.all(
                                          color: _getArticleCardBorderColor(widget.currentTheme),
                                          width: 1.5,
                                        ),
                                        boxShadow: _getArticleCardShadows(widget.currentTheme),
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        isThreeLine: false,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: _getNumberBadgeGradient(widget.currentTheme),
                                            boxShadow: _getNumberBadgeShadows(widget.currentTheme),
                                          ),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            child: Text(
                                              '${articleIndex + 1}',
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            shadows: [
                                              Shadow(
                                                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                                                blurRadius: 1,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          _formatDate(article),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                            fontWeight: FontWeight.w600,
                                            shadows: [
                                              Shadow(
                                                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                                                blurRadius: 1,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () => _openArticle(article),
                                        trailing: Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppTheme.primaryBlue,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: snapshot.data!.length + (snapshot.data!.length ~/ 5) + 1, // +1 for attribution
                        ),
                      ),
                    ),
                  ],
                    ), // End of CustomScrollView
                    // Refresh overlay with centered loader
                    AnimatedOpacity(
                      opacity: _isRefreshing ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Visibility(
                        visible: _isRefreshing,
                        child: Positioned.fill(
                          child: AbsorbPointer(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.6),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Theme.of(context).colorScheme.primary,
                                        strokeWidth: 3,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Refreshing articles...',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                          onPressed: _isRefreshing ? null : _refreshFromButton,
                          icon: _isRefreshing 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(isFinalError ? 'Try Again' : 'Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              // Loading state - show splash-like design instead of black screen
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryBlue,
                      AppTheme.darkBlue,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const PandaLightningIcon(size: 80),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryYellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          Positioned(
            right: 16,
            bottom: 16,
            child: _buildFloatingActionButtons(),
          )
        ],
      ),
    );
  }


  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Theme FAB
        FloatingActionButton(
          heroTag: "theme_fab",
          mini: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () => _showThemeBottomSheet(),
          child: Icon(
            AppTheme.getThemeIcon(widget.currentTheme),
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showThemeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Choose Theme',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            ...AppThemeMode.values.map((mode) => ListTile(
              leading: Icon(AppTheme.getThemeIcon(mode)),
              title: Text(AppTheme.getThemeName(mode)),
              trailing: widget.currentTheme == mode 
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                widget.onThemeChange(mode);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
            // Attribution
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Made with ❤️ by Nikhil Bastikar',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  LinearGradient _getArticleCardGradient(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.colorful:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.vibrantPurple.withValues(alpha: 0.3),
            AppTheme.vibrantPink.withValues(alpha: 0.25),
            AppTheme.vibrantPurple.withValues(alpha: 0.2),
          ],
        );
      case AppThemeMode.light:
      case AppThemeMode.dark:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.15),
          ],
        );
    }
  }

  Color _getArticleCardBorderColor(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.colorful:
        return AppTheme.vibrantPurple.withValues(alpha: 0.4);
      case AppThemeMode.light:
      case AppThemeMode.dark:
        return Colors.white.withValues(alpha: 0.3);
    }
  }

  List<BoxShadow> _getArticleCardShadows(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.colorful:
        return [
          BoxShadow(
            color: AppTheme.vibrantPurple.withValues(alpha: 0.4),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.vibrantPink.withValues(alpha: 0.3),
            blurRadius: 50,
            spreadRadius: 0,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 0,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ];
      case AppThemeMode.light:
      case AppThemeMode.dark:
        return [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.darkBlue.withValues(alpha: 0.3),
            blurRadius: 50,
            spreadRadius: 0,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 0,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ];
    }
  }

  LinearGradient _getNumberBadgeGradient(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.colorful:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.vibrantPurple,
            AppTheme.vibrantPink,
          ],
        );
      case AppThemeMode.light:
      case AppThemeMode.dark:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.darkBlue,
          ],
        );
    }
  }

  List<BoxShadow> _getNumberBadgeShadows(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.colorful:
        return [
          BoxShadow(
            color: AppTheme.vibrantPurple.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ];
      case AppThemeMode.light:
      case AppThemeMode.dark:
        return [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ];
    }
  }
}
