import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
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
  Act0ArchivedAttemptV1._(this.evidence, this.reflection, this.events);

  static final _sourceRevision = RegExp(r'^[a-f0-9]{64}$');

  /// Capture a journal at submission. Historical evidence alone can be
  /// archived with an empty journal. Never populate it from today's catalog.
  static Act0ArchivedAttemptV1? fromRecordedDecision(
    Act0LearningEvidenceRecordV1 evidence, {
    Act0AttemptReflectionV1 reflection = const Act0AttemptReflectionV1(),
    Iterable<Act0ActionTrailItemV1> recordedTrail = const [],
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
    );
  }

  final Act0LearningEvidenceRecordV1 evidence;
  final Act0AttemptReflectionV1 reflection;
  final List<Act0ActionTrailItemV1> events;

  String get id => evidence.recordId;

  Map<String, Object?> toPayload() => {
    'evidence': evidence.toPayload(),
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

  static Act0ArchivedAttemptV1? tryParse(Object? raw) {
    if (raw is! Map || raw['events'] is! List) return null;
    final evidence = Act0LearningEvidenceRecordV1.tryParse(raw['evidence']);
    if (evidence == null) return null;
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
    );
  }
}

class Act0AttemptArchiveV1 {
  const Act0AttemptArchiveV1.empty() : attempts = const [], selectedId = null;

  Act0AttemptArchiveV1._(
    Iterable<Act0ArchivedAttemptV1> attempts,
    this.selectedId,
  ) : attempts = List.unmodifiable(attempts);

  static const limit = Act0LearningEvidenceHistoryV1.maxRecords;
  final List<Act0ArchivedAttemptV1> attempts;
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
    );
  }

  Act0AttemptArchiveV1 select(String? id) => Act0AttemptArchiveV1._(
    attempts,
    attempts.any((attempt) => attempt.id == id) ? id : null,
  );

  Act0AttemptArchiveV1 remove(String id) => Act0AttemptArchiveV1._(
    attempts.where((attempt) => attempt.id != id),
    selectedId == id ? null : selectedId,
  );

  Map<String, Object?> toPayload() => {
    'format': 1,
    'entries': attempts.map((attempt) => attempt.toPayload()).toList(),
    if (selectedId != null) 'selectedId': selectedId,
  };

  static Act0AttemptArchiveV1 restore(Object? payload) {
    if (payload is! Map ||
        payload['format'] != 1 ||
        payload['entries'] is! List) {
      return const Act0AttemptArchiveV1.empty();
    }
    var archive = const Act0AttemptArchiveV1.empty();
    for (final row in payload['entries'] as List) {
      if (Act0ArchivedAttemptV1.tryParse(row) case final attempt?) {
        archive = archive.add(attempt);
      }
    }
    final selection = payload['selectedId'];
    return selection is String ? archive.select(selection) : archive;
  }
}

/// A replay cursor owns no hand or grade. Its positions count saved events.
class Act0AttemptReplayV1 {
  const Act0AttemptReplayV1(this.attempt) : position = 0, isPlaying = false;
  const Act0AttemptReplayV1._(this.attempt, this.position, this.isPlaying);

  final Act0ArchivedAttemptV1 attempt;
  final int position;
  final bool isPlaying;

  bool get atEnd => position == attempt.events.length;
  Act0ActionTrailItemV1? get current =>
      position == 0 ? null : attempt.events[position - 1];
  List<String> get textAlternative =>
      attempt.events.take(position).map((event) => event.learnerLabel).toList();

  Act0AttemptReplayV1 play() =>
      atEnd ? this : Act0AttemptReplayV1._(attempt, position, true);
  Act0AttemptReplayV1 pause() =>
      Act0AttemptReplayV1._(attempt, position, false);
  Act0AttemptReplayV1 reset() => Act0AttemptReplayV1(attempt);
  Act0AttemptReplayV1 back() =>
      Act0AttemptReplayV1._(attempt, position > 0 ? position - 1 : 0, false);

  Act0AttemptReplayV1 forward() {
    if (atEnd) return this;
    final next = position + 1;
    return Act0AttemptReplayV1._(
      attempt,
      next,
      isPlaying && next < attempt.events.length,
    );
  }

  Act0AttemptReplayV1 tick() => isPlaying ? forward() : this;
}
