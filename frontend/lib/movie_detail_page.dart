import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  MovieDetails? movie;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    try {
      final res = await http.get(
        Uri.parse('http://localhost:8000/get_movies/${widget.movieId}'),
      );
      if (res.statusCode == 200) {
        setState(() {
          movie = MovieDetails.fromJson(jsonDecode(res.body));
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching movie detail: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie?.title ?? "Loading...")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Image.network(movie!.image, height: 250, fit: BoxFit.cover),
                  const SizedBox(height: 16),
                  Text(
                    movie!.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text("⭐ ${movie!.stars} | 🎯 ${movie!.rating}"),
                  const SizedBox(height: 8),
                  Text("Genre: ${movie!.genre}"),
                  const Divider(),
                  Text("Description:\n${movie!.description}"),
                  const SizedBox(height: 8),
                  Text("My Review:\n${movie!.myReview}"),
                  const Divider(),
                  Text("Actors: ${movie!.actors.join(', ')}"),
                  Text("Tags: ${movie!.tags.join(', ')}"),
                ],
              ),
            ),
    );
  }
}
