/// Platform abstraction for web-specific auth/landing integration.
///
/// This is the single seam between the Flutter app and the static landing page.
/// It is responsible for:
///   - marking the user as authenticated so the landing page can skip itself,
///   - navigating back to the landing page on logout.
///
/// On non-web platforms (Android/iOS) every method is a no-op, so the existing
/// mobile flow is completely unaffected.
///
/// The storage mechanism (currently `localStorage`) is encapsulated here so it
/// can later be swapped for cookies or a secure session without changing any
/// other part of the Flutter codebase (SOLID / dependency inversion).
library;

import 'web_auth_bridge_stub.dart'
    if (dart.library.html) 'web_auth_bridge_web.dart';

/// Public API used by the rest of the app.
///
/// Never instantiate this directly in business logic — obtain it via
/// dependency injection or call the static helpers. Keeping it as an abstract
/// class makes it trivial to mock in tests.
abstract class WebAuthBridge {
  /// Marks the current browser session as authenticated (or not).
  ///
  /// On web this writes the flag the landing page reads to decide whether to
  /// redirect to `/app/`. On mobile this does nothing.
  static void setAuthenticated(bool authenticated) =>
      WebAuthBridgeImpl.setAuthenticated(authenticated);

  /// Navigates the browser to the landing page at the domain root (`/`).
  ///
  /// On web this performs a full-page navigation so the Flutter app is
  /// unloaded and the static landing page is served. On mobile this does
  /// nothing — the caller is expected to use the normal GetX navigation.
  static void goToLanding() => WebAuthBridgeImpl.goToLanding();
}
