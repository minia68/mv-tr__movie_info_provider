import 'dart:io';

import 'package:movie_info_provider/src/tracker/rutor/detail_parser.dart';
import 'package:test/test.dart';

void main() {
  test('imdbId not found', () {
    final searchParser = DetailParser();
    try {
      searchParser.getTorrentDetail(
          '<a href="http://imdb.com/title//" target="_blank"></a>');
      throw Exception();
    } on DetailParserException catch (e) {
      expect(e.message, 'id not found');
    }
  });
  test('kinopoiskId not found', () {
    final searchParser = DetailParser();
    try {
      searchParser.getTorrentDetail(
          '<a href="http://www.imdb.com/title/123/" target="_blank"></a>');
      throw Exception();
    } on DetailParserException catch (e) {
      expect(e.message, 'id not found');
    }
  });

  test('getTorrentDetail', () {
    final page = File('test/assets/detail.html').readAsStringSync();
    final searchParser = DetailParser();
    expect(
        searchParser.getTorrentDetail(page),
        DetailParserResult(kinopoiskId: '4784969', imdbId: 'tt12610390', audio: [
        '01: AC-3, 6 ch, 640 kbps | Русский, DUB | Videofilm Int. |',
        'Аудио 02: E-AC-3, 6 ch, 640 kbps | Русский, DUB | Videofilm Int. |',
        'Аудио 03: AC-3, 6 ch, 448 kbps | Русский, MVO | TVShows |',
        'Аудио 04: AC-3, 2 ch, 192 kbps | Русский, MVO | HDrezka Studio |',
        'Аудио 05: E-AC-3, 6 ch, 640 kbps | Украинский, DUB | Так Треба Продакшн |',
        'Аудио 06: E-AC-3 Atmos, 6 ch, 768 kbps | Английский |',
        ]));
  });
}
