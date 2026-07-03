import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/loading_overlay.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authNotifier = ref.read(authStateProvider.notifier);
    await authNotifier.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Show errors via snackbar
    ref.listen(authStateProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ref.read(authStateProvider.notifier).clearError();
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        message: 'Logging in...',
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Title
                  Icon(
                    Icons.admin_panel_settings,
                    size: 64,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'BackOffice',
                    style: AppTypography.display,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    'Management System',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space8),

                  // Email field
                  AppTextField(
                    label: 'Username',
                    hintText: 'Masukkan username',
                    controller: _emailController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.space4),

                  // Password field
                  AppTextField(
                    label: 'Password',
                    hintText: 'Masukkan password',
                    controller: _passwordController,
                    obscureText: true,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  // Login button
                  AppButton(
                    label: 'Login',
                    onPressed: _handleLogin,
                    isLoading: authState.isLoading,
                    isEnabled:
                        _emailController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty &&
                        !authState.isLoading,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
