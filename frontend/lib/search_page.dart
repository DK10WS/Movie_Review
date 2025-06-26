import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;
  const SearchPage({super.key, this.initialQuery = ''});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _ctrl = TextEditingController();
  List<Movie> results = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) searchMovies(widget.initialQuery);
  }

  Future<void> searchMovies(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => isLoading = true);

    try {
      final res = await http.get(
        Uri.parse(
          "http://localhost:8000/search?query=${Uri.encodeQueryComponent(q)}",
        ),
      );
      if (res.statusCode == 200) {
        setState(() {
          results = (jsonDecode(res.body) as List)
              .map((e) => Movie.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      print("Search error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          cursorColor: Theme.of(context).colorScheme.secondary,
          textInputAction: TextInputAction.search,
          onSubmitted: searchMovies,
          decoration: InputDecoration(
            hintText: 'Search movies or shows...',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
          ? Center(
              child: Text(
                'No results',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            )
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) {
                final m = results[i];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      m.image,
                      width: 50,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey, width: 50, height: 75),
                    ),
                  ),
                  title: Text(m.title, style: textTheme.bodyLarge),
                  subtitle: Text(
                    m.genre,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        m.stars.toStringAsFixed(1),
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  onTap: () {
                    if (m.type == 'movie') {
                      Navigator.pushNamed(context, '/get_movie/${m.id}');
                    } else if (m.type == 'series') {
                      Navigator.pushNamed(context, '/get_series/${m.id}');
                    }
                  },
                );
              },
            ),
    );
  }
}
