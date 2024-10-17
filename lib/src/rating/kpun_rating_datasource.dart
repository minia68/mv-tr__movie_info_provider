import 'package:dio/dio.dart';
import 'package:movie_info_provider/src/rating/rating.dart';
import 'rating_data_source.dart';

class KpunRatingDatasource implements RatingDataSource {
  final String _apiKey;
  final Dio _dio;

  KpunRatingDatasource({
    required String apiKey,
    required Dio dio,
  })  : _apiKey = apiKey,
        _dio = dio;

  @override
  Future<Rating> getRating({required String kinopoiskId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://kinopoiskapiunofficial.tech/api/v2.2/films/$kinopoiskId',
      options: Options(headers: {'X-API-KEY': _apiKey}),
    );
    return Rating(
      imdbVoteAverage: response.data?['ratingImdb'] as double? ?? 0,
      imdbVoteCount: response.data?['ratingImdbVoteCount'] as int? ?? 0,
      kinopoiskVoteAverage: response.data?['ratingKinopoisk'] as double? ?? 0,
      kinopoiskVoteCount:
          response.data?['ratingKinopoiskVoteCount'] as int? ?? 0,
    );
  }
}
