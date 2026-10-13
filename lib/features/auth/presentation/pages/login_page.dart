import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swasthsetu/core/router/app_routes.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/core/theme/app_text_styles.dart';
import 'package:swasthsetu/core/constants/app_constants.dart';
import 'package:swasthsetu/features/auth/bloc/auth_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:swasthsetu/features/sos/presentation/widgets/sos_bottom_sheet.dart';

/// Login screen using Google Sign-In
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthAuthenticated || state is BiometricAvailable) {
          context.go(AppRoutes.home);
        } else if (state is NewUserRegistered) {
          context.go(AppRoutes.patientDetails);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Emergency banner ─────────────────────────────────────────
                  _EmergencyBanner(),
                  const SizedBox(height: 32),
                  
                  // ── Logo ─────────────────────────────────────────────────────
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/logo/logo.png',
                            width: 140,
                            height: 140,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  // ── Animation ────────────────────────────────────────────────
                  Lottie.asset(
                    'assets/animations/Online Doctor.json',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  
                  // ── Headline ─────────────────────────────────────────────────
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Welcome to\n',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: AppConstants.appName,
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // ── Google Sign-In button ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(const SignInWithGoogleEvent());
                            },
                      icon: isLoading
                          ? const SizedBox.shrink()
                          : Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                              height: 24,
                            ),
                      label: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Sign in with Google', style: AppTextStyles.buttonLabel.copyWith(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _EmergencyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const SosBottomSheet(),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.emergency,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone, color: AppColors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              'Dial 24x7 Emergency',
              style: AppTextStyles.emergencyBanner,
            ),
            const Spacer(),
            const Icon(Icons.translate, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
