import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

const int act0ProfileEvidenceMinimumAttemptsV1 = 5;
const int act0ProfileEvidenceMinimumCorrectForPositiveSignalV1 = 3;

const String act0ProfileEvidenceStateInsufficientSampleV1 =
    'insufficient_sample_v1';
const String act0ProfileEvidenceStateEligibleSignalV1 = 'eligible_signal_v1';
const String act0ProfileEvidenceStateNeedsMorePracticeV1 =
    'needs_more_practice_v1';

class Act0ProfileEvidenceProjectionV1 {
  const Act0ProfileEvidenceProjectionV1({
    this.signals = const <Act0ProfileCapabilitySignalV1>[],
  });

  final List<Act0ProfileCapabilitySignalV1> signals;

  bool get hasSignals => signals.isNotEmpty;

  List<Map<String, Object?>> toPayload() =>
      signals.map((signal) => signal.toPayload()).toList(growable: false);

  static Act0ProfileEvidenceProjectionV1 fromLearningEvidenceHistory(
    Act0LearningEvidenceHistoryV1 history, {
    int sampleThreshold = act0ProfileEvidenceMinimumAttemptsV1,
    int minimumCorrectForPositiveSignal =
        act0ProfileEvidenceMinimumCorrectForPositiveSignalV1,
  }) {
    final safeSampleThreshold = sampleThreshold < 1
        ? act0ProfileEvidenceMinimumAttemptsV1
        : sampleThreshold;
    final safeMinimumCorrect = minimumCorrectForPositiveSignal < 1
        ? act0ProfileEvidenceMinimumCorrectForPositiveSignalV1
        : minimumCorrectForPositiveSignal;
    final groups = <String, List<Act0LearningEvidenceRecordV1>>{};
    for (final record in history.records) {
      final skillAtomId = record.skillAtomId.trim();
      if (skillAtomId.isEmpty) {
        continue;
      }
      groups.putIfAbsent(skillAtomId, () => <Act0LearningEvidenceRecordV1>[]);
      groups[skillAtomId]!.add(record);
    }
    final signals = <Act0ProfileCapabilitySignalV1>[];
    for (final entry in groups.entries) {
      final records = entry.value
        ..sort((a, b) => a.createdOrder.compareTo(b.createdOrder));
      final attemptCount = records.length;
      final correctCount = records.where((record) => record.isCorrect).length;
      final incorrectCount = attemptCount - correctCount;
      final sampleThresholdMet = attemptCount >= safeSampleThreshold;
      final positiveSignalThresholdMet = correctCount >= safeMinimumCorrect;
      final eligibilityState = !sampleThresholdMet
          ? act0ProfileEvidenceStateInsufficientSampleV1
          : positiveSignalThresholdMet
          ? act0ProfileEvidenceStateEligibleSignalV1
          : act0ProfileEvidenceStateNeedsMorePracticeV1;
      signals.add(
        Act0ProfileCapabilitySignalV1(
          signalId: 'profile_evidence_v1|${entry.key}',
          skillAtomId: entry.key,
          attemptCount: attemptCount,
          correctCount: correctCount,
          incorrectCount: incorrectCount,
          accuracyPercent: ((correctCount * 100) / attemptCount).round(),
          sampleThreshold: safeSampleThreshold,
          sampleThresholdMet: sampleThresholdMet,
          positiveSignalThresholdMet: positiveSignalThresholdMet,
          worldIds: _sortedUnique(records.map((record) => record.worldId)),
          lessonIds: _sortedUnique(records.map((record) => record.lessonId)),
          latestOrder: records.last.createdOrder,
          eligibilityState: eligibilityState,
        ),
      );
    }
    signals.sort((a, b) => a.skillAtomId.compareTo(b.skillAtomId));
    return Act0ProfileEvidenceProjectionV1(
      signals: List<Act0ProfileCapabilitySignalV1>.unmodifiable(signals),
    );
  }

  static Act0ProfileEvidenceProjectionV1? tryParse(Object? raw) {
    if (raw is! List) {
      return null;
    }
    final signals =
        raw
            .map(Act0ProfileCapabilitySignalV1.tryParse)
            .whereType<Act0ProfileCapabilitySignalV1>()
            .toList(growable: false)
          ..sort((a, b) => a.skillAtomId.compareTo(b.skillAtomId));
    return Act0ProfileEvidenceProjectionV1(
      signals: List<Act0ProfileCapabilitySignalV1>.unmodifiable(signals),
    );
  }
}

class Act0ProfileCapabilitySignalV1 {
  const Act0ProfileCapabilitySignalV1({
    this.schemaVersion = 1,
    required this.signalId,
    required this.skillAtomId,
    required this.attemptCount,
    required this.correctCount,
    required this.incorrectCount,
    required this.accuracyPercent,
    required this.sampleThreshold,
    required this.sampleThresholdMet,
    required this.positiveSignalThresholdMet,
    required this.worldIds,
    required this.lessonIds,
    required this.latestOrder,
    required this.eligibilityState,
  });

  final int schemaVersion;
  final String signalId;
  final String skillAtomId;
  final int attemptCount;
  final int correctCount;
  final int incorrectCount;
  final int accuracyPercent;
  final int sampleThreshold;
  final bool sampleThresholdMet;
  final bool positiveSignalThresholdMet;
  final List<String> worldIds;
  final List<String> lessonIds;
  final int latestOrder;
  final String eligibilityState;

  bool get isCapabilityEligible =>
      eligibilityState == act0ProfileEvidenceStateEligibleSignalV1;

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'signalId': signalId,
    'skillAtomId': skillAtomId,
    'attemptCount': attemptCount,
    'correctCount': correctCount,
    'incorrectCount': incorrectCount,
    'accuracyPercent': accuracyPercent,
    'sampleThreshold': sampleThreshold,
    'sampleThresholdMet': sampleThresholdMet,
    'positiveSignalThresholdMet': positiveSignalThresholdMet,
    'worldIds': worldIds,
    'lessonIds': lessonIds,
    'latestOrder': latestOrder,
    'eligibilityState': eligibilityState,
  };

  static Act0ProfileCapabilitySignalV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']);
    final signalId = _requiredString(map['signalId']);
    final skillAtomId = _requiredString(map['skillAtomId']);
    final attemptCount = _positiveInt(map['attemptCount']);
    final correctCount = _nonNegativeInt(map['correctCount']);
    final incorrectCount = _nonNegativeInt(map['incorrectCount']);
    final accuracyPercent = _boundedPercent(map['accuracyPercent']);
    final sampleThreshold = _positiveInt(map['sampleThreshold']);
    final sampleThresholdMet = map['sampleThresholdMet'];
    final positiveSignalThresholdMet = map['positiveSignalThresholdMet'];
    final worldIds = _uniqueStringList(map['worldIds']);
    final lessonIds = _uniqueStringList(map['lessonIds']);
    final latestOrder = _nonNegativeInt(map['latestOrder']);
    final eligibilityState = _requiredString(map['eligibilityState']);
    if (schemaVersion != 1 ||
        signalId == null ||
        skillAtomId == null ||
        attemptCount == null ||
        correctCount == null ||
        incorrectCount == null ||
        attemptCount != correctCount + incorrectCount ||
        accuracyPercent == null ||
        sampleThreshold == null ||
        sampleThresholdMet is! bool ||
        sampleThresholdMet != (attemptCount >= sampleThreshold) ||
        positiveSignalThresholdMet is! bool ||
        worldIds.isEmpty ||
        lessonIds.isEmpty ||
        latestOrder == null ||
        eligibilityState == null ||
        !_profileEvidenceStatesV1.contains(eligibilityState)) {
      return null;
    }
    final expectedState = !sampleThresholdMet
        ? act0ProfileEvidenceStateInsufficientSampleV1
        : positiveSignalThresholdMet
        ? act0ProfileEvidenceStateEligibleSignalV1
        : act0ProfileEvidenceStateNeedsMorePracticeV1;
    if (eligibilityState != expectedState) {
      return null;
    }
    return Act0ProfileCapabilitySignalV1(
      signalId: signalId,
      skillAtomId: skillAtomId,
      attemptCount: attemptCount,
      correctCount: correctCount,
      incorrectCount: incorrectCount,
      accuracyPercent: accuracyPercent,
      sampleThreshold: sampleThreshold,
      sampleThresholdMet: sampleThresholdMet,
      positiveSignalThresholdMet: positiveSignalThresholdMet,
      worldIds: List<String>.unmodifiable(worldIds),
      lessonIds: List<String>.unmodifiable(lessonIds),
      latestOrder: latestOrder,
      eligibilityState: eligibilityState,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Act0ProfileCapabilitySignalV1 &&
      other.schemaVersion == schemaVersion &&
      other.signalId == signalId &&
      other.skillAtomId == skillAtomId &&
      other.attemptCount == attemptCount &&
      other.correctCount == correctCount &&
      other.incorrectCount == incorrectCount &&
      other.accuracyPercent == accuracyPercent &&
      other.sampleThreshold == sampleThreshold &&
      other.sampleThresholdMet == sampleThresholdMet &&
      other.positiveSignalThresholdMet == positiveSignalThresholdMet &&
      _sameStrings(other.worldIds, worldIds) &&
      _sameStrings(other.lessonIds, lessonIds) &&
      other.latestOrder == latestOrder &&
      other.eligibilityState == eligibilityState;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    schemaVersion,
    signalId,
    skillAtomId,
    attemptCount,
    correctCount,
    incorrectCount,
    accuracyPercent,
    sampleThreshold,
    sampleThresholdMet,
    positiveSignalThresholdMet,
    ...worldIds,
    ...lessonIds,
    latestOrder,
    eligibilityState,
  ]);
}

const Set<String> _profileEvidenceStatesV1 = <String>{
  act0ProfileEvidenceStateInsufficientSampleV1,
  act0ProfileEvidenceStateEligibleSignalV1,
  act0ProfileEvidenceStateNeedsMorePracticeV1,
};

List<String> _sortedUnique(Iterable<String> raw) {
  final values =
      raw
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(growable: false)
        ..sort();
  return List<String>.unmodifiable(values);
}

List<String> _uniqueStringList(Object? raw) {
  if (raw is! List) {
    return const <String>[];
  }
  return _sortedUnique(raw.map((value) => value?.toString() ?? ''));
}

bool _sameStrings(List<String> a, List<String> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

String? _requiredString(Object? raw) {
  final value = raw?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

int? _nonNegativeInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}

int? _positiveInt(Object? raw) {
  final value = _nonNegativeInt(raw);
  return value == null || value < 1 ? null : value;
}

int? _boundedPercent(Object? raw) {
  final value = _nonNegativeInt(raw);
  return value == null || value > 100 ? null : value;
}
