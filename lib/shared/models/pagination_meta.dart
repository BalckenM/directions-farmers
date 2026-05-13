/// Pagination metadata returned by list endpoints.
class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  bool get hasNext => page < totalPages;
  bool get hasPrevious => page > 1;
  bool get isFirstPage => page == 1;
  bool get isLastPage => page == totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        page: (json['page'] as num?)?.toInt() ?? 1,
        pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
        totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
        totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'page': page,
        'page_size': pageSize,
        'total_items': totalItems,
        'total_pages': totalPages,
      };

  /// Convenience factory for a single-page (non-paginated) result.
  factory PaginationMeta.singlePage(int count) => PaginationMeta(
        page: 1,
        pageSize: count,
        totalItems: count,
        totalPages: 1,
      );

  @override
  String toString() => 'PaginationMeta(page: $page/$totalPages, total: $totalItems)';
}
