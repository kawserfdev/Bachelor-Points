import 'package:flutter/material.dart';

import 'package:bachelorpoints/l10n/app_localizations.dart';
import 'settings_card_shell.dart';

/// Desktop-only Subscription settings card.
///
/// Displays the user's current plan (Free Plan — Active) with a feature
/// summary and a "Manage Plan" button. This is a **presentation-only** card
/// with no backing controller logic; it reuses the existing localization keys
/// and is ready to be wired to a billing service in the future.
class SettingsSubscriptionCard extends StatelessWidget {
  const SettingsSubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SettingsCardShell(
      icon: Icons.workspace_premium_rounded,
      iconColor: Colors.deepPurple,
      title: local.settingsSubscriptionTitle,
      description: local.settingsSubscriptionDesc,
      actions: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.green.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                local.settingsSubscriptionActive,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.withValues(alpha: 0.08),
              cs.primaryContainer.withValues(alpha: 0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.deepPurple.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.deepPurple.shade300,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        local.settingsSubscriptionFreePlan,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        local.settingsSubscriptionFeatures,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  // Placeholder — no billing service exists yet.
                },
                icon: const Icon(Icons.manage_accounts_rounded),
                label: Text(local.settingsSubscriptionManage),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
