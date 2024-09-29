import 'dart:math';

import 'package:html/parser.dart' show parse;

import '../search_result.dart';

//https://nnmclub.to/forum/tracker.php?f=954&nm=2160p
class SearchParser {
  List<SearchParserResult> getSearchResults(
      String page, String baseUrl, {int? maxResults}) {
    final document = parse(page);
    final trs =
        document.querySelectorAll('table.forumline.tablesorter tbody tr');
    if (trs.isEmpty) {
      throw SearchParserException('torrents block not found');
    }
    final result = <SearchParserResult>[];
    final length = min(maxResults ?? trs.length, trs.length);
    for (var i = 0; i < length; i++) {
      final tr = trs[i];
      final tds = tr.children;
      if (tds.length != 10) {
        throw SearchParserException('wrong torrent block format');
      }
      final dateElement = tds[9];
      final mainElement = tds[2];
      final sizeElement = tds[5];
      final seedersElement = tds[6];
      final leechersElement = tds[7];

      DateTime date;
      try {
        final dateStrArr = dateElement.text.split(' ')[1].split('-');
        date = DateTime(
          int.parse(dateStrArr[2].substring(0, 4)),
          int.parse(dateStrArr[1]),
          int.parse(dateStrArr[0]),
        );
      } catch (e) {
        throw SearchParserException('wrong date block format. ${e.toString()}');
      }

      int seeders, leechers;
      try {
        seeders = int.parse(seedersElement.text.trim());
        leechers = int.parse(leechersElement.text.trim());
      } catch (e) {
        throw SearchParserException('wrong peer block format. ${e.toString()}');
      }

      double size;
      try {
        final sizeStr = sizeElement.text;
        int multiplier;
        if (sizeStr.endsWith('GB')) {
          multiplier = 1024 * 1024 * 1024;
        } else if (sizeStr.endsWith('MB')) {
          multiplier = 1024 * 1024;
        } else if (sizeStr.endsWith('KB')) {
          multiplier = 1024;
        } else {
          multiplier = 1;
        }

        size = double.parse(sizeStr.split(' ')[1]) * multiplier;
      } catch (e) {
        throw SearchParserException('wrong size block format. ${e.toString()}');
      }

      String detailUrl, title;
      try {
        final mainElements = mainElement.getElementsByTagName('a');
        detailUrl = mainElements[0].attributes['href'] ?? '';
        if (detailUrl.isEmpty) {
          throw SearchParserException('wrong detail url format');
        }
        if (!detailUrl.startsWith('http')) {
          detailUrl = baseUrl +
              (detailUrl.startsWith('/') ? detailUrl.substring(1) : detailUrl);
        }

        title = mainElements[0].text.trim();
      } catch (e) {
        throw SearchParserException('wrong main block format. ${e.toString()}');
      }

      result.add(SearchParserResult(
        detailUrl: detailUrl,
        title: title,
        size: size,
        seeders: seeders,
        leechers: leechers,
        date: date,
      ));
    }
    return result;
  }
}

class SearchParserResult extends SearchResult {
  final String title;
  final double size;
  final int seeders;
  final int leechers;

  SearchParserResult({
    required String detailUrl,
    required this.title,
    required this.size,
    required this.seeders,
    required this.leechers,
    required DateTime date,
  }) : super(detailUrl, date);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParserResult &&
          runtimeType == other.runtimeType &&
          detailUrl == other.detailUrl &&
          title == other.title &&
          size == other.size &&
          seeders == other.seeders &&
          leechers == other.leechers;

  @override
  int get hashCode =>
      detailUrl.hashCode ^
      title.hashCode ^
      size.hashCode ^
      seeders.hashCode ^
      leechers.hashCode;

  @override
  String toString() {
    return 'Result{detailUrl: $detailUrl, title: $title, size: $size, seeders: $seeders, leechers: $leechers}';
  }
}

class SearchParserException implements Exception {
  SearchParserException(this.message);

  final String message;

  @override
  String toString() {
    return 'SearchParserException{message: $message}';
  }
}
