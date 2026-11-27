import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/screens/discovery_screen.dart';
import 'package:anycook/screens/signup_screen.dart';
import 'package:anycook/screens/forgot_password_screen.dart';
import 'package:anycook/theme/app_theme.dart';
import 'package:anycook/widgets/ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToDiscovery() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DiscoveryScreen()),
    );
  }

  void _signIn() {
    context.read<AppState>().loginWithUsername(
          _usernameController.text.trim().isEmpty ? 'User' : _usernameController.text.trim(),
          _passwordController.text,
        );
    _goToDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Welcome back',
      subtitle: 'Sign in with your username.',
      children: [
        AuthField(
          label: 'Username',
          controller: _usernameController,
          hint: 'moonmaiden',
          textInputAction: TextInputAction.next,
        ),
        AuthField(
          label: 'Password',
          controller: _passwordController,
          hint: '••••••••',
          obscure: _obscurePassword,
          onSubmitted: (_) => _signIn(),
          suffix: IconButton(
            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.muted, size: 20),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            ),
            child: const Text('Forgot password?'),
          ),
        ),
        FilledButton(
          onPressed: _signIn,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: const Text('Sign in'),
        ),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('or', style: TextStyle(color: AppColors.muted, fontSize: 13)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        OutlinedButton(
          onPressed: () {
            context.read<AppState>().skipLogin();
            _goToDiscovery();
          },
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: const Text('Continue as guest'),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('New to AnyCook?', style: TextStyle(color: AppColors.muted, fontSize: 14)),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              ),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Split-screen layout for sign in / sign up / forgot password:
/// glowing brand panel on the left (top on phones), form on the right.
class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool showBack;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);

    final brand = GlowBackground(
      base: const Color(0xFFFBF5EE),
      child: Padding(
        padding: EdgeInsets.all(wide ? 40 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Row(
              children: [
                if (showBack)
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                const Logo(),
              ],
            ),
            SizedBox(height: wide ? 0 : 28),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your kitchen, your rules, your recipes.',
                    style: AppTheme.display(size: wide ? 64 : 36, weight: FontWeight.w300, height: 1.03),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Save your appliances, keep your pantry in sync and climb from Taste Tester to Head Chef.',
                    style: TextStyle(fontSize: 16, height: 1.6, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            if (wide)
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Tag(label: 'Taste Tester', bg: AppColors.surface, ink: AppColors.ink, fontSize: 13),
                  Tag(label: 'Home Cook', bg: AppColors.surface, ink: AppColors.ink, fontSize: 13),
                  Tag(label: 'Sous Chef', bg: AppColors.surface, ink: AppColors.ink, fontSize: 13),
                  Tag(label: 'Head Chef', bg: AppColors.ink, ink: Colors.white, fontSize: 13),
                ],
              ),
          ],
        ),
      ),
    );

    final form = Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: wide ? 48 : 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: staggerIn(context, [
              Text(title, style: AppTheme.display(size: 32)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(fontSize: 15, color: AppColors.muted)),
              const SizedBox(height: 24),
              for (final c in children) ...[c, const SizedBox(height: 14)],
            ]),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [Expanded(flex: 11, child: brand), Expanded(flex: 9, child: form)],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [brand, form],
                ),
              ),
      ),
    );
  }
}

/// Label + rounded text field, used on the auth screens.
class AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;

  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix, errorText: errorText),
        ),
      ],
    );
  }
}
