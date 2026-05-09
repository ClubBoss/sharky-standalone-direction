class PersonaActivationSnapshotV4 {
  const PersonaActivationSnapshotV4({
    this.finalActivationBundle,
    this.activationOutcome,
    this.activationConfidence,
    this.activationTier,
    this.readinessMatrix,
    this.activationGate,
    this.activationSupervisor,
    this.diagnosticSurface,
    this.diagnosticConsistency,
    this.runtimeContext,
    this.runtimeEnvelope,
    this.runtimeEnvelopeDeep,
    this.kernelSurface,
    this.kernelCohesion,
    this.kernelMeshDescriptor,
    this.kernelMeshVector,
    this.kernelMeshFusion,
    this.kernelMeshConsistency,
    this.meshDescriptor,
    this.meshVector,
    this.meshFusion,
    this.meshConsistency,
    this.surfaceTriple,
    this.cohesionWeights,
  });

  final Map<String, Object?>? finalActivationBundle;
  final Map<String, Object?>? activationOutcome;
  final Map<String, Object?>? activationConfidence;
  final Map<String, Object?>? activationTier;
  final Map<String, Object?>? readinessMatrix;
  final Map<String, Object?>? activationGate;
  final Map<String, Object?>? activationSupervisor;
  final Map<String, Object?>? diagnosticSurface;
  final Map<String, Object?>? diagnosticConsistency;
  final Map<String, Object?>? runtimeContext;
  final Map<String, Object?>? runtimeEnvelope;
  final Map<String, Object?>? runtimeEnvelopeDeep;
  final Map<String, double>? kernelSurface;
  final Map<String, double>? kernelCohesion;
  final Map<String, Object?>? kernelMeshDescriptor;
  final Map<String, Object?>? kernelMeshVector;
  final Map<String, Object?>? kernelMeshFusion;
  final Map<String, Object?>? kernelMeshConsistency;
  final Map<String, Object?>? meshDescriptor;
  final Map<String, Object?>? meshVector;
  final Map<String, Object?>? meshFusion;
  final Map<String, Object?>? meshConsistency;
  final Map<String, Object?>? surfaceTriple;
  final Map<String, Object?>? cohesionWeights;

  Map<String, Object?>? asReadOnlyMap() {
    final map = <String, Object?>{};
    if (finalActivationBundle != null) {
      map['finalActivationBundle'] = finalActivationBundle;
    }
    if (activationOutcome != null) map['activationOutcome'] = activationOutcome;
    if (activationConfidence != null) {
      map['activationConfidence'] = activationConfidence;
    }
    if (activationTier != null) map['activationTier'] = activationTier;
    if (readinessMatrix != null) map['readinessMatrix'] = readinessMatrix;
    if (activationGate != null) map['activationGate'] = activationGate;
    if (activationSupervisor != null) {
      map['activationSupervisor'] = activationSupervisor;
    }
    if (diagnosticSurface != null) {
      map['diagnosticSurface'] = diagnosticSurface;
    }
    if (diagnosticConsistency != null) {
      map['diagnosticConsistency'] = diagnosticConsistency;
    }
    if (runtimeContext != null) map['runtimeContext'] = runtimeContext;
    if (runtimeEnvelope != null) {
      map['runtimeEnvelope'] = runtimeEnvelope;
    }
    if (runtimeEnvelopeDeep != null) {
      map['runtimeEnvelopeDeep'] = runtimeEnvelopeDeep;
    }
    if (kernelSurface != null) map['kernelSurface'] = kernelSurface;
    if (kernelCohesion != null) map['kernelCohesion'] = kernelCohesion;
    if (kernelMeshDescriptor != null) {
      map['kernelMeshDescriptor'] = kernelMeshDescriptor;
    }
    if (kernelMeshVector != null) map['kernelMeshVector'] = kernelMeshVector;
    if (kernelMeshFusion != null) {
      map['kernelMeshFusion'] = kernelMeshFusion;
    }
    if (kernelMeshConsistency != null) {
      map['kernelMeshConsistency'] = kernelMeshConsistency;
    }
    if (meshDescriptor != null) map['meshDescriptor'] = meshDescriptor;
    if (meshVector != null) map['meshVector'] = meshVector;
    if (meshFusion != null) map['meshFusion'] = meshFusion;
    if (meshConsistency != null) map['meshConsistency'] = meshConsistency;
    if (surfaceTriple != null) map['surfaceTriple'] = surfaceTriple;
    if (cohesionWeights != null) map['cohesionWeights'] = cohesionWeights;
    return map.isEmpty ? null : map;
  }

  Map<String, Object?> harmonizedForTelemetry() {
    final map = <String, Object?>{};
    final surfaceMap = <String, Object?>{};
    if (surfaceTriple != null) surfaceMap['surfaceTriple'] = surfaceTriple;
    if (kernelSurface != null) surfaceMap['kernelSurface'] = kernelSurface;
    if (diagnosticSurface != null) {
      surfaceMap['diagnosticSurface'] = diagnosticSurface;
    }
    if (runtimeContext != null) surfaceMap['runtimeContext'] = runtimeContext;
    if (surfaceMap.isNotEmpty) map['v4Surface'] = surfaceMap;

    final cohesionMap = <String, Object?>{};
    if (cohesionWeights != null) {
      cohesionMap['cohesionWeights'] = cohesionWeights;
    }
    if (kernelCohesion != null) cohesionMap['kernelCohesion'] = kernelCohesion;
    if (diagnosticConsistency != null) {
      cohesionMap['diagnosticConsistency'] = diagnosticConsistency;
    }
    if (cohesionMap.isNotEmpty) map['v4Cohesion'] = cohesionMap;

    final meshMap = <String, Object?>{};
    if (meshDescriptor != null) meshMap['meshDescriptor'] = meshDescriptor;
    if (meshVector != null) meshMap['meshVector'] = meshVector;
    if (meshFusion != null) meshMap['meshFusion'] = meshFusion;
    if (meshConsistency != null) meshMap['meshConsistency'] = meshConsistency;
    if (kernelMeshDescriptor != null) {
      meshMap['kernelMeshDescriptor'] = kernelMeshDescriptor;
    }
    if (kernelMeshVector != null) {
      meshMap['kernelMeshVector'] = kernelMeshVector;
    }
    if (kernelMeshFusion != null) {
      meshMap['kernelMeshFusion'] = kernelMeshFusion;
    }
    if (kernelMeshConsistency != null) {
      meshMap['kernelMeshConsistency'] = kernelMeshConsistency;
    }
    if (meshMap.isNotEmpty) map['v4Mesh'] = meshMap;

    final activationMap = <String, Object?>{};
    if (finalActivationBundle != null) {
      activationMap['finalActivationBundle'] = finalActivationBundle;
    }
    if (activationOutcome != null)
      activationMap['activationOutcome'] = activationOutcome;
    if (activationConfidence != null) {
      activationMap['activationConfidence'] = activationConfidence;
    }
    if (activationTier != null)
      activationMap['activationTier'] = activationTier;
    if (readinessMatrix != null)
      activationMap['readinessMatrix'] = readinessMatrix;
    if (activationGate != null)
      activationMap['activationGate'] = activationGate;
    if (activationSupervisor != null) {
      activationMap['activationSupervisor'] = activationSupervisor;
    }
    if (runtimeEnvelope != null) {
      activationMap['runtimeEnvelope'] = runtimeEnvelope;
    }
    if (runtimeEnvelopeDeep != null) {
      activationMap['runtimeEnvelopeDeep'] = runtimeEnvelopeDeep;
    }
    if (activationMap.isNotEmpty) map['v4Activation'] = activationMap;

    return map;
  }

  Map<String, Object?> outboundAligned() {
    final harmonized = harmonizedForTelemetry();
    final outbound = <String, Object?>{};
    final surface = harmonized['v4Surface'];
    if (surface != null) outbound['surface_v4'] = surface;
    final cohesion = harmonized['v4Cohesion'];
    if (cohesion != null) outbound['cohesion_v4'] = cohesion;
    final mesh = harmonized['v4Mesh'];
    if (mesh != null) outbound['mesh_v4'] = mesh;
    final activation = harmonized['v4Activation'];
    if (activation != null) outbound['activation_v4'] = activation;
    return outbound;
  }

  Map<String, Object?> unifiedOutboundEnvelope() {
    return {'persona_v4_activation': outboundAligned()};
  }

  Map<String, Object?> relayForCrossModule() {
    final unified = unifiedOutboundEnvelope();
    final map = <String, Object?>{};
    for (final entry in unified.entries) {
      switch (entry.key) {
        case 'persona_v4_activation':
          map['activation_v4_cross'] = entry.value;
          break;
        case 'persona_v4_synthesis':
          map['synthesis_v4_cross'] = entry.value;
          break;
        case 'persona_v4_synthesis_telemetry':
          map['synthesis_v4_cross_telemetry'] = entry.value;
          break;
        default:
          map[entry.key] = entry.value;
      }
    }
    return map;
  }

  Map<String, Object?> crossModuleHandshake() {
    return {'persona_v4_handshake': unifiedOutboundEnvelope()};
  }

  Map<String, Object?> telemetryIntegrityPass() {
    final harmonized = harmonizedForTelemetry();
    final hasSurface = harmonized['v4Surface'] != null;
    final hasCohesion = harmonized['v4Cohesion'] != null;
    final hasMesh = harmonized['v4Mesh'] != null;
    final hasActivation = harmonized['v4Activation'] != null;
    return {
      'hasSurface': hasSurface,
      'hasCohesion': hasCohesion,
      'hasMesh': hasMesh,
      'hasActivation': hasActivation,
      'isIntegrityOk': hasSurface && hasCohesion && hasMesh && hasActivation,
    };
  }
}
