import '../mdb_datasource.dart';
import '../mdb_movie_info.dart';
import 'client.dart';
import 'movie_response.dart';

class TmdbDataSource implements MdbDataSource {
  final TmdbClient _client;
  final String _language;

  TmdbDataSource(String tmdbApiKey, {TmdbClient? client, String? language})
      : _client = client ?? TmdbClient.setup(tmdbApiKey),
        _language = language ?? 'ru-RU';

  @override
  Future<String?> getImageBasePath() async {
    // final response = await _client.configuration();
    // return response.images?.baseUrl;
    return 'https://imagetmdb.com/t/p/';
  }

  @override
  Future<MdbMovieInfo?> getMovieInfo(String id) async {
    final findResponse = await _client.find(id, _language, 'imdb_id');
    if (findResponse.movieResults.length != 1) {
      return null;
    }
    final movieResult = findResponse.movieResults[0];

    final movie = await _client.getMovie(movieResult.id, _language);

    Video? video;
    try {
      video = movie.videos?.results
          ?.firstWhere((e) => e.type == 'Trailer' && e.site == 'YouTube');
    } catch (e) {
      try {
        video = movie.videos?.results
            ?.firstWhere((e) => e.type == 'Teaser' && e.site == 'YouTube');
      } catch (e) {}
    }

    return MdbMovieInfo(
      id: movieResult.id.toString(),
      posterPath: movieResult.posterPath,
      overview: movieResult.overview,
      releaseDate: movieResult.releaseDate != null
          ? DateTime.parse(movieResult.releaseDate!)
          : null,
      title: movieResult.title,
      backdropPath: movieResult.backdropPath,
      voteAverage: movieResult.voteAverage,
      voteCount: movieResult.voteCount,
      cast: movie.credits?.cast
          ?.map((e) => MdbMovieCast(
                character: e.character,
                name: e.name,
                posterPath: e.profilePath,
              ))
          .toList(),
      crew: movie.credits?.crew
          ?.map((e) => MdbMovieCrew(
                job: e.job,
                name: e.name,
                posterPath: e.profilePath,
              ))
          .toList(),
      genres: movie.genres?.map((e) => e.name).toList(),
      productionCountries: movie.productionCountries
          ?.map((e) => MdbMovieCountry(
                code: e.code,
                name: e.name,
              ))
          .toList(),
      youtubeTrailerKey: video?.key,
    );
  }
}
