import 'package:flutter/material.dart';
import 'package:frontend/redirects.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'auth.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  MovieDetails? movie;
  bool isLoading = true;
  bool submitting = false;
  List<Review> reviews = [];
  List<String> recommendations = [];
  String? currentUsername;
  String? currentUserRole;
  int userRating = 0;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserAndDetails();
  }

  Future<void> fetchUserAndDetails() async {
    await fetchCurrentUser();
    await fetchDetails();
    await fetchReviews();
  }

  Future<void> fetchCurrentUser() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    try {
      final res = await http.get(
        Uri.parse(Whoami),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          currentUsername = data['username'];
          currentUserRole = data['role'];
        });
      } else {
        print("whoami failed: ${res.statusCode} ${res.body}");
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  Future<void> fetchDetails() async {
    try {
      final res = await http.get(Uri.parse('$movieDetail${widget.movieId}'));
      if (res.statusCode == 200) {
        setState(() {
          movie = MovieDetails.fromJson(jsonDecode(res.body));
          isLoading = false;
        });
        await fetchRecommendations();
      }
    } catch (e) {
      print("Error fetching movie detail: $e");
    }
  }

  Future<void> fetchReviews() async {
    try {
      final res = await http.get(Uri.parse('$reviews_link${widget.movieId}'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          reviews = data.map((json) => Review.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print("Error fetching reviews: $e");
    }
  }

  Future<void> fetchRecommendations() async {
    try {
      final response = await http.get(
        Uri.parse('$recommendation${Uri.encodeComponent(movie!.title)}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          recommendations = data.cast<String>();
        });
      } else {
        print("Recommendation fetch failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching recommendations: $e");
    }
  }

  Future<void> submitReview() async {
    if (userRating == 0 || commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide both rating and comment."),
        ),
      );
      return;
    }

    final token = await AuthService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login required to post a comment.")),
      );
      return;
    }

    final res = await http.post(
      Uri.parse(comment),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "movie_id": widget.movieId,
        "rating": userRating,
        "comment": commentController.text.trim(),
      }),
    );

    if (res.statusCode == 200) {
      commentController.clear();
      userRating = 0;
      await fetchReviews();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Review added!")));
    } else {
      AuthService.handleApiError(res, context);
    }
  }

  Future<void> deleteComment(int commentId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      AuthService.showError("Please log in first.", context);
      return;
    }

    final res = await http.delete(
      Uri.parse('$delete_comment$commentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 204) {
      await fetchReviews();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Comment deleted")));
    } else {
      AuthService.handleApiError(res, context);
    }
  }

  Widget buildSection(String title, String content) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRecommendations() {
    if (recommendations.isEmpty) return const SizedBox.shrink();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          children: [
            const Divider(height: 32),
            Text(
              "Recommended Movies",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ...recommendations.map(
              (title) => ListTile(
                leading: const Icon(Icons.movie),
                title: Text(title),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStarInput() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(10, (index) {
        return IconButton(
          icon: Icon(
            index < userRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => setState(() => userRating = index + 1),
        );
      }),
    );
  }

  Widget buildReviewInput() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          children: [
            const Divider(height: 32),
            Text(
              "Leave a Review",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            buildStarInput(),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Your comment",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: submitting ? null : submitReview,
              child: submitting
                  ? const CircularProgressIndicator()
                  : const Text("Submit Review"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReviewsSection() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Divider(height: 32),
            Text(
              "User Reviews",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ...reviews.map((review) {
              final isMineOrAdmin =
                  review.username == currentUsername ||
                  currentUserRole == 'admin';
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(review.comment),
                  subtitle: Text("⭐ ${review.rating} — by ${review.username}"),
                  trailing: isMineOrAdmin
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete Comment?"),
                                content: const Text(
                                  "Are you sure you want to delete this comment?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true)
                              await deleteComment(review.commentId!);
                          },
                        )
                      : null,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie?.title ?? "Loading...")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 728 / 1062,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            movie!.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 48),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        movie!.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "⭐ ${movie!.stars.toStringAsFixed(1)}",
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      buildSection("Year of Release", movie!.year_release),
                      buildSection("Language", movie!.language),
                      buildSection("Movie Rating", movie!.rating),
                      buildSection("Genre", movie!.genre),
                      buildSection("Description", movie!.description),
                      buildSection("My Review", movie!.myReview),
                      buildSection("Actors", movie!.actors.join(', ')),
                      buildSection("Tags", movie!.tags.join(', ')),
                      buildRecommendations(),
                      buildReviewInput(),
                      buildReviewsSection(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
