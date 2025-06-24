import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'movie_detail_page.dart';
import 'auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Movie> movies = [];
  List<Movie> series = [];
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchContent();
  }

  Future<void> fetchUser() async {
    final user = await AuthService.whoami(context);
    if (mounted && user != null) {
      setState(() => username = user['username']);
    }
  }

  Future<void> fetchContent() async {
    try {
      final movieRes = await http.get(
        Uri.parse('http://localhost:8000/movies/top'),
      );
      final seriesRes = await http.get(
        Uri.parse('http://localhost:8000/series/top'),
      );

      if (movieRes.statusCode == 200 && seriesRes.statusCode == 200) {
        setState(() {
          movies = List<Map<String, dynamic>>.from(
            jsonDecode(movieRes.body),
          ).map((e) => Movie.fromJson(e)).toList();
          series = List<Map<String, dynamic>>.from(
            jsonDecode(seriesRes.body),
          ).map((e) => Movie.fromJson(e)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching top content: $e");
    }
  }

  void goToDetails(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailPage(movieId: id)),
    );
  }

  void handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Widget buildSection(String title, List<Movie> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => goToDetails(item.id),
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          item.image,
                          height: 180,
                          width: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "⭐ ${item.stars.toStringAsFixed(1)}",
                              style: const TextStyle(color: Colors.orange),
                            ),
                            Text(
                              item.genre,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "DK's List",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(onPressed: handleLogout, child: const Text("Logout")),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Welcome${username != null ? ', $username' : ''}! DK's List is your personal guide to top-rated movies and series. Explore curated content, read reviews, and discover new favorites.",
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removes back button automatically
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("DK's List"),
        actions: [
          IconButton(onPressed: handleLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeader(),
                  buildSection("Top 10 Movies", movies),
                  const SizedBox(height: 16),
                  buildSection("Top 10 Series", series),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
