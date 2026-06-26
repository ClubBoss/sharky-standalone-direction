import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';

const String act0AchievementSeedStateEarnedV1 = 'earned_v1';
const String act0AchievementSeedStateNotEarnedV1 = 'not_earned_v1';
const String act0AchievementSeedStateBlockedMissingSourceV1 =
    'blocked_missing_source_v1';
const String act0AchievementSeedStateDeferredV1 = 'deferred_v1';

const String act0AchievementSeedFirstCorrectReadV1 = 'first_correct_read_v1';
const String act0AchievementSeedFirstRepairNoteV1 = 'first_repair_note_v1';
const String act0AchievementSeedFirstReviewHistoryItemV1 =
    'first_review_history_item_v1';
const String act0AchievementSeedFirstEvidenceSignalV1 =
    'first_evidence_signal_v1';
const String act0AchievementSeedFirstSessionCompleteV1 =
    'first_session_complete_v1';
const String act0AchievementSeedThreeDayStreakV1 = 'three_day_streak_v1';
const String act0AchievementSeedFirstLessonCompleteV1 =
    'first_lesson_complete_v1';
const String act0AchievementSeedFirstCleanMiniDrillV1 =
    'first_clean_mini_drill_v1';

class Act0AchievementSeedProjectionV1 {
  const Act0AchievementSeedProjectionV1({
    this.seeds = const <Act0AchievementSeedV1>[],
  });

  final List<Act0AchievementSeedV1> seeds;

  List<Act0AchievementSeedV1> get earnedSeeds =>
      List<Act0AchievementSeedV1>.unmodifiable(
        seeds.where((seed) => seed.earned),
      );

  Act0AchievementSeedV1 seedForId(String id) =>
      seeds.firstWhere((seed) => seed.id == id);

  List<Map<String, Object?>> toPayload() =>
      seeds.map((seed) => seed.toPayload()).toList(growable: false);

  static Act0AchievementSeedProjectionV1 fromSources({
    Act0LearningEvidenceHistoryV1 learningEvidenceHistory =
        const Act0LearningEvidenceHistoryV1(),
    List<Act0RepairIntentV1> repairIntents = const <Act0RepairIntentV1>[],
    Act0ReviewMistakeHistoryV1 reviewMistakeHistory =
        const Act0ReviewMistakeHistoryV1(),
    Act0ProfileEvidenceProjectionV1? profileEvidenceProjection,
    int? profileStreakDays,
  }) {
    final profileEvidence =
        profileEvidenceProjection ??
        Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
          learningEvidenceHistory,
        );
    final reviewRecords = reviewMistakeHistory.records;
    final latestRunSummary = learningEvidenceHistory.latestRunSummary();
    final safeStreakDays = profileStreakDays == null || profileStreakDays < 0
        ? 0
        : profileStreakDays;

    return Act0AchievementSeedProjectionV1(
      seeds: List<Act0AchievementSeedV1>.unmodifiable(<Act0AchievementSeedV1>[
        _earnedWhen(
          id: act0AchievementSeedFirstCorrectReadV1,
          internalTitle: 'First correct read',
          sourceOwner: 'Act0LearningEvidenceHistoryV1',
          earnedRecord: _firstCorrectRecord(learningEvidenceHistory),
          summaryBuilder: (record) => <String, Object?>{
            'completedCorrectDecisions': learningEvidenceHistory.records
                .where((item) => item.isCorrect)
                .length,
            'firstCreatedOrder': record.createdOrder,
          },
          sequenceBuilder: (record) => record.createdOrder,
        ),
        _repairSeed(repairIntents: repairIntents, reviewRecords: reviewRecords),
        _earnedWhen(
          id: act0AchievementSeedFirstReviewHistoryItemV1,
          internalTitle: 'One miss to fix',
          sourceOwner: 'Act0ReviewMistakeHistoryV1',
          earnedRecord: _oldestReviewRecord(reviewRecords),
          summaryBuilder: (record) => <String, Object?>{
            'unresolvedHistoryCount': reviewRecords.length,
            'firstCreatedOrder': record.createdOrder,
          },
          sequenceBuilder: (record) => record.createdOrder,
        ),
        _earnedWhen(
          id: act0AchievementSeedFirstEvidenceSignalV1,
          internalTitle: 'First evidence signal',
          sourceOwner: 'Act0ProfileEvidenceProjectionV1',
          earnedRecord: _firstEligibleSignal(profileEvidence),
          summaryBuilder: (signal) => <String, Object?>{
            'eligibleSignalCount': profileEvidence.signals
                .where((item) => item.isCapabilityEligible)
                .length,
            'firstSignalLatestOrder': signal.latestOrder,
          },
          sequenceBuilder: (signal) => signal.latestOrder,
        ),
        _earnedWhen(
          id: act0AchievementSeedFirstSessionCompleteV1,
          internalTitle: 'First session complete',
          sourceOwner: 'Act0LearningEvidenceHistoryV1.latestRunSummary',
          earnedRecord:
              latestRunSummary != null &&
                  latestRunSummary.currentSessionOnly &&
                  latestRunSummary.spotsPlayed > 0
              ? latestRunSummary
              : null,
          summaryBuilder: (summary) => <String, Object?>{
            'runId': summary.runId,
            'runKind': summary.runKind,
            if (summary.runOrdinal != null) 'runOrdinal': summary.runOrdinal,
            'spotsPlayed': summary.spotsPlayed,
          },
          sequenceBuilder: (summary) => summary.runOrdinal,
        ),
        Act0AchievementSeedV1(
          id: act0AchievementSeedThreeDayStreakV1,
          internalTitle: 'Three-day rhythm',
          sourceOwner: 'Act0ProfileStateV1.streakDays',
          state: safeStreakDays >= 3
              ? act0AchievementSeedStateEarnedV1
              : act0AchievementSeedStateNotEarnedV1,
          earned: safeStreakDays >= 3,
          earnedSequence: safeStreakDays >= 3 ? safeStreakDays : null,
          sourceSummary: safeStreakDays >= 3
              ? <String, Object?>{'streakDays': safeStreakDays}
              : const <String, Object?>{},
          eligibilityState: safeStreakDays >= 3
              ? act0AchievementSeedStateEarnedV1
              : act0AchievementSeedStateNotEarnedV1,
        ),
        const Act0AchievementSeedV1(
          id: act0AchievementSeedFirstLessonCompleteV1,
          internalTitle: 'First lesson complete',
          sourceOwner: 'route/progression completion source',
          state: act0AchievementSeedStateBlockedMissingSourceV1,
          earned: false,
          sourceSummary: <String, Object?>{},
          eligibilityState: act0AchievementSeedStateBlockedMissingSourceV1,
        ),
        const Act0AchievementSeedV1(
          id: act0AchievementSeedFirstCleanMiniDrillV1,
          internalTitle: 'First clean mini drill',
          sourceOwner: 'practice run source',
          state: act0AchievementSeedStateBlockedMissingSourceV1,
          earned: false,
          sourceSummary: <String, Object?>{},
          eligibilityState: act0AchievementSeedStateBlockedMissingSourceV1,
        ),
      ]),
    );
  }

  static Act0AchievementSeedProjectionV1? tryParse(Object? raw) {
    if (raw is! List) {
      return null;
    }
    final seeds =
        raw
            .map(Act0AchievementSeedV1.tryParse)
            .whereType<Act0AchievementSeedV1>()
            .toList(growable: false)
          ..sort((a, b) => _seedOrder(a.id).compareTo(_seedOrder(b.id)));
    return Act0AchievementSeedProjectionV1(
      seeds: List<Act0AchievementSeedV1>.unmodifiable(seeds),
    );
  }
}

class Act0AchievementSeedV1 {
  const Act0AchievementSeedV1({
    this.schemaVersion = 1,
    required this.id,
    required this.internalTitle,
    required this.sourceOwner,
    required this.state,
    required this.earned,
    this.earnedSequence,
    required this.sourceSummary,
    required this.eligibilityState,
  });

  final int schemaVersion;
  final String id;
  final String internalTitle;
  final String sourceOwner;
  final String state;
  final bool earned;
  final int? earnedSequence;
  final Map<String, Object?> sourceSummary;
  final String eligibilityState;

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'id': id,
    'internalTitle': internalTitle,
    'sourceOwner': sourceOwner,
    'state': state,
    'earned': earned,
    if (earnedSequence != null) 'earnedSequence': earnedSequence,
    'sourceSummary': sourceSummary,
    'eligibilityState': eligibilityState,
  };

  static Act0AchievementSeedV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']);
    final id = _requiredString(map['id']);
    final internalTitle = _requiredString(map['internalTitle']);
    final sourceOwner = _requiredString(map['sourceOwner']);
    final state = _requiredString(map['state']);
    final earned = map['earned'];
    final earnedSequence = map.containsKey('earnedSequence')
        ? _nonNegativeInt(map['earnedSequence'])
        : null;
    final sourceSummary = _summaryMap(map['sourceSummary']);
    final eligibilityState = _requiredString(map['eligibilityState']);
    if (schemaVersion != 1 ||
        id == null ||
        !_seedIdsV1.contains(id) ||
        internalTitle == null ||
        sourceOwner == null ||
        state == null ||
        !_seedStatesV1.contains(state) ||
        earned is! bool ||
        earned != (state == act0AchievementSeedStateEarnedV1) ||
        eligibilityState == null ||
        !_seedStatesV1.contains(eligibilityState) ||
        sourceSummary == null) {
      return null;
    }
    return Act0AchievementSeedV1(
      id: id,
      internalTitle: internalTitle,
      sourceOwner: sourceOwner,
      state: state,
      earned: earned,
      earnedSequence: earnedSequence,
      sourceSummary: Map<String, Object?>.unmodifiable(sourceSummary),
      eligibilityState: eligibilityState,
    );
  }
}

Act0AchievementSeedV1 _repairSeed({
  required List<Act0RepairIntentV1> repairIntents,
  required List<Act0ReviewMistakeRecordV1> reviewRecords,
}) {
  final earned = repairIntents.isNotEmpty || reviewRecords.isNotEmpty;
  final oldestReviewRecord = _oldestReviewRecord(reviewRecords);
  return Act0AchievementSeedV1(
    id: act0AchievementSeedFirstRepairNoteV1,
    internalTitle: 'Back to the spot',
    sourceOwner: 'Act0RepairIntentV1|Act0ReviewMistakeHistoryV1',
    state: earned
        ? act0AchievementSeedStateEarnedV1
        : act0AchievementSeedStateNotEarnedV1,
    earned: earned,
    earnedSequence: repairIntents.isNotEmpty
        ? 1
        : oldestReviewRecord?.createdOrder,
    sourceSummary: earned
        ? <String, Object?>{
            'repairIntentCount': repairIntents.length,
            'unresolvedHistoryCount': reviewRecords.length,
            if (oldestReviewRecord != null)
              'firstCreatedOrder': oldestReviewRecord.createdOrder,
          }
        : const <String, Object?>{},
    eligibilityState: earned
        ? act0AchievementSeedStateEarnedV1
        : act0AchievementSeedStateNotEarnedV1,
  );
}

Act0AchievementSeedV1 _earnedWhen<T extends Object>({
  required String id,
  required String internalTitle,
  required String sourceOwner,
  required T? earnedRecord,
  required Map<String, Object?> Function(T record) summaryBuilder,
  required int? Function(T record) sequenceBuilder,
}) {
  final earned = earnedRecord != null;
  return Act0AchievementSeedV1(
    id: id,
    internalTitle: internalTitle,
    sourceOwner: sourceOwner,
    state: earned
        ? act0AchievementSeedStateEarnedV1
        : act0AchievementSeedStateNotEarnedV1,
    earned: earned,
    earnedSequence: earned ? sequenceBuilder(earnedRecord) : null,
    sourceSummary: earned
        ? summaryBuilder(earnedRecord)
        : const <String, Object?>{},
    eligibilityState: earned
        ? act0AchievementSeedStateEarnedV1
        : act0AchievementSeedStateNotEarnedV1,
  );
}

Act0LearningEvidenceRecordV1? _firstCorrectRecord(
  Act0LearningEvidenceHistoryV1 history,
) {
  final records = history.records.where((record) => record.isCorrect).toList()
    ..sort((a, b) => a.createdOrder.compareTo(b.createdOrder));
  return records.isEmpty ? null : records.first;
}

Act0ReviewMistakeRecordV1? _oldestReviewRecord(
  List<Act0ReviewMistakeRecordV1> records,
) {
  final sorted = <Act0ReviewMistakeRecordV1>[...records]
    ..sort((a, b) => a.createdOrder.compareTo(b.createdOrder));
  return sorted.isEmpty ? null : sorted.first;
}

Act0ProfileCapabilitySignalV1? _firstEligibleSignal(
  Act0ProfileEvidenceProjectionV1 projection,
) {
  final signals =
      projection.signals.where((signal) => signal.isCapabilityEligible).toList()
        ..sort((a, b) => a.latestOrder.compareTo(b.latestOrder));
  return signals.isEmpty ? null : signals.first;
}

int _seedOrder(String id) {
  final index = _seedIdsV1.indexOf(id);
  return index == -1 ? _seedIdsV1.length : index;
}

const List<String> _seedIdsV1 = <String>[
  act0AchievementSeedFirstCorrectReadV1,
  act0AchievementSeedFirstRepairNoteV1,
  act0AchievementSeedFirstReviewHistoryItemV1,
  act0AchievementSeedFirstEvidenceSignalV1,
  act0AchievementSeedFirstSessionCompleteV1,
  act0AchievementSeedThreeDayStreakV1,
  act0AchievementSeedFirstLessonCompleteV1,
  act0AchievementSeedFirstCleanMiniDrillV1,
];

const Set<String> _seedStatesV1 = <String>{
  act0AchievementSeedStateEarnedV1,
  act0AchievementSeedStateNotEarnedV1,
  act0AchievementSeedStateBlockedMissingSourceV1,
  act0AchievementSeedStateDeferredV1,
};

String? _requiredString(Object? raw) {
  final value = raw?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

int? _nonNegativeInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}

Map<String, Object?>? _summaryMap(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  return raw.map((key, value) => MapEntry(key.toString(), value));
}
