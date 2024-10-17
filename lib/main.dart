import 'package:dio/dio.dart';
import 'package:movie_info_provider/src/rating/kpun_rating_datasource.dart';

void main(List<String> args) async {
  final kp = KpunRatingDatasource(
    apiKey: '2b0377c0-269b-4927-9f4f-9972764a76a7',
    dio: Dio(),
  );
  final response = await kp.getRating(kinopoiskId: '301');
  print(response.imdbVoteCount);
  print(response.imdbVoteAverage);
  print(response.kinopoiskVoteCount);
  print(response.kinopoiskVoteAverage);
}