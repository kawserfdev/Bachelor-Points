import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

/// AuthGate is the splash screen / route gatekeeper.
/// It listens to the auth stream and redirects the user to:
///   - Login screen if unauthenticated
///   - Verify email screen if email not verified
///   - Home screen if fully authenticated
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state to trigger rebuilds when it changes
    ref.watch(authStateProvider);

    // Show a branded splash screen while determining auth state
    // (the GoRouter redirect handles actual routing — this is the visual)
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/applogo.png", height: 80, ),
            // Icon(
            //   Icons.restaurant_menu_rounded,
            //   size: 80,
            //   color: Theme.of(context).colorScheme.primary,
            // ),
            const SizedBox(height: 24),
            Text(
              'BachelorPoints',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mess Management Simplified',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}