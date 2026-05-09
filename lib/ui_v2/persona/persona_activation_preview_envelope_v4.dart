import 'persona_activation_final_bundle_v4.dart';
import 'persona_activation_diagnostic_surface_v4.dart';
import 'persona_activation_confidence_v4.dart';
import 'persona_activation_staged_v4.dart';
import 'persona_activation_outcome_resolver_v4.dart';
import 'runtime_activation_context_v4.dart';

class PersonaActivationPreviewEnvelopeV4 {
  const PersonaActivationPreviewEnvelopeV4({
    this.finalBundle,
    this.runtimeContext,
    this.diagnosticSurface,
    this.confidence,
    this.staged,
    this.outcome,
  });

  final PersonaActivationFinalBundleV4? finalBundle;
  final RuntimeActivationContextV4? runtimeContext;
  final PersonaActivationDiagnosticSurfaceV4? diagnosticSurface;
  final PersonaActivationConfidenceV4? confidence;
  final PersonaActivationStagedV4? staged;
  final PersonaActivationOutcomeResolverV4? outcome;

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{};
    if (finalBundle != null) {
      map['finalBundle'] = finalBundle!.asReadOnlyMap();
    }
    if (runtimeContext != null) {
      map['runtimeContext'] = runtimeContext!.asReadOnlyMap();
    }
    if (diagnosticSurface != null) {
      map['diagnosticSurface'] = diagnosticSurface!.asReadOnlyMap();
    }
    if (confidence != null) {
      map['confidence'] = confidence!.asReadOnlyMap();
    }
    if (staged != null) {
      map['staged'] = staged!.asReadOnlyMap();
    }
    if (outcome != null) {
      map['outcome'] = outcome!.asReadOnlyMap();
    }
    return map;
  }
}
