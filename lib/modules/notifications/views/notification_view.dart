import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../../shared/helpers/navigation_helper.dart';
import '../../../data/models/notification_model.dart';
import '../providers/notification_providers.dart';

enum NotificationFilter { all, unread, read }

class NotificationView extends ConsumerStatefulWidget {
  const NotificationView({super.key});

  @override
  ConsumerState<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends ConsumerState<NotificationView> {
  NotificationFilter _selectedFilter = NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: l10n.markAllAsReadTooltip,
            onPressed: () {
              ref
                  .read(notificationControllerProvider.notifier)
                  .markAllAsRead()
                  .then((_) {
                    AppNavigation.showSnackBar(
                      l10n.notificationsTitle,
                      l10n.allMarkedAsRead,
                    );
                  });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Selector (Material 3 SegmentedButton)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<NotificationFilter>(
                segments: <ButtonSegment<NotificationFilter>>[
                  ButtonSegment<NotificationFilter>(
                    value: NotificationFilter.all,
                    label: Text(l10n.notifFilterAll),
                    icon: const Icon(Icons.clear_all_rounded),
                  ),
                  ButtonSegment<NotificationFilter>(
                    value: NotificationFilter.unread,
                    label: Text(l10n.notifFilterUnread),
                    icon: const Icon(Icons.mark_email_unread_rounded),
                  ),
                  ButtonSegment<NotificationFilter>(
                    value: NotificationFilter.read,
                    label: Text(l10n.notifFilterRead),
                    icon: const Icon(Icons.mark_email_read_rounded),
                  ),
                ],
                selected: <NotificationFilter>{_selectedFilter},
                onSelectionChanged: (Set<NotificationFilter> newSelection) {
                  setState(() {
                    _selectedFilter = newSelection.first;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Notification List
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    l10n.notifErrorLoading(err.toString()),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              data: (list) {
                // Apply filters locally
                final filteredList = list.where((notif) {
                  switch (_selectedFilter) {
                    case NotificationFilter.unread:
                      return !notif.isRead;
                    case NotificationFilter.read:
                      return notif.isRead;
                    case NotificationFilter.all:
                      return true;
                  }
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noNotificationsFound,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final notif = filteredList[index];
                    final isRead = notif.isRead;

                    return Dismissible(
                      key: Key('notif_${notif.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        color: colorScheme.error,
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        ref
                            .read(notificationControllerProvider.notifier)
                            .deleteNotification(notif.id);
                        AppNavigation.showSnackBar(
                          l10n.notificationsTitle,
                          l10n.notifDeleted,
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        color: isRead
                            ? colorScheme.surface
                            : colorScheme.primaryContainer.withValues(
                                alpha: 0.15,
                              ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isRead
                                ? colorScheme.outlineVariant.withValues(
                                    alpha: 0.3,
                                  )
                                : colorScheme.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (!isRead) {
                              ref
                                  .read(notificationControllerProvider.notifier)
                                  .markAsRead(notif.id);
                            }
                            _showNotificationDetails(context, notif);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 16.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Leading icon based on read state
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    isRead
                                        ? Icons.notifications_none_rounded
                                        : Icons.notifications_active_rounded,
                                    color: isRead
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Title, Body, Timestamp
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notif.title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: isRead
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                              color: isRead
                                                  ? colorScheme.onSurface
                                                  : colorScheme.primary,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif.body,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        notif.createdAt
                                            .toLocal()
                                            .toString()
                                            .split('.')[0],
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withValues(alpha: 0.6),
                                              fontSize: 11,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Unread Dot Indicator
                                if (!isRead)
                                  Container(
                                    margin: const EdgeInsets.only(
                                      top: 8,
                                      left: 8,
                                    ),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(BuildContext context, NotificationModel notif) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        IconData iconData = Icons.notifications_rounded;
        Color iconColor = colorScheme.primary;
        String actionLabel = l10n.notifActionGoToPage;

        if (notif.type == 'meal') {
          iconData = Icons.restaurant_rounded;
          iconColor = Colors.orangeAccent;
          actionLabel = l10n.notifActionViewMeals;
        } else if (notif.type == 'expense') {
          iconData = Icons.account_balance_wallet_rounded;
          iconColor = Colors.redAccent;
          actionLabel = l10n.notifActionViewRequest;
        } else if (notif.type == 'deposit') {
          iconData = Icons.monetization_on_rounded;
          iconColor = Colors.green;
          actionLabel = l10n.notifActionViewRequest;
        } else if (notif.type == 'manager') {
          iconData = Icons.supervised_user_circle_rounded;
          iconColor = Colors.purpleAccent;
          actionLabel = l10n.notifActionGoToSettings;
        } else if (notif.type == 'request_status') {
          iconData = Icons.info_outline_rounded;
          iconColor = Colors.blueAccent;
          actionLabel = l10n.notifActionViewRequest;
        }

        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet handle
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title row with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif.createdAt.toLocal().toString().split('.')[0],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Divider
              Divider(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                height: 1,
              ),
              const SizedBox(height: 20),

              // Body content
              Text(
                notif.body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.notifCloseBtn),
                    ),
                  ),
                  if (notif.route != null && notif.route!.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          AppNavigation.to(notif.route!);
                        },
                        child: Text(actionLabel),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
