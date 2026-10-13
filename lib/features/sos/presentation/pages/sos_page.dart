import 'package:flutter/material.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/core/theme/app_text_styles.dart';

/// Placeholder page for [SOS Emergency].
/// Replace with real implementation when the feature is built.
class SosPage extends StatelessWidget {
  const SosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SOS Emergency')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('SOS Emergency', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Feature coming soon',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
