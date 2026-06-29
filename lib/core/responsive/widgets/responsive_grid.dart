import 'package:flutter/material.dart';

import '../domain/breakpoints.dart';
import '../domain/device_type.dart';
import 'responsive_builder.dart';

/// A responsive grid that automatically chooses a column count based on the
/// available width, using Material Design 3 window-size classes.
///
/// Internally it uses a [SliverGridDelegateWithMaxCrossAxisExtent] so that
/// items keep a consistent maximum width and the column count adapts fluidly
/// as the viewport changes — rather than snapping only at fixed breakpoints.
/// The [maxCrossAxisExtent] controls the *target* item width; the actual
/// column count is `floor(availableWidth / maxCrossAxisExtent)`.
///
/// Use the [columns] builder when you need explicit per-device column counts
/// instead of the fluid behaviour.
///
/// Example (fluid):
/// ```dart
/// ResponsiveGrid(
///   maxCrossAxisExtent: 300,
///   children: items.map((item) => ItemCard(item: item)).toList(),
/// )
/// ```
///
/// Example (explicit columns):
/// ```dart
/// ResponsiveGrid.builder(
///   maxCrossAxisExtent: 300,
///   columns: (deviceType) => switch (deviceType) {
///     DeviceType.mobile => 1,
///     DeviceType.tablet => 2,
///     DeviceType.desktop => 3,
///   },
///   itemCount: items.length,
///   itemBuilder: (context, index) => ItemCard(item: items[index]),
/// )
/// ```
class ResponsiveGrid extends StatelessWidget {
  /// Creates a responsive grid from an explicit list of children.
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.maxCrossAxisExtent = 300,
    this.mainAxisSpacing = Breakpoints.gridSpacing,
    this.crossAxisSpacing = Breakpoints.gridSpacing,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
    this.columns,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  })  : itemCount = null,
        itemBuilder = null;

  /// Creates a responsive grid that builds items lazily.
  const ResponsiveGrid.builder({
    super.key,
    required this.maxCrossAxisExtent,
    required int this.itemCount,
    required this.itemBuilder,
    this.mainAxisSpacing = Breakpoints.gridSpacing,
    this.crossAxisSpacing = Breakpoints.gridSpacing,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
    this.columns,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  }) : children = null;

  /// The explicit children. Mutually exclusive with [itemBuilder].
  final List<Widget>? children;

  /// The number of items to build when using the builder constructor.
  final int? itemCount;

  /// Builds items lazily when using the builder constructor.
  final Widget Function(BuildContext, int)? itemBuilder;

  /// The maximum width of a single grid item. The column count is derived
  /// from this and the available width.
  final double maxCrossAxisExtent;

  /// Spacing between rows.
  final double mainAxisSpacing;

  /// Spacing between columns.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each item.
  final double childAspectRatio;

  /// The extent of each item along the main axis. When non-null, takes
  /// precedence over [childAspectRatio].
  final double? mainAxisExtent;

  /// Optional override for the column count based on [DeviceType]. When
  /// provided, the grid uses a fixed column count per device class instead of
  /// the fluid [maxCrossAxisExtent] behaviour.
  final int Function(DeviceType deviceType)? columns;

  /// Whether the scroll view should shrink-wrap its contents.
  final bool shrinkWrap;

  /// The scroll physics. Defaults to the platform default when `null`.
  final ScrollPhysics? physics;

  /// Padding around the grid.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, sizeClass, constraints) {
        final delegate = columns != null
            ? SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns!(deviceType),
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
                childAspectRatio: childAspectRatio,
                mainAxisExtent: mainAxisExtent,
              )
            : SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: maxCrossAxisExtent,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
                childAspectRatio: childAspectRatio,
                mainAxisExtent: mainAxisExtent,
              );

        final grid = children != null
            ? GridView(
                gridDelegate: delegate,
                shrinkWrap: shrinkWrap,
                physics: physics,
                padding: padding,
                children: children!,
              )
            : GridView.builder(
                gridDelegate: delegate,
                shrinkWrap: shrinkWrap,
                physics: physics,
                padding: padding,
                itemCount: itemCount,
                itemBuilder: itemBuilder!,
              );

        return grid;
      },
    );
  }
}
