import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'main.dart';
import 'theme.dart';
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
  int _retryCount = 0;
  static const int _maxRetries = 3;
  Timer? _retryTimer;
  Timer? _loadTimeoutTimer;
  static const Duration _loadTimeout = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _initializeWebViewWithRetry();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _loadTimeoutTimer?.cancel();
    super.dispose();
  }

  void _initializeWebViewWithRetry({bool isRetry = false}) {
    if (isRetry) {
      _retryCount++;
    } else {
      _retryCount = 0;
    }

    try {
      final actualUrl = _extractActualUrl(widget.article.url);

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setUserAgent('Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  loadingPercentage = progress;
                });
              }
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  loadingPercentage = 0;
                  _hasError = false;
                });
                // Start timeout timer
                _loadTimeoutTimer?.cancel();
                _loadTimeoutTimer = Timer(_loadTimeout, () {
                  if (mounted && _isLoading) {
                    // Timeout occurred - treat as error
                    _handleTimeoutError();
                  }
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                _loadTimeoutTimer?.cancel(); // Cancel timeout on success
                setState(() {
                  _isLoading = false;
                  loadingPercentage = 100;
                  _hasError = false;
                  _retryCount = 0; // Reset on success
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              // Handle network errors that should trigger retry
              if (error.errorCode == -2 || error.errorCode == -1009 || error.errorCode == -1001) {
                _handleWebViewError(error);
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(actualUrl));
    } catch (e) {
      _handleInitializationError(e);
    }
  }

  void _handleWebViewError(WebResourceError error) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load article: ${error.description}';
      });

      // Auto-retry if we haven't exceeded max retries
      if (_retryCount < _maxRetries) {
        _scheduleRetry();
      } else {
        // Show error after all retries exhausted
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _handleTimeoutError() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Request timed out after ${_loadTimeout.inSeconds} seconds';
      });

      // Auto-retry if we haven't exceeded max retries
      if (_retryCount < _maxRetries) {
        _scheduleRetry();
      } else {
        // Show error after all retries exhausted
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _handleInitializationError(dynamic error) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize WebView: $error';
      });

      // Auto-retry if we haven't exceeded max retries
      if (_retryCount < _maxRetries) {
        _scheduleRetry();
      } else {
        // Show error after all retries exhausted
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _loadTimeoutTimer?.cancel();
    // Exponential backoff: 1s, 2s, 4s
    final delay = Duration(seconds: 1 << _retryCount);
    
    _retryTimer = Timer(delay, () {
      if (mounted && _retryCount < _maxRetries) {
        setState(() {
          _isLoading = true;
          _hasError = false;
          loadingPercentage = 0;
        });
        _initializeWebViewWithRetry(isRetry: true);
      }
    });
  }

  void _manualRetry() {
    _retryTimer?.cancel();
    _loadTimeoutTimer?.cancel();
    _retryCount = 0; // Reset retry count for manual retry
    
    if (mounted) {
      setState(() {
        _hasError = false;
        _isLoading = true;
        loadingPercentage = 0;
      });
      
      if (_controller != null) {
        _controller!.reload();
      } else {
        _initializeWebViewWithRetry();
      }
    }
  }

  String _getUserFriendlyErrorMessage() {
    // Convert technical error messages to user-friendly ones
    final error = _errorMessage.toLowerCase();
    
    if (error.contains('err_name_not_resolved') || 
        error.contains('name not resolved') ||
        error.contains('dns')) {
      return 'Unable to connect to the article.\n\nPlease check your internet connection and try again.';
    } else if (error.contains('timeout') || error.contains('timed out')) {
      return 'The article is taking too long to load.\n\nThis might be due to a slow connection. Please try again.';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Network connection issue.\n\nPlease check your internet connection and try again.';
    } else if (error.contains('failed to load') || error.contains('failed to initialize')) {
      return 'Unable to load the article.\n\nPlease try again or open it in your browser.';
    } else {
      return 'Something went wrong while loading the article.\n\nPlease try again or open it in your browser.';
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
          // WebView - hide when loading to prevent content showing through
          if (!_hasError && _controller != null && !_isLoading)
            WebViewWidget(controller: _controller!),
          
          // Loading overlay - fully opaque to hide webview content
          if (_isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Container(
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
                ),
              ),
            ),
          
          // Error overlay - fully opaque
          if (_hasError)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: false,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 40,
                                spreadRadius: 0,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Error Icon with background
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primaryBlue.withValues(alpha: 0.1),
                                      AppTheme.primaryBlue.withValues(alpha: 0.05),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.cloud_off_rounded,
                                  size: 50,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Error Title
                              Text(
                                'Unable to Load Article',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              // User-friendly error message
                              Text(
                                _getUserFriendlyErrorMessage(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              // Primary Action Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _manualRetry,
                                  icon: const Icon(Icons.refresh_rounded, size: 20),
                                  label: const Text(
                                    'Try Again',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                              // Secondary Action Button - Only show in debug mode
                              if (kDebugMode) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _openInExternalBrowser,
                                    icon: const Icon(Icons.open_in_new_rounded, size: 20),
                                    label: const Text(
                                      'Open in Browser (Debug)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryBlue,
                                      side: BorderSide(
                                        color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}
