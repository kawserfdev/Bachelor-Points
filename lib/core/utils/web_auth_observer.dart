/// Observes the existing auth state stream and bridges it to the web layer.
///
/// This is the Observer pattern applied to [AuthService.currentUser] so that
/// the web-specific landing-page integration stays completely decoupled from
/// the auth/routing/business logic. [AuthService] itself is NOT modified.
///
/// Responsibilities:
///   - When the user becomes authenticated → set the web auth flag so the
///     landing page can skip itself on the next root visit.
///   - When the user signs out (transition non-null → null) → clear the flag
///     and navigate to the landing page (web only).
///
/// On non-web platforms [WebAuthBridge] is a no-op, so this observer is
/// effectively inert on mobile — the existing mobile flow is unchanged.
library;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import 'web_auth_bridge.dart';

/// A small, self-contained observer started once during app bootstrap.
///
/// It holds a [Worker] (GetX stream subscription) so it can be disposed if
/// ever needed, though in practice it lives for the app's lifetime.
class WebAuthObserver {
  final AuthService _authService;
  Worker? _worker;

  /// Tracks the previous auth state so we only react to *transitions*,
  /// not the initial value. This prevents an unwanted redirect to the landing
  /// page when the app starts with no signed-in user.
  bool _wasAuthenticated = false;

  WebAuthObserver(this._authService);

  /// Begins listening to [AuthService.currentUser].
  ///
  /// Call once after [AuthService.init] has completed.
  void start() {
    // Seed the initial state so the first emission doesn't look like a logout.
    _wasAuthenticated = _authService.currentUser.value != null;
    // Keep the flag in sync immediately on startup.
    WebAuthBridge.setAuthenticated(_wasAuthenticated);

    _worker = ever<dynamic>(_authService.currentUser, (user) {
      final isAuthenticated = user is User;
      if (isAuthenticated) {
        // User signed in (or was already signed in) → mark as authenticated.
        WebAuthBridge.setAuthenticated(true);
        _wasAuthenticated = true;
      } else {
        // User is null.
        if (_wasAuthenticated) {
          // Transition non-null → null: a real sign-out.
          // Clear the flag and (on web) go to the landing page.
          WebAuthBridge.setAuthenticated(false);
          WebAuthBridge.goToLanding();
        }
        _wasAuthenticated = false;
      }
    });

    if (kDebugMode) {
      debugPrint('WebAuthObserver started (web=$kIsWeb)');
    }
  }

  /// Stops listening. Safe to call multiple times.
  void dispose() {
    _worker?.dispose();
    _worker = null;
  }
}
