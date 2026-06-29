import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../../../data/models/shopping_item_model.dart';
import '../../shopping_controller.dart';
import 'shopping_priority_badge.dart';

/// Desktop-only shopping table.
///
/// Renders approved shopping items as a dense [DataTable] with columns:
/// Item, Quantity, Priority, Requested By, Note, and a purchased toggle.
/// It receives a pre-filtered [items] list from the parent and performs
/// **no** business logic — the checkbox delegates to the controller's
/// existing [ShoppingController.togglePurchased] method.
class ShoppingTable extends StatelessWidget {
  const ShoppingTable({
    super.key,
    required this.items,
  });

  /// Pre-filtered approved items to render.
  final List<ShoppingItemModel> items;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (items.isEmpty) {
      return _buildEmpty(context, local, theme, cs);
    }

    final controller = Get.find<ShoppingController>();

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(cs.primary.withAlpha(18)),
          dataRowMinHeight: 56,
          dataRowMaxHeight: 72,
          horizontalMargin: 16,
          columnSpacing: 24,
          columns: [
            DataColumn(
              label: _header(local.shoppingTableItem, theme),
              onSort: (_, _) {},
            ),
            DataColumn(label: _header(local.shoppingTableQty, theme)),
            DataColumn(label: _header(local.shoppingTablePriority, theme)),
            DataColumn(label: _header(local.shoppingTableRequestedBy, theme)),
            DataColumn(label: _header(local.shoppingTableNote, theme)),
            DataColumn(label: _header(local.shoppingStatusPurchased, theme)),
          ],
          rows: items.map((item) {
            return DataRow(
              key: ValueKey(item.id),
              color: WidgetStateProperty.resolveWith<Color?>((states) {
                if (item.isPurchased) {
                  return cs.surfaceContainerHighest.withAlpha(60);
                }
                return null;
              }),
              cells: [
                // Item name
                DataCell(
                  Row(
                    children: [
                      Icon(
                        item.isPurchased
                            ? Icons.check_circle_rounded
                            : Icons.shopping_bag_outlined,
                        size: 18,
                        color: item.isPurchased
                            ? cs.primary
                            : cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          item.itemName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: item.isPurchased
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isPurchased
                                ? cs.onSurfaceVariant
                                : cs.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quantity
                DataCell(
                  Text(
                    item.quantity.isEmpty
                        ? '—'
                        : item.quantity,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                // Priority badge
                DataCell(ShoppingPriorityBadge(priority: item.priority)),
                // Requested by
                DataCell(
                  Text(
                    item.requestedByName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Note
                DataCell(
                  item.note != null && item.note!.isNotEmpty
                      ? Text(
                          item.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          '—',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.outline,
                          ),
                        ),
                ),
                // Purchased toggle
                DataCell(
                  Checkbox(
                    value: item.isPurchased,
                    onChanged: (val) {
                      if (val != null) {
                        controller.togglePurchased(item.id, item.isPurchased);
                      }
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _header(String label, ThemeData theme) {
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEmpty(
    BuildContext context,
    AppLocalizations local,
    ThemeData theme,
    ColorScheme cs,
  ) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_add_rounded,
              size: 56,
              color: cs.secondary.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(
              local.shoppingTableEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
