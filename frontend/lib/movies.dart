import 'package:flutter/material.dart';
import 'models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'redirects.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  Map<String, List<Movie>> moviesByLanguage = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      final res = await http.get(Uri.parse(movieslangugage));
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        setState(() {
          moviesByLanguage = data.map(
            (lang, list) => MapEntry(
              lang,
              (list as List).map((e) => Movie.fromJson(e)).toList(),
            ),
          );
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching movies by language: $e');
    }
  }

  Widget buildMovieCard(Movie m) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/get_movie/${m.id}');
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 728 / 1062,
                  child: Image.network(
                    m.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(m.stars.toStringAsFixed(1)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.genre,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLanguageSection(String language, List<Movie> list) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            language,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: list.map(buildMovieCard).toList()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Top Movies")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: moviesByLanguage.entries
                  .map((entry) => buildLanguageSection(entry.key, entry.value))
                  .toList(),
            ),
    );
  }
}
