import 'dart:io';

import 'package:enough_convert/enough_convert.dart';
import 'package:movie_info_provider/src/tracker/nnmclub/search_parser.dart';
import 'package:test/test.dart';

void main() {
  test('torrents block not found', () {
    final page = '<html></html>';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message == 'torrents block not found')));
  });

  test('wrong torrent block format', () {
    final page =
        '<html><div id="index"><table class="forumline tablesorter"><tr class="gai"><td>01&nbsp;Сен&nbsp;24</td></tr></table></div></html>';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message == 'wrong torrent block format')));
  });

  test('wrong date block format', () {
    final page = '''<html><div id="index"><table class="forumline tablesorter"><tr class="gai">
        <td></td>
        <td><a href="magnet"></a></td>
        <td>12\u00A0GB</td>
        <td><span class="green">1</span><span class="red">2</span></td>
        <td>12\u00A0GB</td>
        <td>12\u00A0GB</td>
        <td>12\u00A0GB</td>
        <td>12\u00A0GB</td>
        <td>12\u00A0GB</td>
        <td>12\u00A0GB</td>
        </tr></table></div></html>''';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message.startsWith('wrong date block format.'))));
  });

  test('wrong peer block format', () {
    final page =
        '''<html><div id="index"><table class="forumline tablesorter"><tr class="gai">
        <td></td>
    <td><a href="magnet"></a></td>
    <td>12\u00A0GB</td>
    <td><span class="green">1</span><span class="red">2</span></td>
    <td>12\u00A0GB</td>
    <td>12\u00A0GB</td>
    <td>12\u00A0GB</td>
    <td>12\u00A0GB</td>
    <td>12\u00A0GB</td>
    <td><u>1725458457</u> 04-09-2024<br>17:00</td>
    </tr></table></div></html>''';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message.startsWith('wrong peer block format'))));
  });

  test('wrong size block format', () {
    final page =
    '''<html><div id="index"><table class="forumline tablesorter"><tr class="gai">
        <td></td>
    <td><a href="magnet"></a></td>
    <td>12\u00A0GB</td>
    <td><span class="green">1</span><span class="red">2</span></td>
    <td>12\u00A0GB</td>
    <td></td>
    <td><b>9</b></td>
    <td><b>9</b></td>
    <td>12\u00A0GB</td>
    <td><u>1725458457</u> 04-09-2024<br>17:00</td>
    </tr></table></div></html>''';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message.startsWith('wrong size block format'))));
  });

  test('wrong detail url format', () {
    final page = '''<html><div id="index"><table class="forumline tablesorter"><tr class="gai">
        <td></td>
    <td></td>
    <td><a href=""></a></td>
    <td><span class="green">1</span><span class="red">2</span></td>
    <td>12\u00A0GB</td>
    <td><u>59632166265</u> 55.5 GB</td>
    <td><b>9</b></td>
    <td><b>9</b></td>
    <td>12\u00A0GB</td>
    <td><u>1725458457</u> 04-09-2024<br>17:00</td>
    </tr></table></div></html>''';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message.startsWith('wrong main block format'))));
  });

  test('wrong main block format', () {
    final page = '''<html><div id="index"><table class="forumline tablesorter"><tr class="gai">
        <td></td>
    <td></td>
    <td></td>
    <td><span class="green">1</span><span class="red">2</span></td>
    <td>12\u00A0GB</td>
    <td><u>59632166265</u> 55.5 GB</td>
    <td><b>9</b></td>
    <td><b>9</b></td>
    <td>12\u00A0GB</td>
    <td><u>1725458457</u> 04-09-2024<br>17:00</td>
    </tr></table></div></html>''';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message.startsWith('wrong main block format.'))));
  });

  test('getSearchResults', () {
    final page = File('test/assets/search_nnmclub.html')
        .readAsStringSync(encoding: Windows1251Codec());
    final searchParser = SearchParser();
    expect(searchParser.getSearchResults(page, 'null', maxResults: 3), [
      SearchParserResult(
        detailUrl:
            'nullviewtopic.php?t=1747466',
        title:
            'Калки, 2898 год нашей эры / Kalki 2898-AD (2024) WEB-DLRip [H.265/2160p] [4K, SDR, 8-bit] [DVO]',
        size: 19.7 * 1024 * 1024 * 1024,
        seeders: 22,
        leechers: 39,
        date: DateTime(2024, 9, 5),
      ),
      SearchParserResult(
        detailUrl:
            'nullviewtopic.php?t=1747318',
        title:
            'Планета обезьян: Новое царство / Kingdom of the Planet of the Apes (2024) UHD BDRemux [H.265/2160p] [4K, HDR10, 10-bit]',
        size: 55.5 * 1024 * 1024 * 1024,
        seeders: 14,
        leechers: 12,
        date: DateTime(2024, 9, 4),
      ),
      SearchParserResult(
        detailUrl:
        'nullviewtopic.php?t=1747128',
        title:
        'Виды доброты / Kinds of Kindness (2024) WEB-DL [H.265/2160p] [4K, HDR10+, Dolby Vision Profile 8.1, 10-bit] [MVO]',
        size: 32.3 * 1024 * 1024 * 1024,
        seeders: 39,
        leechers: 20,
        date: DateTime(2024, 9, 3),
      ),
    ]);
  });
}
