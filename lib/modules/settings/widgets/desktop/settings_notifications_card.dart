import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../../notifications/providers/notification_providers.dart';
import 'settings_card_shell.dart';

/// Desktop-only Notification Preferences settings card.
///
/// Renders the seven notification toggles (meal, expense, deposit, shopping,
/// push, sound, vibration) in a responsive two-column grid of switch tiles.
/// It reads and writes via the existing Riverpod
/// [notificationPrefsProvider] — **no** new business logic is introduced;
/// this is a pure UI redesign of the mobile
/// `_buildNotificationPreferencesCard` expansion tile.
class SettingsNotificationsCard extends ConsumerWidget {
  const SettingsNotificationsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final prefsAsync = ref.watch(notificationPrefsProvider);

    return SettingsCardShell(
      icon: Icons.notifications_active_outlined,
      iconColor: Colors.amber.shade700,
      title: local.settingsNotificationsTitle,
      description: local.settingsNotificationsDesc,
      child: prefsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            local.settingsErrorPreferences(error.toString()),
            style: TextStyle(color: cs.error),
          ),
        ),
        data: (prefs) {
          final controller =
              ref.read(notificationPrefsProvider.notifier);

          final toggles = <_ToggleData>[
            _ToggleData(
              label: local.mealNotifications,
              description: local.mealNotificationsDesc,
              icon: Icons.restaurant_rounded,
              value: prefs.mealNotifications,
              onChanged: controller.toggleMealNotifications,
            ),
            _ToggleData(
              label: local.expenseNotifications,
              description: local.expenseNotificationsDesc,
              icon: Icons.receipt_long_rounded,
              value: prefs.expenseNotifications,
              onChanged: controller.toggleExpenseNotifications,
            ),
            _ToggleData(
              label: local.depositNotifications,
              description: local.depositNotificationsDesc,
              icon: Icons.savings_rounded,
              value: prefs.depositNotifications,
              onChanged: controller.toggleDepositNotifications,
            ),
            _ToggleData(
              label: local.shoppingNotifications,
              description: local.shoppingNotificationsDesc,
              icon: Icons.shopping_cart_rounded,
              value: prefs.shoppingNotifications,
              onChanged: controller.toggleShoppingNotifications,
            ),
            _ToggleData(
              label: local.pushNotifications,
              description: local.pushNotificationsDesc,
              icon: Icons.notifications_rounded,
              value: prefs.pushNotifications,
              onChanged: controller.togglePushNotifications,
            ),
            _ToggleData(
              label: local.notificationSound,
              description: null,
              icon: Icons.volume_up_rounded,
              value: prefs.sound,
              onChanged: controller.toggleSound,
            ),
            _ToggleData(
              label: local.vibration,
              description: null,
              icon: Icons.vibration_rounded,
              value: prefs.vibration,
              onChanged: controller.toggleVibration,
            ),
          ];

          return LayoutBuilder(
            builder: (context, constraints) {
              // Two columns on desktop, one on narrow.
              final columns =
                  (constraints.maxWidth / 320).floor().clamp(1, 2);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: toggles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 12,
                  childAspectRatio: columns == 2 ? 4.2 : 6.5,
                ),
                itemBuilder: (context, index) => _ToggleTile(
                  data: toggles[index],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Data carrier for a single notification toggle.
class _ToggleData {
  final String label;
  final String? description;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleData({
    required this.label,
    required this.description,
    required this.icon,
    required this.value,
    required this.onChanged,
  });
}

/// A single notification switch tile with leading icon.
class _ToggleTile extends StatelessWidget {
  final _ToggleData data;

  const _ToggleTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: cs.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (data.description != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    data.description!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: data.value,
            onChanged: data.onChanged,
          ),
        ],
      ),
    );
  }
}
