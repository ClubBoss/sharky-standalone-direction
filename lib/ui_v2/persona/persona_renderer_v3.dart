import 'package:flutter/material.dart';

import 'persona_emotional_fusion_v3.dart';
import 'persona_emotional_kernel_v3.dart';
import 'persona_frame_v1.dart';
import 'persona_surface_v4_descriptor.dart';
import 'persona_v4_visual_identity_sync.dart';
import 'persona_visual_container_v3.dart';
import 'ai_personalization_tier_c_v1.dart';
import '../../engine/simulation_motion_kernel.dart';
import '../theme/v4_theme_builder.dart';
import '../theme/v4_token_registry.dart';
import '../theme/v4_visual_qa_snapshot_v1.dart';
import '../theme_v3/style_token_bundle_v4.dart';
import 'persona_sync_v4.dart';
import 'pre_activation_persona_audit_v4.dart';
import 'pre_activation_persona_check_matrix_v4.dart';
import '../app_root.dart';
import 'persona_v4_exports.dart';
import 'profile/persona_profile_explanation_hooks_v1.dart';
import 'profile/persona_profile_bundle_v1.dart';
import 'profile/persona_profile_model_v1.dart';
import 'profile/persona_profile_overlay_v1.dart';
import 'profile/persona_profile_surface_v1.dart';
import 'ai_personalization_delta_v4.dart';
import 'ai_personalization_preflight_v4.dart';
import 'ai_personalization_preflight_consistency_v4.dart';
import 'ai_personalization_preflight_delta_v4.dart';
import 'ai_personalization_preflight_aggregator_v4.dart';
import 'ai_personalization_preflight_gate_v4.dart';
import 'ai_personalization_preflight_gate_consistency_v4.dart';
import 'ai_personalization_preflight_merged_v4.dart';
import 'ai_personalization_consistency_v4.dart';
import 'ai_personalization_tier_d_v1.dart';
import 'ai_personalization_tier_e_v1.dart';
import '../recommendations/advice_summary_v1.dart';
import '../recommendations/recommendation_explainer_v1.dart';
import '../recommendations/recommendation_surface_v1.dart';
import '../sr/sr_entrypoint_v1.dart';
import '../sr/sr_recommendation_bridge_v1.dart';
import '../sr/sr_ribbon_v1.dart';
import '../sr/sr_routing_v1.dart';
import '../sr/sr_session_bridge_v1.dart';
import '../sr/sr_session_loop_v1.dart';
import '../../telemetry/telemetry_service.dart';
import 'persona_v4_telemetry_unified_bundle_v4.dart';

class PersonaRendererV3 {
  final Object surfaceState;
  final Object motionState;
  final Object overlayState;
  final Object personaState;
  PersonaActivationSnapshotV4? _lastUnifiedSnapshotForRelay;

  PersonaRendererV3({
    this.surfaceState = const _PlaceholderSurfaceState(),
    this.motionState = const _PlaceholderMotionState(),
    this.overlayState = const _PlaceholderOverlayState(),
    this.personaState = const _PlaceholderPersonaState(),
    this.v4ActivationEnablementBundle,
    this.v4ActivationConsistencyRelay,
    this.v4DiagnosticsBundle,
    this.v4ActivationRelay,
    Map<String, Object?>? v4ActivationMasterBind,
    this.v4EmotionalContext,
    this.v4VisualContext,
    Object? emotionalDeltaTierB,
    Object? emotionalAggregatorTierB,
    Object? emotionalSynthesisTierB,
    Object? emotionalStateTierA,
    Object? emotionalStabilityTierA,
    Object? emotionalReadinessTierA,
    PersonaEmotionalKernelV3? kernel,
    PersonaEmotionalFusionV3? fusion,
  }) : emotionalStateTierA =
           emotionalStateTierA ?? v4ActivationRelay?['enablement'],
       emotionalStabilityTierA =
           emotionalStabilityTierA ?? v4ActivationRelay?['consistency'],
       emotionalReadinessTierA =
           emotionalReadinessTierA ?? v4ActivationRelay?['readiness'],
       emotionalDeltaTierB = emotionalDeltaTierB ?? v4ActivationRelay?['delta'],
       emotionalAggregatorTierB =
           emotionalAggregatorTierB ?? v4ActivationRelay?['aggregator'],
       emotionalSynthesisTierB =
           emotionalSynthesisTierB ?? v4ActivationRelay?['synthesis'],
       v4ActivationMasterBind = v4ActivationMasterBind ?? v4ActivationRelay,
       _kernel = kernel ?? PersonaEmotionalKernelV3(),
       _fusion = fusion ?? PersonaEmotionalFusionV3();

  final PersonaEmotionalKernelV3 _kernel;
  final PersonaEmotionalFusionV3 _fusion;
  Map<String, dynamic>? _v4BlendedStyle;
  Map<String, dynamic>? _v4ActivationEnablementBundle;
  final Map<String, Object?>? v4ActivationEnablementBundle;
  final Map<String, Object?>? v4ActivationConsistencyRelay;
  final Map<String, Object?>? v4DiagnosticsBundle;
  final Map<String, Object?>? v4ActivationRelay;
  final Map<String, Object?>? v4ActivationMasterBind;
  final Map<String, Object?>? v4EmotionalContext;
  final Map<String, Object?>? v4VisualContext;
  final Object? emotionalStateTierA;
  final Object? emotionalStabilityTierA;
  final Object? emotionalReadinessTierA;
  final Object? emotionalDeltaTierB;
  final Object? emotionalAggregatorTierB;
  final Object? emotionalSynthesisTierB;
  StyleTokenBundleV4? _moodAdjustedBundle;
  double? _finalV4SurfaceRadius;
  double? _finalV4SurfaceElevation;
  double? _finalV4SurfaceSpacing;
  Map<String, Object>? _v4ProfileContext;
  Map<String, Object>? _v4ProfileKernel;

  void renderBase() {}
  void renderThemeLayer() {}
  void renderMotionLayer() {}
  void renderAdaptiveLayer() {}
  String snapshotRender() => '';

  void syncStyle(String style) {}

  void attachV4BlendedStyle(Map<String, dynamic> data) {
    _v4BlendedStyle = data;
  }

  void attachV4ActivationEnablementBundle(Map<String, dynamic> data) {
    _v4ActivationEnablementBundle = data;
  }

  Map<String, dynamic>? get v4BlendedStyle => _v4BlendedStyle;
  Map<String, Object?>? get exportV4ActivationMasterBind =>
      v4ActivationMasterBind;
  Map<String, Object> exportV4VisualQASnapshotV1() =>
      V4VisualQASnapshotV1.build();
  Object? get exportEmotionalStateTierA => emotionalStateTierA;
  Object? get exportEmotionalStabilityTierA => emotionalStabilityTierA;
  Object? get exportEmotionalReadinessTierA => emotionalReadinessTierA;
  Object? get exportEmotionalDeltaTierB => emotionalDeltaTierB;
  Object? get exportEmotionalAggregatorTierB => emotionalAggregatorTierB;
  Object? get exportEmotionalSynthesisTierB => emotionalSynthesisTierB;
  Map<String, Object?> exportEmotionalTierBConsolidated() => <String, Object?>{
    'delta': emotionalDeltaTierB,
    'aggregator': emotionalAggregatorTierB,
    'synthesis': emotionalSynthesisTierB,
  };
  Map<String, Object> exportEmotionalTierA() {
    final Map<String, Object> tierA = <String, Object>{};
    if (emotionalStateTierA != null) tierA['state'] = emotionalStateTierA!;
    if (emotionalStabilityTierA != null) {
      tierA['stability'] = emotionalStabilityTierA!;
    }
    if (emotionalReadinessTierA != null) {
      tierA['readiness'] = emotionalReadinessTierA!;
    }
    return tierA;
  }

  Map<String, Object> exportEmotionalTierB() {
    final consolidated = exportEmotionalTierBConsolidated();
    final Map<String, Object> tierB = <String, Object>{};
    consolidated.forEach((key, value) {
      if (value != null) tierB[key] = value;
    });
    return tierB;
  }

  Map<String, Object> exportTierCSurfaceV1({
    required Map<String, Object> activationRelay,
    required Map<String, Object> emotionalTierA,
    required Map<String, Object> emotionalTierB,
    required Map<String, Object> visualQASnapshot,
  }) => AIPersonalizationTierCV1.build(
    activationRelay: activationRelay,
    emotionalTierA: emotionalTierA,
    emotionalTierB: emotionalTierB,
    visualQASnapshot: visualQASnapshot,
  );

  Map<String, Object> exportTierDSurfaceV1({
    required Map<String, Object> tierC,
    required Map<String, Object> activationRelay,
    required Map<String, Object> emotionalTierA,
    required Map<String, Object> emotionalTierB,
    required Map<String, Object> visualQASnapshot,
  }) => AIPersonalizationTierDV1.build(
    tierC: tierC,
    activationRelay: activationRelay,
    emotionalTierA: emotionalTierA,
    emotionalTierB: emotionalTierB,
    visualQASnapshot: visualQASnapshot,
  );

  Map<String, Object> exportTierEV1() {
    const Map<String, Object> empty = <String, Object>{};
    final tierA = exportEmotionalTierA();
    final tierB = exportEmotionalTierB();
    final tierC = exportTierCSurfaceV1(
      activationRelay: empty,
      emotionalTierA: tierA,
      emotionalTierB: tierB,
      visualQASnapshot: exportV4VisualQASnapshotV1(),
    );
    final tierD = exportTierDSurfaceV1(
      tierC: tierC,
      activationRelay: empty,
      emotionalTierA: tierA,
      emotionalTierB: tierB,
      visualQASnapshot: exportV4VisualQASnapshotV1(),
    );
    final activationBundle = exportV4ActivationMasterBundle();
    final visualSnapshot = exportV4VisualQASnapshotV1();
    return AIPersonalizationTierEV1.build(
      tierA: tierA,
      tierB: tierB,
      tierC: tierC,
      tierD: tierD,
      activationBundle: <String, Object>{
        for (final entry in activationBundle.entries)
          if (entry.value != null) entry.key: entry.value as Object,
      },
      visualSnapshot: visualSnapshot,
    );
  }

  Map<String, Object?> exportV4ActivationMasterMerged() => <String, Object?>{
    'master_bind': v4ActivationMasterBind,
    'relay': v4ActivationRelay,
    'tier_a': <String, Object?>{
      'state': emotionalStateTierA,
      'stability': emotionalStabilityTierA,
      'readiness': emotionalReadinessTierA,
    },
    'tier_b': <String, Object?>{
      'delta': emotionalDeltaTierB,
      'aggregator': emotionalAggregatorTierB,
      'synthesis': emotionalSynthesisTierB,
    },
  };

  Map<String, Object?> exportV4ActivationMasterBundle() => <String, Object?>{
    'activation_master_merged': exportV4ActivationMasterMerged(),
    'activation_master_bind': v4ActivationMasterBind,
    'activation_relay': v4ActivationRelay,
  };

  Map<String, Object?> exportV4SyncStabilizationBundle() => <String, Object?>{
    'master_bundle': exportV4ActivationMasterBundle(),
    'master_merged': exportV4ActivationMasterMerged(),
    'master_bind': v4ActivationMasterBind,
    'relay': v4ActivationRelay,
  };

  Map<String, Object?> exportV4SyncStabilizationQASurface() =>
      <String, Object?>{
        'sync_stabilization': exportV4SyncStabilizationBundle(),
        'master_bundle': exportV4ActivationMasterBundle(),
        'relay': v4ActivationRelay,
      };

  Map<String, Object?> exportV4VisualQALinkage() => <String, Object?>{
    'activation_master_bundle': exportV4ActivationMasterBundle(),
    'activation_master_merged': exportV4ActivationMasterMerged(),
    'sync_stabilization': exportV4SyncStabilizationBundle(),
    'tier_a': <String, Object?>{
      'state': emotionalStateTierA,
      'stability': emotionalStabilityTierA,
      'readiness': emotionalReadinessTierA,
    },
    'tier_b': <String, Object?>{
      'delta': emotionalDeltaTierB,
      'aggregator': emotionalAggregatorTierB,
      'synthesis': emotionalSynthesisTierB,
    },
  };

  Map<String, Object?> exportV4VisualQAExport() => <String, Object?>{
    'visual_qa_linkage': exportV4VisualQALinkage(),
    'activation_master_bundle': exportV4ActivationMasterBundle(),
    'sync_stabilization': exportV4SyncStabilizationBundle(),
    'activation_relay': v4ActivationRelay,
  };

  Map<String, Object?> exportV4RuntimeFullReadiness() => <String, Object?>{
    'activation_relay': v4ActivationRelay,
    'activation_master_bundle': exportV4ActivationMasterBundle(),
    'activation_master_merged': exportV4ActivationMasterMerged(),
    'sync_stabilization': exportV4SyncStabilizationBundle(),
    'visual_qa_linkage': exportV4VisualQALinkage(),
    'visual_qa_export': exportV4VisualQAExport(),
    'tier_a': <String, Object?>{
      'state': emotionalStateTierA,
      'stability': emotionalStabilityTierA,
      'readiness': emotionalReadinessTierA,
    },
    'tier_b': <String, Object?>{
      'delta': emotionalDeltaTierB,
      'aggregator': emotionalAggregatorTierB,
      'synthesis': emotionalSynthesisTierB,
    },
  };
  Map<String, Object>? get v4ProfileContext => _v4ProfileContext;
  Map<String, Object>? get v4ProfileKernel => _v4ProfileKernel;

  String? get personaTitle {
    final title = _v4ProfileContext?['title'];
    return title?.toString();
  }

  String? get personaShortExplanation {
    final short = _v4ProfileKernel?['activation_state_explainer'];
    return short?.toString();
  }

  List<String> get personaHints {
    if (_v4ProfileKernel == null) return const <String>[];
    final values = _v4ProfileKernel!.values
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
    return List<String>.unmodifiable(values);
  }

  Map<String, Object> get personaUXBundle {
    final title = personaTitle;
    final short = personaShortExplanation;
    final hints = personaHints;
    if (title == null && short == null && hints.isEmpty) {
      return const <String, Object>{};
    }
    return Map<String, Object>.unmodifiable({
      'title': title,
      'short': short,
      'hints': hints,
    });
  }

  Map<String, Object> exportPersonaV4MATConsistency({
    required bool isV4Active,
    required Map<String, Object> personaUX,
    required Map<String, Object> inlineSurface,
    required Map<String, Object> themeSnapshot,
  }) {
    if (!isV4Active) return const <String, Object>{};
    final missingPersona = <String>[];
    for (final key in ['title', 'short', 'hints']) {
      if (!personaUX.containsKey(key)) missingPersona.add(key);
    }
    final missingExplain = <String>[];
    final title = inlineSurface['title'];
    final sections = inlineSurface['sections'];
    if (title == null || title.toString().isEmpty) missingExplain.add('title');
    if (sections is! List || sections.isEmpty) {
      missingExplain.add('sections');
    }
    final requiredCategories = [
      'color',
      'radius',
      'padding',
      'typography',
      'motion',
    ];
    final missingMat = <String>[];
    for (final cat in requiredCategories) {
      if (!themeSnapshot.containsKey(cat)) missingMat.add(cat);
    }
    missingPersona.sort();
    missingExplain.sort();
    missingMat.sort();
    final ok =
        missingPersona.isEmpty && missingExplain.isEmpty && missingMat.isEmpty;
    return Map<String, Object>.unmodifiable({
      'ok': ok,
      'persona_keys_missing': List<String>.unmodifiable(missingPersona),
      'explain_keys_missing': List<String>.unmodifiable(missingExplain),
      'mat_categories_missing': List<String>.unmodifiable(missingMat),
    });
  }

  bool get canApplyV4Activation {
    final bundle = _v4ActivationEnablementBundle;
    if (bundle == null) return false;
    final flag = bundle['activationFlag'];
    if (flag is! Map<String, dynamic> || flag['enabled'] != true) return false;
    final enablement = bundle['visualEnablement'];
    if (enablement is! Map<String, dynamic> ||
        enablement['canApplyV4Visuals'] != true) {
      return false;
    }
    return true;
  }

  PersonaSurfaceV4Descriptor? get v4SurfaceDescriptor => null;

  // ignore: unused_element
  PersonaSurfaceV4Descriptor? _attachV4SurfaceDescriptorIfAvailable() =>
      v4SurfaceDescriptor;

  Map<String, Object>? get v4SurfaceMetadataOrNull =>
      _attachV4SurfaceDescriptorIfAvailable()?.asReadOnlyMap();

  PersonaFrameV1 get personaFrameV1OrNull {
    final descriptor = _attachV4SurfaceDescriptorIfAvailable();
    final frame = _buildPersonaFrameV1(descriptor);
    if (descriptor != null) {
      SimulationMotionKernel.current?.acceptV4SurfaceMetadata(
        frame.asReadOnlyMap(),
      );
      final emotionMap = personaEmotionEngineV4OrNull?.asReadOnlyMap();
      SimulationMotionKernel.current?.acceptEmotionV4(emotionMap);
    }
    return frame;
  }

  PersonaVisualContainerV3? get personaVisualContainerV3OrNull {
    final descriptor = _attachV4SurfaceDescriptorIfAvailable();
    if (descriptor == null &&
        _finalV4SurfaceRadius == null &&
        _finalV4SurfaceElevation == null &&
        _finalV4SurfaceSpacing == null)
      return null;
    final weights = _cohesionWeights();
    return PersonaVisualContainerV3(
      v4SurfaceRadius: _finalV4SurfaceRadius ?? descriptor?.surfaceRadius,
      v4SurfaceElevation:
          _finalV4SurfaceElevation ?? descriptor?.surfaceElevation,
      v4SurfaceSpacing: _finalV4SurfaceSpacing ?? descriptor?.surfaceSpacing,
      v4RadiusWeight: weights?['radius'],
      v4ElevationWeight: weights?['elevation'],
      v4SpacingWeight: weights?['spacing'],
    );
  }

  PersonaV4VisualIdentitySync? get personaV4VisualIdentitySyncOrNull {
    final radius = _finalV4SurfaceRadius;
    final elevation = _finalV4SurfaceElevation;
    final spacing = _finalV4SurfaceSpacing;
    if (radius == null && elevation == null && spacing == null) return null;
    final weights = _cohesionWeights();
    return PersonaV4VisualIdentitySync(
      radius: radius,
      elevation: elevation,
      spacing: spacing,
      v4RadiusWeight: weights?['radius'],
      v4ElevationWeight: weights?['elevation'],
      v4SpacingWeight: weights?['spacing'],
    );
  }

  PersonaSyncV4? get personaSyncV4OrNull {
    if (!canApplyV4Activation) return null;
    final radius = _finalV4SurfaceRadius;
    final elevation = _finalV4SurfaceElevation;
    final spacing = _finalV4SurfaceSpacing;
    final weights = _cohesionWeights();
    final kernel = SimulationMotionKernel.current;
    final emotionMap = personaEmotionEngineV4OrNull?.asReadOnlyMap();
    return PersonaSyncV4(
      v4SurfaceRadius: radius,
      v4SurfaceElevation: elevation,
      v4SurfaceSpacing: spacing,
      v4RadiusWeight: weights?['radius'],
      v4ElevationWeight: weights?['elevation'],
      v4SpacingWeight: weights?['spacing'],
      meshDescriptor: kernel?.motionMeshDescriptorOrNull?.asReadOnlyMap(),
      meshVector: kernel?.motionMeshVectorOrNull?.asReadOnlyMap(),
      meshFusion: kernel?.motionMeshFusionOrNull?.asReadOnlyMap(),
      meshConsistency: kernel?.motionMeshConsistencyOrNull?.asReadOnlyMap(),
      emotion: emotionMap,
    );
  }

  PreActivationPersonaAuditV4? get personaPreActivationAuditV4OrNull {
    final sync = personaSyncV4OrNull;
    if (sync == null) return null;
    return PreActivationPersonaAuditV4.fromSync(sync);
  }

  PreActivationPersonaCheckMatrixV4?
  get personaPreActivationCheckMatrixV4OrNull {
    final audit = personaPreActivationAuditV4OrNull;
    if (audit == null) return null;
    return PreActivationPersonaCheckMatrixV4.fromAudit(audit);
  }

  PersonaActivationGateV4? get personaActivationGateV4OrNull {
    final matrix = personaPreActivationCheckMatrixV4OrNull;
    if (matrix == null) return null;
    return PersonaActivationGateV4.fromMatrix(matrix);
  }

  PersonaActivationSupervisorV4? get personaActivationSupervisorV4OrNull {
    final gate = personaActivationGateV4OrNull;
    final matrix = personaPreActivationCheckMatrixV4OrNull;
    final kernel = SimulationMotionKernel.current;
    if (gate == null || matrix == null || kernel == null) return null;
    return PersonaActivationSupervisorV4.fromGateAndKernel(
      gate,
      matrix,
      kernel,
    );
  }

  PersonaActivationConsistencyResolverV4?
  get personaActivationConsistencyResolverV4OrNull {
    final supervisor = personaActivationSupervisorV4OrNull;
    if (supervisor == null) return null;
    return PersonaActivationConsistencyResolverV4.fromSupervisor(supervisor);
  }

  PersonaActivationOutcomeResolverV4?
  get personaActivationOutcomeResolverV4OrNull {
    final consistency = personaActivationConsistencyResolverV4OrNull;
    if (consistency == null) return null;
    return PersonaActivationOutcomeResolverV4.fromConsistency(consistency);
  }

  PersonaActivationConfidenceV4? get personaActivationConfidenceV4OrNull {
    final outcome = personaActivationOutcomeResolverV4OrNull;
    if (outcome == null) return null;
    return PersonaActivationConfidenceV4.fromOutcome(outcome);
  }

  PersonaActivationStagedV4? get personaActivationStagedV4OrNull {
    final confidence = personaActivationConfidenceV4OrNull;
    if (confidence == null) return null;
    return PersonaActivationStagedV4.fromConfidence(confidence);
  }

  PersonaActivationFinalBundleV4? get personaActivationFinalBundleV4OrNull {
    final staged = personaActivationStagedV4OrNull;
    final sync = personaSyncV4OrNull;
    if (staged == null || sync == null) return null;
    return PersonaActivationFinalBundleV4.fromStaged(staged, sync);
  }

  PersonaActivationDiagnosticSurfaceV4?
  get personaActivationDiagnosticSurfaceV4OrNull {
    final bundle = personaActivationFinalBundleV4OrNull;
    if (bundle == null) return null;
    return PersonaActivationDiagnosticSurfaceV4.fromFinalBundle(bundle);
  }

  PersonaActivationDiagnosticConsistencyMapV4?
  get personaActivationDiagnosticConsistencyMapV4OrNull {
    final surface = personaActivationDiagnosticSurfaceV4OrNull;
    if (surface == null) return null;
    return PersonaActivationDiagnosticConsistencyMapV4.fromDiagnosticSurface(
      surface,
    );
  }

  PersonaRuntimeActivationEnvelopeV4?
  get personaRuntimeActivationEnvelopeV4OrNull {
    final context = personaRuntimeActivationContextV4OrNull;
    final bundle = personaActivationFinalBundleV4OrNull;
    if (context == null || bundle == null) return null;
    return PersonaRuntimeActivationEnvelopeV4(
      finalActivationBundle: bundle,
      runtimeContext: context,
    );
  }

  PersonaRuntimeActivationEnvelopeDeepV4?
  get personaRuntimeActivationEnvelopeDeepV4OrNull {
    final envelope = personaRuntimeActivationEnvelopeV4OrNull;
    final surface = personaActivationDiagnosticSurfaceV4OrNull;
    final consistency = personaActivationDiagnosticConsistencyMapV4OrNull;
    final context = personaRuntimeActivationContextV4OrNull;
    final audit = personaPreActivationAuditV4OrNull;
    final matrix = personaPreActivationCheckMatrixV4OrNull;
    final gate = personaActivationGateV4OrNull;
    final supervisor = personaActivationSupervisorV4OrNull;
    final outcome = personaActivationOutcomeResolverV4OrNull;
    final consistencyResolver = personaActivationConsistencyResolverV4OrNull;
    final confidence = personaActivationConfidenceV4OrNull;
    final staged = personaActivationStagedV4OrNull;
    final finalBundle = personaActivationFinalBundleV4OrNull;
    if (envelope == null ||
        surface == null ||
        consistency == null ||
        context == null ||
        audit == null ||
        matrix == null ||
        gate == null ||
        supervisor == null ||
        outcome == null ||
        consistencyResolver == null ||
        confidence == null ||
        staged == null ||
        finalBundle == null) {
      return null;
    }
    return PersonaRuntimeActivationEnvelopeDeepV4.fromComponents(
      finalBundle: finalBundle,
      surface: surface,
      consistency: consistency,
      runtimeContext: context,
      runtimeEnvelope: envelope,
      audit: audit,
      matrix: matrix,
      gate: gate,
      supervisor: supervisor,
      outcome: outcome,
      consistencyResolver: consistencyResolver,
      confidence: confidence,
      staged: staged,
    );
  }

  Map<String, Object?>? get personaActivationTelemetryHandshakeV4OrNull {
    final snapshot = personaActivationSnapshotV4OrNull;
    final runtimeDeep = personaRuntimeActivationEnvelopeDeepV4OrNull;
    if (snapshot == null || runtimeDeep == null) return null;
    return snapshot.crossModuleHandshake();
  }

  PersonaActivationPreviewV4? get personaActivationPreviewV4OrNull {
    final bundle = personaActivationFinalBundleV4OrNull;
    if (bundle == null) return null;
    return PersonaActivationPreviewV4(
      finalBundle: bundle,
      runtimeContext: personaRuntimeActivationContextV4OrNull,
      diagnosticSurface: personaActivationDiagnosticSurfaceV4OrNull,
      confidence: personaActivationConfidenceV4OrNull,
    );
  }

  PersonaActivationPreflightEnvelopeV4?
  get personaActivationPreflightEnvelopeV4OrNull {
    final bundle = personaActivationFinalBundleV4OrNull;
    final preview = personaActivationPreviewEnvelopeV4OrNull;
    if (bundle == null || preview == null) return null;
    return PersonaActivationPreflightEnvelopeV4(
      preview: preview,
      finalBundle: bundle,
      diagnosticSurface: personaActivationDiagnosticSurfaceV4OrNull,
      diagnosticConsistency: personaActivationDiagnosticConsistencyMapV4OrNull,
      confidence: personaActivationConfidenceV4OrNull,
      staged: personaActivationStagedV4OrNull,
      outcome: personaActivationOutcomeResolverV4OrNull,
      runtimeContext: personaRuntimeActivationContextV4OrNull,
      runtimeEnvelope: personaRuntimeActivationEnvelopeV4OrNull,
    );
  }

  PersonaActivationPreflightConsistencyV4?
  get personaActivationPreflightConsistencyV4OrNull {
    final envelope = personaActivationPreflightEnvelopeV4OrNull;
    if (envelope == null) return null;
    return PersonaActivationPreflightConsistencyV4.fromEnvelope(envelope);
  }

  PersonaActivationPreflightDeltaV4?
  get personaActivationPreflightDeltaV4OrNull {
    final envelope = personaActivationPreflightEnvelopeV4OrNull;
    final consistency = personaActivationPreflightConsistencyV4OrNull;
    if (envelope == null || consistency == null) return null;
    return PersonaActivationPreflightDeltaV4.fromEnvelopeAndConsistency(
      envelope,
      consistency,
    );
  }

  PersonaActivationPreflightAggregatorV4?
  get personaActivationPreflightAggregatorV4OrNull {
    final envelope = personaActivationPreflightEnvelopeV4OrNull;
    final consistency = personaActivationPreflightConsistencyV4OrNull;
    final delta = personaActivationPreflightDeltaV4OrNull;
    if (envelope == null || consistency == null || delta == null) return null;
    return PersonaActivationPreflightAggregatorV4.fromComponents(
      envelope,
      consistency,
      delta,
    );
  }

  PersonaActivationPreflightGateV4? get personaActivationPreflightGateV4OrNull {
    final aggregator = personaActivationPreflightAggregatorV4OrNull;
    if (aggregator == null) return null;
    return PersonaActivationPreflightGateV4.fromAggregator(aggregator);
  }

  PersonaActivationPreflightGateConsistencyV4?
  get personaActivationPreflightGateConsistencyV4OrNull {
    final gate = personaActivationPreflightGateV4OrNull;
    final delta = personaActivationPreflightDeltaV4OrNull;
    if (gate == null || delta == null) return null;
    return PersonaActivationPreflightGateConsistencyV4.fromGateAndDelta(
      gate,
      delta,
    );
  }

  PersonaActivationPreflightMergedV4?
  get personaActivationPreflightMergedV4OrNull {
    final envelope = personaActivationPreflightEnvelopeV4OrNull;
    final consistency = personaActivationPreflightConsistencyV4OrNull;
    final delta = personaActivationPreflightDeltaV4OrNull;
    if (envelope == null || consistency == null || delta == null) return null;
    return PersonaActivationPreflightMergedV4.fromParts(
      envelope,
      consistency,
      delta,
    );
  }

  PersonaActivationPreviewEnvelopeV4?
  get personaActivationPreviewEnvelopeV4OrNull {
    final bundle = personaActivationFinalBundleV4OrNull;
    if (bundle == null) return null;
    return PersonaActivationPreviewEnvelopeV4(
      finalBundle: bundle,
      runtimeContext: personaRuntimeActivationContextV4OrNull,
      diagnosticSurface: personaActivationDiagnosticSurfaceV4OrNull,
      confidence: personaActivationConfidenceV4OrNull,
      staged: personaActivationStagedV4OrNull,
      outcome: personaActivationOutcomeResolverV4OrNull,
    );
  }

  PersonaActivationSynthesisV4? get personaActivationSynthesisV4OrNull {
    final merged = personaActivationPreflightMergedV4OrNull;
    final gate = personaActivationPreflightGateV4OrNull;
    final gateConsistency = personaActivationPreflightGateConsistencyV4OrNull;
    final consistency = personaActivationPreflightConsistencyV4OrNull;
    final delta = personaActivationPreflightDeltaV4OrNull;
    if (merged == null ||
        gate == null ||
        gateConsistency == null ||
        consistency == null ||
        delta == null)
      return null;
    return PersonaActivationSynthesisV4.fromPreflight(
      merged: merged,
      gate: gate,
      gateConsistency: gateConsistency,
      consistency: consistency,
      delta: delta,
    );
  }

  PersonaActivationSynthesisAnnotatedV4?
  get personaActivationSynthesisAnnotatedV4OrNull {
    final synthesis = personaActivationSynthesisV4OrNull;
    if (synthesis == null) return null;
    return PersonaActivationSynthesisAnnotatedV4.fromSynthesisTier0(synthesis);
  }

  PersonaActivationSynthesisWeightedV4?
  get personaActivationSynthesisWeightedV4OrNull {
    final annotated = personaActivationSynthesisAnnotatedV4OrNull;
    if (annotated == null) return null;
    return PersonaActivationSynthesisWeightedV4.fromAnnotated(annotated);
  }

  PersonaActivationSynthesisResolvedV4?
  get personaActivationSynthesisResolvedV4OrNull {
    final weighted = personaActivationSynthesisWeightedV4OrNull;
    if (weighted == null) return null;
    return PersonaActivationSynthesisResolvedV4.fromWeighted(weighted);
  }

  PersonaActivationSynthesisFinalV4?
  get personaActivationSynthesisFinalV4OrNull {
    final resolved = personaActivationSynthesisResolvedV4OrNull;
    if (resolved == null) return null;
    return PersonaActivationSynthesisFinalV4.fromResolved(resolved);
  }

  PersonaActivationSynthesisEnvelopeV4?
  get personaActivationSynthesisEnvelopeV4OrNull {
    final finalLayer = personaActivationSynthesisFinalV4OrNull;
    if (finalLayer == null) return null;
    return PersonaActivationSynthesisEnvelopeV4.fromFinal(finalLayer);
  }

  PersonaActivationSynthesisTelemetryV4?
  get personaActivationSynthesisTelemetryV4OrNull {
    final envelope = personaActivationSynthesisEnvelopeV4OrNull;
    if (envelope == null) return null;
    return PersonaActivationSynthesisTelemetryV4.fromEnvelope(envelope);
  }

  PersonaActivationSynthesisTelemetryEnvelopeV4?
  get personaActivationSynthesisTelemetryEnvelopeV4OrNull {
    final envelope = personaActivationSynthesisEnvelopeV4OrNull;
    final telemetry = personaActivationSynthesisTelemetryV4OrNull;
    if (envelope == null || telemetry == null) return null;
    return PersonaActivationSynthesisTelemetryEnvelopeV4.fromSources(
      synthesisEnvelope: envelope,
      telemetrySnapshot: telemetry,
    );
  }

  PersonaActivationTelemetryUnifiedBridgeV4?
  get personaActivationTelemetryUnifiedBridgeV4OrNull {
    final synthesisEnvelope =
        personaActivationSynthesisTelemetryEnvelopeV4OrNull;
    final unifiedSnapshot = personaActivationSnapshotV4UnifiedOrNull;
    if (synthesisEnvelope == null || unifiedSnapshot == null) return null;
    return PersonaActivationTelemetryUnifiedBridgeV4.fromEnvelopes(
      synthesisTelemetryEnvelope: synthesisEnvelope,
      unifiedOutbound: unifiedSnapshot,
    );
  }

  Map<String, Object?>? get personaActivationTelemetryRelayV4OrNull {
    final unified = personaActivationTelemetryUnifiedBridgeV4OrNull;
    final snapshot = _lastUnifiedSnapshotForRelay;
    if (unified == null || snapshot == null) return null;
    return snapshot.relayForCrossModule();
  }

  Map<String, Object?>? get personaV4TelemetryUnifiedOrNull {
    if (!_isV4RuntimeActivated) return null;
    final activation = personaActivationSynthesisTelemetryEnvelopeV4OrNull;
    final emotion = personaEmotionSynthesisTelemetryV4OrNull;
    final fusion =
        personaEmotionFusionSynthesisTelemetryUnifiedEnvelopeV4OrNull;
    if (activation == null || emotion == null || fusion == null) return null;
    final bundle = PersonaV4TelemetryUnifiedBundleV4(
      activation: activation.asUnifiedTelemetry(),
      emotion: emotion.asTelemetryMap(),
      fusion: fusion.asReadOnlyMap(),
    );
    return bundle.asReadOnlyMap();
  }

  PersonaV4TelemetryMasterEnvelopeV4?
  get personaV4TelemetryMasterEnvelopeV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final activation = personaActivationSynthesisTelemetryEnvelopeV4OrNull;
    final emotion = personaEmotionSynthesisTelemetryV4OrNull;
    final fusion =
        personaEmotionFusionSynthesisTelemetryUnifiedEnvelopeV4OrNull;
    if (activation == null || emotion == null || fusion == null) return null;
    return PersonaV4TelemetryMasterEnvelopeV4(
      activationTelemetry: activation.asUnifiedTelemetry(),
      emotionTelemetry: emotion.asTelemetryMap(),
      fusionTelemetry: fusion.asReadOnlyMap(),
    );
  }

  Map<String, Object?>? get personaV4TelemetryMasterRelayOrNull {
    final envelope = personaV4TelemetryMasterEnvelopeV4OrNull;
    if (envelope == null) return null;
    return envelope.harmonizedMasterRelay();
  }

  PersonaActivationSnapshotV4? get personaActivationSnapshotV4OrNull {
    final finalBundle = personaActivationFinalBundleV4OrNull;
    final outcome = personaActivationOutcomeResolverV4OrNull;
    final confidence = personaActivationConfidenceV4OrNull;
    final staged = personaActivationStagedV4OrNull;
    final matrix = personaPreActivationCheckMatrixV4OrNull;
    final gate = personaActivationGateV4OrNull;
    final supervisor = personaActivationSupervisorV4OrNull;
    final surface = personaActivationDiagnosticSurfaceV4OrNull;
    final consistency = personaActivationDiagnosticConsistencyMapV4OrNull;
    final runtimeContext = personaRuntimeActivationContextV4OrNull;
    final runtimeEnvelope = personaRuntimeActivationEnvelopeV4OrNull;
    final runtimeEnvelopeDeep = personaRuntimeActivationEnvelopeDeepV4OrNull;
    if (finalBundle == null ||
        outcome == null ||
        confidence == null ||
        staged == null ||
        matrix == null ||
        gate == null ||
        supervisor == null ||
        surface == null ||
        consistency == null ||
        runtimeContext == null ||
        runtimeEnvelope == null ||
        runtimeEnvelopeDeep == null)
      return null;
    final kernel = SimulationMotionKernel.current;
    return PersonaActivationSnapshotV4(
      finalActivationBundle: finalBundle.asReadOnlyMap(),
      activationOutcome: outcome.asReadOnlyMap(),
      activationConfidence: confidence.asReadOnlyMap(),
      activationTier: staged.asReadOnlyMap(),
      readinessMatrix: matrix.asReadOnlyMap(),
      activationGate: gate.asReadOnlyMap(),
      activationSupervisor: supervisor.asReadOnlyMap(),
      diagnosticSurface: surface.asReadOnlyMap(),
      diagnosticConsistency: consistency.asReadOnlyMap(),
      runtimeContext: runtimeContext.asReadOnlyMap(),
      runtimeEnvelope: runtimeEnvelope.asReadOnlyMap(),
      runtimeEnvelopeDeep: runtimeEnvelopeDeep.asReadOnlyMap(),
      kernelSurface: kernel?.v4SurfaceSyncTripleOrNull,
      kernelCohesion: kernel?.v4CohesionWeightsOrNull,
      kernelMeshDescriptor: kernel?.motionMeshDescriptorOrNull?.asReadOnlyMap(),
      kernelMeshVector: kernel?.motionMeshVectorOrNull?.asReadOnlyMap(),
      kernelMeshFusion: kernel?.motionMeshFusionOrNull?.asReadOnlyMap(),
      kernelMeshConsistency: kernel?.motionMeshConsistencyOrNull
          ?.asReadOnlyMap(),
    );
  }

  bool get _isV4RuntimeActivated => appRoot.isV4RuntimeFullyActivated;

  EmotionEngineV4? get personaEmotionEngineV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    const engine = EmotionEngineV4(
      moodVector: MoodVectorV4(),
      toneVector: ToneVectorV4(),
      arousal: null,
      valence: null,
      moodStability: null,
      arousalStability: null,
      moodRegulation: null,
      toneRegulation: null,
      arousalRegulation: null,
      valenceRegulation: null,
      moodCoherence: null,
      toneCoherence: null,
      arousalCoherence: null,
      valenceCoherence: null,
      moodFusion: null,
      toneFusion: null,
      arousalFusion: null,
      valenceFusion: null,
    );
    SimulationMotionKernel.current?.acceptEmotionFusionV4(
      engine.asReadOnlyMap(),
    );
    return engine;
  }

  Map<String, Object?>? get personaEmotionPassiveLogicV4OrNull {
    final engine = personaEmotionEngineV4OrNull;
    if (engine == null) return null;
    return engine.asPassiveLogicMap();
  }

  EmotionFusionSynthesisV4? get personaEmotionFusionSynthesisV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final engine = personaEmotionEngineV4OrNull;
    if (engine == null) return null;
    return EmotionFusionSynthesisV4(fusion: engine.asReadOnlyMap());
  }

  EmotionFusionPreflightV4? get personaEmotionFusionPreflightV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final synthesis = personaEmotionFusionSynthesisV4OrNull;
    if (synthesis == null) return null;
    return EmotionFusionPreflightV4(fusion: synthesis.asReadOnlyMap());
  }

  EmotionFusionPreflightConsistencyV4?
  get personaEmotionFusionPreflightConsistencyV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final preflight = personaEmotionFusionPreflightV4OrNull;
    final synthesis = personaEmotionFusionSynthesisV4OrNull;
    if (preflight == null || synthesis == null) return null;
    return EmotionFusionPreflightConsistencyV4(
      preflight: preflight,
      synthesis: synthesis,
    );
  }

  EmotionFusionPreflightDeltaV4?
  get personaEmotionFusionPreflightDeltaV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final preflight = personaEmotionFusionPreflightV4OrNull;
    final consistency = personaEmotionFusionPreflightConsistencyV4OrNull;
    if (preflight == null || consistency == null) return null;
    return EmotionFusionPreflightDeltaV4(
      preflight: preflight,
      consistency: consistency,
    );
  }

  EmotionFusionPreflightAggregatorV4?
  get personaEmotionFusionPreflightAggregatorV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final synthesis = personaEmotionFusionSynthesisV4OrNull;
    final preflight = personaEmotionFusionPreflightV4OrNull;
    final consistency = personaEmotionFusionPreflightConsistencyV4OrNull;
    final delta = personaEmotionFusionPreflightDeltaV4OrNull;
    if (synthesis == null ||
        preflight == null ||
        consistency == null ||
        delta == null)
      return null;
    return EmotionFusionPreflightAggregatorV4(
      fusionSynthesis: synthesis.asReadOnlyMap(),
      fusionPreflight: preflight.asReadOnlyMap(),
      fusionConsistency: consistency.asReadOnlyMap(),
      fusionDelta: delta.asReadOnlyMap(),
    );
  }

  EmotionFusionMergedV4? get personaEmotionFusionMergedV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final synthesis = personaEmotionFusionSynthesisV4OrNull;
    final preflight = personaEmotionFusionPreflightV4OrNull;
    final consistency = personaEmotionFusionPreflightConsistencyV4OrNull;
    final delta = personaEmotionFusionPreflightDeltaV4OrNull;
    if (synthesis == null ||
        preflight == null ||
        consistency == null ||
        delta == null)
      return null;
    return EmotionFusionMergedV4(
      synthesis: synthesis.asReadOnlyMap(),
      preflight: preflight.asReadOnlyMap(),
      consistency: consistency.asReadOnlyMap(),
      delta: delta.asReadOnlyMap(),
    );
  }

  EmotionFusionSynthesisFinalV4?
  get personaEmotionFusionSynthesisFinalV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final merged = personaEmotionFusionMergedV4OrNull;
    if (merged == null) return null;
    return EmotionFusionSynthesisFinalV4(merged: merged.asReadOnlyMap());
  }

  EmotionFusionSynthesisEnvelopeV4?
  get personaEmotionFusionSynthesisEnvelopeV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final finalLayer = personaEmotionFusionSynthesisFinalV4OrNull;
    final merged = personaEmotionFusionMergedV4OrNull;
    if (finalLayer == null || merged == null) return null;
    return EmotionFusionSynthesisEnvelopeV4(
      finalSynthesis: finalLayer.asReadOnlyMap(),
      merged: merged.asReadOnlyMap(),
    );
  }

  EmotionFusionSynthesisTelemetryV4?
  get personaEmotionFusionSynthesisTelemetryV4OrNull {
    final envelope = personaEmotionFusionSynthesisEnvelopeV4OrNull;
    if (envelope == null) return null;
    return EmotionFusionSynthesisTelemetryV4(
      finalSynthesis: envelope.finalSynthesis,
      merged: envelope.merged,
    );
  }

  EmotionFusionSynthesisTelemetryEnvelopeV4?
  get personaEmotionFusionSynthesisTelemetryEnvelopeV4OrNull {
    final envelope = personaEmotionFusionSynthesisEnvelopeV4OrNull;
    final telemetry = personaEmotionFusionSynthesisTelemetryV4OrNull;
    if (envelope == null || telemetry == null) return null;
    return EmotionFusionSynthesisTelemetryEnvelopeV4(
      envelope: envelope.asReadOnlyMap(),
      telemetry: telemetry.asReadOnlyMap(),
    );
  }

  EmotionFusionSynthesisTelemetryBridgeV4?
  get personaEmotionFusionSynthesisTelemetryBridgeV4OrNull {
    final envelope = personaEmotionFusionSynthesisTelemetryEnvelopeV4OrNull;
    final telemetry = personaEmotionFusionSynthesisTelemetryV4OrNull;
    if (envelope == null || telemetry == null) return null;
    return EmotionFusionSynthesisTelemetryBridgeV4(
      envelope: envelope.asReadOnlyMap(),
      telemetry: telemetry.asReadOnlyMap(),
    );
  }

  EmotionFusionSynthesisTelemetryUnifiedEnvelopeV4?
  get personaEmotionFusionSynthesisTelemetryUnifiedEnvelopeV4OrNull {
    final envelope = personaEmotionFusionSynthesisTelemetryEnvelopeV4OrNull;
    final telemetry = personaEmotionFusionSynthesisTelemetryV4OrNull;
    if (envelope == null || telemetry == null) return null;
    return EmotionFusionSynthesisTelemetryUnifiedEnvelopeV4(
      envelope: envelope.asReadOnlyMap(),
      telemetry: telemetry.asReadOnlyMap(),
    );
  }

  EmotionFusionSynthesisTelemetryRelayV4?
  get personaEmotionFusionSynthesisTelemetryRelayV4OrNull {
    final envelope = personaEmotionFusionSynthesisTelemetryEnvelopeV4OrNull;
    final telemetry = personaEmotionFusionSynthesisTelemetryV4OrNull;
    if (envelope == null || telemetry == null) return null;
    return EmotionFusionSynthesisTelemetryRelayV4(
      envelope: envelope.asReadOnlyMap(),
      telemetry: telemetry.asReadOnlyMap(),
    );
  }

  EmotionFusionPreflightGateV4? get personaEmotionFusionPreflightGateV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final aggregator = personaEmotionFusionPreflightAggregatorV4OrNull;
    if (aggregator == null) return null;
    final delta = aggregator.fusionDelta;
    return EmotionFusionPreflightGateV4(
      moodReady: delta['moodFusionDelta'] == false,
      toneReady: delta['toneFusionDelta'] == false,
      arousalReady: delta['arousalFusionDelta'] == false,
      valenceReady: delta['valenceFusionDelta'] == false,
    );
  }

  EmotionFusionPreflightGateConsistencyV4?
  get personaEmotionFusionPreflightGateConsistencyV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final gate = personaEmotionFusionPreflightGateV4OrNull;
    final delta = personaEmotionFusionPreflightDeltaV4OrNull;
    if (gate == null || delta == null) return null;
    return EmotionFusionPreflightGateConsistencyV4(
      moodConsistent: gate.moodReady == !(delta.moodFusionDelta),
      toneConsistent: gate.toneReady == !(delta.toneFusionDelta),
      arousalConsistent: gate.arousalReady == !(delta.arousalFusionDelta),
      valenceConsistent: gate.valenceReady == !(delta.valenceFusionDelta),
    );
  }

  EmotionSynthesisV4? get personaEmotionSynthesisV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final engine = personaEmotionEngineV4OrNull;
    final enginePassive = personaEmotionPassiveLogicV4OrNull;
    if (engine == null || enginePassive == null) return null;
    final engineMap = {...engine.asReadOnlyMap(), ...enginePassive};
    final preflight = personaEmotionPreflightV4OrNull;
    final consistency = personaEmotionPreflightConsistencyV4OrNull;
    final delta = personaEmotionPreflightDeltaV4OrNull;
    final merged = personaEmotionPreflightMergedV4OrNull;
    if (preflight == null ||
        consistency == null ||
        delta == null ||
        merged == null)
      return null;
    return EmotionSynthesisV4(
      preflight: preflight.asReadOnlyMap(),
      consistency: consistency.asReadOnlyMap(),
      delta: delta.asReadOnlyMap(),
      merged: merged.asReadOnlyMap(),
      engineState: engineMap,
    );
  }

  EmotionTierAFinalEnvelopeV4? get personaEmotionTierAFinalEnvelopeV4OrNull {
    final synthesis = personaEmotionSynthesisV4OrNull;
    if (synthesis == null) return null;
    return EmotionTierAFinalEnvelopeV4(synthesis: synthesis.asReadOnlyMap());
  }

  EmotionTierASurfaceAuditorV4? get emotionTierASurfaceAuditorV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final synthesis = personaEmotionSynthesisV4OrNull;
    if (synthesis == null) return null;
    return EmotionTierASurfaceAuditorV4(
      synthesisMap: synthesis.asReadOnlyMap(),
    );
  }

  EmotionTierAReadinessMatrixV4? get emotionTierAReadinessMatrixV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final synthesis = personaEmotionSynthesisV4OrNull;
    if (synthesis == null) return null;
    return EmotionTierAReadinessMatrixV4(
      synthesisMap: synthesis.asReadOnlyMap(),
    );
  }

  EmotionTierASupervisorV4? get emotionTierASupervisorV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final readiness = emotionTierAReadinessMatrixV4OrNull;
    if (readiness == null) return null;
    return EmotionTierASupervisorV4(readinessMatrix: readiness.asReadOnlyMap());
  }

  EmotionTierAOutcomeResolverV4? get emotionTierAOutcomeResolverV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final readiness = emotionTierAReadinessMatrixV4OrNull;
    final supervisor = emotionTierASupervisorV4OrNull;
    if (readiness == null || supervisor == null) return null;
    return EmotionTierAOutcomeResolverV4(
      readinessMatrix: readiness.asReadOnlyMap(),
      supervisor: supervisor.asReadOnlyMap(),
    );
  }

  EmotionTierAFinalBundleV4? get emotionTierAFinalBundleV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final readiness = emotionTierAReadinessMatrixV4OrNull;
    final supervisor = emotionTierASupervisorV4OrNull;
    final outcome = emotionTierAOutcomeResolverV4OrNull;
    final synthesis = personaEmotionSynthesisV4OrNull;
    if (readiness == null ||
        supervisor == null ||
        outcome == null ||
        synthesis == null)
      return null;
    return EmotionTierAFinalBundleV4(
      readinessMatrix: readiness.asReadOnlyMap(),
      supervisor: supervisor.asReadOnlyMap(),
      outcome: outcome.asReadOnlyMap(),
      synthesis: synthesis.asReadOnlyMap(),
    );
  }

  EmotionTierAFinalLogicV4? get personaEmotionTierAFinalLogicV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final synthesis = personaEmotionSynthesisV4OrNull;
    if (synthesis == null) return null;
    return EmotionTierAFinalLogicV4(synthesis: synthesis.asReadOnlyMap());
  }

  EmotionTierAMasterEnvelopeV4? get personaEmotionTierAMasterEnvelopeV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final finalBundle = emotionTierAFinalBundleV4OrNull;
    final synthesis = personaEmotionSynthesisV4OrNull;
    if (finalBundle == null || synthesis == null) return null;
    return EmotionTierAMasterEnvelopeV4(
      finalBundle: finalBundle.asReadOnlyMap(),
      synthesis: synthesis.asReadOnlyMap(),
    );
  }

  EmotionTierATelemetryV4? get emotionTierATelemetryV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final finalBundle = emotionTierAFinalBundleV4OrNull;
    if (finalBundle == null) return null;
    return EmotionTierATelemetryV4(finalBundle: finalBundle.asReadOnlyMap());
  }

  EmotionTierATelemetryEnvelopeV4? get emotionTierATelemetryEnvelopeV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final finalBundle = emotionTierAFinalBundleV4OrNull;
    final telemetry = emotionTierATelemetryV4OrNull;
    if (finalBundle == null || telemetry == null) return null;
    return EmotionTierATelemetryEnvelopeV4(
      finalBundle: finalBundle.asReadOnlyMap(),
      telemetryMap: telemetry.asReadOnlyMap(),
    );
  }

  EmotionTierATelemetryBridgeV4? get emotionTierATelemetryBridgeV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final envelope = emotionTierATelemetryEnvelopeV4OrNull;
    final telemetry = emotionTierATelemetryV4OrNull;
    if (envelope == null || telemetry == null) return null;
    return EmotionTierATelemetryBridgeV4(
      envelope: envelope.asReadOnlyMap(),
      telemetry: telemetry.asReadOnlyMap(),
    );
  }

  AIPersonalizationSeedV4? get personaAIPersonalizationSeedV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    return const AIPersonalizationSeedV4();
  }

  AIPersonalizationVectorV4? get personaAIPersonalizationVectorV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    return const AIPersonalizationVectorV4();
  }

  AIPersonalizationConsistencyV4?
  get personaAIPersonalizationConsistencyV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final seed = personaAIPersonalizationSeedV4OrNull;
    final vector = personaAIPersonalizationVectorV4OrNull;
    if (seed == null || vector == null) return null;
    return AIPersonalizationConsistencyV4(
      seed: seed.asReadOnlyMap(),
      vector: vector.asReadOnlyMap(),
    );
  }

  AIPersonalizationSynthesisV4? get personaAIPersonalizationSynthesisV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final seed = personaAIPersonalizationSeedV4OrNull;
    final vector = personaAIPersonalizationVectorV4OrNull;
    if (seed == null || vector == null) return null;
    return AIPersonalizationSynthesisV4(
      seed: seed.asReadOnlyMap(),
      vector: vector.asReadOnlyMap(),
    );
  }

  AIPersonalizationPreflightV4? get personaAIPersonalizationPreflightV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final seed = personaAIPersonalizationSeedV4OrNull;
    final vector = personaAIPersonalizationVectorV4OrNull;
    return AIPersonalizationPreflightV4(
      hasSeed: seed != null,
      hasVector: vector != null,
    );
  }

  AIPersonalizationPreflightConsistencyV4?
  get personaAIPersonalizationPreflightConsistencyV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final preflight = personaAIPersonalizationPreflightV4OrNull;
    if (preflight == null) return null;
    return AIPersonalizationPreflightConsistencyV4(
      seedConsistent: preflight.hasSeed,
      vectorConsistent: preflight.hasVector,
    );
  }

  AIPersonalizationPreflightDeltaV4?
  get personaAIPersonalizationPreflightDeltaV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final preflight = personaAIPersonalizationPreflightV4OrNull;
    final consistency = personaAIPersonalizationPreflightConsistencyV4OrNull;
    if (preflight == null || consistency == null) return null;
    return AIPersonalizationPreflightDeltaV4(
      hasSeed: preflight.hasSeed,
      hasVector: preflight.hasVector,
      seedConsistent: consistency.seedConsistent,
      vectorConsistent: consistency.vectorConsistent,
    );
  }

  AIPersonalizationDeltaV4? get personaAIPersonalizationDeltaV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final preflight = personaAIPersonalizationPreflightV4OrNull;
    final consistency = personaAIPersonalizationPreflightConsistencyV4OrNull;
    if (preflight == null || consistency == null) return null;
    return AIPersonalizationDeltaV4(
      seedDelta: preflight.hasSeed != consistency.seedConsistent,
      vectorDelta: preflight.hasVector != consistency.vectorConsistent,
    );
  }

  AIPersonalizationPreflightAggregatorV4?
  get personaAIPersonalizationPreflightAggregatorV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final synthesis = personaAIPersonalizationSynthesisV4OrNull;
    final preflight = personaAIPersonalizationPreflightV4OrNull;
    final consistency = personaAIPersonalizationPreflightConsistencyV4OrNull;
    final delta = personaAIPersonalizationPreflightDeltaV4OrNull;
    if (synthesis == null ||
        preflight == null ||
        consistency == null ||
        delta == null)
      return null;
    return AIPersonalizationPreflightAggregatorV4(
      synthesis: synthesis.asReadOnlyMap(),
      preflight: preflight.asReadOnlyMap(),
      consistency: consistency.asReadOnlyMap(),
      delta: delta.asReadOnlyMap(),
    );
  }

  AIPersonalizationPreflightMergedV4?
  get personaAIPersonalizationPreflightMergedV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final synthesis = personaAIPersonalizationSynthesisV4OrNull;
    final preflight = personaAIPersonalizationPreflightV4OrNull;
    final consistency = personaAIPersonalizationPreflightConsistencyV4OrNull;
    final delta = personaAIPersonalizationPreflightDeltaV4OrNull;
    if (synthesis == null ||
        preflight == null ||
        consistency == null ||
        delta == null)
      return null;
    return AIPersonalizationPreflightMergedV4(
      synthesis: synthesis.asReadOnlyMap(),
      preflight: preflight.asReadOnlyMap(),
      consistency: consistency.asReadOnlyMap(),
      delta: delta.asReadOnlyMap(),
    );
  }

  AIPersonalizationSynthesisFinalV4?
  get personaAIPersonalizationSynthesisFinalV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final synthesis = personaAIPersonalizationSynthesisV4OrNull;
    final merged = personaAIPersonalizationPreflightMergedV4OrNull;
    if (synthesis == null || merged == null) return null;
    return AIPersonalizationSynthesisFinalV4(
      synthesis: synthesis.asReadOnlyMap(),
      merged: merged.asReadOnlyMap(),
    );
  }

  AIPersonalizationSynthesisTelemetryV4?
  get personaAIPersonalizationSynthesisTelemetryV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final finalLayer = personaAIPersonalizationSynthesisFinalV4OrNull;
    if (finalLayer == null) return null;
    return AIPersonalizationSynthesisTelemetryV4(
      finalSynthesis: finalLayer.asReadOnlyMap(),
    );
  }

  AIPersonalizationSynthesisEnvelopeV4?
  get personaAIPersonalizationSynthesisEnvelopeV4OrNull {
    final finalLayer = personaAIPersonalizationSynthesisFinalV4OrNull;
    final merged = personaAIPersonalizationPreflightMergedV4OrNull;
    if (!_isV4RuntimeActivated || finalLayer == null || merged == null)
      return null;
    return AIPersonalizationSynthesisEnvelopeV4(
      finalSynthesis: finalLayer.asReadOnlyMap(),
      merged: merged.asReadOnlyMap(),
    );
  }

  AIPersonalizationSynthesisTelemetryEnvelopeV4?
  get personaAIPersonalizationSynthesisTelemetryEnvelopeV4OrNull {
    final finalLayer = personaAIPersonalizationSynthesisFinalV4OrNull;
    final telemetry = personaAIPersonalizationSynthesisTelemetryV4OrNull;
    if (!_isV4RuntimeActivated || finalLayer == null || telemetry == null)
      return null;
    return AIPersonalizationSynthesisTelemetryEnvelopeV4(
      finalSynthesis: finalLayer.asReadOnlyMap(),
      telemetry: telemetry.asReadOnlyMap(),
    );
  }

  AIPersonalizationSynthesisTelemetryUnifiedV4?
  get personaAIPersonalizationSynthesisTelemetryUnifiedV4OrNull {
    final envelope = personaAIPersonalizationSynthesisTelemetryEnvelopeV4OrNull;
    final telemetry = personaAIPersonalizationSynthesisTelemetryV4OrNull;
    if (envelope == null || telemetry == null) return null;
    return AIPersonalizationSynthesisTelemetryUnifiedV4(
      telemetryEnvelope: envelope.asReadOnlyMap(),
      telemetryMap: telemetry.asReadOnlyMap(),
    );
  }

  AIPersonalizationSynthesisTelemetryRelayV4?
  get personaAIPersonalizationSynthesisTelemetryRelayV4OrNull {
    final envelope = personaAIPersonalizationSynthesisTelemetryEnvelopeV4OrNull;
    final telemetry = personaAIPersonalizationSynthesisTelemetryV4OrNull;
    if (!_isV4RuntimeActivated || envelope == null || telemetry == null) {
      return null;
    }
    return AIPersonalizationSynthesisTelemetryRelayV4(
      telemetryEnvelope: envelope.asReadOnlyMap(),
      telemetryMap: telemetry.asReadOnlyMap(),
    );
  }

  AIPersonalizationTierBTelemetryEnvelopeV4?
  get personaAIPersonalizationTierBTelemetryEnvelopeV4OrNull {
    final telemetry = personaAIPersonalizationSynthesisTelemetryV4OrNull;
    final relay = personaAIPersonalizationSynthesisTelemetryRelayV4OrNull;
    final master = personaAIPersonalizationTierBMasterBundleV4OrNull;
    if (!_isV4RuntimeActivated ||
        telemetry == null ||
        relay == null ||
        master == null)
      return null;
    return AIPersonalizationTierBTelemetryEnvelopeV4(
      telemetry: telemetry.asReadOnlyMap(),
      relay: relay.asReadOnlyMap(),
      masterBundle: master.asReadOnlyMap(),
    );
  }

  AIPersonalizationTierBTelemetryUnifiedV4?
  get personaAIPersonalizationTierBTelemetryUnifiedV4OrNull {
    final envelope = personaAIPersonalizationSynthesisTelemetryEnvelopeV4OrNull;
    final telemetry = personaAIPersonalizationSynthesisTelemetryV4OrNull;
    if (envelope == null || telemetry == null) return null;
    return AIPersonalizationTierBTelemetryUnifiedV4(
      telemetryEnvelope: envelope.asReadOnlyMap(),
      telemetryMap: telemetry.asReadOnlyMap(),
    );
  }

  AIPersonalizationTierBTelemetryBridgeV4?
  get personaAIPersonalizationTierBTelemetryBridgeV4OrNull {
    final unified = personaAIPersonalizationTierBTelemetryUnifiedV4OrNull;
    final telemetry = personaAIPersonalizationSynthesisTelemetryV4OrNull;
    if (!_isV4RuntimeActivated || unified == null || telemetry == null) {
      return null;
    }
    return AIPersonalizationTierBTelemetryBridgeV4(
      telemetryUnified: unified.asReadOnlyMap(),
      telemetryMap: telemetry.asReadOnlyMap(),
    );
  }

  EmotionTierATelemetryMasterV4?
  get personaEmotionTierATelemetryMasterV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final finalLogic = personaEmotionTierAFinalLogicV4OrNull;
    final masterEnvelope = personaEmotionTierAMasterEnvelopeV4OrNull;
    final telemetry = emotionTierATelemetryV4OrNull;
    final relay = emotionTierATelemetryRelayV4OrNull;
    if (finalLogic == null ||
        masterEnvelope == null ||
        telemetry == null ||
        relay == null) {
      return null;
    }
    return EmotionTierATelemetryMasterV4(
      finalLogic: finalLogic.asReadOnlyMap(),
      masterEnvelope: masterEnvelope.asReadOnlyMap(),
      telemetryMap: telemetry.asReadOnlyMap(),
      telemetryRelay: relay.asRelayMap(),
    );
  }

  PersonaV4TelemetryUnifiedBridgeV4?
  get personaV4TelemetryUnifiedBridgeV4OrNull {
    final activation = personaActivationSynthesisTelemetryEnvelopeV4OrNull;
    final emotion = emotionTierATelemetryEnvelopeV4OrNull;
    final tierB = personaAIPersonalizationTierBTelemetryEnvelopeV4OrNull;
    if (!_isV4RuntimeActivated ||
        activation == null ||
        emotion == null ||
        tierB == null) {
      return null;
    }
    return PersonaV4TelemetryUnifiedBridgeV4(
      activation: activation.asUnifiedTelemetry(),
      emotion: emotion.asReadOnlyMap(),
      fusion: emotion.asReadOnlyMap(),
      tierB: tierB.asReadOnlyMap(),
    );
  }

  AIPersonalizationTierBMasterEnvelopeV4?
  get personaAIPersonalizationTierBMasterEnvelopeV4OrNull {
    final bridge = personaAIPersonalizationTierBTelemetryBridgeV4OrNull;
    final unified = personaAIPersonalizationTierBTelemetryUnifiedV4OrNull;
    if (!_isV4RuntimeActivated || bridge == null || unified == null) {
      return null;
    }
    return AIPersonalizationTierBMasterEnvelopeV4(
      telemetryBridge: bridge.asReadOnlyMap(),
      telemetryUnified: unified.asReadOnlyMap(),
    );
  }

  AIPersonalizationTierBMasterRelayV4?
  get personaAIPersonalizationTierBMasterRelayV4OrNull {
    final envelope = personaAIPersonalizationTierBMasterEnvelopeV4OrNull;
    final telemetry = personaAIPersonalizationSynthesisTelemetryV4OrNull;
    if (!_isV4RuntimeActivated || envelope == null || telemetry == null) {
      return null;
    }
    return AIPersonalizationTierBMasterRelayV4(
      masterEnvelope: envelope.asReadOnlyMap(),
      telemetryMap: telemetry.asReadOnlyMap(),
    );
  }

  AIPersonalizationTierBMasterBundleV4?
  get personaAIPersonalizationTierBMasterBundleV4OrNull {
    if (!appRoot.isV4RuntimeActivated) return null;
    final finalSynthesis = personaAIPersonalizationSynthesisFinalV4OrNull;
    final telemetry = personaAIPersonalizationSynthesisTelemetryV4OrNull;
    final relay = personaAIPersonalizationSynthesisTelemetryRelayV4OrNull;
    if (finalSynthesis == null || telemetry == null || relay == null)
      return null;
    return AIPersonalizationTierBMasterBundleV4(
      finalSynthesis: finalSynthesis.asReadOnlyMap(),
      telemetry: telemetry.asReadOnlyMap(),
      relay: relay.asReadOnlyMap(),
    );
  }

  Map<String, Object>? get personaProfileStaticTraitsOrNull {
    final finalSynthesis = personaAIPersonalizationSynthesisFinalV4OrNull;
    if (finalSynthesis == null) return null;
    final map = finalSynthesis.asReadOnlyMap();
    final traits = <String, Object>{'profile_name': 'Persona V3'};
    const keys = [
      'finalState',
      'synthSeedScore',
      'synthVectorScore',
      'synthTotalScore',
      'finalSeedLogic',
      'finalVectorLogic',
      'finalPairLogic',
      'finalTierBLogic',
    ];
    for (final key in keys) {
      if (map.containsKey(key)) {
        traits[key] = _coerceTraitValue(map[key]);
      }
    }
    return _sortedAsciiMap(traits);
  }

  Map<String, Object>? get personaProfileAiInsightsOrNull {
    final bundle = personaAIPersonalizationTierBMasterBundleV4OrNull;
    if (bundle == null) return null;
    final bundleMap = bundle.asReadOnlyMap();
    final finalSynthesis = bundleMap['final_synthesis'];
    if (finalSynthesis is! Map<String, Object?>) return null;
    final insights = <String, Object>{};
    for (final entry in finalSynthesis.entries) {
      insights[entry.key] = _coerceTraitValue(entry.value);
    }
    if (insights.isEmpty) return null;
    return _sortedAsciiMap(insights);
  }

  PersonaProfileViewBundleV1? get personaProfileViewBundleOrNull {
    if (!appRoot.isV4RuntimeActivated) return null;
    final staticTraits = personaProfileStaticTraitsOrNull;
    final aiInsights = personaProfileAiInsightsOrNull;
    if (staticTraits == null || aiInsights == null) return null;
    final personaName =
        staticTraits['profile_name']?.toString() ?? 'Persona V3';
    final sortedTraits = Map<String, Object>.unmodifiable(staticTraits);
    final sortedInsights = Map<String, Object>.unmodifiable(aiInsights);
    final surface = PersonaProfileSurfaceV1(
      personaName: personaName,
      staticTraits: sortedTraits,
      aiInsights: sortedInsights,
      readOnly: true,
    );
    final hooks = PersonaProfileExplanationHooksV1(
      staticTraits: sortedTraits,
      aiInsights: sortedInsights,
    );
    final shortExplanation = _clampShortSummary(hooks.buildShortExplanation());
    final longExplanation = _clampLongSummary(hooks.buildLongExplanation());
    return PersonaProfileViewBundleV1(
      surface: surface,
      personaId: personaName.isNotEmpty ? personaName : 'persona_v3',
      staticTraits: sortedTraits,
      aiInsights: sortedInsights,
      shortExplanation: shortExplanation,
      longExplanation: longExplanation,
    );
  }

  PersonaProfileModelV1? get personaProfileModelOrNull {
    if (!appRoot.isV4RuntimeActivated) return null;
    final bundle = personaProfileViewBundleOrNull;
    if (bundle == null) return null;
    final hooks = PersonaProfileExplanationHooksV1(
      staticTraits: bundle.staticTraits,
      aiInsights: bundle.aiInsights,
    );
    return PersonaProfileModelV1(
      personaId: bundle.personaId,
      staticTraits: _toStringMap(bundle.staticTraits),
      aiInsights: _toStringMap(bundle.aiInsights),
      shortSummary: hooks.buildShortExplanation().trim(),
      longSummary: hooks.buildLongExplanation().trim(),
    );
  }

  PersonaProfileOverlayV1? get personaProfileOverlayOrNull {
    final model = personaProfileModelOrNull;
    if (model == null || !appRoot.isV4RuntimeActivated) return null;
    return PersonaProfileOverlayV1(
      title: 'Persona Summary',
      body: model.shortSummary,
    );
  }

  PersonaProfileBundleV1? get personaProfileBundleOrNull {
    final model = personaProfileModelOrNull;
    final overlay = personaProfileOverlayOrNull;
    if (model == null || overlay == null || !appRoot.isV4RuntimeActivated) {
      return null;
    }
    return PersonaProfileBundleV1(model: model, overlay: overlay);
  }

  Widget? buildPersonaProfileOverlayOrNull(BuildContext context) {
    if (!appRoot.isV4RuntimeActivated) return null;
    Theme.of(context);
    final bundle = personaProfileBundleOrNull;
    if (bundle == null) return null;
    final subtitle = personaProfileSubtitleOrNull(context);
    return PersonaProfileOverlayV1(
      title: 'Persona Summary',
      body: bundle.model.shortSummary,
      subtitle: subtitle,
    );
  }

  Widget? srRibbonOrNull(BuildContext context) {
    if (!appRoot.isV4RuntimeActivated) return null;
    final prompt = srPromptOrNull;
    final hint = srHintOrNull;
    if (prompt == null && hint == null) return null;
    return SRRibbonV1(prompt: prompt, hint: hint);
  }

  Widget? recommendationSurfaceOrNull(BuildContext context) {
    if (!appRoot.isV4RuntimeActivated) return null;
    final bridge = srRecommendationBridgeOrNull;
    final topItem = bridge?.ranked.isNotEmpty == true
        ? bridge!.ranked.first
        : null;
    if (topItem == null) return null;
    return RecommendationSurfaceV1(
      title: 'Top Recommendation',
      topItem: topItem,
    );
  }

  Widget? recommendationExplanationOrNull(BuildContext context) {
    if (!appRoot.isV4RuntimeActivated) return null;
    final bridge = srRecommendationBridgeOrNull;
    final topItem = bridge?.ranked.isNotEmpty == true
        ? bridge!.ranked.first
        : null;
    if (topItem == null) return null;
    final model = personaProfileModelOrNull;
    final traits = model != null
        ? Map<String, String>.from(model.staticTraits)
        : null;
    final insights = model != null
        ? Map<String, String>.from(model.aiInsights)
        : null;
    return RecommendationExplainerV1(
      topItem: topItem,
      personaTraits: traits,
      personaInsights: insights,
    );
  }

  Widget? adviceSummaryOrNull(BuildContext context) {
    if (!appRoot.isV4RuntimeActivated) return null;
    final bridge = srRecommendationBridgeOrNull;
    final topItem = bridge?.ranked.isNotEmpty == true
        ? bridge!.ranked.first
        : null;
    if (topItem == null) return null;
    final base = personaProfileShortSummary ?? personaProfileSafeSummary();
    final explanation = recommendationExplanationOrNull(context);
    final snippet = _buildAdviceSnippet(base, explanation);
    return AdviceSummaryV1(topItem: topItem, shortSummaryText: snippet);
  }

  String? get personaProfileShortSummary => appRoot.isV4RuntimeActivated
      ? personaProfileModelOrNull?.shortSummary
      : null;

  String? get personaProfileLongSummary => appRoot.isV4RuntimeActivated
      ? personaProfileModelOrNull?.longSummary
      : null;

  PersonaProfileModelV1? get runtimePersonaProfileOrNull =>
      appRoot.isV4RuntimeActivated ? personaProfileModelOrNull : null;

  String? get runtimePersonaLongSummaryOrNull => appRoot.isV4RuntimeActivated
      ? personaProfileModelOrNull?.longSummary
      : null;

  String personaProfileSafeSummary() {
    final summary = runtimePersonaLongSummaryOrNull;
    if (summary != null && summary.isNotEmpty) {
      return summary.trim();
    }
    return 'No persona data';
  }

  String? personaProfileSubtitleOrNull(BuildContext context) {
    Theme.of(context);
    if (!appRoot.isV4RuntimeActivated) return null;
    final shortSummary = personaProfileShortSummary;
    if (shortSummary == null || shortSummary.isEmpty) return null;
    final text = shortSummary.trim();
    if (text.length > 40) {
      return text.substring(0, 40);
    }
    return text;
  }

  String? get srPromptOrNull {
    if (!appRoot.isV4RuntimeActivated) return null;
    return buildSRPromptOrNull(personaProfileModelOrNull);
  }

  String? get srHintOrNull {
    if (!appRoot.isV4RuntimeActivated) return null;
    return buildSRHintOrNull(personaProfileModelOrNull);
  }

  String? get srNextItemIdOrNull {
    if (!appRoot.isV4RuntimeActivated) return null;
    final queue = const <Map<String, Object?>>[];
    final next = nextSRItemOrNull(queue);
    if (next == null) return null;
    final id = next['id'];
    if (id is String && id.isNotEmpty) return id;
    if (id != null) return id.toString();
    return null;
  }

  String? get srNextPersonaRoutedItemIdOrNull {
    if (!appRoot.isV4RuntimeActivated) return null;
    final model = personaProfileModelOrNull;
    if (model == null) return null;
    final traits = Map<String, String>.from(model.staticTraits);
    final insights = Map<String, String>.from(model.aiInsights);
    final queue = const <Map<String, Object?>>[];
    final next = routeNextItemOrNull(
      queue,
      personaTraits: traits,
      personaInsights: insights,
    );
    if (next == null) return null;
    final id = next['id'];
    if (id is String && id.isNotEmpty) return id;
    if (id != null) return id.toString();
    return null;
  }

  SRSessionBridgeV1? get srSessionBridgeOrNull {
    if (!appRoot.isV4RuntimeActivated) return null;
    final model = personaProfileModelOrNull;
    if (model == null) return null;
    final traits = Map<String, String>.from(model.staticTraits);
    final insights = Map<String, String>.from(model.aiInsights);
    final bridge = SRSessionBridgeV1(
      items: const <Map<String, Object?>>[],
      personaTraits: traits,
      personaInsights: insights,
      nextIdSupplier: () =>
          srNextPersonaRoutedItemIdOrNull ?? srNextItemIdOrNull,
    );
    return bridge;
  }

  SRRecommendationBridgeV1? get srRecommendationBridgeOrNull {
    if (!appRoot.isV4RuntimeActivated) return null;
    final model = personaProfileModelOrNull;
    if (model == null) return null;
    final traits = Map<String, String>.from(model.staticTraits);
    final insights = Map<String, String>.from(model.aiInsights);
    final queues = <String, List<Map<String, Object?>>>{};
    return SRRecommendationBridgeV1(
      items: const <Map<String, Object?>>[],
      srQueues: queues,
      model: model,
    );
  }

  String _clampShortSummary(String text) {
    final trimmed = text.trim();
    return trimmed.length <= 80 ? trimmed : trimmed.substring(0, 80);
  }

  String _clampLongSummary(String text) {
    final trimmed = text.trim();
    return trimmed.length <= 500 ? trimmed : trimmed.substring(0, 500);
  }

  String _buildAdviceSnippet(String base, Widget? explanation) {
    var snippet = base.trim();
    if (explanation != null) {
      snippet += ' • explanation ready';
    }
    if (snippet.length > 120) {
      snippet = snippet.substring(0, 120);
    }
    return snippet;
  }

  ProfilePersonaBridgeV1? get profilePersonaBridgeOrNull {
    final bundle = personaProfileViewBundleOrNull;
    if (bundle == null) return null;
    return ProfilePersonaBridgeV1(
      staticTraits: bundle.staticTraits,
      aiInsights: bundle.aiInsights,
      shortExplanation: bundle.shortExplanation,
      longExplanation: bundle.longExplanation,
    );
  }

  String get personaProfileSummaryText =>
      profilePersonaBridgeOrNull?.shortExplanation ?? '';

  AIPersonalizationPreflightGateV4?
  get personaAIPersonalizationPreflightGateV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final preflight = personaAIPersonalizationPreflightV4OrNull;
    final consistency = personaAIPersonalizationPreflightConsistencyV4OrNull;
    final delta = personaAIPersonalizationPreflightDeltaV4OrNull;
    final aggregator = personaAIPersonalizationPreflightAggregatorV4OrNull;
    if (preflight == null ||
        consistency == null ||
        delta == null ||
        aggregator == null)
      return null;
    final deltaMap = delta.asReadOnlyMap();
    return AIPersonalizationPreflightGateV4(
      isSeedReady: deltaMap['seedDelta'] == false,
      isVectorReady: deltaMap['vectorDelta'] == false,
    );
  }

  AIPersonalizationPreflightGateConsistencyV4?
  get personaAIPersonalizationPreflightGateConsistencyV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final gate = personaAIPersonalizationPreflightGateV4OrNull;
    final delta = personaAIPersonalizationPreflightDeltaV4OrNull;
    if (gate == null || delta == null) return null;
    final deltaMap = delta.asReadOnlyMap();
    return AIPersonalizationPreflightGateConsistencyV4(
      seedConsistent:
          gate.isSeedReady == !(deltaMap['seedDelta'] as bool? ?? false),
      vectorConsistent:
          gate.isVectorReady == !(deltaMap['vectorDelta'] as bool? ?? false),
    );
  }

  EmotionTierATelemetryUnifiedV4? get emotionTierATelemetryUnifiedV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final envelope = emotionTierATelemetryEnvelopeV4OrNull;
    final telemetry = emotionTierATelemetryV4OrNull;
    if (envelope == null || telemetry == null) return null;
    return EmotionTierATelemetryUnifiedV4(
      envelope: envelope.asReadOnlyMap(),
      telemetry: telemetry.asReadOnlyMap(),
    );
  }

  EmotionTierATelemetryRelayV4? get emotionTierATelemetryRelayV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final unified = emotionTierATelemetryUnifiedV4OrNull;
    final telemetry = emotionTierATelemetryV4OrNull;
    if (unified == null || telemetry == null) return null;
    return EmotionTierATelemetryRelayV4(
      envelope: unified.asReadOnlyMap(),
      telemetry: telemetry.asReadOnlyMap(),
    );
  }

  EmotionTierAMasterBundleV4? get emotionTierAMasterBundleV4OrNull {
    if (!_isV4RuntimeActivated) return null;
    final finalBundle = emotionTierAFinalBundleV4OrNull;
    final telemetry = emotionTierATelemetryV4OrNull;
    final relay = emotionTierATelemetryRelayV4OrNull;
    if (finalBundle == null || telemetry == null || relay == null) return null;
    return EmotionTierAMasterBundleV4(
      finalBundle: finalBundle.asReadOnlyMap(),
      telemetry: telemetry.asReadOnlyMap(),
      relay: relay.asRelayMap(),
    );
  }

  EmotionSynthesisFinalV4? get personaEmotionSynthesisFinalV4OrNull {
    final synthesis = personaEmotionSynthesisV4OrNull;
    if (synthesis == null) return null;
    final map = synthesis.asReadOnlyMap();
    final finalState = map['merged'] != null ? 'ok' : 'warn';
    return EmotionSynthesisFinalV4(synthesis: map, finalState: finalState);
  }

  EmotionSynthesisEnvelopeV4? get personaEmotionSynthesisEnvelopeV4OrNull {
    final finalLayer = personaEmotionSynthesisFinalV4OrNull;
    final synthesis = personaEmotionSynthesisV4OrNull;
    if (finalLayer == null || synthesis == null) return null;
    return EmotionSynthesisEnvelopeV4(
      finalLayer: finalLayer.asReadOnlyMap(),
      synthesis: synthesis.asReadOnlyMap(),
    );
  }

  EmotionSynthesisTelemetryV4? get personaEmotionSynthesisTelemetryV4OrNull {
    final envelope = personaEmotionSynthesisEnvelopeV4OrNull;
    if (envelope == null) return null;
    return EmotionSynthesisTelemetryV4(envelope: envelope.asReadOnlyMap());
  }

  EmotionPreflightV4? get personaEmotionPreflightV4OrNull {
    final synthesis = personaEmotionSynthesisV4OrNull;
    if (synthesis == null) return null;
    final map = synthesis.asReadOnlyMap();
    return EmotionPreflightV4(
      synthesis: map,
      hasMood: map['mood'] != null,
      hasTone: map['tone'] != null,
      hasArousal: map['arousal'] != null,
      hasValence: map['valence'] != null,
    );
  }

  EmotionPreflightConsistencyV4?
  get personaEmotionPreflightConsistencyV4OrNull {
    final preflight = personaEmotionPreflightV4OrNull;
    if (preflight == null) return null;
    return EmotionPreflightConsistencyV4.fromPreflight(preflight);
  }

  EmotionPreflightDeltaV4? get personaEmotionPreflightDeltaV4OrNull {
    final preflight = personaEmotionPreflightV4OrNull;
    final consistency = personaEmotionPreflightConsistencyV4OrNull;
    if (preflight == null || consistency == null) return null;
    return EmotionPreflightDeltaV4.fromPreflightAndConsistency(
      preflight,
      consistency,
    );
  }

  EmotionPreflightAggregatorV4? get personaEmotionPreflightAggregatorV4OrNull {
    final preflight = personaEmotionPreflightV4OrNull;
    final consistency = personaEmotionPreflightConsistencyV4OrNull;
    final delta = personaEmotionPreflightDeltaV4OrNull;
    if (preflight == null || consistency == null || delta == null) return null;
    return EmotionPreflightAggregatorV4(
      preflight: preflight.asReadOnlyMap(),
      consistency: consistency.asReadOnlyMap(),
      delta: delta.asReadOnlyMap(),
    );
  }

  EmotionPreflightGateV4? get personaEmotionPreflightGateV4OrNull {
    final preflight = personaEmotionPreflightV4OrNull;
    final consistency = personaEmotionPreflightConsistencyV4OrNull;
    final aggregator = personaEmotionPreflightAggregatorV4OrNull;
    if (preflight == null || consistency == null || aggregator == null)
      return null;
    return EmotionPreflightGateV4(
      isReadyMood: consistency.moodConsistent ?? false,
      isReadyTone: consistency.toneConsistent ?? false,
      isReadyArousal: consistency.arousalConsistent ?? false,
      isReadyValence: consistency.valenceConsistent ?? false,
    );
  }

  EmotionPreflightGateConsistencyV4?
  get personaEmotionPreflightGateConsistencyV4OrNull {
    final gate = personaEmotionPreflightGateV4OrNull;
    final delta = personaEmotionPreflightDeltaV4OrNull;
    if (gate == null || delta == null) return null;
    return EmotionPreflightGateConsistencyV4(
      isConsistentMood: gate.isReadyMood == delta.moodDelta,
      isConsistentTone: gate.isReadyTone == delta.toneDelta,
      isConsistentArousal: gate.isReadyArousal == delta.arousalDelta,
      isConsistentValence: gate.isReadyValence == delta.valenceDelta,
    );
  }

  EmotionPreflightMergedV4? get personaEmotionPreflightMergedV4OrNull {
    final preflight = personaEmotionPreflightV4OrNull;
    final consistency = personaEmotionPreflightConsistencyV4OrNull;
    final delta = personaEmotionPreflightDeltaV4OrNull;
    if (preflight == null || consistency == null || delta == null) return null;
    return EmotionPreflightMergedV4(
      preflight: preflight.asReadOnlyMap(),
      consistency: consistency.asReadOnlyMap(),
      delta: delta.asReadOnlyMap(),
    );
  }

  Map<String, Object?>? get personaActivationSnapshotV4ExportOrNull {
    if (personaActivationSnapshotV4OrNull == null) return null;
    return TelemetryService.instance.exportPersonaActivationSnapshotV4();
  }

  Map<String, Object?>? get personaPreparedActivationSnapshotV4OrNull {
    if (personaActivationSnapshotV4ExportOrNull == null) return null;
    return TelemetryService.instance
        .preparePersonaActivationSnapshotV4ForExport();
  }

  Map<String, Object?>? get personaActivationSnapshotV4HarmonizedOrNull {
    final snapshot = personaActivationSnapshotV4OrNull;
    if (snapshot == null) return null;
    return snapshot.harmonizedForTelemetry();
  }

  Map<String, Object?>? get personaActivationSnapshotV4OutboundOrNull {
    final snapshot = personaActivationSnapshotV4OrNull;
    if (snapshot == null) return null;
    return snapshot.outboundAligned();
  }

  Map<String, Object?>? get personaActivationSnapshotV4UnifiedOrNull {
    final snapshot = personaActivationSnapshotV4OrNull;
    if (snapshot == null) {
      _lastUnifiedSnapshotForRelay = null;
      return null;
    }
    _lastUnifiedSnapshotForRelay = snapshot;
    return snapshot.unifiedOutboundEnvelope();
  }

  Map<String, Object?>? get personaActivationSnapshotV4IntegrityOrNull {
    final snapshot = personaActivationSnapshotV4OrNull;
    if (snapshot == null) return null;
    return snapshot.telemetryIntegrityPass();
  }

  RuntimeActivationContextV4? get personaRuntimeActivationContextV4OrNull {
    final bundle = personaActivationFinalBundleV4OrNull;
    final consistency = personaActivationDiagnosticConsistencyMapV4OrNull;
    if (bundle == null || consistency == null) return null;
    return RuntimeActivationContextV4.fromBundles(
      bundle: bundle,
      consistency: consistency,
    );
  }

  PersonaFrameV1 _buildPersonaFrameV1(PersonaSurfaceV4Descriptor? descriptor) {
    final weights = _cohesionWeights();
    final radiusWeight = weights?['radius'];
    final elevationWeight = weights?['elevation'];
    final spacingWeight = weights?['spacing'];
    SimulationMotionKernel.current?.acceptV4CohesionWeights(
      radiusWeight,
      elevationWeight,
      spacingWeight,
    );
    return PersonaFrameV1(
      surfaceRadius: _finalV4SurfaceRadius ?? descriptor?.surfaceRadius,
      surfaceElevation:
          _finalV4SurfaceElevation ?? descriptor?.surfaceElevation,
      surfaceSpacing: _finalV4SurfaceSpacing ?? descriptor?.surfaceSpacing,
      v4RadiusWeight: radiusWeight,
      v4ElevationWeight: elevationWeight,
      v4SpacingWeight: spacingWeight,
    );
  }

  Map<String, dynamic>? exportV4ActivationEnablementBundle() {
    return _v4ActivationEnablementBundle;
  }

  void attachV4Profile({
    required Map<String, Object> profile,
    required Map<String, Object> kernel,
  }) {
    _v4ProfileContext = Map<String, Object>.unmodifiable(profile);
    _v4ProfileKernel = Map<String, Object>.unmodifiable(kernel);
  }

  Map<String, double>? get personaCohesionSeedOrNull {
    if (!canApplyV4Activation) return null;
    return V4ThemeDataBuilder().exportPersonaCohesionSeed();
  }

  Map<String, double>? _cohesionWeights() {
    final seed = personaCohesionSeedOrNull;
    if (seed == null) return null;
    return {
      'radius': (seed['radiusBase'] ?? 0.0) / 100.0,
      'elevation': (seed['elevationLow'] ?? 0.0) / 100.0,
      'spacing': (seed['spacingMd'] ?? 0.0) / 100.0,
    };
  }

  PersonaRendererV3V4Style resolveV4PersonaStyle({
    required Color baseTint,
    required TextStyle baseLabelStyle,
    Color? baseIconTone,
  }) {
    final tokens = V4TokenRegistry();
    if (!canApplyV4Activation) {
      _finalV4SurfaceRadius = null;
      _finalV4SurfaceElevation = null;
      _finalV4SurfaceSpacing = null;
      return PersonaRendererV3V4Style(
        tint: baseTint,
        labelStyle: baseLabelStyle,
        iconTone: baseIconTone,
      );
    }
    _finalV4SurfaceRadius = null;
    _finalV4SurfaceElevation = null;
    _finalV4SurfaceSpacing = null;
    final strength = _readEffectiveStyleValue('colorStrength');
    final delta = resolveV4ActivationColorDelta(0.0);
    final lightnessBase = HSLColor.fromColor(baseTint);
    final lightnessAdjustment =
        (lightnessBase.lightness + delta * 0.01 + (strength * 0.005)).clamp(
          0.0,
          1.0,
        );
    final tinted = _blendTint(
      lightnessBase.withLightness(lightnessAdjustment).toColor(),
      tokens.v4SurfaceTint,
    );
    final labelStyle = _personaTextStyle(baseLabelStyle, tokens);
    final iconTone = baseIconTone == null
        ? null
        : _personaIconTone(baseIconTone, strength, tokens);
    final metadata = v4SurfaceMetadataOrNull;
    final surfaceRadius = metadata?['radius'] as double?;
    final surfaceElevation = metadata?['elevation'] as double?;
    final surfaceSpacing = metadata?['spacing'] as double?;
    final overrideRadius = surfaceRadius == null
        ? null
        : overrideV4SurfaceRadius(surfaceRadius) ?? surfaceRadius;
    final overrideElevation = surfaceElevation == null
        ? null
        : overrideV4SurfaceElevation(surfaceElevation) ?? surfaceElevation;
    final overrideSpacing = surfaceSpacing == null
        ? null
        : overrideV4SurfaceSpacing(surfaceSpacing) ?? surfaceSpacing;
    _finalV4SurfaceRadius = overrideRadius;
    _finalV4SurfaceElevation = overrideElevation;
    _finalV4SurfaceSpacing = overrideSpacing;
    return PersonaRendererV3V4Style(
      tint: tinted,
      labelStyle: labelStyle,
      iconTone: iconTone,
      v4SurfaceRadius: overrideRadius,
      v4SurfaceElevation: overrideElevation,
      v4SurfaceSpacing: overrideSpacing,
    );
  }

  void applyComponentBundle(StyleTokenBundleV4 bundle) {
    final mood = _kernel.inferMood();
    _moodAdjustedBundle = bundle.copyWith(mood: mood).applyMoodVariant();
  }

  double resolveV4ActivationColorDelta(double base) {
    if (!canApplyV4Activation || _v4BlendedStyle == null) return base;
    final colorValue = _v4BlendedStyle!['color'];
    double delta = 0.0;
    if (colorValue is num) {
      delta = colorValue.toDouble();
    } else if (colorValue is String) {
      delta = double.tryParse(colorValue) ?? 0.0;
    }
    final microdeltas = _kernel.inferMicrodeltas();
    final baseAccent =
        _moodAdjustedBundle?.accentSurface ?? const Color(0xFF000000);
    final feedbackColor = _fusion.applyFeedbackDelta(
      baseAccent,
      _kernel.stressLevel,
      _kernel.focusLevel,
    );
    final microColor = _fusion.applyMicrodeltas(feedbackColor, microdeltas);
    final microLightness = HSLColor.fromColor(microColor).lightness;
    final microSum = microdeltas.values.fold(0.0, (p, e) => p + e);
    final moodColor =
        _moodAdjustedBundle?.accentSurface ?? const Color(0xFF000000);
    final moodLightness = HSLColor.fromColor(moodColor).lightness;
    return base +
        delta +
        microSum +
        microLightness * 0.01 +
        moodLightness * 0.005;
  }

  double _readEffectiveStyleValue(String key) {
    final bundle = _v4ActivationEnablementBundle;
    if (bundle == null) return 0.0;
    final effective = bundle['effectiveStyle'];
    if (effective is! Map<String, dynamic>) return 0.0;
    final value = effective[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Color _blendTint(Color color, double tint) {
    final tinted = _colorWithMultiplier(color, tint);
    return Color.alphaBlend(tinted, color);
  }

  Color _colorWithMultiplier(Color color, double multiplier) {
    final adjustedAlpha =
        ((color.alpha / 255.0 * multiplier).clamp(0.0, 1.0) * 255).round();
    return color.withAlpha(adjustedAlpha);
  }

  TextStyle _personaTextStyle(TextStyle base, V4TokenRegistry tokens) {
    final fontSize = base.fontSize != null
        ? tokens.v4FontSizeBody
        : tokens.v4FontSizeBody;
    return base.copyWith(
      fontSize: fontSize,
      fontWeight: _personaFontWeight(base.fontWeight, tokens.v4FontWeightBody),
      letterSpacing: tokens.v4LetterSpacingBody,
    );
  }

  FontWeight _personaFontWeight(FontWeight? base, int delta) {
    if (delta == 0) return base ?? FontWeight.normal;
    final target = delta > 0 ? FontWeight.w700 : FontWeight.w300;
    final ratio = (delta.abs() / 3.0).clamp(0.0, 1.0);
    return FontWeight.lerp(base ?? FontWeight.normal, target, ratio) ??
        (base ?? FontWeight.normal);
  }

  Map<String, Object> _sortedAsciiMap(Map<String, Object> source) {
    final keys = source.keys.toList()..sort();
    final sorted = <String, Object>{};
    for (final key in keys) {
      final value = source[key];
      if (value != null) {
        sorted[key] = value;
      }
    }
    return sorted;
  }

  Map<String, String> _toStringMap(Map<String, Object> source) {
    final entries = <String, String>{};
    for (final entry in source.entries) {
      entries[entry.key] = entry.value.toString();
    }
    return entries;
  }

  Object _coerceTraitValue(Object? value) => value ?? 'pending';

  Color _personaIconTone(Color base, double strength, V4TokenRegistry tokens) {
    final hsl = HSLColor.fromColor(base);
    final saturation = (hsl.saturation * tokens.v4IconTone + (strength * 0.05))
        .clamp(0.0, 1.0);
    final lightness = (hsl.lightness + (strength * 0.01)).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).withLightness(lightness).toColor();
  }

  double? overrideV4SurfaceRadius(double original) => null;

  double? overrideV4SurfaceElevation(double original) => null;

  double? overrideV4SurfaceSpacing(double original) => null;
}

class _PlaceholderSurfaceState {
  const _PlaceholderSurfaceState();
}

class _PlaceholderMotionState {
  const _PlaceholderMotionState();
}

class _PlaceholderOverlayState {
  const _PlaceholderOverlayState();
}

class _PlaceholderPersonaState {
  const _PlaceholderPersonaState();
}

class PersonaRendererV3V4Style {
  const PersonaRendererV3V4Style({
    required this.tint,
    required this.labelStyle,
    this.iconTone,
    this.v4SurfaceRadius,
    this.v4SurfaceElevation,
    this.v4SurfaceSpacing,
  });

  final Color tint;
  final TextStyle labelStyle;
  final Color? iconTone;

  final double? v4SurfaceRadius;
  final double? v4SurfaceElevation;
  final double? v4SurfaceSpacing;

  Map<String, double>? asV4SurfaceTripleOrNull() {
    final map = <String, double>{};
    if (v4SurfaceRadius != null) map['radius'] = v4SurfaceRadius!;
    if (v4SurfaceElevation != null) map['elevation'] = v4SurfaceElevation!;
    if (v4SurfaceSpacing != null) map['spacing'] = v4SurfaceSpacing!;
    return map.isEmpty ? null : map;
  }
}

class PersonaProfileViewBundleV1 {
  const PersonaProfileViewBundleV1({
    required this.surface,
    required this.staticTraits,
    required this.aiInsights,
    required this.shortExplanation,
    required this.longExplanation,
    required this.personaId,
  });

  final Widget surface;
  final Map<String, Object> staticTraits;
  final Map<String, Object> aiInsights;
  final String shortExplanation;
  final String longExplanation;
  final String personaId;
}

class ProfilePersonaBridgeV1 {
  const ProfilePersonaBridgeV1({
    required this.staticTraits,
    required this.aiInsights,
    required this.shortExplanation,
    required this.longExplanation,
  });

  final Map<String, Object> staticTraits;
  final Map<String, Object> aiInsights;
  final String shortExplanation;
  final String longExplanation;
}
