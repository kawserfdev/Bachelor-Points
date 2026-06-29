import 'package:flutter/material.dart';

import '../../../../data/models/property_model.dart';
import 'property_card.dart';

/// Responsive grid of [PropertyCard]s for the desktop property listing.
///
/// Uses a [LayoutBuilder] to compute the number of columns based on the
/// available width, then lays the cards out in a [Wrap]. This is a pure
/// presentation widget — it receives an already-filtered list of properties
/// and performs no data mutations.
class PropertyGrid extends StatelessWidget {
  const PropertyGrid({
    super.key,
    required this.properties,
    this.maxColumns = 4,
    this.spacing = 16,
  });

  /// The (already filtered) properties to display.
  final List<PropertyModel> properties;

  /// Maximum number of columns regardless of available width.
  final int maxColumns;

  /// Horizontal + vertical spacing between cards.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return _buildEmptyState(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardMinWidth = 280.0;
        final columns = (constraints.maxWidth / (cardMinWidth + spacing))
            .floor()
            .clamp(1, maxColumns);
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final property in properties)
              SizedBox(
                width: cardWidth,
                height: 360,
                child: PropertyCard(property: property),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 64,
            color: cs.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No properties found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search query.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
