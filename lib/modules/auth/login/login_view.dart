import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/routes/go_router_config.dart';
import '../../../shared/widgets/auth_scaffold.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Login view optimized for LargeScreen Web SaaS and Mobile apps
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.emailRequired;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return AppLocalizations.of(context)!.validEmailRequired;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.passwordRequired;
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(appAuthServiceProvider);
      await authService.signInWithEmail(email: email, password: password);

      if (mounted) {
        context.go(GoRoutes.splash);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(appAuthServiceProvider);
      await authService.signInWithGoogle();

      if (mounted) {
        context.go(GoRoutes.splash);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    return AuthScaffold(
      brandHeadline: 'Welcome Back to Your Mess.',
      brandSubtitle: 'Log in to record today\'s meals, check live bazar costs, and view your current balance.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mobile-only logo header
            if (!isDesktop) ...[
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B3DFF), Color(0xFFA855F7)],
                    ),
                  ),
                  child: const Icon(Icons.layers_rounded, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Form Title & Subtitle
            Text(
              local.welcomeBack,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              textAlign: isDesktop ? TextAlign.start : TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              local.signInToContinue,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
                fontSize: 13,
              ),
              textAlign: isDesktop ? TextAlign.start : TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Email Field
            CustomTextField(
              label: local.email,
              hint: local.enterEmail,
              prefixIcon: Icons.email_outlined,
              controller: _emailController,
              validator: _validateEmail,
            ),
            const SizedBox(height: 14),

            // Password Field
            CustomTextField(
              label: local.password,
              hint: local.enterPassword,
              prefixIcon: Icons.lock_outline,
              controller: _passwordController,
              isPassword: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: 6),

            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(GoRoutes.forgotPassword),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  foregroundColor: cs.primary,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                child: Text(local.forgotPasswordTitle),
              ),
            ),
            const SizedBox(height: 14),

            // Primary Log In Button
            PrimaryButton(
              text: local.loginBtn,
              isLoading: _isLoading,
              onPressed: _login,
            ),
            const SizedBox(height: 16),

            // Divider with 'or'
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    local.or.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF71717A) : const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Google Sign In Button
            OutlinedButton(
              onPressed: _isLoading ? null : _googleSignIn,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: isDark ? const Color(0xFF1B1B26) : Colors.white,
                side: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/google_logo.png',
                    width: 18,
                    height: 18,
                    errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    local.continueWithGoogle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Don't have an account? Sign up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  local.dontHaveAccount,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(GoRoutes.signup),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: Text(
                    local.signUp,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
