import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../data/models/notification_model.dart';
import '../data/notification_repository.dart';
import '../domain/notification_preferences.dart';

/// StreamProvider exposing the user's notifications in real-time.
final notificationsStreamProvider =
    StreamProvider.autoDispose<List<NotificationModel>>((ref) {
      final userAsync = ref.watch(authUserStreamProvider);
      final user = userAsync.asData?.value;
      if (user == null) {
        return const Stream.empty();
      }

      final repo = ref.watch(notificationRepositoryProvider);
      return repo.getNotificationsStream(user.uid);
    });

/// Controller class managing notification state modifications (read, delete).
class NotificationController extends AsyncNotifier<void> {
  late final NotificationRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.watch(notificationRepositoryProvider);
  }

  /// Marks a specific notification as read.
  Future<void> markAsRead(String notificationId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.markAsRead(notificationId),
    );
  }

  /// Marks all notifications for the active user as read.
  Future<void> markAllAsRead() async {
    final userAsync = ref.read(authUserStreamProvider);
    final user = userAsync.asData?.value;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.markAllAsRead(user.uid));
  }

  /// Deletes a specific notification.
  Future<void> deleteNotification(String notificationId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.deleteNotification(notificationId),
    );
  }
}

/// Riverpod provider for notification control actions.
final notificationControllerProvider =
    AsyncNotifierProvider.autoDispose<NotificationController, void>(
      NotificationController.new,
    );

/// Controller managing async user notification preferences toggles.
class NotificationPrefsController
    extends AsyncNotifier<NotificationPreferences> {
  late final NotificationRepository _repository;
  String? _userId;

  @override
  FutureOr<NotificationPreferences> build() async {
    _repository = ref.watch(notificationRepositoryProvider);

    final userAsync = ref.watch(authUserStreamProvider);
    final user = userAsync.asData?.value;
    if (user == null) {
      return const NotificationPreferences();
    }

    _userId = user.uid;
    return _repository.getPreferences(user.uid);
  }

  Future<void> toggleMealNotifications(bool value) =>
      _update((p) => p.copyWith(mealNotifications: value));
  Future<void> toggleExpenseNotifications(bool value) =>
      _update((p) => p.copyWith(expenseNotifications: value));
  Future<void> toggleDepositNotifications(bool value) =>
      _update((p) => p.copyWith(depositNotifications: value));
  Future<void> toggleShoppingNotifications(bool value) =>
      _update((p) => p.copyWith(shoppingNotifications: value));
  Future<void> togglePushNotifications(bool value) =>
      _update((p) => p.copyWith(pushNotifications: value));
  Future<void> toggleSound(bool value) =>
      _update((p) => p.copyWith(sound: value));
  Future<void> toggleVibration(bool value) =>
      _update((p) => p.copyWith(vibration: value));

  Future<void> _update(
    NotificationPreferences Function(NotificationPreferences) updateFn,
  ) async {
    if (_userId == null) return;
    final currentData = state.value ?? const NotificationPreferences();
    final newData = updateFn(currentData);

    state = AsyncValue.data(newData);
    await _repository.updatePreferences(_userId!, newData);
  }
}

/// Riverpod provider for active user notification preferences.
final notificationPrefsProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationPrefsController,
      NotificationPreferences
    >(NotificationPrefsController.new);

/// Provider exposing the count of unread notifications in real-time.
final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final notifsAsync = ref.watch(notificationsStreamProvider);
  return notifsAsync.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
