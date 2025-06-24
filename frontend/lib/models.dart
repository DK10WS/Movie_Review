class Movie {
  final int id;
  final String title;
  final double stars;
  final String rating;
  final String genre;
  final String image;

  Movie({
    required this.id,
    required this.title,
    required this.stars,
    required this.rating,
    required this.genre,
    required this.image,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? 'Untitled',
      stars: double.tryParse(json['stars'].toString()) ?? 0.0,
      rating: json['rating']?.toString() ?? 'N/A',
      genre: json['genre']?.toString() ?? 'Unknown',
      image: json['image']?.toString() ?? '',
    );
  }
}

class MovieDetails extends Movie {
  final String description;
  final String myReview;
  final List<String> actors;
  final List<String> tags;

  MovieDetails({
    required super.id,
    required super.title,
    required super.stars,
    required super.rating,
    required super.genre,
    required super.image,
    required this.description,
    required this.myReview,
    required this.actors,
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
      description: json['description']?.toString() ?? '',
      myReview: json['my_review']?.toString() ?? '',
      actors: List<String>.from(json['actors'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
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

  Series({
    required this.id,
    required this.title,
    required this.stars,
    required this.rating,
    required this.genre,
    required this.image,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id'],
      title: json['title'] ?? 'Untitled',
      stars: double.tryParse(json['stars'].toString()) ?? 0.0,
      rating: json['rating']?.toString() ?? 'N/A',
      genre: json['genre']?.toString() ?? 'Unknown',
      image: json['image']?.toString() ?? '',
    );
  }
}
