import 'package:movie_info_provider/src/rating/rating.dart';
import 'package:movie_info_provider/src/rating/rating_data_source.dart';

class DummyRatingDatasource implements RatingDataSource {
  @override
  Future<Rating> getRating({required String kinopoiskId}) async {
    return Rating(
      imdbVoteAverage: 0,
      imdbVoteCount: 0,
      kinopoiskVoteAverage: 0,
      kinopoiskVoteCount: 0,
    );
  }
}
