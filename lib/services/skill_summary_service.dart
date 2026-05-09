import 'session_log_service.dart';

/// Represents a topic/skill with its category (strong/weak/new)
class SkillTopic {
  final String topicId;
  final String category; // 'strong', 'weak', 'new'

  const SkillTopic({required this.topicId, required this.category});
}

/// Service that analyzes recent training sessions to identify:
/// - **Strong topics**: ≥3 correct spots, no mistakes in last 14 days
/// - **Weak topics**: ≥2 mistakes in last 14 days
/// - **New topics**: First-ever session completed in last 7 days
///
/// This provides a dynamic "skill map" showing what the user excels at,
/// needs practice with, and has recently started learning.
///
/// **Usage:**
/// ```dart
/// final service = SkillSummaryService.instance;
/// await service.load();
///
/// final strong = service.getStrongTopics(limit: 3);
/// final weak = service.getWeakTopics(limit: 3);
/// final new_ = service.getNewTopics(limit: 3);
/// ```
class SkillSummaryService {
  SkillSummaryService._();
  static final instance = SkillSummaryService._();

  bool _loaded = false;
  final Map<String, int> _correctByTopic = {};
  final Map<String, int> _mistakesByTopic = {};
  final Map<String, DateTime> _firstSeenByTopic = {};
  final Map<String, DateTime> _lastSeenByTopic = {};

  /// Loads and analyzes session logs from SessionLogService.
  ///
  /// Should be called before accessing strong/weak/new topics.
  Future<void> load() async {
    _correctByTopic.clear();
    _mistakesByTopic.clear();
    _firstSeenByTopic.clear();
    _lastSeenByTopic.clear();

    final sessionLogService = SessionLogService.instance;
    await sessionLogService.load();

    final fourteenDaysAgo = DateTime.now().subtract(const Duration(days: 14));

    // Analyze all sessions to find first-seen dates
    for (final log in sessionLogService.logs) {
      for (final tag in log.tags) {
        final topic = tag.trim().toLowerCase();
        if (topic.isEmpty) continue;

        final firstSeen = _firstSeenByTopic[topic];
        if (firstSeen == null || log.completedAt.isBefore(firstSeen)) {
          _firstSeenByTopic[topic] = log.completedAt;
        }

        final lastSeen = _lastSeenByTopic[topic];
        if (lastSeen == null || log.completedAt.isAfter(lastSeen)) {
          _lastSeenByTopic[topic] = log.completedAt;
        }
      }

      // Also check categories
      for (final category in log.categories.keys) {
        final topic = category.trim().toLowerCase();
        if (topic.isEmpty) continue;

        final firstSeen = _firstSeenByTopic[topic];
        if (firstSeen == null || log.completedAt.isBefore(firstSeen)) {
          _firstSeenByTopic[topic] = log.completedAt;
        }

        final lastSeen = _lastSeenByTopic[topic];
        if (lastSeen == null || log.completedAt.isAfter(lastSeen)) {
          _lastSeenByTopic[topic] = log.completedAt;
        }
      }
    }

    // Analyze recent 14 days for strong/weak topics
    final recentLogs = sessionLogService.logs
        .where((log) => log.completedAt.isAfter(fourteenDaysAgo))
        .toList();

    for (final log in recentLogs) {
      // Process tags
      for (final tag in log.tags) {
        final topic = tag.trim().toLowerCase();
        if (topic.isEmpty) continue;

        _correctByTopic[topic] =
            (_correctByTopic[topic] ?? 0) + log.correctCount;
        _mistakesByTopic[topic] =
            (_mistakesByTopic[topic] ?? 0) + log.mistakeCount;
      }

      // Process categories
      for (final entry in log.categories.entries) {
        final topic = entry.key.trim().toLowerCase();
        if (topic.isEmpty) continue;

        // Categories map stores mistake counts
        _mistakesByTopic[topic] = (_mistakesByTopic[topic] ?? 0) + entry.value;
      }
    }

    _loaded = true;
  }

  /// Returns strong topics: ≥3 correct spots, no mistakes in last 14 days.
  ///
  /// Topics are sorted by correct count (descending).
  /// Use [limit] to restrict the number of results (default: 3).
  List<String> getStrongTopics({int limit = 3}) {
    if (!_loaded) return const [];

    final candidates = <MapEntry<String, int>>[];

    for (final entry in _correctByTopic.entries) {
      final topic = entry.key;
      final correct = entry.value;
      final mistakes = _mistakesByTopic[topic] ?? 0;

      // Strong: ≥3 correct AND 0 mistakes
      if (correct >= 3 && mistakes == 0) {
        candidates.add(MapEntry(topic, correct));
      }
    }

    // Sort by correct count (descending)
    candidates.sort((a, b) => b.value.compareTo(a.value));

    return candidates.take(limit).map((e) => e.key).toList();
  }

  /// Returns weak topics: ≥2 mistakes in last 14 days.
  ///
  /// Topics are sorted by mistake count (descending).
  /// Use [limit] to restrict the number of results (default: 3).
  List<String> getWeakTopics({int limit = 3}) {
    if (!_loaded) return const [];

    final candidates = <MapEntry<String, int>>[];

    for (final entry in _mistakesByTopic.entries) {
      final topic = entry.key;
      final mistakes = entry.value;

      // Weak: ≥2 mistakes
      if (mistakes >= 2) {
        candidates.add(MapEntry(topic, mistakes));
      }
    }

    // Sort by mistake count (descending)
    candidates.sort((a, b) => b.value.compareTo(a.value));

    return candidates.take(limit).map((e) => e.key).toList();
  }

  /// Returns new topics: first-ever session completed in last 7 days.
  ///
  /// Topics are sorted by first-seen date (most recent first).
  /// Use [limit] to restrict the number of results (default: 3).
  List<String> getNewTopics({int limit = 3}) {
    if (!_loaded) return const [];

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final candidates = <MapEntry<String, DateTime>>[];

    for (final entry in _firstSeenByTopic.entries) {
      final topic = entry.key;
      final firstSeen = entry.value;

      // New: first seen in last 7 days
      if (firstSeen.isAfter(sevenDaysAgo)) {
        candidates.add(MapEntry(topic, firstSeen));
      }
    }

    // Sort by first-seen date (most recent first)
    candidates.sort((a, b) => b.value.compareTo(a.value));

    return candidates.take(limit).map((e) => e.key).toList();
  }

  /// Returns true if service has been loaded.
  bool get isLoaded => _loaded;

  /// Clears all cached data. Call load() again to refresh.
  void clear() {
    _loaded = false;
    _correctByTopic.clear();
    _mistakesByTopic.clear();
    _firstSeenByTopic.clear();
    _lastSeenByTopic.clear();
  }

  Future<Map<String, int>> getSkillSummary() async {
    // TODO replace stub when logic is restored.
    return const {'strong': 0, 'weak': 0, 'new': 0};
  }

  Future<List<Map<String, dynamic>>> getTopPracticedTopics() async {
    // TODO replace stub when logic is restored.
    return const [];
  }

  String? getWeakestTopic() {
    // TODO replace stub when logic is restored.
    return null;
  }

  Map<String, String> getAllTopicsWithCategories() {
    // TODO replace stub when logic is restored.
    return const {};
  }
}
