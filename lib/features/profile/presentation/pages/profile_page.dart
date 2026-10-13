import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swasthsetu/core/router/app_routes.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/core/theme/app_text_styles.dart';
import 'package:swasthsetu/features/auth/bloc/auth_bloc.dart';
import 'package:swasthsetu/features/profile/bloc/profile_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      String? uid;
      if (authState is AuthAuthenticated) uid = authState.userId;
      if (authState is NewUserRegistered) uid = authState.userId;
      
      if (uid != null) {
        context.read<ProfileBloc>().add(LoadProfileEvent(uid: uid));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Light bluish background like image
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.medical_services, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'aadhar\nHEALTH INSTITUTE',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          String name = 'Loading...';
          String ageGender = '';

          if (state is ProfileLoaded) {
            name = state.user.name ?? 'Guest User';
            final age = state.user.age?.toString() ?? '--';
            final gender = state.user.gender ?? '--';
            ageGender = 'Age $age | Gender: $gender';
          } else if (state is ProfileSaved) {
            name = state.user.name ?? 'Guest User';
            final age = state.user.age?.toString() ?? '--';
            final gender = state.user.gender ?? '--';
            ageGender = 'Age $age | Gender: $gender';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                // Top Profile Card
                GestureDetector(
                  onTap: () {
                    context.push(AppRoutes.patientDetails);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7A8BBD), // Blueish tint from image
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (ageGender.isNotEmpty)
                                Text(
                                  ageGender,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Actions Card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAction(Icons.person_outline, 'Profile', () {
                        context.push(AppRoutes.patientDetails);
                      }),
                      _buildQuickAction(Icons.upload_file, 'Upload Document', () {}),
                      _buildQuickAction(Icons.account_balance_wallet, 'My Wallet', () {}),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // List Items
                _buildListItem(Icons.g_translate, 'Select Language', trailing: const Icon(Icons.chevron_right)),
                _buildListItem(Icons.feedback_outlined, 'Feedback', trailing: const Icon(Icons.chevron_right)),
                _buildListItem(Icons.fingerprint, 'Enable Biometric', trailing: Switch(value: true, onChanged: (v) {}, activeColor: Colors.teal)),
                _buildListItem(Icons.directions_walk, 'Steps Counter', trailing: const Icon(Icons.chevron_right)),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.teal[300],
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.group, color: Colors.white),
                              SizedBox(width: 8),
                              Text('About Us', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.read<AuthBloc>().add(LogoutEvent());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7A8BBD),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.power_settings_new, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF7A8BBD), size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String label, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF7A8BBD)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing,
        onTap: trailing is Switch ? null : () {},
      ),
    );
  }
}
