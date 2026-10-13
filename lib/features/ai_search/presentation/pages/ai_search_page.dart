import 'package:flutter/material.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/core/theme/app_text_styles.dart';

/// Placeholder page for [AI Search].
/// Replace with real implementation when the feature is built.
class AiSearchPage extends StatelessWidget {
  const AiSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Search')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('AI Search', style: AppTextStyles.headlineMedium),
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
