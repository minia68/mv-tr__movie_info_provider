import 'package:enough_convert/enough_convert.dart';

import '../../html_page_provider.dart';
import '../detail_result.dart';
import '../tracker_datasource.dart';
import 'detail_parser.dart';
import 'search_parser.dart';

class NnmClubTrackerDatasource
    extends TrackerDataSource<SearchParserResult, DetailResult> {
  final HtmlPageProvider _htmlPageProvider;
  final SearchParser? _searchParser;

  NnmClubTrackerDatasource({
    HtmlPageProvider? htmlPageProvider,
    required super.baseUrl,
    required super.query,
    super.searchLimit,
    SearchParser? searchParser,
  })  : _htmlPageProvider = htmlPageProvider ??
            DioHtmlPageProvider(
              decoder: (bytes, _, __) => Windows1251Codec().decode(bytes),
            ),
        _searchParser = searchParser;

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
  Future<List<SearchParserResult>> search() async {
    final page = await _htmlPageProvider(baseUrl + query);
    final searchParser = _searchParser ?? SearchParser();
    final result =
        searchParser.getSearchResults(page, baseUrl, maxResults: searchLimit);
    return result;
  }
}
