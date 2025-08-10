import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';

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

class HotItem {
  final String title;
  final String url;
  HotItem(this.title, this.url);
}

class HotScreen extends StatefulWidget {
  const HotScreen({super.key});
  @override
  State<HotScreen> createState() => _HotScreenState();
}

class _HotScreenState extends State<HotScreen> {
  late Future<List<HotItem>> future;

  @override
  void initState() {
    super.initState();
    future = fetchHot();
  }

  Future<List<HotItem>> fetchHot() async {
    try {
      final res = await http.get(Uri.parse('https://skimfeed.com/'), headers: {
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1',
      });
      
      if (res.statusCode != 200) throw Exception('Failed to load: ${res.statusCode}');
      
      final doc = html_parser.parse(res.body);
      final items = <HotItem>[];
      
      // Try multiple parsing strategies
      
      // Strategy 1: Look for "What's Hot" section
      try {
        final hotHeaders = doc.querySelectorAll('h1,h2,h3,h4,h5,h6');
        for (final header in hotHeaders) {
          if (header.text.toUpperCase().contains("WHAT'S HOT") || 
              header.text.toUpperCase().contains("HOT") ||
              header.text.toUpperCase().contains("TRENDING")) {
            var node = header.nextElementSibling;
            while (node != null && items.length < 50) {
              for (final a in node.querySelectorAll('a')) {
                final t = a.text.trim();
                final h = a.attributes['href'] ?? '';
                if (t.isNotEmpty && h.startsWith('http') && t.length > 10) {
                  items.add(HotItem(t, h));
                }
              }
              if (items.isNotEmpty) break;
              node = node.nextElementSibling;
            }
            if (items.isNotEmpty) break;
          }
        }
      } catch (e) {
        // Continue to next strategy
      }
      
      // Strategy 2: Look for any links with substantial text
      if (items.isEmpty) {
        try {
          final allLinks = doc.querySelectorAll('a[href^="http"]');
          for (final link in allLinks) {
            final t = link.text.trim();
            final h = link.attributes['href'] ?? '';
            if (t.isNotEmpty && h.startsWith('http') && t.length > 15 && !t.contains('http')) {
              items.add(HotItem(t, h));
              if (items.length >= 30) break;
            }
          }
        } catch (e) {
          // Continue to next strategy
        }
      }
      
      // Strategy 3: Look for article-like content
      if (items.isEmpty) {
        try {
          final articles = doc.querySelectorAll('article, .article, .post, .item');
          for (final article in articles) {
            final link = article.querySelector('a[href^="http"]');
            if (link != null) {
              final t = link.text.trim();
              final h = link.attributes['href'] ?? '';
              if (t.isNotEmpty && h.startsWith('http') && t.length > 10) {
                items.add(HotItem(t, h));
                if (items.length >= 20) break;
              }
            }
          }
        } catch (e) {
          // Continue to fallback
        }
      }
      
      if (items.isEmpty) {
        throw Exception("Couldn't parse content from skimfeed.com. The site structure may have changed.");
      }
      
      return items;
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  Future<void> refresh() async => setState(() => future = fetchHot());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("What's Hot")),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: FutureBuilder<List<HotItem>>(
          future: future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              if (snapshot.hasError) {
                return ListView(children: [
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          snapshot.error.toString(), 
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                ]);
              }
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!;
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final it = items[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(it.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(it.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => launchUrl(Uri.parse(it.url), mode: LaunchMode.externalApplication),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
