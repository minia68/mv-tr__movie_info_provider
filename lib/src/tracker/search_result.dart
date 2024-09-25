class SearchResult {
  final String detailUrl;
  final DateTime date;

  SearchResult(this.detailUrl, this.date);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResult &&
          runtimeType == other.runtimeType &&
          detailUrl == other.detailUrl;

  @override
  int get hashCode => detailUrl.hashCode;
}