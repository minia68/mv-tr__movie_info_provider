import 'package:html/parser.dart';

class DetailParser {
  DetailParserResult getTorrentDetail(String page) {
    final doc = parse(page);
    String imdbId;
    double? imdbRating;
    int? imdbVotes;
    try {
      final imdbSpan = doc.querySelector('span.imdbRatingPlugin');
      imdbId = imdbSpan!.attributes['data-title']!;
      final imdbRatingStr = imdbSpan.querySelector('span.rating')?.text ?? '';
      final idx = imdbRatingStr.indexOf('/');
      imdbRating = double.tryParse(
          idx > 0 ? imdbRatingStr.substring(0, idx) : imdbRatingStr);
      imdbVotes = int.tryParse(
          (imdbSpan.querySelector('span.votes')?.text ?? '')
              .replaceAll(',', ''));
    } catch (e) {
      throw DetailParserException('imdb id not found');
    }

    String kinopoiskId;
    try {
      kinopoiskId = _getId(page, '"https://www.kinopoisk.ru/film/(.*?)/"');
    } catch (_) {
      kinopoiskId =
          _getId(page, '"https://www.kinopoisk.ru/level/1/film/(.*?)/"');
    }

    String magnetUrl;
    try {
      magnetUrl = RegExp(r'href="(magnet:.*?)"').firstMatch(page)!.group(1)!;
    } catch (e) {
      throw DetailParserException('magnetUrl not found');
    }
    return DetailParserResult(
      imdbId: imdbId,
      kinopoiskId: kinopoiskId,
      audio: _getAudio(page),
      imdbVoteCount: imdbVotes,
      imdbRating: imdbRating,
      magnetUrl: magnetUrl,
    );
  }

  String _getId(String page, String url) {
    final matches = RegExp(url).allMatches(page).toList();
    if (matches.isEmpty || matches[0].groupCount < 1) {
      throw DetailParserException('id not found');
    }
    return matches[0].group(1)!;
  }

  List<String> _getAudio(String page) {
    var audios = RegExp(r'Аудио(.{10,}?)(<br|<div)').allMatches(page);
    final result = <String>[];
    for (final audio in audios) {
      final group = audio.group(1);
      if (group != null) {
        result.add(group.replaceAll(RegExp(r'<[^>]*>'), '').trim());
      }
    }
    return result;
  }
}

class DetailParserResult {
  final String magnetUrl;
  final String imdbId;
  final String kinopoiskId;
  final List<String> audio;
  final double? imdbRating;
  final int? imdbVoteCount;

  DetailParserResult({
    required this.magnetUrl,
    required this.imdbId,
    required this.kinopoiskId,
    required this.audio,
    required this.imdbRating,
    required this.imdbVoteCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetailParserResult &&
          runtimeType == other.runtimeType &&
          magnetUrl == other.magnetUrl &&
          imdbId == other.imdbId &&
          kinopoiskId == other.kinopoiskId &&
          audio == other.audio &&
          imdbRating == other.imdbRating &&
          imdbVoteCount == other.imdbVoteCount;

  @override
  int get hashCode =>
      magnetUrl.hashCode ^
      imdbId.hashCode ^
      kinopoiskId.hashCode ^
      audio.hashCode ^
      imdbRating.hashCode ^
      imdbVoteCount.hashCode;

  @override
  String toString() {
    return 'DetailParserResult{magnetUrl: $magnetUrl, imdbId: $imdbId, kinopoiskId: $kinopoiskId, audio: $audio, imdbRating: $imdbRating, imdbVoteCount: $imdbVoteCount}';
  }
}

class DetailParserException implements Exception {
  DetailParserException(this.message);

  final String message;

  @override
  String toString() {
    return 'DetailParserException{message: $message}';
  }
}
