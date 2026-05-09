import 'package:shared_preferences/shared_preferences.dart';
import 'skill_summary_service.dart';

/// Represents the current weekly skill focus
class WeeklySkillFocus {
  final String topicId;
  final DateTime setAt;
  final bool isDismissed;

  const WeeklySkillFocus({
    required this.topicId,
    required this.setAt,
    this.isDismissed = false,
  });

  Map<String, dynamic> toJson() => {
    'topicId': topicId,
    'setAt': setAt.toIso8601String(),
    'isDismissed': isDismissed,
  };

  factory WeeklySkillFocus.fromJson(Map<String, dynamic> json) =>
      WeeklySkillFocus(
        topicId: json['topicId'] as String? ?? '',
        setAt:
            DateTime.tryParse(json['setAt'] as String? ?? '') ?? DateTime.now(),
        isDismissed: json['isDismissed'] as bool? ?? false,
      );
}

/// Service that recommends one weak or new topic per week as a focus drill.
///
/// **Design:**
/// - Selects 1 topic from weak or new categories via SkillSummaryService
/// - Rotates weekly (7-day cycle)
/// - Persists current topic + timestamp in SharedPreferences
/// - Supports dismiss action (user can skip current week's recommendation)
///
/// **Usage:**
/// ```dart
/// final service = WeeklySkillBuilderService.instance;
/// await service.initialize();
///
/// final focus = await service.getCurrent();
/// if (focus != null && service.shouldShow()) {
///   // Show SkillOfWeekCard with focus.topicId
/// }
/// ```
class WeeklySkillBuilderService {
  WeeklySkillBuilderService._();
  static final instance = WeeklySkillBuilderService._();

  static const _keyTopicId = 'weekly_skill_builder_topic_id';
  static const _keySetAt = 'weekly_skill_builder_set_at';
  static const _keyDismissed = 'weekly_skill_builder_dismissed';

  bool _initialized = false;
  WeeklySkillFocus? _currentFocus;

  /// Initialize service by loading persisted focus or selecting new one.
  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final topicId = prefs.getString(_keyTopicId);
    final setAtStr = prefs.getString(_keySetAt);
    final isDismissed = prefs.getBool(_keyDismissed) ?? false;

    if (topicId != null && setAtStr != null) {
      final setAt = DateTime.tryParse(setAtStr);
      if (setAt != null) {
        _currentFocus = WeeklySkillFocus(
          topicId: topicId,
          setAt: setAt,
          isDismissed: isDismissed,
        );

        // Check if current focus is expired (>7 days old)
        final now = DateTime.now();
        final age = now.difference(setAt);
        if (age.inDays >= 7) {
          // Expired - select new focus
          await _selectNewFocus();
        }
      }
    }

    // No valid focus found - select new one
    if (_currentFocus == null) {
      await _selectNewFocus();
    }

    _initialized = true;
  }

  /// Returns the current weekly skill focus.
  ///
  /// Returns null if:
  /// - Service not initialized
  /// - No topic could be selected (empty skill lists)
  Future<WeeklySkillFocus?> getCurrent() async {
    if (!_initialized) await initialize();
    return _currentFocus;
  }

  /// Returns true if the skill-of-week card should be displayed.
  ///
  /// Shows when:
  /// - Valid focus exists
  /// - Not dismissed
  /// - Not expired (within 7 days)
  Future<bool> shouldShow() async {
    if (!_initialized) await initialize();
    if (_currentFocus == null || _currentFocus!.isDismissed) return false;

    final now = DateTime.now();
    final age = now.difference(_currentFocus!.setAt);
    return age.inDays < 7;
  }

  /// Marks current focus as dismissed (user skipped this week).
  ///
  /// The card will not show again until next week's rotation.
  Future<void> markDismissed() async {
    if (!_initialized) await initialize();
    if (_currentFocus == null) return;

    _currentFocus = WeeklySkillFocus(
      topicId: _currentFocus!.topicId,
      setAt: _currentFocus!.setAt,
      isDismissed: true,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDismissed, true);
  }

  /// Forces selection of a new weekly focus topic.
  ///
  /// Useful for testing or manual rotation.
  Future<void> reset() async {
    await _selectNewFocus();
  }

  /// Clears all persisted data.
  Future<void> clear() async {
    _initialized = false;
    _currentFocus = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTopicId);
    await prefs.remove(_keySetAt);
    await prefs.remove(_keyDismissed);
  }

  // Private methods

  Future<void> _selectNewFocus() async {
    final skillService = SkillSummaryService.instance;
    await skillService.load();

    // Priority 1: Pick weakest topic (most mistakes)
    String? selectedTopic = skillService.getWeakestTopic();

    // Priority 2: If no weak topics, pick newest topic
    if (selectedTopic == null) {
      final newTopics = skillService.getNewTopics(limit: 1);
      if (newTopics.isNotEmpty) {
        selectedTopic = newTopics.first;
      }
    }

    // Priority 3: If still nothing, pick any weak topic
    if (selectedTopic == null) {
      final weakTopics = skillService.getWeakTopics(limit: 1);
      if (weakTopics.isNotEmpty) {
        selectedTopic = weakTopics.first;
      }
    }

    // If still no topic found, leave focus as null
    if (selectedTopic == null) {
      _currentFocus = null;
      return;
    }

    final now = DateTime.now();
    _currentFocus = WeeklySkillFocus(
      topicId: selectedTopic,
      setAt: now,
      isDismissed: false,
    );

    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTopicId, selectedTopic);
    await prefs.setString(_keySetAt, now.toIso8601String());
    await prefs.setBool(_keyDismissed, false);
  }

  /// Returns days remaining until next rotation.
  Future<int> getDaysRemaining() async {
    if (!_initialized) await initialize();
    if (_currentFocus == null) return 0;

    final now = DateTime.now();
    final age = now.difference(_currentFocus!.setAt);
    final remaining = 7 - age.inDays;
    return remaining > 0 ? remaining : 0;
  }
}
