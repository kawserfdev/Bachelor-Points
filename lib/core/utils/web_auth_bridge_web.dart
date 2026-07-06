/// Web implementation of [WebAuthBridge].
///
/// This file is selected by the conditional import in `web_auth_bridge.dart`
/// ONLY when `dart:html` is available (i.e. Flutter Web). It must never be
/// compiled on Android/iOS — the conditional import guarantees that.
///
/// Storage mechanism: `localStorage` with the key `bp_authed`.
/// The landing page reads this same key (see `web-landing_page/app/layout.tsx`)
/// to decide whether to redirect straight to `/app/`.
///
/// To switch to cookies or a secure session later, replace ONLY the bodies of
/// [setAuthenticated] and the private storage helpers below — no other file in
/// the app needs to change.
library;

// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
// `dart:html` is intentionally used here: this file is only compiled on web
// (via conditional import) and provides the simplest localStorage access.
// Migrating to `package:web` + `dart:js_interop` is a future option that
// would only touch this single file.
import 'dart:html' show window, Storage;

/// The localStorage key shared with the static landing page.
///
/// Keep this in sync with the redirect script in
/// `web-landing_page/app/layout.tsx`.
const String _kAuthedKey = 'bp_authed';

/// The landing page URL (domain root).
const String _kLandingUrl = '/';

class WebAuthBridgeImpl {
  /// Writes/clears the auth flag in the browser's `localStorage`.
  ///
  /// Wraps the storage access in try/catch because `localStorage` can throw
  /// (e.g. private browsing mode, quota exceeded). A failure here must never
  /// crash the app — the worst case is the landing page not auto-redirecting,
  /// which is a harmless UX degradation.
  static void setAuthenticated(bool authenticated) {
    try {
      final Storage storage = window.localStorage;
      if (authenticated) {
        storage[_kAuthedKey] = 'true';
      } else {
        storage.remove(_kAuthedKey);
      }
    } catch (_) {
      // Swallow: storage may be unavailable (private mode / disabled).
      // The app continues to work; only the landing auto-redirect is affected.
    }
  }

  /// Performs a full-page navigation to the landing page.
  ///
  /// Using `href` (not `replace`) so the Flutter app URL remains in history —
  /// this lets a logged-out user press Back if they change their mind. The
  /// landing page's own redirect script uses `replace`, so once authenticated
  /// the landing is skipped cleanly.
  static void goToLanding() {
    window.location.href = _kLandingUrl;
  }
}
