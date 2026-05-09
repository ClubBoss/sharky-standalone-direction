import 'package:flutter/foundation.dart';
import '../models/internal_goal.dart';

/// Service to track and update internal player goals.
/// In-memory only, no persistence. Goals reset on app restart.
class InternalGoalsService {
  /// Singleton instance for app-wide access.
  static final InternalGoalsService instance = InternalGoalsService._();

  InternalGoalsService._() {
    _initializeGoals();
  }

  /// Notifier for active goals (max 3 displayed).
  final ValueNotifier<List<InternalGoal>> goalsNotifier =
      ValueNotifier<List<InternalGoal>>([]);

  final Map<String, InternalGoal> _goals = {};

  /// Initialize hardcoded example goals.
  void _initializeGoals() {
    _goals.clear();

    // Goal 1: Earn 50 XP today
    _goals['daily_xp_50'] = const InternalGoal(
      id: 'daily_xp_50',
      titleEn: 'Earn 50 XP today',
      titleRu: 'Заработай 50 XP сегодня',
      progress: 0,
      target: 50,
      completed: false,
      type: InternalGoalType.xp,
    );

    // Goal 2: Complete 5 drills
    _goals['drills_5'] = const InternalGoal(
      id: 'drills_5',
      titleEn: 'Complete 5 drills',
      titleRu: 'Завершите 5 дриллов',
      progress: 0,
      target: 5,
      completed: false,
      type: InternalGoalType.drills,
    );

    // Goal 3: Complete 1 module
    _goals['modules_1'] = const InternalGoal(
      id: 'modules_1',
      titleEn: 'Complete 1 module',
      titleRu: 'Завершите 1 модуль',
      progress: 0,
      target: 1,
      completed: false,
      type: InternalGoalType.modules,
    );

    // Goal 4: Complete weekly challenge
    _goals['weekly_challenge'] = const InternalGoal(
      id: 'weekly_challenge',
      titleEn: 'Complete weekly challenge',
      titleRu: 'Завершите еженедельный вызов',
      progress: 0,
      target: 1,
      completed: false,
      type: InternalGoalType.challenges,
    );

    // Goal 5: Earn 200 XP this week
    _goals['weekly_xp_200'] = const InternalGoal(
      id: 'weekly_xp_200',
      titleEn: 'Earn 200 XP this week',
      titleRu: 'Заработай 200 XP на этой неделе',
      progress: 0,
      target: 200,
      completed: false,
      type: InternalGoalType.xp,
    );

    _updateNotifier();
  }

  /// Get all active goals (incomplete goals first, limited to 3).
  List<InternalGoal> getActiveGoals() {
    final allGoals = _goals.values.toList();

    // Sort: incomplete first, then by progress
    allGoals.sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1; // Incomplete first
      }
      return b.progress.compareTo(a.progress); // Higher progress first
    });

    // Return max 3 goals
    return allGoals.take(3).toList();
  }

  /// Update progress for XP-related goals.
  void onXpAwarded(int amount) {
    for (final goal in _goals.values) {
      if (goal.type == InternalGoalType.xp && !goal.completed) {
        _incrementProgress(goal.id, amount);
      }
    }
  }

  /// Update progress for drill completion goals.
  void onDrillCompleted() {
    for (final goal in _goals.values) {
      if (goal.type == InternalGoalType.drills && !goal.completed) {
        _incrementProgress(goal.id, 1);
      }
    }
  }

  /// Update progress for module completion goals.
  void onModuleCompleted() {
    for (final goal in _goals.values) {
      if (goal.type == InternalGoalType.modules && !goal.completed) {
        _incrementProgress(goal.id, 1);
      }
    }
  }

  /// Update progress for challenge completion goals.
  void onChallengeCompleted() {
    for (final goal in _goals.values) {
      if (goal.type == InternalGoalType.challenges && !goal.completed) {
        _incrementProgress(goal.id, 1);
      }
    }
  }

  /// Increment progress for a specific goal.
  void _incrementProgress(String goalId, int amount) {
    final goal = _goals[goalId];
    if (goal == null || goal.completed) return;

    final newProgress = goal.progress + amount;
    final isCompleted = newProgress >= goal.target;

    _goals[goalId] = goal.copyWith(
      progress: newProgress,
      completed: isCompleted,
    );

    _updateNotifier();
  }

  /// Reset all goals (for testing or manual reset).
  void reset() {
    _initializeGoals();
  }

  /// Update the notifier with current active goals.
  void _updateNotifier() {
    goalsNotifier.value = getActiveGoals();
  }

  /// Get a specific goal by ID (for testing).
  InternalGoal? getGoal(String id) => _goals[id];
}
