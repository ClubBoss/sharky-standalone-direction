import 'package:shared_preferences/shared_preferences.dart';

import '../models/training_progress_snapshot.dart';
import 'module_progress_service.dart';

/// Service that converts module completion data into a progress snapshot.
class TrainingProgressService {
  TrainingProgressService({ProgressStore? store})
    : _store = store ?? ModuleProgressStore();

  static final TrainingProgressService instance = TrainingProgressService();

  static List<TrainingModuleProgress>? _mockData;
  final ProgressStore _store;
  final Map<String, double> _progressCache = {};
  final Map<String, double> _stageProgressCache = {};
  final Map<String, double> _tagProgressCache = {};
  final Map<String, Map<String, double>> subStageProgress = {};

  /// Overrides the backing data for tests/dev environments.
  static void setMockData(List<TrainingModuleProgress>? data) {
    _mockData = data;
  }

  TrainingProgressSnapshot getSnapshot() {
    final entries = _mockData ?? _store.getAllProgress();
    if (entries.isEmpty) {
      return const TrainingProgressSnapshot(
        label: 'overall',
        completedModules: 0,
        totalModules: 0,
      );
    }
    final total = entries.length;
    final completed = entries.where((entry) => entry.isCompleted).length;

    return TrainingProgressSnapshot(
      label: 'overall',
      completedModules: completed,
      totalModules: total,
    );
  }

  List<TrainingProgressSnapshot> getScopedProgressSnapshots() {
    final entries = _mockData ?? _store.getAllProgress();
    final totalsByScope = <String, Set<String>>{
      for (final entry in _defaultScopeModuleIds.entries)
        entry.key: entry.value.toSet(),
    };
    final completedByScope = <String, Set<String>>{};

    void register(String moduleId, bool isCompleted) {
      final scope = _scopeForModule(moduleId);
      if (scope == null) return;
      totalsByScope.putIfAbsent(scope, () => <String>{}).add(moduleId);
      if (isCompleted) {
        completedByScope.putIfAbsent(scope, () => <String>{}).add(moduleId);
      }
    }

    for (final entry in entries) {
      register(entry.moduleId, entry.isCompleted);
    }

    final scoped = <TrainingScopeProgress>[];
    for (final scope in _scopeOrder) {
      final totalSet = totalsByScope[scope];
      if (totalSet == null || totalSet.isEmpty) continue;
      final completedSet = completedByScope[scope] ?? const <String>{};
      final totalCount = totalSet.length;
      final completedCount = completedSet.length > totalCount
          ? totalCount
          : completedSet.length;
      scoped.add(
        TrainingScopeProgress(
          label: scope,
          completed: completedCount,
          total: totalCount,
        ),
      );
    }

    return TrainingProgressSnapshot.fromScopeProgress(scoped);
  }

  Future<double> getProgress(String templateId) async {
    final cached = _progressCache[templateId];
    if (cached != null) return cached;
    final prefs = await SharedPreferences.getInstance();
    final key = 'tpl_prog_$templateId';
    final legacyKey = 'progress_tpl_$templateId';
    final raw = prefs.getInt(key) ?? prefs.getInt(legacyKey);
    double progress;
    if (raw == null) {
      progress = 0.0;
    } else {
      progress = (raw + 1) / 20.0;
      if (progress > 1.0) progress = 1.0;
      if (progress < 0) progress = 0.0;
    }
    _progressCache[templateId] = progress;
    return progress;
  }

  Future<Map<String, double>> getProgressForModule(String moduleId) async {
    // TODO replace stub when logic is restored.
    return const {'theory': 0.0, 'drills': 0.0, 'demos': 0.0};
  }

  Future<double> getSubStageProgress(String stageId, String templateId) async {
    final stageMap = subStageProgress.putIfAbsent(stageId, () => {});
    final cached = stageMap[templateId];
    if (cached != null) return cached;
    final base = await getProgress(templateId);
    final normalized = base > 0 ? base : 0.1;
    final clamped = normalized.clamp(0.0, 1.0);
    stageMap[templateId] = clamped;
    // Update aggregate cache so stage progress reflects latest value.
    _stageProgressCache.remove(stageId);
    return clamped;
  }

  Future<double> getStageProgress(String stageId) async {
    final cached = _stageProgressCache[stageId];
    if (cached != null) return cached;
    final map = subStageProgress[stageId];
    if (map == null || map.isEmpty) {
      _stageProgressCache[stageId] = 0.0;
      return 0.0;
    }
    final avg =
        map.values.fold<double>(0, (sum, value) => sum + value) / map.length;
    final clamped = avg.clamp(0.0, 1.0);
    _stageProgressCache[stageId] = clamped;
    return clamped;
  }

  Future<double> getTagProgress(String tag) async {
    final key = tag.trim().toLowerCase();
    final cached = _tagProgressCache[key];
    if (cached != null) return cached;
    // Legacy implementation aggregated per-tag history. We expose a stubbed value.
    _tagProgressCache[key] = 0.0;
    return 0.0;
  }
}

/// Represents a single module's completion state.
class TrainingModuleProgress {
  final String moduleId;
  final bool isCompleted;

  const TrainingModuleProgress({
    required this.moduleId,
    required this.isCompleted,
  });
}

/// Provides access to persisted module progress data.
abstract class ProgressStore {
  List<TrainingModuleProgress> getAllProgress();
}

class ModuleProgressStore implements ProgressStore {
  ModuleProgressStore({
    ModuleProgressService? progressService,
    List<String>? trackedModuleIds,
  }) : _progressService = progressService ?? ModuleProgressService(),
       _trackedModuleIds = trackedModuleIds ?? _defaultModuleIds;

  final ModuleProgressService _progressService;
  final List<String> _trackedModuleIds;

  @override
  List<TrainingModuleProgress> getAllProgress() {
    final completed = _progressService.getCompletedModules();
    final moduleIds = <String>{..._trackedModuleIds, ...completed};
    final sortedIds = moduleIds.toList()..sort();

    return sortedIds
        .map(
          (id) => TrainingModuleProgress(
            moduleId: id,
            isCompleted: completed.contains(id),
          ),
        )
        .toList(growable: false);
  }
}

String? _scopeForModule(String moduleId) {
  if (moduleId.startsWith('core_')) return 'core';
  if (moduleId.startsWith('cash_')) return 'cash';
  if (moduleId.startsWith('mtt_')) return 'mtt';
  if (moduleId.startsWith('live_')) return 'live';
  return null;
}

const List<String> _scopeOrder = ['core', 'cash', 'mtt', 'live'];

const List<String> _defaultCoreModules = [
  'core_bankroll_management',
  'core_starting_hands',
  'core_rules_and_setup',
  'core_pot_odds_equity',
];

const List<String> _defaultCashModules = [
  'cash_single_raised_pots',
  'cash_blind_vs_blind',
  'cash_blind_defense',
  'cash_fourbet_pots',
];

const List<String> _defaultMttModules = [
  'mtt_deep_stack',
  'mtt_mid_stack',
  'mtt_late_reg_strategy',
  'mtt_short_stack',
];

const List<String> _defaultLiveModules = [
  'live_tells_and_dynamics',
  'live_table_selection_and_seat_change',
  'live_floor_calls_and_dispute_resolution',
  'live_rake_structures_and_tips',
];

const Map<String, List<String>> _defaultScopeModuleIds = {
  'core': _defaultCoreModules,
  'cash': _defaultCashModules,
  'mtt': _defaultMttModules,
  'live': _defaultLiveModules,
};

const List<String> _defaultModuleIds = [
  ..._defaultCoreModules,
  ..._defaultCashModules,
  ..._defaultMttModules,
  ..._defaultLiveModules,
];
