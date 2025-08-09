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
    final res = await http.get(Uri.parse('https://skimfeed.com/'), headers: {
      'User-Agent': 'Skimpulse/1.0 (+flutter)',
    });
    if (res.statusCode != 200) throw Exception('Failed: ${res.statusCode}');
    final doc = html_parser.parse(res.body);
    final header = doc
        .querySelectorAll('h1,h2,h3,h4')
        .firstWhere(
          (e) => e.text.toUpperCase().contains("WHAT'S HOT"),
          orElse: () => html_parser.parse('<div></div>').documentElement!,
        );
    final items = <HotItem>[];
    var node = header.nextElementSibling;
    while (node != null && items.length < 60) {
      for (final a in node.querySelectorAll('a')) {
        final t = a.text.trim();
        final h = a.attributes['href'] ?? '';
        if (t.isNotEmpty && h.startsWith('http')) items.add(HotItem(t, h));
      }
      if (items.isNotEmpty) break;
      node = node.nextElementSibling;
    }
    if (items.isEmpty) throw Exception("Couldn't parse What's Hot");
    return items;
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
                    child: Text(snapshot.error.toString(), textAlign: TextAlign.center),
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
