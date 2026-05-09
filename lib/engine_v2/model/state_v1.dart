import 'engine_types_v1.dart';
import 'snapshot_v1.dart';

abstract class EngineStateV1 {
  const EngineStateV1({required this.kind, required this.snapshot});

  final EngineStateKindV1 kind;
  final EngineSnapshotV1 snapshot;

  @override
  bool operator ==(Object other) {
    if (other is! EngineStateV1) {
      return false;
    }
    return kind == other.kind && snapshot == other.snapshot;
  }

  @override
  int get hashCode => Object.hash(kind, snapshot);
}

class SetupEngineStateV1 extends EngineStateV1 {
  const SetupEngineStateV1({required super.snapshot})
    : super(kind: EngineStateKindV1.setup);
}

class StreetActiveEngineStateV1 extends EngineStateV1 {
  const StreetActiveEngineStateV1({
    required this.phase,
    required super.snapshot,
  }) : super(kind: EngineStateKindV1.streetActive);

  final StreetPhaseV1 phase;

  @override
  bool operator ==(Object other) {
    if (other is! StreetActiveEngineStateV1) {
      return false;
    }
    return phase == other.phase && super == other;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, phase);
}

class EvaluationEngineStateV1 extends EngineStateV1 {
  const EvaluationEngineStateV1({required super.snapshot})
    : super(kind: EngineStateKindV1.evaluation);
}

class OutcomeEngineStateV1 extends EngineStateV1 {
  const OutcomeEngineStateV1({required super.snapshot})
    : super(kind: EngineStateKindV1.outcome);
}
