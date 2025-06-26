// Auth

String baseurl = "http://localhost:8000";
String login = "$baseurl/login";
String Whoami = "$baseurl/whoami";
String sendotp = "$baseurl/sendotp";
String register = "$baseurl/register";

// Homepage
String topmovies = "$baseurl/movies/top";
String topseries = "$baseurl/series/top";

// Shows

String serieslanguage = "$baseurl/series/top_by_language";

// Movies

String movieslangugage = "$baseurl/movies/top_by_language";

// Search

String search = "$baseurl/search?query=";

// Movie Detail

String movieDetail = "$baseurl/get_movies/";
String reviews_link = "$baseurl/reviews?movie_id=";
String comment = "$baseurl/comment";
String delete_comment = "$baseurl/delete/comment/";

// Series Detail

String seriesDetails = "$baseurl/get_series/";
String series_reviews = "$baseurl/reviews?series_id=";
