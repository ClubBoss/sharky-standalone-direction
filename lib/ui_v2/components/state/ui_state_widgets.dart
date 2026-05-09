import 'package:flutter/material.dart';

import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const String kUiStateNoTrainingPacksMessage = 'No training packs found';
const String kUiStateDefaultRetryLabel = 'Retry';

/// Represents a button that appears in the footer of an [UiStateLayout].
class UiStateAction {
  const UiStateAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

class UiStateLayout extends StatelessWidget {
  const UiStateLayout({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.primaryAction,
    this.secondaryAction,
  });

  final Widget? icon;
  final String title;
  final String? subtitle;
  final UiStateAction? primaryAction;
  final UiStateAction? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];
    if (secondaryAction != null) {
      actions.add(_buildActionButton(secondaryAction!, filled: false));
    }
    if (primaryAction != null) {
      actions.add(_buildActionButton(primaryAction!, filled: true));
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(height: 16)],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(UiStateAction action, {required bool filled}) {
    final buttonStyle = filled
        ? ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBrand,
            foregroundColor: Colors.white,
          )
        : OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBrand,
            side: BorderSide(color: AppColors.primaryBrand.withOpacity(0.7)),
          );
    return filled
        ? ElevatedButton(
            onPressed: action.onPressed,
            style: buttonStyle,
            child: Text(action.label),
          )
        : OutlinedButton(
            onPressed: action.onPressed,
            style: buttonStyle,
            child: Text(action.label),
          );
  }
}

class UiLoadingState extends StatelessWidget {
  const UiLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class UiEmptyState extends StatelessWidget {
  const UiEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.primaryAction,
    this.secondaryAction,
  });

  final String title;
  final String? subtitle;
  final Widget? icon;
  final UiStateAction? primaryAction;
  final UiStateAction? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return UiStateLayout(
      icon: icon,
      title: title,
      subtitle: subtitle,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
    );
  }
}

class UiErrorState extends StatelessWidget {
  const UiErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.primaryAction,
    this.secondaryAction,
  });

  final String title;
  final String? subtitle;
  final Widget? icon;
  final UiStateAction? primaryAction;
  final UiStateAction? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return UiStateLayout(
      icon: icon ?? Icon(Icons.error_outline, size: 48, color: AppColors.error),
      title: title,
      subtitle: subtitle,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
    );
  }
}
