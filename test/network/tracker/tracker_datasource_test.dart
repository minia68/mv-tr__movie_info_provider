import 'package:mocktail/mocktail.dart';
import 'package:movie_info_provider/movie_info_provider.dart';
import 'package:movie_info_provider/src/tracker/detail_result.dart';
import 'package:movie_info_provider/src/tracker/rutor/search_parser.dart'
    as rutor;
import 'package:movie_info_provider/src/tracker/nnmclub/search_parser.dart'
    as nnm;
import 'package:test/test.dart';

void main() {
  test('check slash in url', () async {
    final baseUrl = 'baseUrl';
    final htmlPageProvider = MockHtmlPageProvider();
    when(() => htmlPageProvider.call(any())).thenAnswer((_) async => '');
    var ds = RutorTrackerDataSource(
      baseUrl: baseUrl,
      htmlPageProvider: htmlPageProvider,
      query: 'qwe',
    );
    try {
      await ds.search();
    } on Exception {}
    ds = RutorTrackerDataSource(
      baseUrl: baseUrl,
      htmlPageProvider: htmlPageProvider,
      query: '/asd',
    );
    try {
      await ds.search();
    } on Exception {}
    expect(verify(() => htmlPageProvider.call(captureAny())).captured,
        ['baseUrl/qwe', 'baseUrl/asd']);
  });

  test('chack limits', () async {
    final htmlPageProvider = MockHtmlPageProvider();
    when(() => htmlPageProvider.call(any())).thenAnswer((_) async => '');
    final rsp = MockRutorSearchParser();
    final nsp = MockNnmSearchParser();
    final ds = RutorTrackerDataSource(
      baseUrl: 'baseUrl',
      htmlPageProvider: htmlPageProvider,
      query: 'qwe',
      searchLimit: 30,
      searchParser: rsp,
    );
    final ds1 = NnmClubTrackerDatasource(
      baseUrl: 'baseUrl1',
      htmlPageProvider: htmlPageProvider,
      query: '/asd22',
      searchLimit: 20,
      searchParser: nsp,
    );
    when(() => rsp.getSearchResults(any(), any(),
        maxResults: any(named: 'maxResults'))).thenReturn([]);
    when(() => nsp.getSearchResults(any(), any(),
        maxResults: any(named: 'maxResults'))).thenReturn([]);
    try {
      await ds.search();
    } on Exception {}
    try {
      await ds1.search();
    } on Exception {}
    verify(() => rsp.getSearchResults('', 'baseUrl/', maxResults: 30)).called(1);
    verify(() => nsp.getSearchResults('', 'baseUrl1/', maxResults: 20))
        .called(1);
  });

  test('getDetail', () async {
    final baseUrl = 'baseUrl';
    final htmlPageProvider = MockHtmlPageProvider();
    when(() => htmlPageProvider.call(any())).thenAnswer((_) async => '''
<a href="http://www.imdb.com/title/tt123/" target="_blank"></a>
<a href="http://www.kinopoisk.ru/film/456/" target="_blank"></a>
<b>Аудио 01:</b> AC-3, 6 ch, 640 kbps | Русский, DUB | Videofilm Int. |<br />''');
    final ds = RutorTrackerDataSource(
      baseUrl: baseUrl,
      htmlPageProvider: htmlPageProvider,
      query: '',
    );
    final searchResult = rutor.SearchParserResult(
      detailUrl: 'detailUrl',
      magnetUrl: 'magnetUrl',
      title: 'title',
      size: 1,
      seeders: 2,
      leechers: 3,
      date: DateTime(2020, 1, 1),
    );
    var response = await ds.getDetail(searchResult);
    expect(
        response,
        DetailResult(
          imdbId: 'tt123',
          kinopoiskId: '456',
          magnetUrl: 'magnetUrl',
          title: 'title',
          size: 1,
          seeders: 2,
          leechers: 3,
          audio: ['01: AC-3, 6 ch, 640 kbps | Русский, DUB | Videofilm Int. |'],
        ));
  });
}

class MockHtmlPageProvider extends Mock implements HtmlPageProvider {}

class MockRutorSearchParser extends Mock implements rutor.SearchParser {}

class MockNnmSearchParser extends Mock implements nnm.SearchParser {}
