class PaginationResult<T> {
  final List<T> data;
  final int totalCount;
  final int page;
  final int limit;

  PaginationResult({
    required this.data,
    required this.totalCount,
    required this.page,
    required this.limit,
  });

  int get totalPages => (totalCount / limit).ceil();
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}
