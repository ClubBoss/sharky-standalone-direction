import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_imported_hand_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

enum Act0DecisionConfidenceV1 { unsure, somewhatSure, verySure }

enum Act0CausalClueV1 {
  callPrice('Compare the chips you still owe with the pot after your call.'),
  remainingPlayers('Look at who can still act after your decision.'),
  sharedCards('Compare the shared cards with the cards only you hold.'),
  effectiveStack('Compare what you and the opponent can still put in.');

  const Act0CausalClueV1(this.text);
  final String text;
}

/// Only explicitly requested help is recorded. Confidence is optional and
/// independent of both assistance and the grade saved in decision evidence.
class Act0AttemptReflectionV1 {
  const Act0AttemptReflectionV1({this.confidence, this.openedClue});

  final Act0DecisionConfidenceV1? confidence;
  final Act0CausalClueV1? openedClue;

  Act0DecisionAssistanceV1 assistanceFor(Act0DecisionAssistanceV1 existing) =>
      openedClue == null || existing == Act0DecisionAssistanceV1.theoryRecall
      ? existing
      : Act0DecisionAssistanceV1.quickHint;
}

class Act0ArchivedAttemptV1 {
  Act0ArchivedAttemptV1._(
    this.evidence,
    this.reflection,
    this.events,
    this.taskLabel,
    this.choiceLabel,
  );

  static final _sourceRevision = RegExp(r'^[a-f0-9]{64}$');

  /// Capture a journal at submission. Historical evidence alone can be
  /// archived with an empty journal. Never populate it from today's catalog.
  static Act0ArchivedAttemptV1? fromRecordedDecision(
    Act0LearningEvidenceRecordV1 evidence, {
    Act0AttemptReflectionV1 reflection = const Act0AttemptReflectionV1(),
    Iterable<Act0ActionTrailItemV1> recordedTrail = const [],
    String? taskLabel,
    String? choiceLabel,
  }) {
    if (Act0LearningEvidenceRecordV1.tryParse(evidence.toPayload()) == null ||
        !_sourceRevision.hasMatch(evidence.authoredSourceFingerprint) ||
        evidence.recordedAtUtc == null ||
        evidence.assistanceKind == Act0DecisionAssistanceV1.legacyUnknown ||
        reflection.assistanceFor(evidence.assistanceKind) !=
            evidence.assistanceKind) {
      return null;
    }
    final events = recordedTrail.toList(growable: false);
    if (events.any(
      (event) =>
          event.label.trim().isEmpty || event.learnerLabel.trim().isEmpty,
    )) {
      return null;
    }
    return Act0ArchivedAttemptV1._(
      evidence,
      reflection,
      List.unmodifiable(events),
      taskLabel,
      choiceLabel,
    );
  }

  final Act0LearningEvidenceRecordV1 evidence;
  final Act0AttemptReflectionV1 reflection;
  final List<Act0ActionTrailItemV1> events;
  final String? taskLabel;
  final String? choiceLabel;

  String get id => evidence.recordId;

  Map<String, Object?> toPayload({bool linkEvidence = false}) => {
    if (linkEvidence) 'recordId': id else 'evidence': evidence.toPayload(),
    if (taskLabel != null) 'taskLabel': taskLabel,
    if (choiceLabel != null) 'choiceLabel': choiceLabel,
    if (reflection.confidence case final confidence?)
      'confidence': confidence.name,
    if (reflection.openedClue case final clue?) 'openedClue': clue.name,
    'events': [
      for (final event in events)
        {
          'kind': event.kind.name,
          'label': event.label,
          if (event.displayLabel != null) 'displayLabel': event.displayLabel,
        },
    ],
  };

  static Act0ArchivedAttemptV1? tryParse(
    Object? raw, {
    Map<String, Act0LearningEvidenceRecordV1> evidenceById = const {},
  }) {
    if (raw is! Map || raw['events'] is! List) return null;
    final reference = raw['recordId'];
    if (reference != null &&
        (reference is! String || raw.containsKey('evidence'))) {
      return null;
    }
    final evidence = reference == null
        ? Act0LearningEvidenceRecordV1.tryParse(raw['evidence'])
        : evidenceById[reference];
    if (evidence == null) return null;
    final taskLabel = raw['taskLabel'];
    final choiceLabel = raw['choiceLabel'];
    if ((taskLabel != null && taskLabel is! String) ||
        (choiceLabel != null && choiceLabel is! String)) {
      return null;
    }
    final confidence = Act0DecisionConfidenceV1.values
        .where((value) => value.name == raw['confidence'])
        .firstOrNull;
    final clue = Act0CausalClueV1.values
        .where((value) => value.name == raw['openedClue'])
        .firstOrNull;
    if ((raw.containsKey('confidence') && confidence == null) ||
        (raw.containsKey('openedClue') && clue == null)) {
      return null;
    }
    final events = <Act0ActionTrailItemV1>[];
    for (final event in raw['events'] as List) {
      if (event is! Map || event['label'] is! String) return null;
      final label = event['label'] as String;
      final display = event['displayLabel'];
      if (display != null && display is! String) return null;
      switch (event['kind']) {
        case 'action':
          events.add(
            Act0ActionTrailItemV1(
              label: label,
              displayLabel: display as String?,
            ),
          );
        case 'note':
          events.add(
            Act0ActionTrailItemV1.note(
              label: label,
              displayLabel: display as String?,
            ),
          );
        default:
          return null;
      }
    }
    return fromRecordedDecision(
      evidence,
      reflection: Act0AttemptReflectionV1(
        confidence: confidence,
        openedClue: clue,
      ),
      recordedTrail: events,
      taskLabel: taskLabel as String?,
      choiceLabel: choiceLabel as String?,
    );
  }
}

class Act0AttemptArchiveV1 {
  const Act0AttemptArchiveV1.empty()
    : attempts = const [],
      importedHands = const [],
      selectedId = null;

  Act0AttemptArchiveV1._(
    Iterable<Act0ArchivedAttemptV1> attempts,
    this.selectedId,
    Iterable<Act0ImportedHandV1> importedHands,
  ) : attempts = List.unmodifiable(attempts),
      importedHands = List.unmodifiable(importedHands);

  static const limit = Act0LearningEvidenceHistoryV1.maxRecords;
  final List<Act0ArchivedAttemptV1> attempts;
  final List<Act0ImportedHandV1> importedHands;
  final String? selectedId;

  Act0ArchivedAttemptV1? get selected =>
      attempts.where((attempt) => attempt.id == selectedId).firstOrNull;

  Act0AttemptArchiveV1 add(Act0ArchivedAttemptV1 attempt) {
    if (attempts.any((saved) => saved.id == attempt.id)) return this;
    final next = [attempt, ...attempts]
      ..sort(
        (a, b) => b.evidence.createdOrder.compareTo(a.evidence.createdOrder),
      );
    final kept = next.take(limit).toList();
    return Act0AttemptArchiveV1._(
      kept,
      kept.any((saved) => saved.id == selectedId) ? selectedId : null,
      importedHands,
    );
  }

  Act0AttemptArchiveV1 select(String? id) => Act0AttemptArchiveV1._(
    attempts,
    attempts.any((attempt) => attempt.id == id) ? id : null,
    importedHands,
  );

  Act0AttemptArchiveV1 remove(String id) => Act0AttemptArchiveV1._(
    attempts.where((attempt) => attempt.id != id),
    selectedId == id ? null : selectedId,
    importedHands,
  );

  /// A source hand never enters the graded attempt or learning evidence lists.
  Act0AttemptArchiveV1 importPokerStars(String text) {
    final hand = Act0ImportedHandV1.parsePokerStars(text);
    for (final saved in importedHands) {
      if (saved.sourceKey != hand.sourceKey) continue;
      if (saved.hasSameRecord(hand)) return this;
      throw const Act0HandImportExceptionV1(
        Act0HandImportErrorV1.conflictingSource,
      );
    }
    return Act0AttemptArchiveV1._(
      attempts,
      selectedId,
      [hand, ...importedHands].take(limit),
    );
  }

  Act0AttemptArchiveV1 saveManualHand(Act0ImportedHandV1 hand) {
    if (!hand.isManual) throw ArgumentError('Expected a manual hand.');
    final exists = importedHands.any(
      (saved) => saved.sourceKey == hand.sourceKey,
    );
    return Act0AttemptArchiveV1._(
      attempts,
      selectedId,
      exists
          ? [
              for (final saved in importedHands)
                saved.sourceKey == hand.sourceKey ? hand : saved,
            ]
          : [hand, ...importedHands].take(limit),
    );
  }

  Act0AttemptArchiveV1 removeImportedHand(String sourceKey) =>
      Act0AttemptArchiveV1._(
        attempts,
        selectedId,
        importedHands.where((hand) => hand.sourceKey != sourceKey),
      );

  /// A progress snapshot can share evidence it already writes in full.
  /// Attempts that age out of the main history still carry their own copy.
  Map<String, Object?> toPayload({
    Iterable<Act0LearningEvidenceRecordV1> snapshotRecords = const [],
  }) {
    final evidenceById = {for (final row in snapshotRecords) row.recordId: row};
    return {
      'format': 1,
      'entries': [
        for (final attempt in attempts)
          attempt.toPayload(
            linkEvidence: evidenceById[attempt.id] == attempt.evidence,
          ),
      ],
      if (importedHands.isNotEmpty)
        'importedHands': [for (final hand in importedHands) hand.toPayload()],
      if (selectedId != null) 'selectedId': selectedId,
    };
  }

  /// Migrate once, when the progress payload predates the archive field.
  /// These records can prove a decision but have no historical event journal.
  static Act0AttemptArchiveV1 fromOlderSave(
    Act0LearningEvidenceHistoryV1 history,
  ) {
    var archive = const Act0AttemptArchiveV1.empty();
    for (final evidence in history.records) {
      if (Act0ArchivedAttemptV1.fromRecordedDecision(evidence)
          case final attempt?) {
        archive = archive.add(attempt);
      }
    }
    return archive;
  }

  static Act0AttemptArchiveV1 restore(
    Object? payload, {
    Iterable<Act0LearningEvidenceRecordV1> snapshotRecords = const [],
  }) {
    if (payload is! Map ||
        payload['format'] != 1 ||
        payload['entries'] is! List) {
      return const Act0AttemptArchiveV1.empty();
    }
    final evidenceById = {for (final row in snapshotRecords) row.recordId: row};
    final records = <String, Act0ArchivedAttemptV1>{};
    for (final row in payload['entries'] as List) {
      if (Act0ArchivedAttemptV1.tryParse(row, evidenceById: evidenceById)
          case final attempt?) {
        records.putIfAbsent(attempt.id, () => attempt);
      }
    }
    final ordered = records.values.toList()
      ..sort(
        (a, b) => b.evidence.createdOrder.compareTo(a.evidence.createdOrder),
      );
    final attempts = ordered.take(limit);
    final selection = payload['selectedId'];
    return Act0AttemptArchiveV1._(
      attempts,
      selection is String && attempts.any((attempt) => attempt.id == selection)
          ? selection
          : null,
      _restoreImportedHands(payload['importedHands']),
    );
  }

  static Iterable<Act0ImportedHandV1> _restoreImportedHands(Object? raw) {
    if (raw is! List || raw.length > limit) return const [];
    final hands = <String, Act0ImportedHandV1>{};
    final conflicts = <String>{};
    for (final row in raw) {
      final hand = Act0ImportedHandV1.tryParse(row);
      if (hand == null) continue;
      final saved = hands.putIfAbsent(hand.sourceKey, () => hand);
      if (!saved.hasSameRecord(hand)) conflicts.add(hand.sourceKey);
    }
    return hands.values.where((hand) => !conflicts.contains(hand.sourceKey));
  }
}

/// A replay cursor owns no hand or grade. Its positions count saved events.
class Act0AttemptReplayV1 {
  Act0AttemptReplayV1(Act0ArchivedAttemptV1 attempt)
    : this.events(attempt.events);
  const Act0AttemptReplayV1.events(this.events)
    : position = 0,
      isPlaying = false;
  const Act0AttemptReplayV1._(this.events, this.position, this.isPlaying);

  final List<Act0ActionTrailItemV1> events;
  final int position;
  final bool isPlaying;

  bool get atEnd => position == events.length;
  Act0ActionTrailItemV1? get current =>
      position == 0 ? null : events[position - 1];
  List<String> get textAlternative =>
      events.take(position).map((event) => event.learnerLabel).toList();

  Act0AttemptReplayV1 play() =>
      atEnd ? this : Act0AttemptReplayV1._(events, position, true);
  Act0AttemptReplayV1 pause() => Act0AttemptReplayV1._(events, position, false);
  Act0AttemptReplayV1 reset() => Act0AttemptReplayV1.events(events);
  Act0AttemptReplayV1 back() =>
      Act0AttemptReplayV1._(events, position > 0 ? position - 1 : 0, false);

  Act0AttemptReplayV1 forward() {
    if (atEnd) return this;
    final next = position + 1;
    return Act0AttemptReplayV1._(
      events,
      next,
      isPlaying && next < events.length,
    );
  }

  Act0AttemptReplayV1 tick() => isPlaying ? forward() : this;
}
