import 'package:domain/domain.dart';
import 'package:logging/logging.dart';
import 'package:movie_info_provider/movie_info_provider.dart';

import 'mdb/mdb_datasource.dart';
import 'mdb/mdb_movie_info.dart';
import 'rating/rating.dart';
import 'rating/rating_data_source.dart';
import 'tracker/detail_result.dart';
import 'tracker/search_result.dart';

final _logger = Logger('MovieInfoProvider');

class MovieInfoProvider {
  final List<TrackerDataSource> _trackerDataSources;
  final RatingDataSource _ratingDataSource;
  final MdbDataSource _mdbDataSource;

  MovieInfoProvider(
    this._trackerDataSources,
    this._ratingDataSource,
    this._mdbDataSource,
  );

  Future<String?> getImageBasePath() {
    return _mdbDataSource.getImageBasePath();
  }

  Future<List<MovieInfo>> getMovies() async {
    final existing = <MovieInfo>[];
    for (var i = 0; i < _trackerDataSources.length; i++) {
      final _trackerDataSource = _trackerDataSources[i];

      _logger.fine('start loading tracker search ${_trackerDataSource.query}');
      final searchResults = await _trackerDataSource.search();
      _logger.fine('load ${searchResults.length} search results');

      for (var searchResult in searchResults) {
        _logger.fine('start loading tracker detail ${searchResult.detailUrl}');
        DetailResult detailResult;
        try {
          detailResult = await _trackerDataSource.getDetail(searchResult);
        } catch (e, s) {
          _logger.warning('error parsing detail page', e, s);
          continue;
        }

        final movieInfo = existing
            .indexWhere((movieInfo) => movieInfo.imdbId == detailResult.imdbId);
        if (movieInfo != -1) {
          await _update(searchResult, detailResult, existing[movieInfo]);
        } else {
          final newMovieInfo = await _create(searchResult, detailResult);
          if (newMovieInfo != null) {
            existing.add(newMovieInfo);
          }
        }
      }
    }

    return existing;
  }

  Future _update(
    SearchResult searchResult,
    DetailResult detailResult,
    MovieInfo movieInfo,
  ) async {
    _logger.fine('find existing imdbId ${detailResult.imdbId}');

    final torrentsInfoIdx = movieInfo.torrentsInfo.indexWhere(
        (torrentsInfo) => torrentsInfo.magnetUrl == detailResult.magnetUrl);
    final movieTorrentInfo = _toMovieTorrentInfo(searchResult, detailResult);
    if (torrentsInfoIdx == -1) {
      _logger.fine('add torrentsInfo ${detailResult.imdbId}');
      movieInfo.torrentsInfo.add(movieTorrentInfo);
    } else {
      _logger.fine('find existing torrentsInfo ${detailResult.magnetUrl}');
      movieInfo.torrentsInfo[torrentsInfoIdx] = movieTorrentInfo;
    }
  }

  Future<MovieInfo?> _create(
    SearchResult searchResult,
    DetailResult detailResult,
  ) async {
    final rating = await _getRating(detailResult);

    MdbMovieInfo? movieInfo;
    try {
      _logger.fine('start loading mdb info ${detailResult.imdbId}');
      movieInfo = await _mdbDataSource.getMovieInfo(detailResult.imdbId);
    } catch (e, s) {
      _logger.warning('error get mdb info ${detailResult.imdbId}', e, s);
    }
    if (movieInfo == null) {
      return null;
    }

    final tmbdDs = _mdbDataSource is TmdbDataSource;
    return MovieInfo(
      tmdbId: int.parse(movieInfo.id),
      imdbId: detailResult.imdbId,
      rating: MovieRating(
        imdbVoteAverage: rating.imdbVoteAverage,
        imdbVoteCount: rating.imdbVoteCount,
        kinopoiskVoteAverage: rating.kinopoiskVoteAverage,
        kinopoiskVoteCount: rating.kinopoiskVoteCount,
        tmdbVoteAverage: tmbdDs ? movieInfo.voteAverage : 0,
        tmdbVoteCount: tmbdDs ? movieInfo.voteCount : 0,
      ),
      kinopoiskId: detailResult.kinopoiskId,
      posterPath: movieInfo.posterPath,
      overview: movieInfo.overview,
      releaseDate: movieInfo.releaseDate,
      title: movieInfo.title,
      backdropPath: movieInfo.backdropPath,
      torrentsInfo: [_toMovieTorrentInfo(searchResult, detailResult)],
      youtubeTrailerKey: movieInfo.youtubeTrailerKey,
      genres: movieInfo.genres ?? [],
      productionCountries:
          movieInfo.productionCountries?.map((e) => e.name).toList() ?? [],
      cast: movieInfo.cast
              ?.map((e) => MovieCast(
                    character: e.character,
                    name: e.name,
                    profilePath: e.posterPath,
                  ))
              .toList() ??
          [],
      crew: movieInfo.crew
              ?.map((e) => MovieCrew(
                    job: e.job,
                    name: e.name,
                    profilePath: e.posterPath,
                  ))
              .toList() ??
          [],
    );
  }

  MovieTorrentInfo _toMovieTorrentInfo(
      SearchResult searchResult, DetailResult detailResult) {
    return MovieTorrentInfo(
      magnetUrl: detailResult.magnetUrl,
      title: detailResult.title,
      size: detailResult.size,
      seeders: detailResult.seeders,
      leechers: detailResult.leechers,
      audio: detailResult.audio,
      date: searchResult.date,
    );
  }

  Future<Rating> _getRating(DetailResult detailResult) async {
    await Future.delayed(Duration(seconds: 10));
    Rating rating;
    try {
      _logger.fine('start loading rating ${detailResult.kinopoiskId}');
      rating = await _ratingDataSource.getRating(
          kinopoiskId: detailResult.kinopoiskId);
    } catch (e, s) {
      _logger.warning('error get rating ${detailResult.imdbId}', e, s);
      rating = Rating(
        imdbVoteAverage: 0,
        imdbVoteCount: 0,
        kinopoiskVoteAverage: 0,
        kinopoiskVoteCount: 0,
      );
    }
    return rating;
  }
}
