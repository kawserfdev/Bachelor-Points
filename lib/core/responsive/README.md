# Responsive Core

A self-contained, Clean Architecture module providing reusable responsive
utilities for **Flutter Mobile, Tablet, Desktop, and Web**.

It depends **only** on Flutter / Material 3. It does **not** touch business
logic, Firebase, Riverpod, or GoRouter — so it can be adopted incrementally
without modifying any existing screen.

## Structure

```
lib/core/responsive/
├── responsive.dart            ← barrel export (import this)
├── domain/
│   ├── breakpoints.dart       ← Material 3 width constants
│   ├── device_type.dart       ← mobile / tablet / desktop enum
│   └── window_size_class.dart ← compact / medium / expanded / large / extraLarge enum
├── utils/
│   └── responsive_extensions.dart ← BuildContext & double extensions
└── widgets/
    ├── responsive_builder.dart  ← foundational LayoutBuilder wrapper
    ├── responsive_layout.dart  ← centered max-width column
    ├── responsive_grid.dart    ← fluid / fixed-column grid
    ├── responsive_spacing.dart ← adaptive SizedBox / Padding
    └── responsive_scaffold.dart ← NavigationBar ↔ NavigationRail shell
```

## Breakpoints (Material 3)

| Class      | Width range   | DeviceType |
|------------|---------------|------------|
| compact    | 0 – 599       | mobile     |
| medium     | 600 – 839     | tablet     |
| expanded    | 840 – 1199    | tablet     |
| large      | 1200 – 1599   | desktop    |
| extraLarge | 1600+         | desktop    |

## Usage

### 1. Branch on device type

```dart
import 'package:bachelorpoints/core/responsive/responsive.dart';

ResponsiveBuilder(
  builder: (context, deviceType, sizeClass, constraints) {
    return switch (deviceType) {
      DeviceType.mobile  => const MobileLayout(),
      DeviceType.tablet  => const TabletLayout(),
      DeviceType.desktop => const DesktopLayout(),
    };
  },
)
```

### 2. Center a single-column screen

```dart
ResponsiveLayout(child: AuthForm())
```

### 3. Adaptive grid

```dart
ResponsiveGrid(
  maxCrossAxisExtent: 300,
  children: items.map((i) => ItemCard(item: i)).toList(),
)
```

### 4. Context extensions

```dart
final padding  = context.responsivePadding;        // 16 / 24 / 32
final isWide   = context.isWide;                    // tablet || desktop
final columns  = context.responsiveGridColumns;    // 1..5
final useRail  = context.shouldUseNavigationRail;   // width ≥ 600
```

### 5. Adaptive navigation shell (GoRouter-compatible)

```dart
ShellRoute(
  builder: (context, state, child) => ResponsiveScaffold(
    destinations: [
      ResponsiveDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      ResponsiveDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Report'),
    ],
    selectedIndex: _indexForRoute(state),
    onDestinationSelected: (i) => context.go(_routeForIndex(i)),
    body: child,
  ),
)
```

## Design principles

1. **No side effects** — the module never reads or writes app state.
2. **Navigation-framework agnostic** — `ResponsiveScaffold` takes a callback,
   so it works with GoRouter, Navigator 1.0, or any custom controller.
3. **Constraint-based** — widgets use `LayoutBuilder`, not `MediaQuery`, so
   they behave correctly inside nested layouts, split views, and dialogs.
4. **Material 3** — uses `NavigationBar`, `NavigationRail`, `Badge`, and the
   M3 window-size classes.
5. **Incremental adoption** — import the barrel file and use any widget; no
   existing screen needs to change.
