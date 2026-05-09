import 'persona_activation_preflight_delta_v4.dart';
import 'persona_activation_preflight_gate_consistency_v4.dart';
import 'persona_activation_preflight_gate_v4.dart';
import 'persona_activation_preflight_consistency_v4.dart';
import 'persona_activation_preflight_merged_v4.dart';

class PersonaActivationSynthesisV4 {
  const PersonaActivationSynthesisV4({
    this.merged,
    this.gate,
    this.gateConsistency,
    this.consistency,
    this.delta,
  });

  final Map<String, Object?>? merged;
  final Map<String, Object?>? gate;
  final Map<String, Object?>? gateConsistency;
  final Map<String, Object?>? consistency;
  final Map<String, Object?>? delta;

  factory PersonaActivationSynthesisV4.fromPreflight({
    required PersonaActivationPreflightMergedV4 merged,
    required PersonaActivationPreflightGateV4 gate,
    required PersonaActivationPreflightGateConsistencyV4 gateConsistency,
    required PersonaActivationPreflightConsistencyV4 consistency,
    required PersonaActivationPreflightDeltaV4 delta,
  }) {
    return PersonaActivationSynthesisV4(
      merged: merged.asReadOnlyMap(),
      gate: gate.asReadOnlyMap(),
      gateConsistency: gateConsistency.asReadOnlyMap(),
      consistency: consistency.asReadOnlyMap(),
      delta: delta.asReadOnlyMap(),
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{};
    if (merged != null) map['merged'] = merged;
    if (gate != null) map['gate'] = gate;
    if (gateConsistency != null) map['gateConsistency'] = gateConsistency;
    if (consistency != null) map['consistency'] = consistency;
    if (delta != null) map['delta'] = delta;
    return map;
  }
}
