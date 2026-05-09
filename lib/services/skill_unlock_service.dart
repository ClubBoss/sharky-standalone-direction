import 'skill_summary_service.dart';
import '../config/skill_unlock_rules.dart';

/// Service that manages topic unlock logic based on mastery prerequisites.
///
/// **Unlock Logic:**
/// - A topic is unlocked if all its prerequisites are "mastered"
/// - Mastery = topic has "strong" category status (≥3 correct, 0 mistakes in 14 days)
/// - Topics with no prerequisites are always unlocked
///
/// **Usage:**
/// ```dart
/// final service = SkillUnlockService.instance;
/// await service.initialize();
///
/// if (service.isUnlocked('advanced_preflop')) {
///   // Allow access to topic
/// } else {
///   final missing = service.getMissingPrerequisites('advanced_preflop');
///   // Show lock UI with missing prerequisites
/// }
/// ```
///
/// **Integration with SkillMapCard:**
/// ```dart
/// final unlockService = SkillUnlockService.instance;
/// await unlockService.initialize();
///
/// for (final topic in topics) {
///   final locked = !unlockService.isUnlocked(topic);
///   // Show lock icon if locked
/// }
/// ```
class SkillUnlockService {
  SkillUnlockService._();
  static final SkillUnlockService instance = SkillUnlockService._();

  // Cache of mastered topics (strong category)
  Set<String> _masteredTopics = {};
  bool _initialized = false;

  /// Returns true if the service has been initialized.
  bool get isInitialized => _initialized;

  /// Returns the set of all mastered topics (strong category).
  Set<String> get masteredTopics => Set.unmodifiable(_masteredTopics);

  /// Initializes the service by loading mastered topics from SkillSummaryService.
  ///
  /// Must be called before using [isUnlocked] or [getMissingPrerequisites].
  /// Safe to call multiple times (will refresh mastered topics).
  Future<void> initialize() async {
    final skillService = SkillSummaryService.instance;
    await skillService.load();

    final categories = skillService.getAllTopicsWithCategories();

    // Extract topics that are mastered (strong category)
    _masteredTopics = categories.entries
        .where((e) => e.value == 'strong')
        .map((e) => e.key)
        .toSet();

    _initialized = true;
  }

  /// Returns true if the topic is unlocked (all prerequisites are mastered).
  ///
  /// A topic is unlocked when:
  /// 1. It has no prerequisites (not in unlock rules), OR
  /// 2. All its prerequisites are mastered (strong category)
  ///
  /// Throws StateError if service not initialized.
  bool isUnlocked(String topicId) {
    if (!_initialized) {
      throw StateError(
        'SkillUnlockService must be initialized before use. '
        'Call await initialize() first.',
      );
    }

    // Topics with no prerequisites are always unlocked
    if (!hasPrerequisites(topicId)) {
      return true;
    }

    // Check if all prerequisites are mastered
    final prerequisites = getPrerequisites(topicId);
    return prerequisites.every((prereq) => _masteredTopics.contains(prereq));
  }

  /// Returns the list of missing (not yet mastered) prerequisites for a topic.
  ///
  /// Returns empty list if:
  /// - Topic has no prerequisites, OR
  /// - All prerequisites are mastered (topic is unlocked)
  ///
  /// Throws StateError if service not initialized.
  List<String> getMissingPrerequisites(String topicId) {
    if (!_initialized) {
      throw StateError(
        'SkillUnlockService must be initialized before use. '
        'Call await initialize() first.',
      );
    }

    if (!hasPrerequisites(topicId)) {
      return [];
    }

    final prerequisites = getPrerequisites(topicId);
    return prerequisites
        .where((prereq) => !_masteredTopics.contains(prereq))
        .toList();
  }

  /// Returns a map of all topics with their unlock status.
  ///
  /// Useful for debugging or displaying complete unlock state.
  ///
  /// Throws StateError if service not initialized.
  Map<String, bool> getAllUnlockStatuses() {
    if (!_initialized) {
      throw StateError(
        'SkillUnlockService must be initialized before use. '
        'Call await initialize() first.',
      );
    }

    final result = <String, bool>{};

    // Add all locked topics (topics with prerequisites)
    for (final topicId in getAllLockedTopics()) {
      result[topicId] = isUnlocked(topicId);
    }

    return result;
  }

  /// Returns the count of topics that are currently locked.
  ///
  /// Throws StateError if service not initialized.
  int getLockedCount() {
    if (!_initialized) {
      throw StateError(
        'SkillUnlockService must be initialized before use. '
        'Call await initialize() first.',
      );
    }

    return getAllLockedTopics().where((topic) => !isUnlocked(topic)).length;
  }

  /// Returns the count of topics that are currently unlocked.
  ///
  /// Throws StateError if service not initialized.
  int getUnlockedCount() {
    if (!_initialized) {
      throw StateError(
        'SkillUnlockService must be initialized before use. '
        'Call await initialize() first.',
      );
    }

    return getAllLockedTopics().where(isUnlocked).length;
  }

  /// Returns a set of all unlocked topics (topics with prerequisites that are accessible).
  ///
  /// Useful for ProgressPathCard to show completed topics.
  ///
  /// Throws StateError if service not initialized.
  Set<String> getUnlockedTopics() {
    if (!_initialized) {
      throw StateError(
        'SkillUnlockService must be initialized before use. '
        'Call await initialize() first.',
      );
    }

    return getAllLockedTopics().where(isUnlocked).toSet();
  }

  /// Returns a set of all locked topics (topics with unmet prerequisites).
  ///
  /// Useful for ProgressPathCard to filter out inaccessible content.
  ///
  /// Throws StateError if service not initialized.
  Set<String> getLockedTopics() {
    if (!_initialized) {
      throw StateError(
        'SkillUnlockService must be initialized before use. '
        'Call await initialize() first.',
      );
    }

    return getAllLockedTopics().where((topic) => !isUnlocked(topic)).toSet();
  }

  /// Returns topics that are "almost unlocked" - only 1 prerequisite missing.
  ///
  /// These are good candidates for the "next step" in a learning path.
  /// Helps users focus on topics that are close to unlocking.
  ///
  /// Throws StateError if service not initialized.
  Set<String> getAlmostUnlockedTopics() {
    if (!_initialized) {
      throw StateError(
        'SkillUnlockService must be initialized before use. '
        'Call await initialize() first.',
      );
    }

    final almostUnlocked = <String>{};

    for (final topicId in getAllLockedTopics()) {
      if (!isUnlocked(topicId)) {
        final missing = getMissingPrerequisites(topicId);
        if (missing.length == 1) {
          almostUnlocked.add(topicId);
        }
      }
    }

    return almostUnlocked;
  }

  /// Clears all cached data. Call [initialize] again to refresh.
  void clear() {
    _masteredTopics.clear();
    _initialized = false;
  }

  /// Returns a human-readable description of a topic's unlock status.
  ///
  /// Returns:
  /// - "Unlocked" if topic is accessible
  /// - "Locked: Requires X, Y" if topic has missing prerequisites
  /// - "Always unlocked" if topic has no prerequisites
  ///
  /// Throws StateError if service not initialized.
  String getUnlockDescription(String topicId, {bool isEnglish = true}) {
    if (!_initialized) {
      throw StateError(
        'SkillUnlockService must be initialized before use. '
        'Call await initialize() first.',
      );
    }

    if (!hasPrerequisites(topicId)) {
      return isEnglish ? 'Always unlocked' : 'Всегда доступно';
    }

    if (isUnlocked(topicId)) {
      return isEnglish ? 'Unlocked' : 'Разблокировано';
    }

    final missing = getMissingPrerequisites(topicId);
    final missingText = missing.join(', ');

    if (isEnglish) {
      return 'Locked: Requires mastery of $missingText';
    } else {
      return 'Заблокировано: требуется мастерство в $missingText';
    }
  }
}
