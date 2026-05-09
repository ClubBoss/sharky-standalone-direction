import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

class CoreStartingHandsScreen extends StatelessWidget {
  const CoreStartingHandsScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  final String moduleId;
  final String moduleTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(
          moduleTitle,
          style: AppTypography.h3.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Starting Hands',
                style: AppTypography.h1.copyWith(color: Colors.white),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Coming soon',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Module ID: $moduleId',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
