import 'package:flutter/material.dart';

import '../domain/device_type.dart';
import '../domain/window_size_class.dart';

/// A builder that receives the resolved responsive metadata for the current
/// layout constraints.
typedef ResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  DeviceType deviceType,
  WindowSizeClass windowSizeClass,
  BoxConstraints constraints,
);

/// The foundational responsive widget.
///
/// [ResponsiveBuilder] wraps a [LayoutBuilder] and resolves the incoming
/// [BoxConstraints] into a [DeviceType] and [WindowSizeClass], then hands
/// them to the [builder]. This is the lowest-level building block of the
/// responsive core — every other responsive widget is built on top of it.
///
/// Prefer this widget when you need direct access to the constraints or when
/// you want to branch on [DeviceType] / [WindowSizeClass] without pulling in
/// [MediaQuery] (which reflects the *screen* size, not the available layout
/// box — important for nested layouts, split views, and dialogs).
///
/// Example:
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, deviceType, sizeClass, constraints) {
///     final columns = switch (deviceType) {
///       DeviceType.mobile => 1,
///       DeviceType.tablet => 2,
///       DeviceType.desktop => 3,
///     };
///     return GridView.count(crossAxisCount: columns, ...);
///   },
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  /// Creates a responsive builder.
  const ResponsiveBuilder({super.key, required this.builder});

  /// Called every time the layout constraints change.
  final ResponsiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the constraint maxWidth when it is finite, otherwise fall back
        // to the screen width from MediaQuery. This keeps the widget usable
        // inside unconstrained scroll views.
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final deviceType = DeviceType.fromWidth(width);
        final sizeClass = WindowSizeClass.fromWidth(width);

        return builder(context, deviceType, sizeClass, constraints);
      },
    );
  }
}
