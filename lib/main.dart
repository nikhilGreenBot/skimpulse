import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
// import 'article_screen.dart'; // Temporarily disabled

void main() => runApp(const SkimpulseApp());

class SkimpulseApp extends StatelessWidget {
  const SkimpulseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Skimpulse",
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const HotScreen(),
    );
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

  @override
  void initState() {
    super.initState();
    future = fetchArticles();
  }

  String _getApiUrl() {
    // Android emulator uses 10.0.2.2, iOS simulator uses localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/skimfeed';
    } else {
      return 'http://localhost:3000/api/skimfeed';
    }
  }

  Future<List<Article>> fetchArticles() async {
    try {
      final response = await http.get(
        Uri.parse(_getApiUrl()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['articles'] != null) {
          final articles = (data['articles'] as List)
              .map((article) => Article.fromJson(article))
              .toList();
          return articles;
        }
      }
      
      throw Exception('Failed to load articles');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> _openArticle(Article article) async {
    // Temporarily open in external browser
    final uri = Uri.parse(article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Show error if can't open
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: ${article.url}')),
        );
      }
    }
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
                future = fetchArticles();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final article = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _openArticle(article),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        future = fetchArticles();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
