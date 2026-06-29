import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/routes/go_router_config.dart';
import '../../../shared/widgets/auth_scaffold.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

/// Login view migrated from GetX to Riverpod + GoRouter
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            Icon(
              Icons.lock_person_rounded,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              local.welcomeBack,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              local.signInToContinue,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
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
              hint: local.enterPassword,
              prefixIcon: Icons.lock_outline,
              controller: _passwordController,
              isPassword: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(GoRoutes.forgotPassword),
                child: Text(local.forgotPasswordTitle),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: local.loginBtn,
              isLoading: _isLoading,
              onPressed: _login,
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
              label:  Text(
                local.continueWithGoogle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).secondaryHeaderColor,
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
                  local.dontHaveAccount,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                TextButton(
                  onPressed: () => context.push(GoRoutes.signup),
                  child: Text(
                    local.signUp,
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
