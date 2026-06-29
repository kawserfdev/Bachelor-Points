import 'package:bachelorpoints/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/routes/go_router_config.dart';
import '../../../shared/widgets/auth_scaffold.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

/// Signup view migrated from GetX to Riverpod + GoRouter
class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.nameRequired;
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.emailRequired;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return AppLocalizations.of(context)!.validEmailRequired;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.passwordRequired;
    if (value.length < 6) return AppLocalizations.of(context)!.passwordLengthError;
    return null;
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(appAuthServiceProvider);
      await authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: name,
      );

      if (mounted) {
        context.go(GoRoutes.verifyEmail);
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

      // Navigate to splash to trigger the GoRouter redirect,
      // which checks auth state + profile and routes accordingly.
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
    return AuthScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      mobilePadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              local.createAccount,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              local.signUpToGetStarted,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            CustomTextField(
              label: local.fullName,
              hint: local.enterFullName,
              prefixIcon: Icons.person_outline,
              controller: _nameController,
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: local.email,
              hint: local.enterEmail,
              prefixIcon: Icons.email_outlined,
              controller: _emailController,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: local.password,
              hint: local.createPassword,
              prefixIcon: Icons.lock_outline,
              controller: _passwordController,
              isPassword: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              text: local.signUp,
              isLoading: _isLoading,
              onPressed: _signup,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    local.or,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _googleSignIn,
              icon: Image.asset(
                'assets/google_logo.png',
                width: 22,
                height: 22,
              ),
              label: Text(
                local.continueWithGoogle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.grey),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  local.alreadyHaveAccount,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    local.loginLink,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
