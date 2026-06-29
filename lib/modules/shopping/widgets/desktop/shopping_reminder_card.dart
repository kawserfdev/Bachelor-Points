import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../shopping_controller.dart';

/// Desktop-only "Bazar Reminder" card.
///
/// A prominent banner that summarizes the active shopping list's status:
/// progress (purchased / total), urgent items still pending, and quick
/// actions (create list / complete list). It reads reactively from the
/// existing [ShoppingController] and performs **no** business logic — the
/// buttons simply delegate to the controller's existing methods.
class ShoppingReminderCard extends StatelessWidget {
  const ShoppingReminderCard({
    super.key,
    this.onCreateList,
    this.onCompleteList,
  });

  /// Callback invoked when the user taps "Create List".
  /// The parent view owns the create-list dialog.
  final VoidCallback? onCreateList;

  /// Callback invoked when the user taps "Complete List".
  /// The parent view owns the complete-list confirmation dialog.
  final VoidCallback? onCompleteList;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return Obx(() {
      final controller = Get.find<ShoppingController>();
      final active = controller.activeList.value;

      // No active list — prompt creation (managers) or inform members.
      if (active == null) {
        return _ReminderSurface(
          accent: cs.tertiary,
          icon: Icons.shopping_basket_outlined,
          title: local.shoppingReminderTitle,
          message: local.shoppingReminderNoList,
          trailing: controller.isManager
              ? FilledButton.tonalIcon(
                  onPressed: onCreateList,
                  icon: const Icon(Icons.create_new_folder_rounded, size: 18),
                  label: Text(local.shoppingReminderCreate),
                )
              : null,
          progress: null,
        );
      }

      final total = controller.totalApprovedCount;
      final purchased = controller.purchasedCount;
      final urgentPending = controller.approvedItems
          .where((i) => i.isUrgent && !i.isPurchased)
          .length;
      final progress = total > 0 ? purchased / total : 0.0;
      final allDone = total > 0 && purchased == total;

      String message;
      Color accent;
      IconData icon;
      if (allDone) {
        message = local.shoppingReminderComplete;
        accent = const Color(0xFF2E7D32);
        icon = Icons.task_alt_rounded;
      } else if (urgentPending > 0) {
        message = local.shoppingReminderUrgent(urgentPending);
        accent = const Color(0xFFC62828);
        icon = Icons.warning_amber_rounded;
      } else {
        message = local.shoppingReminderProgress(purchased, total);
        accent = cs.primary;
        icon = Icons.shopping_cart_checkout_rounded;
      }

      final period = (active.startDate != null && active.endDate != null)
          ? '${DateFormat('d MMM', locale).format(active.startDate!)} – '
              '${DateFormat('d MMM yyyy', locale).format(active.endDate!)}'
          : null;

      return _ReminderSurface(
        accent: accent,
        icon: icon,
        title: active.title,
        message: message,
        caption: period,
        progress: total > 0 ? progress : null,
        progressLabel: '$purchased / $total',
        trailing: controller.isManager
            ? FilledButton.tonalIcon(
                onPressed: allDone ? onCompleteList : null,
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: Text(local.shoppingReminderCompleteBtn),
              )
            : null,
      );
    });
  }
}

/// Private surface that renders the reminder card's visual shell.
class _ReminderSurface extends StatelessWidget {
  const _ReminderSurface({
    required this.accent,
    required this.icon,
    required this.title,
    required this.message,
    this.caption,
    this.progress,
    this.progressLabel,
    this.trailing,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String message;
  final String? caption;
  final double? progress;
  final String? progressLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    caption!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withAlpha(210),
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: accent.withAlpha(30),
                            color: accent,
                          ),
                        ),
                      ),
                      if (progressLabel != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          progressLabel!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing!,
          ],
        ],
      ),
    );
  }
}
