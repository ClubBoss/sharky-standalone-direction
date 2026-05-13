import 'persona_activation_preview_envelope_v4.dart';
import 'persona_activation_final_bundle_v4.dart';
import 'persona_activation_diagnostic_surface_v4.dart';
import 'persona_activation_diagnostic_consistency_map_v4.dart';
import 'persona_activation_confidence_v4.dart';
import 'persona_activation_staged_v4.dart';
import 'persona_activation_outcome_resolver_v4.dart';
import 'runtime_activation_context_v4.dart';
import 'persona_runtime_activation_envelope_v4.dart';

class PersonaActivationPreflightEnvelopeV4 {
  const PersonaActivationPreflightEnvelopeV4({
    this.preview,
    this.finalBundle,
    this.diagnosticSurface,
    this.diagnosticConsistency,
    this.confidence,
    this.staged,
    this.outcome,
    this.runtimeContext,
    this.runtimeEnvelope,
  });

  final PersonaActivationPreviewEnvelopeV4? preview;
  final PersonaActivationFinalBundleV4? finalBundle;
  final PersonaActivationDiagnosticSurfaceV4? diagnosticSurface;
  final PersonaActivationDiagnosticConsistencyMapV4? diagnosticConsistency;
  final PersonaActivationConfidenceV4? confidence;
  final PersonaActivationStagedV4? staged;
  final PersonaActivationOutcomeResolverV4? outcome;
  final RuntimeActivationContextV4? runtimeContext;
  final PersonaRuntimeActivationEnvelopeV4? runtimeEnvelope;

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{};
    if (preview != null) map['preview'] = preview!.asReadOnlyMap();
    if (finalBundle != null) map['finalBundle'] = finalBundle!.asReadOnlyMap();
    if (diagnosticSurface != null) {
      map['diagnosticSurface'] = diagnosticSurface!.asReadOnlyMap();
    }
    if (confidence != null) map['confidence'] = confidence!.asReadOnlyMap();
    if (staged != null) map['staged'] = staged!.asReadOnlyMap();
    if (outcome != null) map['outcome'] = outcome!.asReadOnlyMap();
    if (runtimeContext != null) {
      map['runtimeContext'] = runtimeContext!.asReadOnlyMap();
    }
    if (runtimeEnvelope != null) {
      map['runtimeEnvelope'] = runtimeEnvelope!.asReadOnlyMap();
    }
    if (diagnosticConsistency != null) {
      map['diagnosticConsistency'] = diagnosticConsistency!.asReadOnlyMap();
    }
    return map;
  }
}
