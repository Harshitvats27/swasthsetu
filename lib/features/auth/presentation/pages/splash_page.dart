import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swasthsetu/core/router/app_routes.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/core/theme/app_text_styles.dart';
import 'package:swasthsetu/core/constants/app_constants.dart';
import 'package:swasthsetu/features/auth/bloc/auth_bloc.dart';

/// Splash page — shown briefly at startup while auth state is determined.
/// Navigates to [LoginPage] or [PinPage] based on session.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.login);
        } else if (state is AuthAuthenticated || state is BiometricAvailable) {
          context.go(AppRoutes.home);
        } else if (state is NewUserRegistered) {
          context.go(AppRoutes.patientDetails);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo placeholder — swap with Image.asset when logo is added
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logo/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppConstants.appName,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppConstants.tagline,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withAlpha(200),
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
