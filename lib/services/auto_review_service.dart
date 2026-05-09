import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'module_progress_service.dart';
import 'session_log_service.dart';
import 'content_module_loader_service.dart';
import 'xp_service.dart';

/// Source of a review candidate module
enum AutoReviewSource {
  /// Module last completed ≥7 days ago (stale knowledge)
  stale,

  /// Module with 2+ failures/mistakes from practice
  failed,

  /// Module never interacted with (cold start)
  neverSeen,
}

/// Review candidate with metadata about why it was selected
class AutoReviewCandidate {
  final String moduleId;
  final AutoReviewSource source;
  final DateTime? lastCompletedAt;
  final int failureCount;
  final int xpEarned;

  const AutoReviewCandidate({
    required this.moduleId,
    required this.source,
    this.lastCompletedAt,
    this.failureCount = 0,
    this.xpEarned = 0,
  });

  @override
  String toString() =>
      'AutoReviewCandidate($moduleId, source: $source, '
      'lastCompleted: $lastCompletedAt, failures: $failureCount, xp: $xpEarned)';
}

/// Service to intelligently select high-priority modules for review
/// based on completion history, performance data, and staleness.
///
/// Priority logic (max 5 candidates):
/// 1. **Failed modules**: 2+ failures from SessionLogService.getRecentMistakes()
///    - Sorted by failure count descending
/// 2. **Stale modules**: Completed ≥7 days ago
///    - Sorted by completion date ascending (oldest first)
/// 3. **Never-seen modules**: 0 XP earned (cold start fallback)
///    - Natural order from ContentModuleLoaderService
///
/// Usage:
/// ```dart
/// final service = AutoReviewService.instance;
/// final candidates = await service.getReviewCandidates();
/// for (final candidate in candidates) {
///   print('${candidate.moduleId}: ${candidate.source}');
/// }
/// ```
///
/// Recording completions:
/// ```dart
/// await service.recordModuleCompletion('core_bankroll_management');
/// ```
class AutoReviewService {
  static final AutoReviewService _instance = AutoReviewService._internal();
  static AutoReviewService get instance => _instance;

  AutoReviewService._internal();

  static const String _completionTimestampsKey = 'module_completion_timestamps';
  static const int _staleDaysThreshold = 7;
  static const int _failureThreshold = 2;
  static const int _maxCandidates = 5;

  /// Get top review candidates prioritized by:
  /// 1. Failed modules (2+ failures)
  /// 2. Stale modules (completed ≥7 days ago)
  /// 3. Never-seen modules (cold start fallback)
  Future<List<AutoReviewCandidate>> getReviewCandidates() async {
    final candidates = <AutoReviewCandidate>[];

    // Load all necessary data
    final moduleProgressService = ModuleProgressService();
    if (!moduleProgressService.isInitialized) {
      await moduleProgressService.initialize();
    }

    final xpService = XpService();
    if (!xpService.isInitialized) {
      await xpService.initialize();
    }

    final contentLoader = ContentModuleLoaderService();
    await contentLoader.initialize();

    final sessionLogService = SessionLogService.instance;
    await sessionLogService.load();

    // Get all available modules
    final allModules = await contentLoader.getModuleIndex();
    final allModuleIds = allModules.map((m) => m.id).toList();

    // Get completion data
    final completedModuleIds = moduleProgressService.getCompletedModules();
    final completionTimestamps = await _loadCompletionTimestamps();

    // Get mistake/failure data
    final mistakeMap = sessionLogService.getRecentMistakes(limit: 100);

    // Track processed modules to avoid duplicates
    final processedIds = <String>{};

    // Priority 1: Failed modules (2+ failures)
    final failedCandidates = _identifyFailedModules(
      allModuleIds,
      mistakeMap,
      xpService,
      completionTimestamps,
    );
    for (final candidate in failedCandidates) {
      if (candidates.length >= _maxCandidates) break;
      candidates.add(candidate);
      processedIds.add(candidate.moduleId);
    }

    // Priority 2: Stale modules (completed ≥7 days ago)
    if (candidates.length < _maxCandidates) {
      final staleCandidates = _identifyStaleModules(
        completedModuleIds,
        completionTimestamps,
        xpService,
        mistakeMap,
        processedIds,
      );
      for (final candidate in staleCandidates) {
        if (candidates.length >= _maxCandidates) break;
        candidates.add(candidate);
        processedIds.add(candidate.moduleId);
      }
    }

    // Priority 3: Never-seen modules (cold start)
    if (candidates.length < _maxCandidates) {
      final neverSeenCandidates = _identifyNeverSeenModules(
        allModuleIds,
        completedModuleIds,
        xpService,
        processedIds,
      );
      for (final candidate in neverSeenCandidates) {
        if (candidates.length >= _maxCandidates) break;
        candidates.add(candidate);
        processedIds.add(candidate.moduleId);
      }
    }

    return candidates;
  }

  /// Identify modules with 2+ failures from mistake logs
  List<AutoReviewCandidate> _identifyFailedModules(
    List<String> allModuleIds,
    Map<String, int> mistakeMap,
    XpService xpService,
    Map<String, DateTime> completionTimestamps,
  ) {
    final candidates = <AutoReviewCandidate>[];

    for (final moduleId in allModuleIds) {
      final mistakes = mistakeMap[moduleId.toLowerCase()] ?? 0;
      if (mistakes >= _failureThreshold) {
        candidates.add(
          AutoReviewCandidate(
            moduleId: moduleId,
            source: AutoReviewSource.failed,
            lastCompletedAt: completionTimestamps[moduleId],
            failureCount: mistakes,
            xpEarned: xpService.getXpForModule(moduleId),
          ),
        );
      }
    }

    // Sort by failure count descending
    candidates.sort((a, b) => b.failureCount.compareTo(a.failureCount));
    return candidates;
  }

  /// Identify modules completed ≥7 days ago
  List<AutoReviewCandidate> _identifyStaleModules(
    Set<String> completedModuleIds,
    Map<String, DateTime> completionTimestamps,
    XpService xpService,
    Map<String, int> mistakeMap,
    Set<String> processedIds,
  ) {
    final candidates = <AutoReviewCandidate>[];
    final now = DateTime.now();

    for (final moduleId in completedModuleIds) {
      if (processedIds.contains(moduleId)) continue;

      final timestamp = completionTimestamps[moduleId];
      if (timestamp != null) {
        final daysSinceCompletion = now.difference(timestamp).inDays;
        if (daysSinceCompletion >= _staleDaysThreshold) {
          final failures = mistakeMap[moduleId.toLowerCase()] ?? 0;
          candidates.add(
            AutoReviewCandidate(
              moduleId: moduleId,
              source: AutoReviewSource.stale,
              lastCompletedAt: timestamp,
              failureCount: failures,
              xpEarned: xpService.getXpForModule(moduleId),
            ),
          );
        }
      }
    }

    // Sort by staleness (oldest first)
    candidates.sort((a, b) {
      if (a.lastCompletedAt == null && b.lastCompletedAt == null) return 0;
      if (a.lastCompletedAt == null) return 1;
      if (b.lastCompletedAt == null) return -1;
      return a.lastCompletedAt!.compareTo(b.lastCompletedAt!);
    });

    return candidates;
  }

  /// Identify modules with no XP earned (never interacted)
  List<AutoReviewCandidate> _identifyNeverSeenModules(
    List<String> allModuleIds,
    Set<String> completedModuleIds,
    XpService xpService,
    Set<String> processedIds,
  ) {
    final candidates = <AutoReviewCandidate>[];

    for (final moduleId in allModuleIds) {
      if (processedIds.contains(moduleId)) continue;

      final xp = xpService.getXpForModule(moduleId);
      if (xp == 0) {
        candidates.add(
          AutoReviewCandidate(
            moduleId: moduleId,
            source: AutoReviewSource.neverSeen,
            xpEarned: 0,
          ),
        );
      }
    }

    // No specific sort order for never-seen (use natural order from index)
    return candidates;
  }

  /// Record module completion timestamp for staleness tracking
  Future<void> recordModuleCompletion(String moduleId) async {
    final timestamps = await _loadCompletionTimestamps();
    timestamps[moduleId] = DateTime.now();
    await _saveCompletionTimestamps(timestamps);
  }

  /// Load completion timestamps from SharedPreferences
  Future<Map<String, DateTime>> _loadCompletionTimestamps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_completionTimestampsKey);
      if (json == null) return {};

      final data = <String, DateTime>{};

      // Parse stored format: "moduleId:timestamp,moduleId:timestamp,..."
      final entries = json.split(',');
      for (final entry in entries) {
        final parts = entry.split(':');
        if (parts.length == 2) {
          final moduleId = parts[0];
          final timestamp = DateTime.tryParse(parts[1]);
          if (timestamp != null) {
            data[moduleId] = timestamp;
          }
        }
      }

      return data;
    } catch (e) {
      return {};
    }
  }

  /// Save completion timestamps to SharedPreferences
  Future<void> _saveCompletionTimestamps(
    Map<String, DateTime> timestamps,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = timestamps.entries
          .map((e) => '${e.key}:${e.value.toIso8601String()}')
          .join(',');
      await prefs.setString(_completionTimestampsKey, encoded);
    } catch (e) {
      // Fail silently
    }
  }

  /// Clear all completion timestamps (for testing)
  Future<void> clearCompletionTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completionTimestampsKey);
  }
}
