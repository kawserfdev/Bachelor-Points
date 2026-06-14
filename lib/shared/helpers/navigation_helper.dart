import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';

/// Drop-in replacement for GetX contextless navigation and snackbar calls.
/// Uses the global [navigatorKey] from main.dart to resolve context.
class AppNavigation {
  AppNavigation._();

  /// Navigate to [route] (replaces the entire navigation stack).
  /// Equivalent to Get.offAllNamed(route) or GoRouter.go(route).
  static void go(String route) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go(route);
    }
  }

  /// Push [route] onto the navigation stack.
  /// Equivalent to Get.toNamed(route) or GoRouter.push(route).
  static void to(String route) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).push(route);
    }
  }

  /// Pop the current route.
  /// Equivalent to Get.back() or Navigator.pop(context).
  static void back() {
    navigatorKey.currentState?.pop();
  }

  /// Show a snackbar with [title] and [message].
  /// Equivalent to Get.snackbar(title, message).
  /// Deferred to the next frame so the current Scaffold is laid out
  /// (prevents "Floating SnackBar presented off screen" after a pop).
  static void showSnackBar(
    String title,
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor ?? Colors.white,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: (textColor ?? Colors.white).withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }
}