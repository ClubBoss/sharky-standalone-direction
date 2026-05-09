import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/user_goal.dart';
import '../widgets/goal_celebration_banner.dart';
import 'goal_analytics_service.dart';

class GoalToastService {
  static const _progressPrefix = 'goal_toast_progress_';
  static const _lastKey = 'goal_toast_last';
  static const _minInterval = Duration(minutes: 5);
  static const _bannerPrefix = 'goal_completed_banner_';

  void maybeShowToast(UserGoal goal, double newProgress) {
    unawaited(_maybeShowToast(goal, newProgress));
  }

  Future<void> _maybeShowToast(UserGoal goal, double newProgress) async {
    final prefs = await SharedPreferences.getInstance();
    await GoalAnalyticsService.instance.logGoalProgress(goal, newProgress);
    final bannerKey = '$_bannerPrefix${goal.id}';
    final bannerShown = prefs.getBool(bannerKey) ?? false;
    final old = prefs.getDouble('$_progressPrefix${goal.id}') ?? 0.0;
    final now = DateTime.now();
    final lastStr = prefs.getString(_lastKey);
    final last = lastStr != null ? DateTime.tryParse(lastStr) : null;
    final ctx = navigatorKey.currentContext;
    if (!bannerShown && (goal.completed || newProgress >= 100)) {
      if (ctx != null && ctx.mounted) {
        _showCelebrationBanner(ctx, goal);
        unawaited(GoalAnalyticsService.instance.logGoalCompleted(goal));
        await prefs.setBool(bannerKey, true);
      }
    }
    if (newProgress - old < 10) {
      await prefs.setDouble('$_progressPrefix${goal.id}', newProgress);
      return;
    }
    if (last != null && now.difference(last) < _minInterval) {
      await prefs.setDouble('$_progressPrefix${goal.id}', newProgress);
      return;
    }
    if (ctx != null && ctx.mounted) {
      final oldPct = old.toStringAsFixed(0);
      final newPct = newProgress.toStringAsFixed(0);
      final tag = goal.tag ?? goal.title;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('🎯 Прогресс по цели #$tag: $oldPct% → $newPct%'),
        ),
      );
    }
    await prefs.setDouble('$_progressPrefix${goal.id}', newProgress);
    await prefs.setString(_lastKey, now.toIso8601String());
  }

  void _showCelebrationBanner(BuildContext context, UserGoal goal) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearMaterialBanners();
    final widget = GoalCelebrationBanner(
      goal: goal,
      onClose: messenger.hideCurrentMaterialBanner,
    ).build(context);
    if (widget is MaterialBanner) {
      messenger.showMaterialBanner(widget);
    } else {
      messenger.showMaterialBanner(
        MaterialBanner(
          content: Text('🎉 Цель ${goal.title} достигнута!'),
          actions: [
            TextButton(
              onPressed: messenger.hideCurrentMaterialBanner,
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    }
    Future.delayed(
      const Duration(seconds: 5),
      messenger.hideCurrentMaterialBanner,
    );
  }
}
