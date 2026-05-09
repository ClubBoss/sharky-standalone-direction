import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import '../constants/telemetry_events.dart';
import 'daily_goal_service.dart';
import 'firebase_lite_telemetry_service.dart';
import 'goal_progress_cloud_service.dart';
import 'goal_progress_persistence_service.dart';
import 'goal_sync_service.dart';

/// Facade that coordinates existing goal services and exposes a stable API.
class GoalOrchestrator {
  GoalOrchestrator._();

  static final GoalOrchestrator instance = GoalOrchestrator._();
  static const int defaultTarget = DailyGoalService.defaultTarget;

  static const String _goalId = 'daily_xp_goal';
  static const String _targetKey = 'goal_orchestrator_target';

  final DailyGoalService _dailyGoal = DailyGoalService.instance;
  final GoalProgressPersistenceService _persistence =
      GoalProgressPersistenceService.instance;
  final bool _firebaseReady = Firebase.apps.isNotEmpty;
  late final GoalProgressCloudService _cloud = GoalProgressCloudService(
    firebaseReady: _firebaseReady,
  );
  late final GoalSyncService _sync = GoalSyncService(
    firebaseReady: _firebaseReady,
  );

  /// Exposes the legacy services for callers that still depend on them.
  DailyGoalService get dailyGoalService => _dailyGoal;
  GoalProgressPersistenceService get progressPersistence => _persistence;
  GoalProgressCloudService get cloudService => _cloud;
  GoalSyncService get syncService => _sync;

  Future<void> setDailyGoal(int xpTarget) async {
    final target = xpTarget.clamp(1, 10000);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_targetKey, target);
    await _emitTelemetry('set', target: target);
  }

  Future<GoalProgressSnapshot> getProgress() async {
    await _dailyGoal.init();
    final target = await _currentTarget();
    final progress = _dailyGoal.getTodayProgress();
    return GoalProgressSnapshot(
      target: target,
      progress: progress,
      completed: progress >= target,
    );
  }

  Future<void> incrementProgress(int xp) async {
    await _dailyGoal.increment(xp);
    final progress = _dailyGoal.getTodayProgress();
    await _emitTelemetry(
      'progress',
      target: await _currentTarget(),
      progress: progress,
    );
  }

  Future<void> completeGoal() async {
    final snapshot = await getProgress();
    final remaining = snapshot.remaining;
    if (remaining > 0) {
      await _dailyGoal.increment(remaining);
    }
    await _persistence.markCompleted(_goalId, DateTime.now());
    await _cloud.saveProgress({
      'templateId': _goalId,
      'goal': snapshot.target,
      'progress': snapshot.target,
      'completedAt': DateTime.now().toIso8601String(),
    });
    await _emitTelemetry(
      'complete',
      target: snapshot.target,
      progress: snapshot.target,
    );
  }

  Future<void> reset() async {
    _dailyGoal.resetForTesting();
    await _dailyGoal.init();
    await _emitTelemetry('reset', target: await _currentTarget(), progress: 0);
  }

  Future<int> _currentTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_targetKey) ?? DailyGoalService.defaultTarget;
  }

  Future<void> _emitTelemetry(
    String action, {
    int? target,
    int? progress,
  }) async {
    await FirebaseLiteTelemetryService.instance.logEvent(
      TelemetryEvents.goalOrchestratorUpdated,
      params: {
        'action': action,
        if (target != null) 'target': target,
        if (progress != null) 'progress': progress,
      },
    );
  }
}

class GoalProgressSnapshot {
  GoalProgressSnapshot({
    required this.target,
    required this.progress,
    required this.completed,
  });

  final int target;
  final int progress;
  final bool completed;

  int get remaining => completed ? 0 : target - progress;
}
