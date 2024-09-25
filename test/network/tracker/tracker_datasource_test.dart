import 'package:mockito/mockito.dart';
import 'package:movie_info_provider/src/html_page_provider.dart';
import 'package:movie_info_provider/src/tracker/detail_result.dart';
import 'package:movie_info_provider/src/tracker/rutor/rutor_tracker_datasource.dart';
import 'package:movie_info_provider/src/tracker/rutor/search_parser.dart';
import 'package:test/test.dart';

void main() {
  test('search', () async {
    final baseUrl = 'baseUrl';
    final htmlPageProvider = MockHtmlPageProvider();
    when(htmlPageProvider.call(any)).thenAnswer((_) async => '');
    final ds = RutorTrackerDataSource(
      baseUrl: baseUrl,
      htmlPageProvider: htmlPageProvider,
    );
    try {
      await ds.search('qwe');
    } on Exception {}
    try {
      await ds.search('/asd');
    } on Exception {}
    expect(verify(htmlPageProvider.call(captureAny)).captured,
        ['baseUrl/qwe', 'baseUrl/asd']);
  });

  test('getDetail', () async {
    final baseUrl = 'baseUrl';
    final htmlPageProvider = MockHtmlPageProvider();
    when(htmlPageProvider.call(any)).thenAnswer((_) async => '''
<a href="http://www.imdb.com/title/tt123/" target="_blank"></a>
<a href="http://www.kinopoisk.ru/film/456/" target="_blank"></a>
<b>Аудио 01:</b> AC-3, 6 ch, 640 kbps | Русский, DUB | Videofilm Int. |<br />''');
    final ds = RutorTrackerDataSource(
      baseUrl: baseUrl,
      htmlPageProvider: htmlPageProvider,
    );
    final searchResult = SearchParserResult(
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

class MockHtmlPageProvider extends Mock implements HtmlPageProvider {
  @override
  Future<String> call(String? url) => super.noSuchMethod(
        Invocation.method(#call, [url]),
        returnValue: Future.value(''),
      );
}
