import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

import '../../services/auth_service.dart';
import '../../services/fcm_service.dart';
import '../../services/realtime_service.dart';
import '../../services/storage_service.dart';

/// GetStorage box instance (initialized once at startup)
final getStorageProvider = Provider<GetStorage>((ref) {
  return GetStorage();
});

/// StorageService — wraps GetStorage with typed read/write
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// AuthService — wraps Firebase Auth + Google Sign-In business logic
/// Kept as a bridge during GetX → Riverpod migration
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// FCM Service — handles push notification token management
final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

/// Realtime Service — handles Firestore real-time listeners
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService();
});

/// Current active mess ID (set when user enters a mess)
final activeMessIdProvider = Provider<String?>((ref) => null);