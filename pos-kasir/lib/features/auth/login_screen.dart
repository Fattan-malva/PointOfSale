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
  late FocusNode _emailFocus;
  late FocusNode _passwordFocus;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final authNotifier = ref.read(authStateProvider.notifier);
    authNotifier.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Show error if present
    if (authState.error != null && authState.error!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authStateProvider.notifier).clearError();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        message: 'Logging in...',
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Title
                  Text(
                    'POS Kasir',
                    style: AppTypography.display,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    'Login untuk melanjutkan',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space8),

                  // Email field
                  AppTextField(
                    label: 'Email',
                    hintText: 'Masukkan email Anda',
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: AppSpacing.space4),

                  // Password field
                  AppTextField(
                    label: 'Password',
                    hintText: 'Masukkan password Anda',
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: true,
                    onChanged: (_) {
                      setState(() {});
                    },
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
                  const SizedBox(height: AppSpacing.space4),

                  // Demo credentials hint
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space3),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Demo Credentials (for testing)',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space1),
                        Text(
                          'Email: admin@posapp.com\nPassword: admin123',
                          style: AppTypography.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
