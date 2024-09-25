import 'dart:io';

import 'package:enough_convert/enough_convert.dart';
import 'package:movie_info_provider/src/tracker/nnmclub/detail_parser.dart';
import 'package:test/test.dart';

void main() {
  test('imdbId not found', () {
    final searchParser = DetailParser();
    try {
      searchParser.getTorrentDetail(
          '<a href="http://imdb.com/title//" target="_blank"></a>');
      throw Exception();
    } on DetailParserException catch (e) {
      expect(e.message, 'imdb id not found');
    }
  });
  test('kinopoiskId not found', () {
    final searchParser = DetailParser();
    try {
      searchParser.getTorrentDetail(
          '<span class="imdbRatingPlugin" data-user="ur79343845" data-title="tt19864802" data-style="p3"></span>');
      throw Exception();
    } on DetailParserException catch (e) {
      expect(e.message, 'id not found');
    }
  });
  test('magnetUrl not found', () {
    final searchParser = DetailParser();
    try {
      searchParser.getTorrentDetail(
          '<a href="https://www.kinopoisk.ru/film/23432423/"></a><span class="imdbRatingPlugin" data-user="ur79343845" data-title="tt19864802" data-style="p3"></span>');
      throw Exception();
    } on DetailParserException catch (e) {
      expect(e.message, 'magnetUrl not found');
    }
  });

  test('getTorrentDetail', () {
    final page = File('test/assets/detail_nnmclub.html')
        .readAsStringSync(encoding: Windows1251Codec());
    final searchParser = DetailParser();
    final result = searchParser.getTorrentDetail(page);
    expect(result.magnetUrl, 'magnet:?xt=urn:btih:B28E908C992D2CF3E5DA88E61F550D16BC65A2D7');
    expect(result.imdbRating, null);
    expect(result.imdbVoteCount, null);
    expect(result.kinopoiskId, '4947994');
    expect(result.imdbId, 'tt19864802');
    expect(result.audio[0], '1: AC3, 6 ch, 448 Kbps - Русский (DUB, Мосфильм-Мастер)');
    expect(result.audio[1], '2: E-AC3, 6 ch, 448 Kbps - Русский (DUB, Мосфильм-Мастер)');
    expect(result.audio[2], '3: DTS-HD MA, 6 ch, 1986 Kbps - Английский (Оригинал)');
  });
}
