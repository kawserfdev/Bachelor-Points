import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../property_search/property_search_controller.dart';

/// Desktop sidebar filter panel for the property search screen.
///
/// Renders the same filter controls as the mobile search view — division,
/// property type, and price range — but laid out vertically in a card so it
/// can sit beside the results grid on wide screens.
///
/// All filter mutations delegate to the existing [PropertySearchController]
/// reactive state and call its [PropertySearchController.search] method. No
/// new business logic is introduced.
class PropertyFilters extends StatelessWidget {
  const PropertyFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<PropertySearchController>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.tune_rounded, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Filters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    controller.resetFilters();
                  },
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Division ──────────────────────────────────────────────
            _FilterLabel(label: 'Division'),
            const SizedBox(height: 8),
            Obx(() => _DropdownField(
                  value: controller.division.value,
                  hint: 'Select division',
                  items: PropertySearchController.divisions,
                  onChanged: (v) {
                    controller.division.value = v;
                    controller.search();
                  },
                )),
            const SizedBox(height: 20),

            // ── Property Type ─────────────────────────────────────────
            _FilterLabel(label: 'Property Type'),
            const SizedBox(height: 8),
            Obx(() => _DropdownField(
                  value: controller.propertyType.value,
                  hint: 'Select type',
                  items: PropertySearchController.propertyTypes,
                  onChanged: (v) {
                    controller.propertyType.value = v;
                    controller.search();
                  },
                )),
            const SizedBox(height: 20),

            // ── Price Range ──────────────────────────────────────────
            _FilterLabel(label: 'Price Range (৳)'),
            const SizedBox(height: 12),
            Obx(() => _PriceRangeSlider(
                  min: controller.minPrice.value,
                  max: controller.maxPrice.value,
                  onChanged: (start, end) {
                    controller.minPrice.value = start;
                    controller.maxPrice.value = end;
                  },
                  onDragEnded: () => controller.search(),
                )),
            const SizedBox(height: 24),

            // ── Search button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => controller.search(),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Search'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Private helpers
// ═══════════════════════════════════════════════════════════════════════════

class _FilterLabel extends StatelessWidget {
  const _FilterLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final String hint;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item.capitalizeFirst ?? item),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _PriceRangeSlider extends StatelessWidget {
  const _PriceRangeSlider({
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onDragEnded,
  });

  final double min;
  final double max;
  final void Function(double start, double end) onChanged;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return StatefulBuilder(
      builder: (context, setState) {
        RangeValues values = RangeValues(min, max);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '৳${values.start.toInt()}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                Text(
                  '৳${values.end.toInt()}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: values,
              min: 0,
              max: 100000,
              divisions: 100,
              labels: RangeLabels(
                '৳${values.start.toInt()}',
                '৳${values.end.toInt()}',
              ),
              onChanged: (v) {
                setState(() => values = v);
                onChanged(v.start, v.end);
              },
              onChangeEnd: (_) => onDragEnded(),
            ),
          ],
        );
      },
    );
  }
}
