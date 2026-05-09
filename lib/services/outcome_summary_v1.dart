import 'package:poker_analyzer/engine/scenario_replayer/scenario_models.dart';

enum OutcomeKindV1 { success, mistake, aborted, unknown }

class OutcomeSummaryV1 {
  const OutcomeSummaryV1({
    required this.packId,
    required this.worldId,
    required this.beatIndex,
    required this.outcomeKind,
    required this.lines,
    this.errorType,
    this.timeToDecisionMs,
  });

  final String packId;
  final int worldId;
  final int beatIndex;
  final OutcomeKindV1 outcomeKind;
  final String? errorType;
  final int? timeToDecisionMs;
  final List<String> lines;

  static OutcomeSummaryV1 fromScenarioResult({
    required String packId,
    required int worldId,
    required int beatIndex,
    required ReplayerSeat winner,
    required String reason,
    required ScenarioReplayerViewModel finalSnapshot,
    int? timeToDecisionMs,
  }) {
    final normalizedReason = reason.trim().toLowerCase();
    final kind = _resolveOutcomeKind(
      winner: winner,
      normalizedReason: normalizedReason,
    );
    final errorType = kind == OutcomeKindV1.mistake
        ? (normalizedReason.isEmpty ? 'incorrect_line' : normalizedReason)
        : null;
    final outcomeLine = _outcomeLineForKind(kind);

    final lines = <String>[
      'Pack: $packId',
      'Beat: W$worldId #${beatIndex + 1}',
      outcomeLine,
      'Stacks: hero ${finalSnapshot.heroStack}, villain ${finalSnapshot.villainStack}, pot ${finalSnapshot.pot}',
    ];
    if (kind == OutcomeKindV1.mistake) {
      lines.add('Fact: villain won after ${_reasonLabel(normalizedReason)}.');
    }
    if (kind == OutcomeKindV1.aborted) {
      lines.add('Fact: run stopped before a resolved showdown.');
    }
    if (errorType != null) {
      lines.add('Error type: $errorType');
    }
    if (timeToDecisionMs != null) {
      lines.add('Decision ms: $timeToDecisionMs');
    }

    return OutcomeSummaryV1(
      packId: packId,
      worldId: worldId,
      beatIndex: beatIndex,
      outcomeKind: kind,
      errorType: errorType,
      timeToDecisionMs: timeToDecisionMs,
      lines: List<String>.unmodifiable(lines),
    );
  }

  static OutcomeKindV1 _resolveOutcomeKind({
    required ReplayerSeat winner,
    required String normalizedReason,
  }) {
    if (normalizedReason == 'aborted' ||
        normalizedReason == 'timeout' ||
        normalizedReason == 'quit') {
      return OutcomeKindV1.aborted;
    }
    if (winner == ReplayerSeat.hero) return OutcomeKindV1.success;
    if (winner == ReplayerSeat.villain) return OutcomeKindV1.mistake;
    return OutcomeKindV1.unknown;
  }

  static String _outcomeLineForKind(OutcomeKindV1 kind) {
    switch (kind) {
      case OutcomeKindV1.success:
        return 'Outcome: line held';
      case OutcomeKindV1.mistake:
        return 'Outcome: mistake punished';
      case OutcomeKindV1.aborted:
        return 'Outcome: run aborted';
      case OutcomeKindV1.unknown:
        return 'Outcome: unresolved';
    }
  }

  static String _reasonLabel(String normalizedReason) {
    if (normalizedReason.isEmpty) return 'incorrect line';
    return normalizedReason;
  }
}
