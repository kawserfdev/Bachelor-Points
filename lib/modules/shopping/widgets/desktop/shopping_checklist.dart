import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../../../data/models/shopping_item_model.dart';
import '../../shopping_controller.dart';

/// Desktop-only compact checklist panel.
///
/// Renders a side panel that mirrors the active shopping list as a compact
/// checklist with a progress header. Each row is a tappable item that
/// toggles its purchased state via the controller's existing
/// [ShoppingController.togglePurchased] method. It performs **no** business
/// logic — it only reads from the controller's reactive state.
class ShoppingChecklist extends StatelessWidget {
  const ShoppingChecklist({
    super.key,
    required this.items,
  });

  /// Pre-filtered approved items to render as checklist rows.
  final List<ShoppingItemModel> items;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final total = items.length;
    final purchased = items.where((i) => i.isPurchased).length;
    final progress = total > 0 ? purchased / total : 0.0;
    final allDone = total > 0 && purchased == total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                allDone
                    ? Icons.task_alt_rounded
                    : Icons.checklist_rounded,
                size: 20,
                color: allDone ? const Color(0xFF2E7D32) : cs.primary,
              ),
              const SizedBox(width: 8),
              Text(
                local.shoppingChecklistTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                local.shoppingChecklistProgress(purchased, total),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              color: allDone ? const Color(0xFF2E7D32) : cs.primary,
            ),
          ),
          const SizedBox(height: 12),
          // List
          if (items.isEmpty)
            _buildEmpty(local, theme, cs)
          else if (allDone)
            _buildAllDone(local, theme, cs)
          else
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _ChecklistRow(item: item);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations local, ThemeData theme, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          local.shoppingChecklistEmpty,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildAllDone(
    AppLocalizations local,
    ThemeData theme,
    ColorScheme cs,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration_rounded,
              size: 40,
              color: const Color(0xFF2E7D32).withAlpha(180),
            ),
            const SizedBox(height: 8),
            Text(
              local.shoppingChecklistAllDone,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// A single checklist row with a checkbox + item name + priority dot.
class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item});

  final ShoppingItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<ShoppingController>();

    return InkWell(
      onTap: () => controller.togglePurchased(item.id, item.isPurchased),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            // Priority dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.isUrgent
                    ? const Color(0xFFC62828)
                    : const Color(0xFF1565C0).withAlpha(120),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            // Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: item.isPurchased,
                onChanged: (val) {
                  if (val != null) {
                    controller.togglePurchased(item.id, item.isPurchased);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            // Name + qty
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.itemName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: item.isPurchased
                          ? TextDecoration.lineThrough
                          : null,
                      color: item.isPurchased
                          ? cs.onSurfaceVariant
                          : cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.quantity.isNotEmpty)
                    Text(
                      item.quantity,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
