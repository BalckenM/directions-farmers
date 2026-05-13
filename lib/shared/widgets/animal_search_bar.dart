import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'rfid_scan_button.dart';

/// A debounced animal search bar with an optional RFID scan button.
///
/// Designed to sit at the top of list screens. Searches are debounced
/// to 300 ms to avoid flooding the provider with rapid keystrokes.
///
/// Per design_system.md §11: "Debounced search across all animals with
/// RFID scan option".
///
/// Usage:
/// ```dart
/// AnimalSearchBar(
///   onSearch: (query) => ref.read(searchProvider.notifier).query = query,
/// )
/// ```
class AnimalSearchBar extends StatefulWidget {
  const AnimalSearchBar({
    super.key,
    required this.onSearch,
    this.hint,
    this.debounceMs = 300,
    this.showRfidButton = true,
    this.autofocus = false,
  });

  /// Called after the debounce period with the current search query.
  /// Passes an empty string when the field is cleared.
  final ValueChanged<String> onSearch;

  /// Placeholder text. Defaults to 'Search animals…'
  final String? hint;

  /// Debounce delay in milliseconds. Default: 300 ms.
  final int debounceMs;

  /// Whether to show the RFID scan button as a suffix. Default: true.
  final bool showRfidButton;

  /// Whether to autofocus the text field. Default: false.
  final bool autofocus;

  @override
  State<AnimalSearchBar> createState() => _AnimalSearchBarState();
}

class _AnimalSearchBarState extends State<AnimalSearchBar> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onSearch(value.trim());
    });
  }

  void _onRfidScanned(String code) {
    _ctrl.text = code;
    _debounce?.cancel();
    widget.onSearch(code.trim());
  }

  void _onClear() {
    _ctrl.clear();
    _debounce?.cancel();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: AppSpacing.minTouchTarget + 4,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.md),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: _ctrl,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: (v) {
                _debounce?.cancel();
                widget.onSearch(v.trim());
              },
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintText: widget.hint ?? 'Search animals…',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          // Clear button — only visible when there is text
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _ctrl,
            builder: (_, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: cs.onSurfaceVariant,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                tooltip: 'Clear search',
                onPressed: _onClear,
              );
            },
          ),
          // RFID scan button
          if (widget.showRfidButton)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: RfidScanButton(
                onScanned: _onRfidScanned,
                tooltip: 'Scan RFID to search',
              ),
            )
          else
            const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}
