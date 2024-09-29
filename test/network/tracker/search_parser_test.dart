import 'dart:io';

import 'package:movie_info_provider/src/tracker/rutor/search_parser.dart';
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
        '<html><div id="index"><table><tr class="gai"><td>01&nbsp;Сен&nbsp;24</td></tr></table></div></html>';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message == 'wrong torrent block format')));
  });

  test('wrong peer block format', () {
    final page =
        '<html><div id="index"><table><tr class="gai"><td>01&nbsp;Сен&nbsp;24</td><td></td><td></td><td></td></tr></table></div></html>';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message.startsWith('wrong peer block format'))));
  });

  test('wrong size block format', () {
    final page =
        '<html><div id="index"><table><tr class="gai"><td>01&nbsp;Сен&nbsp;24</td><td></td><td></td><td><span class="green">1</span><span class="red">2</span></td></tr></table></div></html>';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message.startsWith('wrong size block format'))));
  });

  test('wrong main block format magnet', () {
    final page = '''<html><div id="index"><table><tr class="gai">
        <td>01&nbsp;Сен&nbsp;24</td>
        <td><a href=""></a></td>
        <td>12&nbsp;GB</td>
        <td><span class="green">1</span><span class="red">2</span></td>
        </tr></table></div></html>''';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message.startsWith('wrong main block format'))));
  });

  test('wrong main block format detail', () {
    final page = '''<html><div id="index"><table><tr class="gai">
        <td>01&nbsp;Сен&nbsp;24</td>
        <td><a href="magnet"></a></td>
        <td>12&nbsp;GB</td>
        <td><span class="green">1</span><span class="red">2</span></td>
        </tr></table></div></html>''';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message.startsWith('wrong main block format'))));
  });

  test('wrong date block format', () {
    final page = '''<html><div id="index"><table><tr class="gai">
        <td></td>
        <td><a href="magnet"></a></td>
        <td>12\u00A0GB</td>
        <td><span class="green">1</span><span class="red">2</span></td>
        </tr></table></div></html>''';
    final searchParser = SearchParser();
    expect(
        () => searchParser.getSearchResults(page, 'null'),
        throwsA(predicate((e) =>
            e is SearchParserException &&
            e.message.startsWith('wrong date block format.'))));
  });

  test('getSearchResults', () {
    final page = File('test/assets/search.html').readAsStringSync();
    final searchParser = SearchParser();
    expect(searchParser.getSearchResults(page, 'null', maxResults: 3), [
      SearchParserResult(
        magnetUrl:
            'magnet:?xt=urn:btih:f81a22449431963302bb72a9bc1a438aea30ba42&dn=rutor.info&tr=udp://opentor.net:6969&tr=http://retracker.local/announce',
        detailUrl:
            'null/torrent/1000116/oppengejmer_oppenheimer-2023-hybrid-2160p-4k-hdr-dolby-vision-profile-8-d-imax',
        title:
            'Оппенгеймер / Oppenheimer (2023) Hybrid 2160p | 4K | HDR | Dolby Vision Profile 8 | D | IMAX',
        size: 95.62 * 1024 * 1024 * 1024,
        seeders: 11,
        leechers: 11,
        date: DateTime(2024, 9, 1),
      ),
      SearchParserResult(
        detailUrl:
            'null/torrent/999991/mjatezhnaja-luna-chast-2-ostavljajuwaja-shramy_rebel-moon-part-two-the-scargiver-2024-web-dl-2160p-4k-hdr-dolby-vision-profile-8-d-rezhisserskaja-versija',
        magnetUrl:
            'magnet:?xt=urn:btih:4268d220d01d475d86e17e944609bd3bc5df0323&dn=rutor.info&tr=udp://opentor.net:6969&tr=http://retracker.local/announce',
        title:
            'Мятежная Луна, часть 2: Оставляющая шрамы / Rebel Moon - Part Two: The Scargiver (2024) WEB-DL 2160p | 4K | HDR | Dolby Vision Profile 8 | D | Режиссерская версия',
        size: 24.13 * 1024 * 1024 * 1024,
        seeders: 43,
        leechers: 30,
        date: DateTime(2024, 8, 31),
      ),
      SearchParserResult(
        magnetUrl:
            'magnet:?xt=urn:btih:3dc98aef5bceb08034bb7632d7e1106ad404a8aa&dn=rutor.info&tr=udp://opentor.net:6969&tr=http://retracker.local/announce',
        detailUrl:
            'null/torrent/999961/garold-i-volshebnyj-melok_harold-and-the-purple-crayon-2024-uhd-web-dl-hevc-2160p-4k-sdr-d',
        title:
            'Гарольд и волшебный мелок / Harold and the Purple Crayon (2024) UHD WEB-DL-HEVC 2160p | 4K | SDR | D',
        size: 8.66 * 1024 * 1024 * 1024,
        seeders: 53,
        leechers: 60,
        date: DateTime(2024, 8, 31),
      ),
    ]);
  });
}
