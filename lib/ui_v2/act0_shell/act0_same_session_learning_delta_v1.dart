import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_run_payoff_v1.dart';

const String act0SameSessionLearningDeltaKindV1 = 'same_session_recovery';
const String act0SameSessionLearningDeltaOutcomeTypeV1 =
    'recovered_after_repair';

/// A read-only, ephemeral projection of the current in-memory Learning Run.
///
/// This is deliberately not persisted and not a durable Fix Proof or
/// later-transfer observation: it describes only one machine-observable
/// change on the terminal original-source recheck, while the recovery-
/// bearing Learning Run still exists (i.e. before Review closes it).
class Act0SameSessionLearningDeltaProjectionV1 {
  const Act0SameSessionLearningDeltaProjectionV1({this.primaryDelta});

  final Act0SameSessionLearningDeltaV1? primaryDelta;

  factory Act0SameSessionLearningDeltaProjectionV1.fromLearningRun(
    Act0LearningRunStateV1? run,
  ) => Act0SameSessionLearningDeltaProjectionV1.fromOutcomes(
    run?.outcomes ?? const <Act0LearningRunOutcomeV1>[],
  );

  factory Act0SameSessionLearningDeltaProjectionV1.fromOutcomes(
    Iterable<Act0LearningRunOutcomeV1> outcomes,
  ) {
    final eligible =
        outcomes
            .map(_deltaForOutcomeV1)
            .whereType<Act0SameSessionLearningDeltaV1>()
            .toList(growable: false)
          ..sort((a, b) {
            final order = b.eventOrder.compareTo(a.eventOrder);
            return order != 0 ? order : a.deltaId.compareTo(b.deltaId);
          });
    return Act0SameSessionLearningDeltaProjectionV1(
      primaryDelta: eligible.isEmpty ? null : eligible.first,
    );
  }
}

class Act0SameSessionLearningDeltaV1 {
  const Act0SameSessionLearningDeltaV1({
    required this.deltaId,
    required this.deltaKind,
    required this.outcomeType,
    required this.sourceTaskId,
    required this.skillId,
    required this.missedSignalId,
    required this.line,
    required this.eventOrder,
  });

  final String deltaId;
  final String deltaKind;
  final String outcomeType;
  final String sourceTaskId;
  final String skillId;
  final String missedSignalId;
  final String line;
  final int eventOrder;

  Map<String, Object?> get telemetryFields => <String, Object?>{
    'schemaVersion': 1,
    'delta_kind': deltaKind,
    'outcome_type': outcomeType,
    'skill_id': skillId,
    'missed_signal_id': missedSignalId,
    'surface': 'source_recheck_feedback',
    'evidence_count': 1,
  };
}

class _Act0LearningDeltaDescriptorV1 {
  const _Act0LearningDeltaDescriptorV1(this.focus);

  final String focus;
}

Act0SameSessionLearningDeltaV1? _deltaForOutcomeV1(
  Act0LearningRunOutcomeV1 outcome,
) {
  final outcomeId = outcome.outcomeId.trim();
  final taskId = outcome.taskId.trim();
  final skillId = outcome.skillId.trim();
  final missedSignalId = outcome.missedSignal.trim();
  if (outcomeId.isEmpty ||
      taskId.isEmpty ||
      skillId.isEmpty ||
      missedSignalId.isEmpty ||
      outcome.firstAttemptCorrect ||
      !outcome.repairAttempted ||
      outcome.recheckResult != true ||
      outcome.finalOutcome !=
          Act0LearningRunFinalOutcomeV1.recoveredAfterRepair) {
    return null;
  }
  final descriptor = _descriptorForV1(skillId, missedSignalId);
  if (descriptor == null) return null;
  final deltaId = 'same_session_delta_v1|$outcomeId|$skillId|$missedSignalId';
  return Act0SameSessionLearningDeltaV1(
    deltaId: deltaId,
    deltaKind: act0SameSessionLearningDeltaKindV1,
    outcomeType: act0SameSessionLearningDeltaOutcomeTypeV1,
    sourceTaskId: taskId,
    skillId: skillId,
    missedSignalId: missedSignalId,
    line:
        'You missed ${descriptor.focus} first. '
        'On the recheck, you used it correctly.',
    eventOrder: outcome.eventOrder,
  );
}

_Act0LearningDeltaDescriptorV1? _descriptorForV1(
  String skillId,
  String missedSignalId,
) => switch (skillId) {
  'action_read' => const _Act0LearningDeltaDescriptorV1('action order'),
  'table_position_read' => const _Act0LearningDeltaDescriptorV1(
    'Hero position',
  ),
  'price_read' => const _Act0LearningDeltaDescriptorV1('the price to continue'),
  'table_read' when missedSignalId == 'hero_seat' =>
    const _Act0LearningDeltaDescriptorV1("Hero's seat"),
  _ => null,
};
