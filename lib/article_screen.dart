import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Import Article class from main.dart to avoid duplication
import 'main.dart';

class ArticleScreen extends StatefulWidget {
  final Article article;

  const ArticleScreen({super.key, required this.article});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late final WebViewController _controller;
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();

    final actualUrl = _extractActualUrl(widget.article.url);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(actualUrl));
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
            onPressed: () async {
              // Optionally, open in external browser
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
        ],
      ),
    );
  }
}
