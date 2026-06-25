import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/auth_service.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  bool _isResending = false;
  bool _isChecking = false;
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    // Auto-poll every 5 seconds. The moment the user clicks the verification
    // link in their inbox, the next poll will detect it and navigate them
    // forward — no manual button press needed.
    _autoCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkVerificationStatus(silent: true),
    );
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  /// Reload the current user and check if the email has been verified.
  /// When [silent] is true (auto-poll), no snackbar is shown on failure.
  ///
  /// We navigate DIRECTLY to the correct destination instead of relying on
  /// GoRouter redirect, which has a timing race: the redirect may fire before
  /// idTokenChanges() re-emits the updated auth state, causing the user to
  /// bounce back to /verify-email.
  Future<void> _checkVerificationStatus({bool silent = false}) async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Reload fetches the latest emailVerified state from Firebase servers.
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null || !refreshedUser.emailVerified) {
        // Not verified yet — show snackbar only if user pressed button.
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.emailNotVerified),
            ),
          );
        }
        return;
      }

      // ✅ Email is verified — stop polling.
      _autoCheckTimer?.cancel();
      debugPrint('[VerifyEmail] Email verified for ${refreshedUser.uid}');

      // Check whether a profile document already exists in Firestore.
      // We do this directly here so we can navigate to the exact destination
      // without waiting for Riverpod providers to re-evaluate after the
      // idTokenChanges() stream re-emits (which would cause the timing race).
      final profileDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(refreshedUser.uid)
          .get();

      if (!mounted) return;

      if (profileDoc.exists) {
        debugPrint('[VerifyEmail] Profile exists → navigating to home');
        context.go(AppRoutes.home);
      } else {
        debugPrint('[VerifyEmail] No profile → navigating to create-profile');
        context.go(AppRoutes.createProfile);
      }
    } catch (e) {
      debugPrint('[VerifyEmail] Error checking verification: $e');
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  /// Resend the verification email to the current user.
  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.verificationEmailSent),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.emailAlreadyVerified),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Failed to send email'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(local.verifyEmailTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                local.checkYourEmail,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                local.verificationLinkSentDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                local.afterVerifyingDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // "I've verified" button — reloads user and checks emailVerified
              ElevatedButton(
                onPressed: _isChecking ? null : _checkVerificationStatus,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(local.iveVerifiedEmail),
              ),
              const SizedBox(height: 16),

              // Resend verification email
              OutlinedButton.icon(
                onPressed: _isResending ? null : _resendVerificationEmail,
                icon: _isResending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(local.resendVerificationEmail),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Back to login — sign out fully via AuthService to clean up
              // GetStorage, Google session, and GetX controllers.
              TextButton(
                onPressed: () async {
                  await Get.find<AuthService>().signOut();
                  // signOut() already navigates to /login via AppNavigation.go
                },
                child: Text(local.backToLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
