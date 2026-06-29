import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Desktop search field for the property listing.
///
/// A controlled text field that reports changes via [onChanged] and supports a
/// clear button. Pure presentation — no data mutations.
class PropertySearchBar extends StatelessWidget {
  const PropertySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search by area, title…',
    this.onSubmitted,
  });

  /// The [TextEditingController] backing this field.
  final TextEditingController controller;

  /// Called when the text changes.
  final ValueChanged<String> onChanged;

  /// Called when the user submits the field (Enter key).
  final ValueChanged<String>? onSubmitted;

  /// Placeholder hint text.
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: cs.onSurface.withValues(alpha: 0.4),
          fontSize: 14,
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            );
          },
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),
    );
  }
}
