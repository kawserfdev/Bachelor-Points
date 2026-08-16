import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../shared/widgets/auth_scaffold.dart';
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
    // Auto-poll every 5 seconds.
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

  Future<void> _checkVerificationStatus({bool silent = false}) async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null || !refreshedUser.emailVerified) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.emailNotVerified),
            ),
          );
        }
        return;
      }

      _autoCheckTimer?.cancel();
      debugPrint('[VerifyEmail] Email verified for ${refreshedUser.uid}');

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return AuthScaffold(
      brandHeadline: 'Verify Your Email Address.',
      brandSubtitle: 'We have sent a verification link to confirm your account security.',
      centered: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: cs.primary.withValues(alpha: 0.25), width: 2),
              ),
              child: Icon(
                Icons.mark_email_unread_rounded,
                size: 40,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            local.checkYourEmail,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          if (currentUserEmail.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                currentUserEmail,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          Text(
            local.verificationLinkSentDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            local.afterVerifyingDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF71717A) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 32),

          // "I've verified" primary action button
          ElevatedButton(
            onPressed: _isChecking ? null : () => _checkVerificationStatus(silent: false),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: cs.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isChecking
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    local.iveVerifiedEmail,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
          ),
          const SizedBox(height: 14),

          // Resend email button
          OutlinedButton.icon(
            onPressed: _isResending ? null : _resendVerificationEmail,
            icon: _isResending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              local.resendVerificationEmail,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Back to login
          TextButton(
            onPressed: () async {
              await Get.find<AuthService>().signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
            ),
            child: Text(
              local.backToLogin,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
