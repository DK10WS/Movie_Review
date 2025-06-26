class Movie {
  final int id;
  final String title;
  final double stars;
  final String rating;
  final String genre;
  final String image;
  final List<String> actors;
  final String myReview;
  final String year_release;
  final String type;

  Movie({
    required this.id,
    required this.title,
    required this.stars,
    required this.rating,
    required this.genre,
    required this.image,
    required this.actors,
    required this.myReview,
    required this.year_release,
    required this.type,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      image: json['image'] ?? '',
      stars: (json['stars'] ?? 0).toDouble(),
      genre: json['genre'] ?? '',
      rating: json['rating'] ?? '',
      actors: List<String>.from(json['actors'] ?? []),
      myReview: json['my_review'] ?? '',
      year_release: json['year_release'] ?? '',
      type: json['type'] ?? 'movie',
    );
  }
}

class MovieDetails extends Movie {
  final String description;
  final List<String> tags;

  MovieDetails({
    required super.id,
    required super.title,
    required super.stars,
    required super.rating,
    required super.genre,
    required super.image,
    required super.actors,
    required super.myReview,
    required super.year_release,
    required super.type,
    required this.description,
    required this.tags,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      id: json['id'],
      title: json['title'] ?? 'Untitled',
      stars: double.tryParse(json['stars'].toString()) ?? 0.0,
      rating: json['rating']?.toString() ?? 'N/A',
      genre: json['genre']?.toString() ?? 'Unknown',
      image: json['image']?.toString() ?? '',
      actors: List<String>.from(json['actors'] ?? []),
      myReview: json['my_review'] ?? '',
      description: json['description']?.toString() ?? '',
      year_release: json['year_release'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      type: json['type'] ?? 'movie',
    );
  }
}

class Series {
  final int id;
  final String title;
  final double stars;
  final String rating;
  final String genre;
  final String image;
  final String year_release;
  final String type;

  Series({
    required this.id,
    required this.title,
    required this.stars,
    required this.rating,
    required this.genre,
    required this.image,
    required this.year_release,
    required this.type,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id'],
      title: json['title'] ?? 'Untitled',
      stars: double.tryParse(json['stars'].toString()) ?? 0.0,
      rating: json['rating']?.toString() ?? 'N/A',
      genre: json['genre']?.toString() ?? 'Unknown',
      image: json['image']?.toString() ?? '',
      year_release: json['year_release'] ?? '',
      type: json['type'] ?? 'series',
    );
  }
}

class Review {
  final int? commentId;
  final String username;
  final double rating;
  final String comment;

  Review({
    required this.commentId,
    required this.username,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      commentId: json['comment_id'],
      username: json['username'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
    );
  }
}
