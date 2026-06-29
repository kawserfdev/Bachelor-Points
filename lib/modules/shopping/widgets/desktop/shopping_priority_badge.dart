import 'package:flutter/material.dart';

import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../../../data/models/shopping_item_model.dart';

/// Desktop-only reusable priority badge for shopping items.
///
/// Renders a compact pill that reflects an item's priority (`urgent` or
/// `normal`). It performs **no** business logic — it only maps the model's
/// [ShoppingItemModel.priority] string to a localized label + color.
class ShoppingPriorityBadge extends StatelessWidget {
  const ShoppingPriorityBadge({
    super.key,
    required this.priority,
    this.compact = false,
  });

  /// The raw priority string from [ShoppingItemModel.priority]
  /// (`'urgent'` or `'normal'`).
  final String priority;

  /// When `true`, renders a smaller dot-only variant for dense table rows.
  final bool compact;

  bool get _isUrgent => priority == 'urgent';

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final label = _isUrgent
        ? local.shoppingPriorityUrgent
        : local.shoppingPriorityNormal;

    final fg = _isUrgent ? const Color(0xFFC62828) : const Color(0xFF1565C0);
    final bg = _isUrgent
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFE3F2FD);
    final border = _isUrgent
        ? const Color(0xFFFFCDD2)
        : const Color(0xFFBBDEFB);

    if (compact) {
      return Tooltip(
        message: label,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: fg,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isUrgent
                ? Icons.warning_amber_rounded
                : Icons.star_rounded,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
