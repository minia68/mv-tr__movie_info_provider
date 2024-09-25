import 'package:domain/domain.dart';

MovieInfo getTestMovieInfo(DateTime date) {
  return MovieInfo(
    backdropPath: 'backdropPath',
    imdbId: 'imdbId',
    rating: MovieRating(
      kinopoiskVoteAverage: 3,
      kinopoiskVoteCount: 4,
      imdbVoteAverage: 1,
      imdbVoteCount: 2,
      tmdbVoteAverage: 7,
      tmdbVoteCount: 8,
    ),
    kinopoiskId: 'kinopoiskId',
    overview: 'overview',
    posterPath: 'posterPath',
    releaseDate: date,
    title: 'title',
    tmdbId: 5,
    torrentsInfo: [
      MovieTorrentInfo(
        leechers: 1,
        magnetUrl: 'magnetUrl',
        seeders: 2,
        size: 3,
        title: 'title',
        audio: ['1fadsvdsv', '2sdsdgdsg', '3fjnfjn'],
        date: DateTime(2020, 1, 1),
      ),
      MovieTorrentInfo(
        leechers: 11,
        magnetUrl: 'magnetUrl1',
        seeders: 21,
        size: 31,
        title: 'title1',
        audio: ['1fadsvdsv', '2sdsdgdsg'],
        date: DateTime(2020, 1, 2),
      )
    ],
    cast: [
      MovieCast(
        character: 'character1',
        name: 'name1',
        profilePath: 'profilePath1',
      ),
      MovieCast(
        character: 'character2',
        name: 'name2',
        profilePath: 'profilePath2',
      ),
    ],
    crew: [
      MovieCrew(
        job: 'job1',
        name: 'name1',
        profilePath: 'profilePath1',
      ),
    ],
    genres: ['genres1', 'genres2'],
    productionCountries: ['productionCountries1', 'productionCountries2'],
    youtubeTrailerKey: 'youtubeTrailerKey1',
  );
}
