import 'package:flutter/material.dart';
import '../screens/training_session_screen.dart';

/// Simple model for module information needed to launch review
class ReviewModuleEntry {
  final String moduleId;
  final String title;

  const ReviewModuleEntry({required this.moduleId, required this.title});
}

/// Service to launch review sessions from recommended modules.
///
/// Provides methods to start single-module or multi-module review sessions
/// with proper tagging for analytics and tracking.
///
/// Usage:
/// ```dart
/// // Launch single module review
/// final entry = ReviewModuleEntry(
///   moduleId: 'core_bankroll_management',
///   title: 'Bankroll Management',
/// );
/// await ReviewLauncherService.instance.launchSingle(context, entry);
///
/// // Launch multiple module review
/// await ReviewLauncherService.instance.launchMultiple(context, entries);
/// ```
class ReviewLauncherService {
  static final ReviewLauncherService _instance =
      ReviewLauncherService._internal();
  static ReviewLauncherService get instance => _instance;

  ReviewLauncherService._internal();

  /// Launch a single module review session
  Future<void> launchSingle(
    BuildContext context,
    ReviewModuleEntry entry,
  ) async {
    if (!context.mounted) return;

    try {
      // For now, navigate to TrainingSessionScreen with review tag
      // In the future, this could:
      // - Load module drills
      // - Create custom training pack
      // - Apply review-specific settings
      await Navigator.push(
        context,
        canonicalLegacyTrainingImplicitRouteV1(
          input: CanonicalLegacyTrainingImplicitLaunchInputV1.reviewSingle(
            moduleId: entry.moduleId,
          ),
        ),
      );

      if (!context.mounted) return;

      // Show success snackbar
      final isRu = Localizations.localeOf(context).languageCode == 'ru';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isRu ? 'Повторение началось!' : 'Review started!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      final isRu = Localizations.localeOf(context).languageCode == 'ru';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRu ? 'Ошибка запуска повторения' : 'Failed to start review',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  /// Launch a multi-module review session
  Future<void> launchMultiple(
    BuildContext context,
    List<ReviewModuleEntry> entries,
  ) async {
    if (!context.mounted) return;
    if (entries.isEmpty) return;

    try {
      // Create comma-separated list of module IDs for tracking
      final moduleIds = entries.map((e) => e.moduleId).join(',');

      // For now, navigate to TrainingSessionScreen with review tag
      // In the future, this could:
      // - Load drills from all modules
      // - Create aggregated training pack
      // - Apply spaced repetition scheduling
      await Navigator.push(
        context,
        canonicalLegacyTrainingImplicitRouteV1(
          input: CanonicalLegacyTrainingImplicitLaunchInputV1.reviewMultiple(
            moduleIds: moduleIds,
          ),
        ),
      );

      if (!context.mounted) return;

      // Show success snackbar
      final isRu = Localizations.localeOf(context).languageCode == 'ru';
      final count = entries.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRu
                ? 'Повторение началось! ($count модулей)'
                : 'Review started! ($count modules)',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      final isRu = Localizations.localeOf(context).languageCode == 'ru';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRu ? 'Ошибка запуска повторения' : 'Failed to start review',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  /// Quick launch helper for single module by ID
  Future<void> launchById(
    BuildContext context,
    String moduleId, {
    String? title,
  }) async {
    final entry = ReviewModuleEntry(
      moduleId: moduleId,
      title: title ?? moduleId,
    );
    await launchSingle(context, entry);
  }

  /// Quick launch helper for multiple modules by IDs
  Future<void> launchByIds(BuildContext context, List<String> moduleIds) async {
    final entries = moduleIds
        .map((id) => ReviewModuleEntry(moduleId: id, title: id))
        .toList();
    await launchMultiple(context, entries);
  }
}
