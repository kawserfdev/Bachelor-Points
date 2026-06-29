import 'package:flutter/material.dart';

import '../domain/breakpoints.dart';
import 'responsive_builder.dart';

/// A widget that constrains its [child] to a maximum width and centers it
/// horizontally, leaving the surrounding space as gutter.
///
/// This is the standard "phone-width column on desktop" pattern: on mobile
/// the child fills the available width; on tablet/desktop it is centered with
/// a configurable [maxWidth].
///
/// Use [ResponsiveLayout] for single-column content (auth forms, chat
/// threads, detail panes). For two-pane master-detail layouts use
/// [ResponsiveLayout.paned] which allows a larger maximum width.
///
/// Example:
/// ```dart
/// ResponsiveLayout(
///   child: LoginForm(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  /// Creates a centered, max-width-constrained container.
  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.contentMaxWidth,
    this.alignment = Alignment.topCenter,
    this.padding,
  }) : paned = false;

  /// Creates a centered container with the larger maximum width recommended
  /// for two-pane (master-detail) layouts.
  const ResponsiveLayout.paned({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.panedContentMaxWidth,
    this.alignment = Alignment.topCenter,
    this.padding,
  }) : paned = true;

  /// The content to constrain and center.
  final Widget child;

  /// The maximum width the content may occupy. Defaults to
  /// [Breakpoints.contentMaxWidth] (600 dp) for the standard constructor and
  /// [Breakpoints.panedContentMaxWidth] (1200 dp) for [ResponsiveLayout.paned].
  final double maxWidth;

  /// How to align the child vertically within the available space.
  ///
  /// Defaults to [Alignment.topCenter] so content scrolls naturally from the
  /// top. Use [Alignment.center] for vertically-centered content such as
  /// empty states.
  final Alignment alignment;

  /// Optional padding applied *inside* the constrained column. When `null`,
  /// no extra padding is applied (the caller controls padding).
  final EdgeInsets? padding;

  /// Whether this layout was created with [ResponsiveLayout.paned].
  final bool paned;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, sizeClass, constraints) {
        // On mobile the child should fill the available width, so we only
        // constrain when the available width exceeds [maxWidth].
        final available = constraints.maxWidth;
        final shouldConstrain = available.isFinite && available > maxWidth;

        Widget content = shouldConstrain
            ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              )
            : child;

        if (padding != null) {
          content = Padding(padding: padding!, child: content);
        }

        return Align(
          alignment: alignment,
          child: content,
        );
      },
    );
  }
}
