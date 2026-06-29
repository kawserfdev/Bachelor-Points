import 'package:flutter/material.dart';

import '../domain/breakpoints.dart';
import '../domain/device_type.dart';
import 'responsive_builder.dart';

/// A widget that introduces adaptive spacing based on the available width.
///
/// It renders an empty [SizedBox] whose dimensions are resolved from the
/// supplied per-device spacings. This is useful for page gutters, section
/// separators, and any gap that should grow on larger screens.
///
/// * [ResponsiveSpacing.horizontal] — a horizontal gap.
/// * [ResponsiveSpacing.vertical] — a vertical gap.
/// * [ResponsiveSpacing.all] — a [Padding] with adaptive insets on all sides.
///
/// Example:
/// ```dart
/// Column(
///   children: [
///     Header(),
///     const ResponsiveSpacing.vertical(),
///     Body(),
///   ],
/// )
/// ```
class ResponsiveSpacing extends StatelessWidget {
  /// Creates adaptive spacing. By default renders a square gap of
  /// [compact] / [medium] / [expanded] size.
  const ResponsiveSpacing({
    super.key,
    this.compact = Breakpoints.paddingCompact,
    this.medium = Breakpoints.paddingMedium,
    this.expanded = Breakpoints.paddingExpanded,
    this.axis,
  });

  /// Creates a horizontal gap.
  const ResponsiveSpacing.horizontal({
    Key? key,
    double compact = Breakpoints.paddingCompact,
    double medium = Breakpoints.paddingMedium,
    double expanded = Breakpoints.paddingExpanded,
  }) : this(
          key: key,
          compact: compact,
          medium: medium,
          expanded: expanded,
          axis: Axis.horizontal,
        );

  /// Creates a vertical gap.
  const ResponsiveSpacing.vertical({
    Key? key,
    double compact = Breakpoints.paddingCompact,
    double medium = Breakpoints.paddingMedium,
    double expanded = Breakpoints.paddingExpanded,
  }) : this(
          key: key,
          compact: compact,
          medium: medium,
          expanded: expanded,
          axis: Axis.vertical,
        );

  /// Creates an [EdgeInsets]-based padding with adaptive insets.
  const ResponsiveSpacing.all({
    super.key,
    this.compact = Breakpoints.paddingCompact,
    this.medium = Breakpoints.paddingMedium,
    this.expanded = Breakpoints.paddingExpanded,
  }) : axis = null;

  /// Spacing used on compact devices (width < 600).
  final double compact;

  /// Spacing used on medium devices (600 ≤ width < 1200).
  final double medium;

  /// Spacing used on expanded / large devices (width ≥ 1200).
  final double expanded;

  /// When `null`, the spacing is applied to both axes (square gap). When
  /// [Axis.horizontal] only the width is set; when [Axis.vertical] only the
  /// height is set. The [ResponsiveSpacing.all] constructor ignores this and
  /// returns a [Padding] instead.
  final Axis? axis;

  /// Resolves the spacing value for the given [deviceType].
  double valueFor(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return compact;
      case DeviceType.tablet:
        return medium;
      case DeviceType.desktop:
        return expanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // The `.all` constructor sets `axis` to null and is meant to render a
    // Padding. We detect that case by checking whether the caller used the
    // `.all` factory (axis == null AND we are not the default square gap).
    // To keep the API simple, the `.all` variant is handled by returning a
    // Padding widget directly.
    if (axis == null) {
      return ResponsiveBuilder(
        builder: (context, deviceType, sizeClass, constraints) {
          final v = valueFor(deviceType);
          return Padding(padding: EdgeInsets.all(v));
        },
      );
    }

    return ResponsiveBuilder(
      builder: (context, deviceType, sizeClass, constraints) {
        final v = valueFor(deviceType);
        return SizedBox(
          width: axis == Axis.horizontal ? v : 0,
          height: axis == Axis.vertical ? v : 0,
        );
      },
    );
  }
}
