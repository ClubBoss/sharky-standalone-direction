import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'training_stats_service.dart';
import 'goal_orchestrator.dart';

class DailyTargetService extends ChangeNotifier {
  static const _key = 'daily_hands_target';
  int _target = 10;
  int get target => _target;

  int get progress {
    final stats = TrainingStatsService.instance;
    if (stats == null) return 0;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return stats.handsPerDay[today] ?? 0;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_key);
    if (stored != null) {
      _target = stored;
    } else {
      final snapshot = await GoalOrchestrator.instance.getProgress();
      _target = snapshot.target;
    }
    notifyListeners();
  }

  Future<void> setTarget(int value) async {
    if (_target == value) return;
    _target = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, value);
    await GoalOrchestrator.instance.setDailyGoal(value);
    notifyListeners();
  }
}
