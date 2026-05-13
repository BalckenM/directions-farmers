import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

/// In-app debug console — only rendered in [kDebugMode].
///
/// Wrap your app's root widget with [DebugConsoleOverlay] in [app.dart].
/// A floating bug-icon FAB appears in the bottom-right. Tap to open a full
/// log viewer sheet with colour-coded entries and tap-to-expand detail.
class DebugConsoleOverlay extends StatefulWidget {
  const DebugConsoleOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<DebugConsoleOverlay> createState() => _DebugConsoleOverlayState();
}

class _DebugConsoleOverlayState extends State<DebugConsoleOverlay> {
  StreamSubscription<LogEntry>? _sub;
  int _errorCount = 0;

  @override
  void initState() {
    super.initState();
    _errorCount = AppLogger.errorCount;
    _sub = AppLogger.stream.listen((entry) {
      if (entry.level == LogLevel.error) {
        if (mounted) setState(() => _errorCount = AppLogger.errorCount);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _openConsole(BuildContext navigatorContext) {
    setState(() => _errorCount = 0); // reset badge when opened
    showModalBottomSheet(
      context: navigatorContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LogSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            right: 16,
            bottom: 80, // above bottom nav
            child: Builder(
              builder: (ctx) => _DebugFab(
                errorCount: _errorCount,
                onTap: () => _openConsole(ctx),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Floating Action Button ──────────────────────────────────────────────────

class _DebugFab extends StatelessWidget {
  const _DebugFab({required this.errorCount, required this.onTap});

  final int errorCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            elevation: 6,
            color: Colors.grey.shade900.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(28),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.bug_report, color: Colors.white, size: 24),
            ),
          ),
          if (errorCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  errorCount > 99 ? '99+' : '$errorCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Log Sheet ───────────────────────────────────────────────────────────────

class _LogSheet extends StatefulWidget {
  const _LogSheet();

  @override
  State<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends State<_LogSheet> {
  StreamSubscription<LogEntry>? _sub;
  final List<LogEntry> _entries = [];
  LogLevel? _filter; // null = all
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _entries.addAll(AppLogger.entries);
    _sub = AppLogger.stream.listen((e) {
      if (mounted) setState(() => _entries.add(e));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  List<LogEntry> get _filtered =>
      _filter == null ? _entries : _entries.where((e) => e.level == _filter).toList();

  Color _levelColor(LogLevel l) => switch (l) {
        LogLevel.debug => Colors.grey.shade400,
        LogLevel.info => Colors.lightBlueAccent,
        LogLevel.warning => Colors.orange,
        LogLevel.error => Colors.redAccent,
      };

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.terminal, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Debug Console  (${filtered.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  // Copy all errors
                  IconButton(
                    icon: const Icon(Icons.copy_all, color: Colors.white54, size: 18),
                    tooltip: 'Copy errors',
                    onPressed: () {
                      final errors = _entries
                          .where((e) => e.level == LogLevel.error)
                          .map((e) =>
                              '[${e.timeStr}][${e.tag ?? '?'}] ${e.message}\n${e.error ?? ''}\n${e.stackTrace ?? ''}')
                          .join('\n---\n');
                      Clipboard.setData(ClipboardData(text: errors));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Errors copied to clipboard')),
                      );
                    },
                  ),
                  // Clear
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 18),
                    tooltip: 'Clear logs',
                    onPressed: () {
                      AppLogger.clear();
                      setState(() => _entries.clear());
                    },
                  ),
                ],
              ),
            ),
            // Level filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _FilterChip(label: 'All', selected: _filter == null, color: Colors.white70,
                      onTap: () => setState(() => _filter = null)),
                  _FilterChip(label: '🔍 Debug', selected: _filter == LogLevel.debug,
                      color: _levelColor(LogLevel.debug),
                      onTap: () => setState(() => _filter = LogLevel.debug)),
                  _FilterChip(label: 'ℹ️ Info', selected: _filter == LogLevel.info,
                      color: _levelColor(LogLevel.info),
                      onTap: () => setState(() => _filter = LogLevel.info)),
                  _FilterChip(label: '⚠️ Warn', selected: _filter == LogLevel.warning,
                      color: _levelColor(LogLevel.warning),
                      onTap: () => setState(() => _filter = LogLevel.warning)),
                  _FilterChip(label: '🔴 Error', selected: _filter == LogLevel.error,
                      color: _levelColor(LogLevel.error),
                      onTap: () => setState(() => _filter = LogLevel.error)),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            // Log list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No logs yet',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _LogTile(
                        entry: filtered[i],
                        levelColor: _levelColor(filtered[i].level),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Log Tile ─────────────────────────────────────────────────────────────────

class _LogTile extends StatefulWidget {
  const _LogTile({required this.entry, required this.levelColor});
  final LogEntry entry;
  final Color levelColor;

  @override
  State<_LogTile> createState() => _LogTileState();
}

class _LogTileState extends State<_LogTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final hasDetail = e.error != null || e.stackTrace != null;
    return InkWell(
      onTap: hasDetail ? () => setState(() => _expanded = !_expanded) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: widget.levelColor, width: 3),
          ),
          color: _expanded ? Colors.white.withValues(alpha: 0.04) : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.timeStr,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
                if (e.tag != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: widget.levelColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      e.tag!,
                      style: TextStyle(
                        color: widget.levelColor,
                        fontSize: 9,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
                if (hasDetail) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                    size: 14,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              e.message,
              style: TextStyle(
                color: widget.levelColor,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            if (_expanded && e.error != null) ...[
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  e.error.toString(),
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            if (_expanded && e.stackTrace != null) ...[
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  e.stackTrace.toString(),
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.25) : Colors.transparent,
          border: Border.all(color: selected ? color : Colors.grey.shade700),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : Colors.grey.shade500,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
