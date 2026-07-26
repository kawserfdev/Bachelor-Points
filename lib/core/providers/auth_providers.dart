import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_service.dart';

/// AppAuthService instance provider
final appAuthServiceProvider = Provider<AppAuthService>((ref) {
  return AppAuthService();
});

/// Firebase Auth user stream — the single source of truth for auth state
final authUserStreamProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(appAuthServiceProvider);
  return authService.authStateChanges;
});

/// Current Firebase auth user (sync access to the cached user)
final currentAuthUserProvider = Provider<User?>((ref) {
  final authService = ref.watch(appAuthServiceProvider);
  return authService.currentUser;
});

/// Is the user currently logged in?
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentAuthUserProvider) != null;
});

/// Is the user's email verified?
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentAuthUserProvider);
  return user?.emailVerified ?? false;
});

/// Auth state enum for routing decisions
enum AuthState {
  /// No user signed in
  unauthenticated,

  /// User signed in but email not verified
  emailNotVerified,

  /// User fully authenticated (profile check happens in AuthGate)
  authenticated,
}

/// High-level auth state for routing.
/// Watches the auth stream so GoRouter redirect re-evaluates on every
/// sign-in/sign-out/email-verification change.
final authStateProvider = Provider<AuthState>((ref) {
  final userAsync = ref.watch(authUserStreamProvider);
  final user = userAsync.asData?.value;
  if (user == null) return AuthState.unauthenticated;
  if (!user.emailVerified) return AuthState.emailNotVerified;
  return AuthState.authenticated;
});

/// Whether the current user has a Firestore profile document.
/// Used by GoRouter redirect to route to createProfile if no profile exists.
/// Watches the auth stream so it re-evaluates on sign-in/sign-out.
final hasProfileProvider = StreamProvider<bool>((ref) {
  final userAsync = ref.watch(authUserStreamProvider);
  final user = userAsync.asData?.value;
  if (user == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('profiles')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) => snapshot.exists);
});