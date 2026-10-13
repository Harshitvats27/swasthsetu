import 'package:flutter/material.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/core/theme/app_text_styles.dart';

import 'package:swasthsetu/features/sos/presentation/widgets/sos_bottom_sheet.dart';

class GlobalEmergencyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlobalEmergencyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      titleSpacing: 16,
      title: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => const SosBottomSheet(),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.emergency,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call, color: AppColors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              'Dial 24x7 Emergency',
              style: AppTextStyles.emergencyBanner.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
          onPressed: () {
            // Chat
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
