import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';

/// Shared layout constants for the map + list finder screens (English Learning,
/// Healthcare, Education) so the resizable map behaves the same in each one.
const kMinMapHeight = 120.0;
const kMinListHeight = 96.0;
const kMapHandleHeight = 22.0;
const kDefaultMapHeight = 220.0;

/// Largest map height that still leaves room for the drag handle and a usable
/// slice of the results list, so the map can never be dragged off screen.
double maxMapHeightFor(double available) {
  const reserved = kMapHandleHeight + kMinListHeight;
  final max = available - reserved;
  return max < kMinMapHeight ? kMinMapHeight : max;
}

/// Draggable divider that lets the user grow or shrink the map above a list.
class MapResizeHandle extends StatelessWidget {
  const MapResizeHandle({super.key, required this.onDrag});

  final void Function(double delta) onDrag;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) => onDrag(details.delta.dy),
        child: Semantics(
          label: 'Resize map',
          child: SizedBox(
            height: kMapHandleHeight,
            child: Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: kBrandGreen.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact one-line summary of the current search, shown in place of the full
/// search panel so results get the screen. Tapping it reopens the panel.
class CollapsedSearchBar extends StatelessWidget {
  const CollapsedSearchBar({
    super.key,
    required this.location,
    required this.emptyLocationHint,
    required this.loading,
    required this.onExpand,
    this.detail,
  });

  final String location;

  /// Shown when no location has been entered or resolved yet.
  final String emptyLocationHint;

  /// Optional second line, e.g. the active filters.
  final String? detail;
  final bool loading;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final hasLocation = location.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: kBrandGreen.withValues(alpha: 0.22)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onExpand,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: kBrandGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kBrandGreen,
                          ),
                        )
                      : const Icon(Icons.search, size: 18, color: kBrandGreen),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLocation ? location : emptyLocationHint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: hasLocation
                              ? Colors.black87
                              : Colors.black87.withValues(alpha: 0.6),
                        ),
                      ),
                      if (detail != null && detail!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          detail!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: kBrandGreen),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chevron button that collapses an expanded search panel.
class CollapsePanelButton extends StatelessWidget {
  const CollapsePanelButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Hide search options',
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.keyboard_arrow_up),
    );
  }
}
