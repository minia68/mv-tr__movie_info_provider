import 'package:enough_convert/enough_convert.dart';

import '../../html_page_provider.dart';
import '../detail_result.dart';
import '../tracker_datasource.dart';
import 'detail_parser.dart';
import 'search_parser.dart';

class NnmClubTrackerDatasource
    implements TrackerDataSource<SearchParserResult, DetailResult> {
  final HtmlPageProvider _htmlPageProvider;
  final String _baseUrl;

  NnmClubTrackerDatasource({
    HtmlPageProvider? htmlPageProvider,
    required String baseUrl,
  })  : _htmlPageProvider = htmlPageProvider ??
            DioHtmlPageProvider(
                decoder: (bytes, _, __) => Windows1251Codec().decode(bytes)),
        _baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

  @override
  Future<DetailResult> getDetail(SearchParserResult searchResult) async {
    final page = await _htmlPageProvider(searchResult.detailUrl);

    final detailResult = DetailParser().getTorrentDetail(page);
    return DetailResult(
      imdbId: detailResult.imdbId,
      kinopoiskId: detailResult.kinopoiskId,
      magnetUrl: detailResult.magnetUrl,
      title: searchResult.title,
      size: searchResult.size,
      seeders: searchResult.seeders,
      leechers: searchResult.leechers,
      audio: detailResult.audio,
      imdbRating: detailResult.imdbRating,
      imdbVoteCount: detailResult.imdbVoteCount,
    );
  }

  @override
  Future<List<SearchParserResult>> search(String search) async {
    final page = await _htmlPageProvider(
        _baseUrl + (search.startsWith('/') ? search.substring(1) : search));
    final searchParser = SearchParser();
    final result = searchParser.getSearchResults(page, _baseUrl);
    return result;
  }
}
