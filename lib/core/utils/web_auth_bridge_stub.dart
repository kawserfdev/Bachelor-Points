/// Non-web stub for [WebAuthBridge].
///
/// This file is selected by the conditional import in `web_auth_bridge.dart`
/// when the `dart:html` library is NOT available (i.e. Android, iOS, desktop).
/// Every method is a no-op so the mobile flow is completely unchanged.
///
/// IMPORTANT: do not import `dart:html` or `dart:js_interop` here — this file
/// must compile on every platform.
class WebAuthBridgeImpl {
  /// No-op on non-web platforms.
  static void setAuthenticated(bool authenticated) {
    // Intentionally empty: the landing page only exists on web.
  }

  /// No-op on non-web platforms.
  ///
  /// Callers on mobile are expected to use the normal GetX navigation
  /// (e.g. `Get.offAllNamed(AppRoutes.login)`) instead.
  static void goToLanding() {
    // Intentionally empty.
  }
}
