import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swasthsetu/core/router/app_routes.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/core/theme/app_text_styles.dart';
import 'package:swasthsetu/core/constants/app_constants.dart';
import 'package:swasthsetu/features/auth/bloc/auth_bloc.dart';

/// 4-digit PIN entry / biometric login screen — matches the Aadhar Health
/// "Login with Fingerprint  OR  Enter Your 4 digit Login PIN" screen.
class PinPage extends StatefulWidget {
  const PinPage({super.key});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  final List<TextEditingController> _controllers =
      List.generate(AppConstants.pinLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(AppConstants.pinLength, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
      _triggerBiometric();
    });
  }

  void _triggerBiometric() {
    final state = context.read<AuthBloc>().state;
    if (state is SessionRestored) {
      context.read<AuthBloc>().add(BiometricCheckEvent(uid: state.uid));
    } else if (state is AuthAuthenticated) {
      context.read<AuthBloc>().add(BiometricCheckEvent(uid: state.userId));
    }
  }

  void _onLogin() {
    final pin = _controllers.map((c) => c.text).join();
    if (pin.length < AppConstants.pinLength) return;
    // For now, PIN is bypassed to home if they enter 4 digits.
    // Real implementation would verify PIN with secure storage.
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is BiometricAvailable) {
          context.go(AppRoutes.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
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
                children: [
                  // Emergency banner
                  _EmergencyBanner(),
                  const SizedBox(height: 32),

                  // Logo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.iconBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: AppColors.primary,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Fingerprint headline
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    )
                  else
                    GestureDetector(
                      onTap: _triggerBiometric,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Login with Fingerprint',
                            style: AppTextStyles.headlineSmall,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.fingerprint,
                              size: 28, color: AppColors.textPrimary),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'or',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter Your ${AppConstants.pinLength} digit Login PIN',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 24),

              // PIN boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(AppConstants.pinLength, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: 60,
                      height: 64,
                      child: TextFormField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        obscureText: true,
                        style: AppTextStyles.pinDigit,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (v) {
                          if (v.isNotEmpty && i < AppConstants.pinLength - 1) {
                            _focusNodes[i + 1].requestFocus();
                          } else if (v.isEmpty && i > 0) {
                            _focusNodes[i - 1].requestFocus();
                          }
                          // Auto-submit when all 4 entered
                          if (i == AppConstants.pinLength - 1 && v.isNotEmpty) {
                            _onLogin();
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Not you / Forgot PIN row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const LogoutEvent());
                      context.go(AppRoutes.login);
                    },
                    child: Text(
                      'Not You ?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: forgot-pin flow
                    },
                    child: Text('Forgot Login PIN ?', style: AppTextStyles.link),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    },
    );
  }
}

class _EmergencyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
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
          Text('Dial 24x7 Emergency',
              style: AppTextStyles.emergencyBanner),
          const Spacer(),
          const Icon(Icons.translate, color: AppColors.accent),
        ],
      ),
    );
  }
}
