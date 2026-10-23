import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swasthsetu/core/router/app_routes.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/core/theme/app_text_styles.dart';
import 'package:swasthsetu/core/widgets/global_emergency_appbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swasthsetu/features/sos/bloc/sos_bloc.dart';

/// Persistent bottom-navigation scaffold that wraps all shell routes.
/// 5 tabs: Home | Schedule | Hospitals | Doctors | Profile
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: AppRoutes.home,
    ),
    _NavItem(
      label: 'Schedule',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      route: AppRoutes.appointments,
    ),
    _NavItem(
      label: 'Hospitals',
      icon: Icons.local_hospital_outlined,
      activeIcon: Icons.local_hospital,
      route: AppRoutes.hospitals,
    ),
    _NavItem(
      label: 'Doctors',
      icon: Icons.medical_services_outlined,
      activeIcon: Icons.medical_services,
      route: AppRoutes.doctors,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: AppRoutes.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _selectedIndex(location);

    return BlocListener<SosBloc, SosState>(
      listener: (context, state) {
        if (state is SosCountdown) {
          if (state.secondsLeft == 5) {
            // First tick, show dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) {
                return BlocBuilder<SosBloc, SosState>(
                  builder: (context, sosState) {
                    if (sosState is SosCountdown) {
                      return AlertDialog(
                        backgroundColor: AppColors.emergency.withValues(alpha: 0.9),
                        title: const Text('SOS Triggered!', style: TextStyle(color: Colors.white)),
                        content: Text(
                          'Sending emergency alerts in ${sosState.secondsLeft} seconds...',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              context.read<SosBloc>().add(CancelSosEmergency());
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('CANCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        ],
                      );
                    } else if (sosState is SosTriggered) {
                      // Close automatically once triggered
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (Navigator.canPop(ctx)) {
                           Navigator.of(ctx).pop();
                        }
                      });
                      return const SizedBox.shrink();
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            );
          }
        } else if (state is SosError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SOS Error: ${state.message}')));
        } else if (state is SosTriggered) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SOS Sent successfully!')));
        }
      },
      child: Scaffold(
        appBar: const GlobalEmergencyAppBar(),
        body: child,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final isSelected = i == selectedIndex;

                // Hospitals tab (index 2) gets the animated pill treatment
                if (i == 2) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => context.go(item.route),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? item.activeIcon : item.icon,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.bottomNavUnselected,
                                size: 20,
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    item.label,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: InkWell(
                    onTap: () => context.go(item.route),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.bottomNavUnselected,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.bottomNavUnselected,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      ),
    );
  }

  int _selectedIndex(String location) {
    if (location.startsWith(AppRoutes.appointments)) return 1;
    if (location.startsWith(AppRoutes.hospitals)) return 2;
    if (location.startsWith(AppRoutes.doctors)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}
