import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_typography.dart';
import 'package:mobile_app/core/theme/payroll_design_tokens.dart';

/// Sortable, paginated data table for payroll list screens.
/// Provides consistent styling across employees, pay runs, payslips, etc.
///
/// Example:
/// ```dart
/// PrDataTable<PayrollEmployee>(
///   columns: [
///     PrTableColumn(id: 'name', label: 'Employee', flex: 2),
///     PrTableColumn(id: 'engagement', label: 'Type'),
///     PrTableColumn(id: 'status', label: 'Status', align: TextAlign.center),
///   ],
///   rows: employees.map((e) => PrTableRow(
///     key: e.id,
///     cells: [Text(e.fullName), PrStatusPill.engagement(e.engagementType), ...],
///     onTap: () => context.push('/payroll/employees/${e.id}'),
///   )).toList(),
/// )
/// ```
class PrDataTable extends StatefulWidget {
  const PrDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.rowsPerPage = 25,
    this.showPagination = true,
    this.sortColumnId,
    this.sortAscending = true,
    this.onSort,
    this.loading = false,
    this.emptyTitle = 'No records found',
    this.emptySubtitle,
    this.emptyIcon = Icons.table_rows_outlined,
    this.headerActions,
  });

  final List<PrTableColumn> columns;
  final List<PrTableRow> rows;
  final int rowsPerPage;
  final bool showPagination;
  final String? sortColumnId;
  final bool sortAscending;
  final void Function(String columnId, bool ascending)? onSort;
  final bool loading;
  final String emptyTitle;
  final String? emptySubtitle;
  final IconData emptyIcon;
  final List<Widget>? headerActions;

  @override
  State<PrDataTable> createState() => _PrDataTableState();
}

class _PrDataTableState extends State<PrDataTable> {
  int _currentPage = 0;
  late String? _sortId;
  late bool _sortAsc;

  @override
  void initState() {
    super.initState();
    _sortId = widget.sortColumnId;
    _sortAsc = widget.sortAscending;
  }

  int get _totalPages =>
      (widget.rows.length / widget.rowsPerPage).ceil().clamp(1, 9999);

  List<PrTableRow> get _pageRows {
    final start = _currentPage * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, widget.rows.length);
    return widget.rows.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PayrollTokens.cardBg,
        borderRadius: PayrollTokens.radiusLg,
        border: Border.all(color: PayrollTokens.border),
        boxShadow: PayrollTokens.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.headerActions != null) _buildHeader(),
          _buildColumnHeaders(),
          if (widget.loading)
            _buildLoadingSkeleton()
          else if (widget.rows.isEmpty)
            _buildEmpty()
          else
            ..._pageRows.asMap().entries.map(
              (e) => _buildRow(e.value, isEven: e.key.isEven),
            ),
          if (widget.showPagination &&
              !widget.loading &&
              widget.rows.isNotEmpty)
            _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PayrollTokens.spacingMd,
        vertical: PayrollTokens.spacingSm,
      ),
      child: Row(children: [const Spacer(), ...widget.headerActions!]),
    );
  }

  Widget _buildColumnHeaders() {
    return Container(
      color: PayrollTokens.pageBg,
      padding: const EdgeInsets.symmetric(
        horizontal: PayrollTokens.spacingMd,
        vertical: 10,
      ),
      child: Row(
        children: widget.columns.map((col) {
          final isSorted = col.id == _sortId;
          return Expanded(
            flex: col.flex,
            child: GestureDetector(
              onTap: col.sortable && widget.onSort != null
                  ? () {
                      final asc = isSorted ? !_sortAsc : true;
                      setState(() {
                        _sortId = col.id;
                        _sortAsc = asc;
                        _currentPage = 0;
                      });
                      widget.onSort!(col.id, asc);
                    }
                  : null,
              child: Row(
                mainAxisAlignment: col.align == TextAlign.right
                    ? MainAxisAlignment.end
                    : col.align == TextAlign.center
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Text(
                    col.label,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: PayrollTokens.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (col.sortable) ...[
                    const SizedBox(width: 4),
                    Icon(
                      isSorted
                          ? (_sortAsc
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded)
                          : Icons.unfold_more_rounded,
                      size: 14,
                      color: isSorted
                          ? PayrollTokens.brand
                          : PayrollTokens.textMuted,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRow(PrTableRow row, {required bool isEven}) {
    return InkWell(
      onTap: row.onTap,
      child: Container(
        color: isEven ? null : PayrollTokens.pageBg.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(
          horizontal: PayrollTokens.spacingMd,
          vertical: 12,
        ),
        child: Row(
          children: row.cells.asMap().entries.map((e) {
            final col = widget.columns[e.key];
            return Expanded(
              flex: col.flex,
              child: Align(
                alignment: col.align == TextAlign.right
                    ? Alignment.centerRight
                    : col.align == TextAlign.center
                    ? Alignment.center
                    : Alignment.centerLeft,
                child: e.value,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(
        6,
        (i) => Container(
          height: 52,
          color: i.isEven ? null : PayrollTokens.pageBg.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(
            horizontal: PayrollTokens.spacingMd,
            vertical: 12,
          ),
          child: Row(
            children: widget.columns.map((col) {
              return Expanded(
                flex: col.flex,
                child: Container(
                  height: 14,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: PayrollTokens.surfaceContainer,
                    borderRadius: PayrollTokens.radiusSm,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(widget.emptyIcon, size: 40, color: PayrollTokens.textMuted),
          const SizedBox(height: 12),
          Text(
            widget.emptyTitle,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: PayrollTokens.textSecondary,
            ),
          ),
          if (widget.emptySubtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.emptySubtitle!,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: PayrollTokens.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination() {
    final start = _currentPage * widget.rowsPerPage + 1;
    final end = ((_currentPage + 1) * widget.rowsPerPage).clamp(
      0,
      widget.rows.length,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PayrollTokens.spacingMd,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: PayrollTokens.border)),
      ),
      child: Row(
        children: [
          Text(
            '$start–$end of ${widget.rows.length}',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: PayrollTokens.textSecondary,
            ),
          ),
          const Spacer(),
          _PageButton(
            icon: Icons.chevron_left_rounded,
            enabled: _currentPage > 0,
            onTap: () => setState(() => _currentPage--),
          ),
          const SizedBox(width: 4),
          Text(
            'Page ${_currentPage + 1} of $_totalPages',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: PayrollTokens.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          _PageButton(
            icon: Icons.chevron_right_rounded,
            enabled: _currentPage < _totalPages - 1,
            onTap: () => setState(() => _currentPage++),
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: PayrollTokens.border),
          borderRadius: PayrollTokens.radiusMd,
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? PayrollTokens.textPrimary : PayrollTokens.textMuted,
        ),
      ),
    );
  }
}

class PrTableColumn {
  const PrTableColumn({
    required this.id,
    required this.label,
    this.flex = 1,
    this.sortable = true,
    this.align = TextAlign.left,
  });
  final String id;
  final String label;
  final int flex;
  final bool sortable;
  final TextAlign align;
}

class PrTableRow {
  const PrTableRow({required this.key, required this.cells, this.onTap});
  final String key;
  final List<Widget> cells;
  final VoidCallback? onTap;
}
