import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'theme.dart';
import 'widgets/lightning_painter.dart';
import 'widgets/panda_lightning_icon.dart';

class ArticleScreen extends StatefulWidget {
  final Article article;

  const ArticleScreen({super.key, required this.article});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  WebViewController? _controller;
  var loadingPercentage = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      final actualUrl = _extractActualUrl(widget.article.url);

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setUserAgent('Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              setState(() {
                loadingPercentage = progress;
              });
            },
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
                loadingPercentage = 0;
                _hasError = false;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
                loadingPercentage = 100;
              });
            },
            onWebResourceError: (WebResourceError error) {
              if (error.errorCode == -2 || error.errorCode == -1009 || error.errorCode == -1001) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  _errorMessage = 'Failed to load article: ${error.description}';
                });
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(actualUrl));
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to initialize WebView: $e';
      });
    }
  }

  String _extractActualUrl(String skimfeedUrl) {
    try {
      if (skimfeedUrl.contains('skimfeed.com/r.php')) {
        final uri = Uri.parse(skimfeedUrl);
        final uParam = uri.queryParameters['u'];
        if (uParam != null) {
          final decodedUrl = Uri.decodeComponent(uParam);
          return decodedUrl;
        }
      }
      if (skimfeedUrl.contains('redirect') || skimfeedUrl.contains('url=')) {
        final uri = Uri.parse(skimfeedUrl);
        final urlParam = uri.queryParameters['url'] ??
                         uri.queryParameters['u'] ??
                         uri.queryParameters['link'] ??
                         uri.queryParameters['target'];
        if (urlParam != null) {
          final decodedUrl = Uri.decodeComponent(urlParam);
          return decodedUrl;
        }
      }
      return skimfeedUrl;
    } catch (e) {
      return skimfeedUrl;
    }
  }

  Future<void> _openInExternalBrowser() async {
    try {
      final originalUrl = widget.article.url;
      final actualUrl = _extractActualUrl(originalUrl);
      if (actualUrl.isEmpty) {
        throw Exception('Empty URL after extraction');
      }
      final uri = Uri.parse(actualUrl);
      if (!uri.hasScheme) {
        throw Exception('URL missing scheme (http/https)');
      }
      if (!uri.hasAuthority) {
        throw Exception('URL missing domain');
      }
      if (await canLaunchUrl(uri)) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          try {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          } catch (_) {
            await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open URL: $actualUrl'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening article: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
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
            icon: const Icon(Icons.open_in_new),
            onPressed: _openInExternalBrowser,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError && _controller != null)
            WebViewWidget(controller: _controller!),
          
          if (_isLoading)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                    AppTheme.primaryYellow.withValues(alpha: 0.05),
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1500),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.5 + (0.5 * value),
                          child: const PandaLightningIcon(size: 50, showShadow: false),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Loading Article...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.article.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        value: loadingPercentage / 100.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${loadingPercentage.toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (_hasError)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                    AppTheme.primaryYellow.withValues(alpha: 0.05),
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to Load Article',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _hasError = false;
                                _isLoading = true;
                                loadingPercentage = 0;
                              });
                              if (_controller != null) {
                                _controller!.reload();
                              } else {
                                _initializeWebView();
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _openInExternalBrowser,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open in Browser'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final testUri = Uri.parse('https://www.google.com');
                            if (await canLaunchUrl(testUri)) {
                              await launchUrl(testUri, mode: LaunchMode.externalApplication);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Test URL opened successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Test failed: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.bug_report),
                        label: const Text('Test Browser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
