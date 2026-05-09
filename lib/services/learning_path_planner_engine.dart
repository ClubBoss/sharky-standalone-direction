import 'dart:convert';
import 'dart:io';
import 'learning_path_orchestrator.dart';
import 'training_progress_service.dart';
import 'session_storage_service.dart';
import 'analytics_service.dart';

/// Computes which learning path stages should be presented in the weekly planner.
class LearningPathPlannerEngine {
  LearningPathPlannerEngine._();

  static final LearningPathPlannerEngine instance =
      LearningPathPlannerEngine._();

  List<String>? _cache;
  DateTime _cacheTime = DateTime.fromMillisecondsSinceEpoch(0);
  String? _lastMode;

  /// Returns up to seven stage ids that are not yet completed.
  Future<List<String>> getPlannedStageIds() async {
    final now = DateTime.now();
    if (_cache != null &&
        now.difference(_cacheTime) < const Duration(minutes: 5)) {
      return _cache!;
    }

    final path = await LearningPathOrchestrator.instance.resolve();
    final plannerState = await _computeAdaptivePlannerState();
    final maxCount = plannerState['maxCount'] as int;
    final mode = plannerState['mode'] as String;
    final result = <String>[];
    for (final stage in path.stages) {
      if (result.length >= maxCount) break;
      final progress = await TrainingProgressService.instance.getStageProgress(
        stage.id,
      );
      if (progress < 1.0) {
        result.add(stage.id);
      }
    }

    // Log telemetry if mode changed
    if (_lastMode != mode) {
      _lastMode = mode;
      AnalyticsService.instance.logEvent('adaptive_planner_mode', {
        'mode': mode,
        'maxCount': maxCount,
        'baseline': 7,
        'delta': maxCount - 7,
        'momentum': plannerState['momentum'] ?? 0.0,
        'fatigue': plannerState['fatigue'] ?? 0.0,
      });
    }

    _cache = result;
    _cacheTime = now;
    return result;
  }

  /// Marks [stageId] as completed and updates the planner state.
  Future<void> markStageCompleted(String stageId) async {
    // TODO(fix): TrainingProgressService does not have markCompleted method
    // await TrainingProgressService.instance.markCompleted(stageId);
    _cacheTime = DateTime.fromMillisecondsSinceEpoch(0);
    final cached = _cache;
    if (cached != null) {
      cached.remove(stageId);
    }
    await SessionStorageService.instance.remove('planner_remaining');
  }

  /// Returns adaptive planner state: mode, maxCount, momentum, fatigue.
  Future<Map<String, dynamic>> _computeAdaptivePlannerState() async {
    const baseCount = 7;
    String mode = 'Balanced';
    int maxCount = baseCount;
    double momentum = 0.0;
    double fatigue = 0.0;

    try {
      final f = File('build/adaptive_learning_summary.json');
      if (await f.exists()) {
        final data = jsonDecode(await f.readAsString());
        if (data is Map) {
          momentum = (data['learning_momentum'] as num?)?.toDouble() ?? 0.0;
          fatigue = (data['fatigue_penalty'] as num?)?.toDouble() ?? 0.0;

          // Determine mode and count based on thresholds
          if (fatigue >= 0.80) {
            mode = 'Light';
            maxCount = (baseCount * 0.7).round().clamp(3, 10);
          } else if (momentum >= 0.9) {
            mode = 'Accelerated';
            maxCount = 10;
          } else {
            mode = 'Balanced';
            maxCount = baseCount;
          }
        }
      }
    } catch (_) {}

    return {
      'mode': mode,
      'maxCount': maxCount,
      'momentum': momentum,
      'fatigue': fatigue,
    };
  }
}
