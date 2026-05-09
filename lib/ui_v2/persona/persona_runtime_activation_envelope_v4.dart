import 'persona_activation_final_bundle_v4.dart';
import 'runtime_activation_context_v4.dart';

class PersonaRuntimeActivationEnvelopeV4 {
  const PersonaRuntimeActivationEnvelopeV4({
    this.finalActivationBundle,
    this.runtimeContext,
  });

  final PersonaActivationFinalBundleV4? finalActivationBundle;
  final RuntimeActivationContextV4? runtimeContext;

  Map<String, Object?>? asReadOnlyMap() {
    final map = <String, Object?>{};
    if (finalActivationBundle != null) {
      map['finalActivationBundle'] = finalActivationBundle!.asReadOnlyMap();
    }
    if (runtimeContext != null) {
      map['runtimeContext'] = runtimeContext!.asReadOnlyMap();
    }
    return map.isEmpty ? null : map;
  }
}
