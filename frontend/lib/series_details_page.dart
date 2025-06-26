import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'auth.dart';

class SeriesDetailPage extends StatefulWidget {
  final int seriesId;
  const SeriesDetailPage({super.key, required this.seriesId});

  @override
  State<SeriesDetailPage> createState() => _SeriesDetailPageState();
}

class _SeriesDetailPageState extends State<SeriesDetailPage> {
  MovieDetails? series;
  bool isLoading = true;
  bool submitting = false;
  List<Review> reviews = [];
  String? currentUsername;
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
        Uri.parse('http://localhost:8000/whoami'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          currentUsername = data['username'];
        });
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  Future<void> fetchDetails() async {
    try {
      final res = await http.get(
        Uri.parse('http://localhost:8000/get_series/${widget.seriesId}'),
      );
      if (res.statusCode == 200) {
        setState(() {
          series = MovieDetails.fromJson(jsonDecode(res.body));
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching series detail: $e");
    }
  }

  Future<void> fetchReviews() async {
    final res = await http.get(
      Uri.parse('http://localhost:8000/reviews?series_id=${widget.seriesId}'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      setState(() {
        reviews = data.map((json) => Review.fromJson(json)).toList();
      });
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
      Uri.parse("http://localhost:8000/comment"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "series_id": widget.seriesId,
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
      Uri.parse('http://localhost:8000/delete/comment/$commentId'),
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

  Widget buildStarInput() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(10, (index) {
        return IconButton(
          icon: Icon(
            index < userRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              userRating = index + 1;
            });
          },
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
              final isMine = review.username == currentUsername;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(review.comment),
                  subtitle: Text("⭐ ${review.rating} — by ${review.username}"),
                  trailing: isMine
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
                            if (confirm == true) {
                              await deleteComment(review.commentId!);
                            }
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
      appBar: AppBar(title: Text(series?.title ?? "Loading...")),
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
                            series!.image,
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
                        series!.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "⭐ ${series!.stars.toStringAsFixed(1)}",
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      buildSection("Year of Release", series!.year_release),
                      buildSection("Rating", series!.rating),
                      buildSection("Genre", series!.genre),
                      buildSection("Description", series!.description),
                      buildSection("My Review", series!.myReview),
                      buildSection("Actors", series!.actors.join(', ')),
                      buildSection("Tags", series!.tags.join(', ')),
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
