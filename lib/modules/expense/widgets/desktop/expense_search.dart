import 'package:flutter/material.dart';

import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Desktop-only search field for the Expense module.
///
/// Purely presentational — the query text is reported to the parent via
/// [onChanged], which performs the in-memory filtering. No controller or
/// data-layer interaction happens here.
class ExpenseSearch extends StatelessWidget {
  /// Current query text (controlled).
  final String query;

  /// Called whenever the query changes.
  final ValueChanged<String> onChanged;

  const ExpenseSearch({
    super.key,
    required this.query,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextField(
      controller: TextEditingController(text: query)..selection =
          TextSelection.collapsed(offset: query.length),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: local.expenseSearchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                tooltip: local.expenseSearchTitle,
                onPressed: () => onChanged(''),
              )
            : null,
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
