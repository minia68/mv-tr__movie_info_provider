import 'detail_result.dart';
import 'search_result.dart';

abstract class TrackerDataSource<S extends SearchResult,
    D extends DetailResult> {
  final String baseUrl;
  final String query;
  final int? searchLimit;

  TrackerDataSource({
    required String baseUrl,
    required String query,
    this.searchLimit,
  })  : baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
        query = query.startsWith('/') ? query.substring(1) : query;

  Future<List<S>> search();

  Future<D> getDetail(S searchResult);
}
