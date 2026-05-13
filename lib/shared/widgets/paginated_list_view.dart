import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/pagination_meta.dart';

/// A paginated [ListView] that triggers [onLoadMore] when the user scrolls
/// within [scrollThreshold] pixels of the bottom.
///
/// Renders each item via [itemBuilder]. Appends a loading spinner row while
/// [isLoadingMore] is true, and a "no more items" indicator when
/// [paginationMeta.isLastPage] is true.
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.paginationMeta,
    required this.onLoadMore,
    this.isLoadingMore = false,
    this.scrollThreshold = 200.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.separatorBuilder,
  });

  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final PaginationMeta paginationMeta;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;
  final double scrollThreshold;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final remaining =
        _controller.position.maxScrollExtent - _controller.position.pixels;
    if (remaining <= widget.scrollThreshold &&
        !widget.isLoadingMore &&
        widget.paginationMeta.hasNext) {
      widget.onLoadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final itemCount = widget.items.length +
        (widget.isLoadingMore || widget.paginationMeta.isLastPage ? 1 : 0);

    final separator = widget.separatorBuilder;

    return ListView.separated(
      controller: _controller,
      padding: widget.padding ??
          const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingHorizontal,
              vertical: AppSpacing.sm),
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemCount: itemCount,
      separatorBuilder:
          separator ?? (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (ctx, index) {
        if (index >= widget.items.length) {
          if (widget.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: Text(
                'All records loaded',
                style:
                    tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          );
        }
        return widget.itemBuilder(ctx, index, widget.items[index]);
      },
    );
  }
}
