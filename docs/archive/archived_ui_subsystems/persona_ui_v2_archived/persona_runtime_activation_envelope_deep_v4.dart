import '../../engine/simulation_motion_kernel.dart';
import 'persona_activation_final_bundle_v4.dart';
import 'persona_activation_diagnostic_consistency_map_v4.dart';
import 'persona_activation_diagnostic_surface_v4.dart';
import 'persona_activation_gate_v4.dart';
import 'pre_activation_persona_check_matrix_v4.dart';
import 'pre_activation_persona_audit_v4.dart';
import 'persona_activation_supervisor_v4.dart';
import 'persona_activation_outcome_resolver_v4.dart';
import 'persona_activation_consistency_resolver_v4.dart';
import 'persona_activation_confidence_v4.dart';
import 'persona_activation_staged_v4.dart';
import 'runtime_activation_context_v4.dart';
import 'persona_runtime_activation_envelope_v4.dart';

class PersonaRuntimeActivationEnvelopeDeepV4 {
  const PersonaRuntimeActivationEnvelopeDeepV4({
    this.finalActivationBundleMap,
    this.diagnosticSurfaceMap,
    this.diagnosticConsistencyMap,
    this.runtimeContextMap,
    this.runtimeEnvelopeMap,
    this.preActivationAuditMap,
    this.readinessMatrixMap,
    this.activationGateMap,
    this.activationSupervisorMap,
    this.activationOutcomeMap,
    this.activationConsistencyMap,
    this.activationConfidenceMap,
    this.activationStagedMap,
    this.kernelSurface,
    this.kernelCohesion,
    this.kernelMeshDescriptor,
    this.kernelMeshVector,
    this.kernelMeshFusion,
    this.kernelMeshConsistency,
  });

  final Map<String, Object?>? finalActivationBundleMap;
  final Map<String, Object?>? diagnosticSurfaceMap;
  final Map<String, Object?>? diagnosticConsistencyMap;
  final Map<String, Object?>? runtimeContextMap;
  final Map<String, Object?>? runtimeEnvelopeMap;
  final Map<String, Object?>? preActivationAuditMap;
  final Map<String, Object?>? readinessMatrixMap;
  final Map<String, Object?>? activationGateMap;
  final Map<String, Object?>? activationSupervisorMap;
  final Map<String, Object?>? activationOutcomeMap;
  final Map<String, Object?>? activationConsistencyMap;
  final Map<String, Object?>? activationConfidenceMap;
  final Map<String, Object?>? activationStagedMap;
  final Map<String, double>? kernelSurface;
  final Map<String, double>? kernelCohesion;
  final Map<String, Object?>? kernelMeshDescriptor;
  final Map<String, Object?>? kernelMeshVector;
  final Map<String, Object?>? kernelMeshFusion;
  final Map<String, Object?>? kernelMeshConsistency;

  factory PersonaRuntimeActivationEnvelopeDeepV4.fromComponents({
    required PersonaActivationFinalBundleV4 finalBundle,
    required PersonaActivationDiagnosticSurfaceV4 surface,
    required PersonaActivationDiagnosticConsistencyMapV4 consistency,
    required RuntimeActivationContextV4 runtimeContext,
    required PersonaRuntimeActivationEnvelopeV4 runtimeEnvelope,
    required PreActivationPersonaAuditV4 audit,
    required PreActivationPersonaCheckMatrixV4 matrix,
    required PersonaActivationGateV4 gate,
    required PersonaActivationSupervisorV4 supervisor,
    required PersonaActivationOutcomeResolverV4 outcome,
    required PersonaActivationConsistencyResolverV4 consistencyResolver,
    required PersonaActivationConfidenceV4 confidence,
    required PersonaActivationStagedV4 staged,
  }) {
    final kernel = SimulationMotionKernel.current;
    return PersonaRuntimeActivationEnvelopeDeepV4(
      finalActivationBundleMap: finalBundle.asReadOnlyMap(),
      diagnosticSurfaceMap: surface.asReadOnlyMap(),
      diagnosticConsistencyMap: consistency.asReadOnlyMap(),
      runtimeContextMap: runtimeContext.asReadOnlyMap(),
      runtimeEnvelopeMap: runtimeEnvelope.asReadOnlyMap(),
      preActivationAuditMap: audit.asReadOnlyMap(),
      readinessMatrixMap: matrix.asReadOnlyMap(),
      activationGateMap: gate.asReadOnlyMap(),
      activationSupervisorMap: supervisor.asReadOnlyMap(),
      activationOutcomeMap: outcome.asReadOnlyMap(),
      activationConsistencyMap: consistencyResolver.asReadOnlyMap(),
      activationConfidenceMap: confidence.asReadOnlyMap(),
      activationStagedMap: staged.asReadOnlyMap(),
      kernelSurface: kernel?.v4SurfaceSyncTripleOrNull,
      kernelCohesion: kernel?.v4CohesionWeightsOrNull,
      kernelMeshDescriptor: kernel?.motionMeshDescriptorOrNull?.asReadOnlyMap(),
      kernelMeshVector: kernel?.motionMeshVectorOrNull?.asReadOnlyMap(),
      kernelMeshFusion: kernel?.motionMeshFusionOrNull?.asReadOnlyMap(),
      kernelMeshConsistency: kernel?.motionMeshConsistencyOrNull
          ?.asReadOnlyMap(),
    );
  }

  Map<String, Object?>? asReadOnlyMap() {
    final map = <String, Object?>{};
    if (finalActivationBundleMap != null) {
      map['finalActivationBundle'] = finalActivationBundleMap;
    }
    if (diagnosticSurfaceMap != null) {
      map['diagnosticSurface'] = diagnosticSurfaceMap;
    }
    if (diagnosticConsistencyMap != null) {
      map['diagnosticConsistency'] = diagnosticConsistencyMap;
    }
    if (runtimeContextMap != null) {
      map['runtimeContext'] = runtimeContextMap;
    }
    if (runtimeEnvelopeMap != null) {
      map['runtimeEnvelope'] = runtimeEnvelopeMap;
    }
    if (preActivationAuditMap != null) {
      map['preActivationAudit'] = preActivationAuditMap;
    }
    if (readinessMatrixMap != null) {
      map['readinessMatrix'] = readinessMatrixMap;
    }
    if (activationGateMap != null) {
      map['activationGate'] = activationGateMap;
    }
    if (activationSupervisorMap != null) {
      map['activationSupervisor'] = activationSupervisorMap;
    }
    if (activationOutcomeMap != null) {
      map['activationOutcome'] = activationOutcomeMap;
    }
    if (activationConsistencyMap != null) {
      map['activationConsistency'] = activationConsistencyMap;
    }
    if (activationConfidenceMap != null) {
      map['activationConfidence'] = activationConfidenceMap;
    }
    if (activationStagedMap != null) {
      map['activationStaged'] = activationStagedMap;
    }
    if (kernelSurface != null) map['kernelSurface'] = kernelSurface;
    if (kernelCohesion != null) map['kernelCohesion'] = kernelCohesion;
    if (kernelMeshDescriptor != null) {
      map['kernelMeshDescriptor'] = kernelMeshDescriptor;
    }
    if (kernelMeshVector != null) map['kernelMeshVector'] = kernelMeshVector;
    if (kernelMeshFusion != null) map['kernelMeshFusion'] = kernelMeshFusion;
    if (kernelMeshConsistency != null) {
      map['kernelMeshConsistency'] = kernelMeshConsistency;
    }
    return map.isEmpty ? null : map;
  }
}
