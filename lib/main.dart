import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'article_screen.dart';
import 'splash_screen.dart';
import 'theme.dart';
import 'widgets/panda_lightning_icon.dart';
import 'widgets/ad_banner.dart';
import 'services/admob_service.dart';

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
    return HotScreen(
      onThemeChange: widget.onThemeChange,
      currentTheme: widget.currentTheme,
    );
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
  final Function(AppThemeMode) onThemeChange;
  final AppThemeMode currentTheme;

  const HotScreen({
    super.key,
    required this.onThemeChange,
    required this.currentTheme,
  });

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

  LinearGradient _getBackgroundGradient() {
    switch (widget.currentTheme) {
      case AppThemeMode.light:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryBlue.withOpacity(0.15),
            AppTheme.lightBlue.withOpacity(0.1),
            AppTheme.primaryYellow.withOpacity(0.08),
            AppTheme.darkBlue.withOpacity(0.12),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        );
      case AppThemeMode.dark:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkBlue.withOpacity(0.3),
            AppTheme.primaryBlue.withOpacity(0.2),
            AppTheme.primaryYellow.withOpacity(0.1),
            Colors.black.withOpacity(0.4),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        );
      case AppThemeMode.colorful:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.vibrantPurple.withOpacity(0.15),
            AppTheme.vibrantPink.withOpacity(0.1),
            AppTheme.vibrantCyan.withOpacity(0.08),
            AppTheme.vibrantGreen.withOpacity(0.12),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        );
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
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PandaLightningIcon(size: 32),
                          const SizedBox(width: 12),
                          const Text("Skimpulse"),
                        ],
                      ),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withOpacity(0.85),
                      elevation: 0,
                      actions: [
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
                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 100,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Calculate total items including ads
                            final articles = snapshot.data!;
                            final totalItems = articles.length + (articles.length ~/ 5);
                            
                            if (index >= totalItems) return null;
                            
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
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.3),
                                            Colors.white.withOpacity(0.2),
                                            Colors.white.withOpacity(0.15),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryBlue
                                                .withOpacity(0.4),
                                            blurRadius: 25,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: AppTheme.darkBlue
                                                .withOpacity(0.3),
                                            blurRadius: 50,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 20),
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.4),
                                            blurRadius: 0,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 1),
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 15,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 5),
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
                                                color: AppTheme.primaryBlue
                                                    .withOpacity(0.5),
                                                blurRadius: 12,
                                                spreadRadius: 0,
                                                offset: const Offset(0, 6),
                                              ),
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 8,
                                                spreadRadius: 0,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
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
                                                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
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
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            fontWeight: FontWeight.w600,
                                            shadows: [
                                              Shadow(
                                                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
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
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: snapshot.data!.length + (snapshot.data!.length ~/ 5),
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
                          Colors.white.withOpacity(0.98),
                          Colors.white.withOpacity(0.95),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.15),
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

          // FABs only (Bottom Nav Bar hidden)
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildFloatingActionButtons(),
          )
        ],
      ),
    );
  }

  Widget _buildBottomBarWithFABs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
          child: _buildFloatingActionButtons(),
        ),
        _buildBottomNavigationBar(),
      ],
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
        const SizedBox(height: 8),
        // Sort FAB
        FloatingActionButton(
          heroTag: "sort_fab",
          mini: true,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onPressed: () => _showSortBottomSheet(),
          child: const Icon(
            Icons.sort,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBottomNavItem(
                icon: Icons.home,
                label: 'Home',
                isSelected: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
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
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sort Articles',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            ...SortOption.values.map((option) => ListTile(
              leading: Icon(_getSortIcon(option)),
              title: Text(_getSortLabel(option)),
              trailing: _currentSort == option 
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                _onSortChanged(option);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.original:
        return Icons.list;
      case SortOption.alphabetical:
        return Icons.sort_by_alpha;
      case SortOption.reverseAlphabetical:
        return Icons.sort_by_alpha;
      case SortOption.rankingHigh:
        return Icons.trending_up;
      case SortOption.rankingLow:
        return Icons.trending_down;
    }
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.original:
        return 'Original Order';
      case SortOption.alphabetical:
        return 'A-Z';
      case SortOption.reverseAlphabetical:
        return 'Z-A';
      case SortOption.rankingHigh:
        return 'Top Ranking';
      case SortOption.rankingLow:
        return 'Lower Ranking';
    }
  }
}
