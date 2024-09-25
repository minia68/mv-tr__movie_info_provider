import 'rating.dart';

abstract class RatingDataSource {
  Future<Rating> getRating({required String kinopoiskId});
}
