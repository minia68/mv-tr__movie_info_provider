class DetailParser {
  DetailParserResult getTorrentDetail(String page) {
    final imdbId = _getId(page, '"http://www.imdb.com/title/(.*?)/"');
    String kinopoiskId;
    try {
      kinopoiskId = _getId(page, '"http://www.kinopoisk.ru/film/(.*?)/"');
    } catch (_) {
      kinopoiskId =
          _getId(page, '"http://www.kinopoisk.ru/level/1/film/(.*?)/"');
    }
    return DetailParserResult(
      imdbId: imdbId,
      kinopoiskId: kinopoiskId,
      audio: _getAudio(page),
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
    var audios = RegExp(r'Аудио(.{10,})<br').allMatches(page);
    if (audios.isEmpty) {
      audios = RegExp(r'Звук(.{10,})<br').allMatches(page);
    }
    final result = <String>[];
    for (final audio in audios) {
      final group = audio.group(1);
      if (group != null) {
        result.add(group.replaceAll(RegExp(r'<[^>]*>'), ''));
      }
    }
    return result;
  }
}

class DetailParserResult {
  final String imdbId;
  final String kinopoiskId;
  final List<String> audio;

  DetailParserResult({
    required this.imdbId,
    required this.kinopoiskId,
    required this.audio,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetailParserResult &&
          runtimeType == other.runtimeType &&
          imdbId == other.imdbId &&
          kinopoiskId == other.kinopoiskId;

  @override
  int get hashCode => imdbId.hashCode ^ kinopoiskId.hashCode;

  @override
  String toString() {
    return 'Result{imdbId: $imdbId, kinopoiskId: $kinopoiskId}';
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
