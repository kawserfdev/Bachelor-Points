import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';

/// A responsive wrapper for authentication screens.
///
/// Provides a single, consistent layout shell for all auth flows (login,
/// signup, forgot password, verify email, create profile) that adapts to the
/// available width:
///
/// * **Mobile** — renders the form content exactly as before: a full-width
///   scrollable column inside [SafeArea]. The existing mobile UI is preserved
///   byte-for-byte.
/// * **Tablet** — centres the content with a constrained max width inside a
///   lightly elevated [Card].
/// * **Desktop** — centres a polished, elevated [Card] with a responsive max
///   width over a subtle brand-tinted gradient background.
///
/// This widget only controls layout chrome. It does **not** touch any
/// authentication logic, Firebase calls, controllers, validators, or form
/// keys — those remain entirely in the owning view.
class AuthScaffold extends StatelessWidget {
  /// The form / body content (typically a [Form] wrapping a [Column] of
  /// fields, or a plain [Column] for non-form screens like verify-email).
  final Widget child;

  /// Optional app bar (e.g. a transparent bar with a back button).
  ///
  /// When `null`, no app bar is shown (used by the login screen which is the
  /// entry point of the auth flow).
  final PreferredSizeWidget? appBar;

  /// Padding applied to the scrollable content on mobile widths.
  ///
  /// Defaults to `EdgeInsets.all(24)` which matches the majority of the
  /// existing auth screens.
  final EdgeInsets mobilePadding;

  /// When `true`, the content is centred vertically (no scroll view) instead
  /// of top-aligned and scrollable.
  ///
  /// Used by the verify-email screen whose content is short and should sit in
  /// the vertical centre of the available space.
  final bool centered;

  /// Maximum width of the centred card on tablet / desktop.
  final double maxWidth;

  const AuthScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.mobilePadding = const EdgeInsets.all(24),
    this.centered = false,
    this.maxWidth = 460,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;
    final isDesktop = deviceType == DeviceType.desktop;
    final isTablet = deviceType == DeviceType.tablet;
    final isLargeScreen = isDesktop || isTablet;

    // ── Mobile: preserve the existing layout exactly ──
    if (!isLargeScreen) {
      return Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: centered
              ? Center(
                  child: Padding(
                    padding: mobilePadding,
                    child: child,
                  ),
                )
              : SingleChildScrollView(
                  padding: mobilePadding,
                  child: child,
                ),
        ),
      );
    }

    // ── Tablet / Desktop: centred card over a subtle gradient ──
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface,
              cs.primary.withValues(alpha: isDesktop ? 0.06 : 0.04),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 32 : 24),
              child: Card(
                elevation: isDesktop ? 12 : 6,
                shadowColor: cs.primary.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(isDesktop ? 28 : 24),
                ),
                child: SafeArea(
                  child: centered
                      ? Padding(
                          padding: EdgeInsets.all(isDesktop ? 40 : 32),
                          child: child,
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(isDesktop ? 40 : 32),
                          child: child,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
