import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:bachelorpoints/core/responsive/responsive.dart';
import 'package:bachelorpoints/shared/widgets/saas_sidebar.dart';
import 'package:bachelorpoints/modules/mess/mess_controller.dart';

/// Wrapper shell that provides a responsive layout:
/// - Desktop/Tablet: Collapsible/expandable side navigation drawer (SaasSidebar) and no bottom navigation.
/// - Mobile: BottomNavigationBar for the 3 main tabs (Home, Tolet, Profile).
///
/// Used as a [ShellRoute] builder in GoRouter — the [child] parameter
/// is the currently active route's page.
class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key, required this.child});

  /// The child widget provided by GoRouter's ShellRoute
  final Widget child;

  /// Index-to-route mapping for the bottom nav
  static const _tabs = <_TabInfo>[
    _TabInfo(
      index: 0,
      icon: Icons.dining_outlined,
      activeIcon: Icons.dining,
      label: 'Home',
      route: '/home',
    ),
    _TabInfo(
      index: 1,
      icon: Icons.home_work_outlined,
      activeIcon: Icons.home_work,
      label: 'Tolet',
      route: '/tolet',
    ),
    
    _TabInfo(
      index: 2,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = context.deviceType == DeviceType.desktop;
    final isTablet = context.deviceType == DeviceType.tablet;
    final isWide = isDesktop || isTablet;

    // Determine which tab is active by matching the current location
    final location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    for (final tab in _tabs) {
      if (location.startsWith(tab.route)) {
        currentIndex = tab.index;
        break;
      }
    }

    final showBottomNav = !isWide && (
      location == '/home' ||
      location == '/tolet' ||
      location == '/profile'
    );

    if (isWide) {
      final messController = Get.isRegistered<MessController>()
          ? Get.find<MessController>()
          : Get.put(MessController());

      return Obx(() {
        if (messController.isLoading.value) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final mess = messController.activeMess.value;
        if (mess == null) {
          return Scaffold(body: child);
        }

        return Scaffold(
          body: Row(
            children: [
              SaasSidebar(
                messName: mess.name,
                inviteCode: mess.inviteCode,
                extended: isDesktop,
                showToggle: isDesktop,
              ),
              Expanded(child: child),
            ],
          ),
        );
      });
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: showBottomNav
          ? Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withAlpha(77),
                    width: 0.5,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  final dest = _tabs[index].route;
                  // Only navigate if we're not already on that tab
                  if (location != dest) {
                    context.go(dest);
                  }
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: colorScheme.surface,
                selectedItemColor: colorScheme.primary,
                unselectedItemColor: colorScheme.onSurface.withAlpha(128),
                selectedFontSize: 12,
                unselectedFontSize: 12,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
                elevation: 0,
                items: _tabs.map((tab) {
                  final isSelected = currentIndex == tab.index;
                  return BottomNavigationBarItem(
                    icon: Icon(isSelected ? tab.activeIcon : tab.icon),
                    label: tab.label,
                  );
                }).toList(),
              ),
            )
          : null,
    );
  }
}

/// Internal data holder for tab configuration
class _TabInfo {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _TabInfo({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
