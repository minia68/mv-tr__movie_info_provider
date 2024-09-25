import 'package:domain/domain.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_info_provider/movie_info_provider.dart';
import 'package:movie_info_provider/src/mdb/mdb_movie_info.dart';
import 'package:movie_info_provider/src/rating/rating.dart';
import 'package:movie_info_provider/src/rating/rating_data_source.dart';
import 'package:movie_info_provider/src/tracker/detail_result.dart';
import 'package:movie_info_provider/src/tracker/rutor/search_parser.dart';
import 'package:movie_info_provider/src/tracker/search_result.dart';
import 'package:movie_info_provider/src/tracker/tracker_datasource.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  late MockTrackerDataSource trackerDataSource;
  late MockRatingDataSource ratingDataSource;
  late MockMdbDataSource mdbDataSource;
  late MovieInfoProvider ds;
  final trackerSearchUrl = 'trackerSearchUrl';

  setUp(() {
    trackerDataSource = MockTrackerDataSource();
    ratingDataSource = MockRatingDataSource();
    mdbDataSource = MockMdbDataSource();
    ds = MovieInfoProvider(
        [trackerDataSource], ratingDataSource, mdbDataSource, [trackerSearchUrl]);
  });

  test('loadTopSeedersFhdMovies', () async {
    when(trackerDataSource.search(any)).thenAnswer((_) async => [
          SearchResult('detailUrl', DateTime(2020, 1, 1)),
          SearchResult('detailUrl1', DateTime(2020, 1, 3)),
          SearchResult('detailUrl2', DateTime(2020, 1, 2)),
          SearchResult('detailUrl3', DateTime(2020, 1, 4)),
        ]);

    when(trackerDataSource
            .getDetail(SearchResult('detailUrl', DateTime(2020, 1, 1))))
        .thenAnswer((_) async => DetailResult(
              imdbId: 'imdbId',
              kinopoiskId: 'kinopoiskId',
              leechers: 1,
              magnetUrl: 'magnetUrl',
              seeders: 2,
              size: 3,
              title: 'title',
              audio: ['1fadsvdsv', '2sdsdgdsg', '3fjnfjn'],
            ));
    when(trackerDataSource
            .getDetail(SearchResult('detailUrl1', DateTime(2020, 1, 3))))
        .thenAnswer((_) async => DetailResult(
              imdbId: 'imdbId1',
              kinopoiskId: 'kinopoiskId1',
              leechers: 1,
              magnetUrl: 'magnetUrl11',
              seeders: 2,
              size: 3,
              title: 'title',
              audio: ['1fadsvdsv', '2sdsdgdsg'],
            ));
    when(trackerDataSource
            .getDetail(SearchResult('detailUrl2', DateTime(2020, 1, 2))))
        .thenAnswer((_) async => DetailResult(
              imdbId: 'imdbId',
              kinopoiskId: 'kinopoiskId',
              leechers: 11,
              magnetUrl: 'magnetUrl1',
              seeders: 21,
              size: 31,
              title: 'title1',
              audio: ['1fadsvdsv', '2sdsdgdsg'],
            ));
    when(trackerDataSource
            .getDetail(SearchResult('detailUrl3', DateTime(2020, 1, 4))))
        .thenAnswer((_) async => throw SearchParserException('test'));

    when(ratingDataSource.getRating(kinopoiskId: anyNamed('kinopoiskId')))
        .thenAnswer((_) async => Rating(
              imdbVoteAverage: 1,
              imdbVoteCount: 2,
              kinopoiskVoteAverage: 3,
              kinopoiskVoteCount: 4,
            ));
    var date = DateTime.now();
    when(mdbDataSource.getMovieInfo('imdbId'))
        .thenAnswer((_) async => MdbMovieInfo(
              id: '5',
              posterPath: 'posterPath',
              overview: 'overview',
              releaseDate: date,
              title: 'title',
              backdropPath: 'backdropPath',
              voteAverage: 7,
              voteCount: 8,
              cast: [
                MdbMovieCast(
                  character: 'character1',
                  name: 'name1',
                  posterPath: 'profilePath1',
                ),
                MdbMovieCast(
                  character: 'character2',
                  name: 'name2',
                  posterPath: 'profilePath2',
                ),
              ],
              crew: [
                MdbMovieCrew(
                  job: 'job1',
                  name: 'name1',
                  posterPath: 'profilePath1',
                ),
              ],
              genres: ['genres1', 'genres2'],
              productionCountries: [
                MdbMovieCountry(name: 'productionCountries1', code: '1'),
                MdbMovieCountry(name: 'productionCountries2', code: '2'),
              ],
              youtubeTrailerKey: 'youtubeTrailerKey1',
            ));
    when(mdbDataSource.getMovieInfo('imdbId1'))
        .thenAnswer((_) async => MdbMovieInfo(
              id: '2',
              releaseDate: null,
              youtubeTrailerKey: null,
              backdropPath: null,
              productionCountries: null,
              genres: null,
              crew: null,
              cast: null,
              overview: '',
              posterPath: null,
              title: '',
              voteAverage: 7,
              voteCount: 8,
            ));

    var movieInfo = getTestMovieInfo(date);

    final response = await ds.getMovies();
    expect(response.length, 2);
    //testMovieInfo(response[0], movieInfo);
    expect(response[0].toJson(), movieInfo.toJson());

    final mi = response[1];
    expect(mi.imdbId, 'imdbId1');
    expect(mi.kinopoiskId, 'kinopoiskId1');
    expect(mi.torrentsInfo.length, 1);
    final ti = mi.torrentsInfo[0];
    expect(ti.magnetUrl, 'magnetUrl11');
    expect(ti.seeders, 2);
    expect(ti.size, 3);
    expect(ti.title, 'title');
    expect(ti.leechers, 1);
    expect(ti.date, DateTime(2020, 1, 3));

    verify(ratingDataSource.getRating(kinopoiskId: anyNamed('kinopoiskId')))
        .called(2);
  });
}

class MockRemoteDataSource extends Mock implements MovieInfoProvider {
  @override
  Future<List<MovieInfo>> getMovies() =>
      super.noSuchMethod(
        Invocation.method(#getMovies, []),
        returnValue: Future.value(<MovieInfo>[]),
      );
}

class MockTrackerDataSource<S extends SearchResult, D extends DetailResult>
    extends Mock implements TrackerDataSource<S, D> {
  @override
  Future<List<S>> search(String? search) => super.noSuchMethod(
        Invocation.method(#search, [search]),
        returnValue: Future.value(<S>[]),
      );

  @override
  Future<D> getDetail(S? searchResult) => super.noSuchMethod(
        Invocation.method(#getDetail, [searchResult]),
        returnValue: Future.value(DetailResult(
          audio: [],
          title: '',
          kinopoiskId: '',
          imdbId: '',
          leechers: 0,
          magnetUrl: '',
          seeders: 0,
          size: 0,
        )),
      );
}

class MockRatingDataSource extends Mock implements RatingDataSource {
  @override
  Future<Rating> getRating({required String? kinopoiskId}) =>
      super.noSuchMethod(
        Invocation.method(#getRating, [], {#kinopoiskId: kinopoiskId}),
        returnValue: Future.value(Rating(
          imdbVoteAverage: 0,
          kinopoiskVoteCount: 0,
          kinopoiskVoteAverage: 0,
          imdbVoteCount: 0,
        )),
      );
}

class MockMdbDataSource extends Mock implements TmdbDataSource {
  @override
  Future<MdbMovieInfo?> getMovieInfo(String? id) => super.noSuchMethod(
        Invocation.method(#getMovieInfo, [id]),
        returnValue: Future.value(null),
      );
}
