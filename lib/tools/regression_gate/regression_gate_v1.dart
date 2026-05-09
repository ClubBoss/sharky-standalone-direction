import 'dart:math';

import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/persona/emotion_engine_tier_a.dart';

const String name_not_map = 'name_not_map';
const String name_missing_ = 'name_missing';
const String name_non_ascii = 'name_non_ascii';
const String key_not_ok = 'key_not_ok';

Map<String, Object> runRegressionGateV1({bool autoFix = false}) {
  final errors = <String>[];
  final checks = <String, bool>{};
  final strictFindings = <String, Object>{};

  void checkMap(
    String name,
    Object? value, [
    List<String> required = const [],
  ]) {
    final isMap = value is Map<String, Object?>;
    checks['$name:is_map'] = isMap;
    if (!isMap) {
      errors.add('$name_not_map');
      return;
    }
    for (final key in required) {
      if (!value.containsKey(key)) {
        errors.add('$name_missing_$key');
      }
    }
    if (!_isAsciiMap(value)) {
      errors.add('$name_non_ascii');
    }
  }

  // V4 exports
  final binderMap = appRoot.exportV4InlineExplainBinder().asReadOnlyMap();
  checkMap('v4_inline_binder', binderMap, ['tooltip', 'overlay']);
  final v4PersonaUX = appRoot.exportV4PersonaUXBundle();
  checkMap('v4_persona_ux', v4PersonaUX);
  final v4Qa = appRoot.exportV4VisualQABundle();
  checkMap('v4_visual_qa', v4Qa);
  _checkVisualQA(v4Qa, errors, checks);
  final v4Cohesion = appRoot.exportV4CohesionQAStatus();
  checkMap('v4_cohesion', v4Cohesion);
  final v4Tokens = appRoot.exportV4TokenVerificationStatus();
  checkMap('v4_tokens', v4Tokens);
  final v4Polish = appRoot.exportV4FinalVisualPolishBundle();
  checkMap('v4_polish', v4Polish);
  _checkPolish(v4Polish, errors, checks);
  _checkVisualCohesionDeep(
    qa: v4Qa,
    cohesion: v4Cohesion,
    tokens: v4Tokens,
    polish: v4Polish,
    errors: errors,
    checks: checks,
  );

  // Persona stack
  checkMap(
    'tierA',
    const EmotionEngineTierA().exportTierAEmotionBundle(
      const <String, Object?>{},
    ),
  );
  checkMap('esm', appRoot.exportESMBundleV1());
  checkMap('attention_tone', appRoot.exportAttentionToneBundleV1());
  checkMap('behavioral_fusion', appRoot.exportBehavioralFusionV1());
  checkMap('behavioral_dynamics', appRoot.exportBehavioralDynamicsV1());
  checkMap('persona_signals', appRoot.exportPersonaDrivenSignalsV1());
  checkMap('persona_aggregator', appRoot.exportPersonaSignalAggregatorV1());
  checkMap('persona_advice', appRoot.exportPersonaAdviceV1());
  checkMap('persona_explanation', appRoot.exportPersonaAdviceExplanationV1());
  checkMap('persona_heuristics', appRoot.exportPersonaDecisionHeuristicsV1());
  checkMap('persona_hooks', appRoot.exportPersonaCoachingHooksV1());
  checkMap('persona_final', appRoot.exportPersonaCoachingFinalV1());
  checkMap('coaching_directives', appRoot.exportCoachingDirectivesV1());
  checkMap('coaching_style', appRoot.exportCoachingStyleV1());
  checkMap('coaching_filters', appRoot.exportCoachingContextFiltersV1());
  checkMap(
    'coaching_multi_stage',
    appRoot.exportCoachingMultiStageRecommendationsV1(),
  );
  checkMap('coaching_surface', appRoot.exportCoachingSurfaceV1());
  final coachingConsistency = appRoot.exportCoachingConsistencyReportV1();
  checkMap('coaching_consistency', coachingConsistency);
  final coachingDirectives = appRoot.exportCoachingDirectivesV1();
  checkMap('coaching_closure', appRoot.exportCoachingFinalClosureV1());
  var marketingTelemetry = appRoot.exportMarketingTelemetryBundleV1();
  checkMap('marketing_telemetry', marketingTelemetry, [
    'funnel',
    'engagement',
    'persona_influence',
  ]);
  _checkMarketingTelemetryGate(strictFindings, marketingTelemetry, errors);
  var funnelRetentionQA = appRoot.exportFunnelRetentionQABundle();
  var marketingAnalyticsPolish = appRoot.exportMarketingAnalyticsSurfaceV1();
  var rpgFusion = appRoot.exportRpgFusionV1();
  var rpgSnapshot = appRoot.exportRpgStabilitySnapshotV1();
  final ordered = _orderedGateSequenceV1([
    'marketing_telemetry_gate',
    'funnel_retention_qa_gate',
    'marketing_analytics_polish_gate',
    'xp_reward_gate',
    'xp_reward_surface_gate',
    'xp_curve_gate',
    'xp_persona_alignment_gate',
    'adaptive_reward_gate',
    'final_xp_reward_coherence_gate',
    'xp_reward_persona_rpg_coaching_stability_gate',
    'final_xp_reward_consolidation_gate',
    'xp_reward_final_gate',
    'rpg_gate',
    'rpg_consistency_gate',
    'rpg_stability_snapshot_gate',
    'xp_reward_rpg_interplay_gate',
    'final_stability_consolidation_gate',
    'final_cross_domain_polish_gate',
    'global_regression_sweep_gate',
    'final_regression_consolidation_gate',
    'v4_final_cohesion_gate',
    'v4_token_final_verification_gate',
    'persona_v4_mat_final_gate',
    'final_visual_polish_gate',
    'final_regression_platform_gate',
    'strict_cross_domain_gate',
    'strict_cohesion_gate',
  ]);
  final gateAttempts = <String, List<Map<String, Object>>>{};

  Map<String, Object> runGateAttempt(
    String gate,
    Map<String, Object>? overrideRaw,
    List<String> gateErrors,
  ) {
    switch (gate) {
      case 'marketing_telemetry_gate':
        final Map<String, Object> map = Map<String, Object>.from(
          overrideRaw ?? marketingTelemetry,
        );
        marketingTelemetry = map;
        _checkMarketingTelemetryGate(
          strictFindings,
          marketingTelemetry,
          gateErrors,
        );
        _assertAsciiMapV1(gate, marketingTelemetry, gateErrors);
        _assertShapeNonEmptyV1(gate, marketingTelemetry, gateErrors);
        return Map<String, Object>.from(marketingTelemetry);
      case 'funnel_retention_qa_gate':
        final Map<String, Object> map = Map<String, Object>.from(
          overrideRaw ?? funnelRetentionQA,
        );
        funnelRetentionQA = map;
        _checkFunnelRetentionVisualQAGate(
          strictFindings,
          funnelRetentionQA,
          gateErrors,
        );
        _assertAsciiMapV1(gate, funnelRetentionQA, gateErrors);
        _assertShapeNonEmptyV1(gate, funnelRetentionQA, gateErrors);
        return Map<String, Object>.from(funnelRetentionQA);
      case 'marketing_analytics_polish_gate':
        final Map<String, Object> map = Map<String, Object>.from(
          overrideRaw ?? marketingAnalyticsPolish,
        );
        marketingAnalyticsPolish = map;
        _checkMarketingAnalyticsPolishGate(
          strictFindings,
          marketingAnalyticsPolish,
          gateErrors,
        );
        _assertAsciiMapV1(gate, marketingAnalyticsPolish, gateErrors);
        _assertShapeNonEmptyV1(gate, marketingAnalyticsPolish, gateErrors);
        return Map<String, Object>.from(marketingAnalyticsPolish);
      case 'xp_reward_gate':
        _checkXpRewardGate(strictFindings, gateErrors);
        final map =
            strictFindings['xp_reward_gate'] as Map<String, Object>? ??
            const <String, Object>{};
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'xp_reward_surface_gate':
        _checkXpRewardSurfaceGate(strictFindings, gateErrors);
        final map =
            strictFindings['xp_reward_surface_gate'] as Map<String, Object>? ??
            const <String, Object>{};
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'xp_curve_gate':
        _checkXpCurveGate(strictFindings, gateErrors);
        final map =
            strictFindings['xp_curve_gate'] as Map<String, Object>? ??
            const <String, Object>{};
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'xp_persona_alignment_gate':
        _checkXpPersonaAlignmentGate(strictFindings, gateErrors);
        final map =
            strictFindings['xp_persona_alignment_gate']
                as Map<String, Object>? ??
            const <String, Object>{};
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'rpg_gate':
        final Map<String, Object> map = Map<String, Object>.from(
          overrideRaw ?? rpgFusion,
        );
        rpgFusion = map;
        _checkRpgGate(strictFindings, rpgFusion, gateErrors);
        final raw =
            strictFindings['rpg_gate'] as Map<String, Object>? ??
            const <String, Object>{};
        _assertAsciiMapV1(gate, raw, gateErrors);
        _assertShapeNonEmptyV1(gate, raw, gateErrors);
        return Map<String, Object>.from(raw);
      case 'rpg_consistency_gate':
        final Map<String, Object> map = Map<String, Object>.from(
          overrideRaw ?? rpgFusion,
        );
        rpgFusion = map;
        _checkRpgConsistencyGate(strictFindings, rpgFusion, gateErrors);
        final raw =
            strictFindings['rpg_consistency_gate'] as Map<String, Object>? ??
            const <String, Object>{};
        _assertAsciiMapV1(gate, raw, gateErrors);
        _assertShapeNonEmptyV1(gate, raw, gateErrors);
        return Map<String, Object>.from(raw);
      case 'rpg_stability_snapshot_gate':
        final Map<String, Object> map = Map<String, Object>.from(
          overrideRaw ?? rpgSnapshot,
        );
        rpgSnapshot = map;
        _checkRpgStabilitySnapshotGate(strictFindings, rpgSnapshot, gateErrors);
        final raw =
            strictFindings['rpg_stability_snapshot_gate']
                as Map<String, Object>? ??
            const <String, Object>{};
        _assertAsciiMapV1(gate, raw, gateErrors);
        _assertShapeNonEmptyV1(gate, raw, gateErrors);
        return Map<String, Object>.from(raw);
      case 'adaptive_reward_gate':
        final rewardSurfaceGate =
            strictFindings['xp_reward_surface_gate'] as Map<String, Object>? ??
            const <String, Object>{};
        final map = Map<String, Object>.from(
          overrideRaw ??
              <String, Object>{
                'xp_curve':
                    strictFindings['xp_curve_gate'] as Map<String, Object>? ??
                    const <String, Object>{},
                'reward_surface':
                    rewardSurfaceGate['reward_surface']
                        as Map<String, Object>? ??
                    const <String, Object>{},
                'persona_surface_modifiers':
                    rewardSurfaceGate['persona_surface_modifiers']
                        as Map<String, Object>? ??
                    const <String, Object>{},
                'effective_power':
                    (rpgFusion['fusion'] as Map?)?['effective_power'] ?? 0,
                'rpg_snapshot':
                    rpgSnapshot as Map<String, Object?>? ??
                    const <String, Object?>{},
              },
        );
        final result = _checkAdaptiveRewardGate(
          strictFindings,
          map,
          gateErrors,
        );
        _assertAsciiMapV1(gate, result, gateErrors);
        _assertShapeNonEmptyV1(gate, result, gateErrors);
        return Map<String, Object>.from(result);
      case 'final_xp_reward_coherence_gate':
        final result = _checkFinalXpRewardCoherenceGate(
          strictFindings: strictFindings,
          xpCurve:
              strictFindings['xp_curve_gate'] as Map<String, Object>? ??
              const <String, Object>{},
          xpRewardSurfaceGate:
              strictFindings['xp_reward_surface_gate']
                  as Map<String, Object>? ??
              const <String, Object>{},
          rpgSnapshot: rpgSnapshot,
          tokenVerificationView: appRoot.exportV4TokenVerificationView(),
          coachingDirectives: coachingDirectives,
        );
        _assertAsciiMapV1(gate, result, gateErrors);
        _assertShapeNonEmptyV1(gate, result, gateErrors);
        return Map<String, Object>.from(result);
      case 'xp_reward_persona_rpg_coaching_stability_gate':
        final result = _checkXpRewardPersonaRpgCoachingStabilityGate(
          strictFindings: strictFindings,
          xpCurve:
              strictFindings['xp_curve_gate'] as Map<String, Object>? ??
              const <String, Object>{},
          xpRewardSurfaceGate:
              strictFindings['xp_reward_surface_gate']
                  as Map<String, Object>? ??
              const <String, Object>{},
          rpgSnapshot: rpgSnapshot,
          personaSignals:
              strictFindings['persona_signals'] as Map<String, Object>? ??
              const <String, Object>{},
          coachingDirectives: coachingDirectives,
          v4Snapshot:
              v4Qa['v4_snapshot'] as Map<String, Object?>? ??
              const <String, Object?>{},
          tierA: const EmotionEngineTierA().exportTierAEmotionBundle(
            const <String, Object?>{},
          ),
        );
        _assertAsciiMapV1(gate, result, gateErrors);
        _assertShapeNonEmptyV1(gate, result, gateErrors);
        return Map<String, Object>.from(result);
      case 'final_xp_reward_consolidation_gate':
        final result = _checkFinalXpRewardConsolidationGate(
          strictFindings: strictFindings,
          xpCurve:
              strictFindings['xp_curve_gate'] as Map<String, Object>? ??
              const <String, Object>{},
          xpRewardSurfaceGate:
              strictFindings['xp_reward_surface_gate']
                  as Map<String, Object>? ??
              const <String, Object>{},
          rpgFusion: rpgFusion,
          rpgSnapshot: rpgSnapshot,
          coachingSurface: appRoot.exportCoachingSurfaceV1(),
          coachingDirectives: coachingDirectives,
          v4Snapshot:
              v4Qa['v4_snapshot'] as Map<String, Object?>? ??
              const <String, Object?>{},
          personaSignals:
              strictFindings['persona_signals'] as Map<String, Object>? ??
              const <String, Object>{},
        );
        _assertAsciiMapV1(gate, result, gateErrors);
        _assertShapeNonEmptyV1(gate, result, gateErrors);
        return Map<String, Object>.from(result);
      case 'xp_reward_final_gate':
        final result = _checkXpRewardFinalGate(
          strictFindings: strictFindings,
          xpRewardSurfaceGate:
              strictFindings['xp_reward_surface_gate']
                  as Map<String, Object>? ??
              const <String, Object>{},
          xpCurveGate:
              strictFindings['xp_curve_gate'] as Map<String, Object>? ??
              const <String, Object>{},
          xpAlignmentGate:
              strictFindings['xp_persona_alignment_gate']
                  as Map<String, Object>? ??
              const <String, Object>{},
          xpRpgInterplayGate:
              strictFindings['xp_reward_rpg_interplay_gate']
                  as Map<String, Object>? ??
              const <String, Object>{},
          rpgFusion: rpgFusion,
          rpgSnapshot: rpgSnapshot,
          coachingSurface: appRoot.exportCoachingSurfaceV1(),
          coachingDirectives: coachingDirectives,
          personaSignals:
              strictFindings['persona_signals'] as Map<String, Object>? ??
              const <String, Object>{},
          readinessSurface: appRoot.exportReleaseReadinessSurfaceV1(),
          finalCoherenceView: appRoot.exportV4FinalCoherencePassV1(),
          errors: gateErrors,
        );
        _assertAsciiMapV1(gate, result, gateErrors);
        _assertShapeNonEmptyV1(gate, result, gateErrors);
        return Map<String, Object>.from(result);
      case 'global_regression_sweep_gate':
        final result = _checkGlobalRegressionSweepGate(strictFindings, {
          'visual': appRoot.exportV4VisualQABundle(),
          'cohesion_view': appRoot.exportV4CohesionQAView(),
          'token_view': appRoot.exportV4TokenVerificationView(),
          'persona_mat_view': appRoot.exportV4PersonaMatConsistencyView(),
          'polish_view': appRoot.exportV4FinalPolishView(),
          'final_coherence': appRoot.exportV4FinalCoherencePassV1(),
          'mat_consistency': appRoot.exportMATSnapshotConsistencyV1(),
          'persona_stack':
              strictFindings['persona_signals'] ?? const <String, Object>{},
          'coaching_stack': appRoot.exportCoachingSurfaceV1(),
          'rpg_stack': rpgFusion,
          'rpg_snapshot': rpgSnapshot,
          'xp_reward_surface_gate':
              strictFindings['xp_reward_surface_gate'] ??
              const <String, Object>{},
          'xp_curve_gate':
              strictFindings['xp_curve_gate'] ?? const <String, Object>{},
          'xp_alignment_gate':
              strictFindings['xp_persona_alignment_gate'] ??
              const <String, Object>{},
          'marketing': marketingAnalyticsPolish,
          'funnel_retention': funnelRetentionQA,
          'release_readiness': appRoot.exportReleaseReadinessSurfaceV1(),
          'omega_bridge': appRoot.exportFinalOmegaQABridgeV1(),
          'final_polish': appRoot.exportV4FinalPolishView(),
        }, gateErrors);
        _assertAsciiMapV1(gate, result, gateErrors);
        _assertShapeNonEmptyV1(gate, result, gateErrors);
        return Map<String, Object>.from(result);
      case 'xp_reward_rpg_interplay_gate':
        _checkXpRewardRpgInterplayGate(strictFindings, gateErrors);
        final map =
            strictFindings['xp_reward_rpg_interplay_gate']
                as Map<String, Object>? ??
            const <String, Object>{};
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'final_stability_consolidation_gate':
        _checkFinalStabilityConsolidationGate(
          strictFindings: strictFindings,
          v4Qa: v4Qa,
          v4Cohesion: v4Cohesion,
          v4Polish: v4Polish,
          personaUX: v4PersonaUX,
          errors: gateErrors,
        );
        final map =
            strictFindings['final_stability_consolidation_gate']
                as Map<String, Object>? ??
            const <String, Object>{};
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'strict_cohesion_gate':
        _v4StrictCohesionConsolidation(
          strictFindings,
          v4Qa,
          v4Cohesion,
          v4Tokens,
          v4PersonaUX,
          v4Polish,
          binderMap,
          gateErrors,
        );
        _checkSnapshotPersonaMat(
          v4Qa,
          v4Cohesion,
          binderMap,
          gateErrors,
          checks,
        );
        _strictCohesionGate(
          strictFindings: strictFindings,
          v4Qa: v4Qa,
          v4Cohesion: v4Cohesion,
          v4Tokens: v4Tokens,
          v4PersonaUX: v4PersonaUX,
          v4Polish: v4Polish,
          binder: binderMap,
          coachingConsistency: coachingConsistency,
          errors: gateErrors,
          checks: checks,
        );
        final map =
            strictFindings['v4_strict_cohesion_consolidation']
                as Map<String, Object>? ??
            const <String, Object>{};
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'strict_cross_domain_gate':
        final map = _checkStrictCrossDomain(strictFindings, gateErrors);
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'final_cross_domain_polish_gate':
        final map = _checkFinalCrossDomainPolishGate(
          strictFindings: strictFindings,
          v4CohesionView: appRoot.exportV4CohesionQAView(),
          v4TokenVerificationView: appRoot.exportV4TokenVerificationView(),
          v4PolishView: appRoot.exportV4ThemePolishView(),
          personaUX: appRoot.exportV4PersonaUXBundle(),
          coachingStyle: appRoot.exportCoachingStyleV1(),
          marketingPolish: appRoot.exportMarketingAnalyticsSurfaceV1(),
          rpgSnapshot: rpgSnapshot,
          xpRewardSurfaceGate:
              strictFindings['xp_reward_surface_gate']
                  as Map<String, Object>? ??
              const <String, Object>{},
        );
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'final_regression_consolidation_gate':
        final map = _checkFinalRegressionConsolidationGate(strictFindings, {
          'marketing': marketingAnalyticsPolish,
          'funnel': funnelRetentionQA,
          'xp_reward_gate':
              strictFindings['xp_reward_gate'] ?? const <String, Object>{},
          'xp_reward_surface_gate':
              strictFindings['xp_reward_surface_gate'] ??
              const <String, Object>{},
          'xp_curve_gate':
              strictFindings['xp_curve_gate'] ?? const <String, Object>{},
          'xp_persona_alignment_gate':
              strictFindings['xp_persona_alignment_gate'] ??
              const <String, Object>{},
          'adaptive_reward_gate':
              strictFindings['adaptive_reward_gate'] ??
              const <String, Object>{},
          'final_xp_reward_coherence_gate':
              strictFindings['final_xp_reward_coherence_gate'] ??
              const <String, Object>{},
          'xp_reward_persona_rpg_coaching_stability_gate':
              strictFindings['xp_reward_persona_rpg_coaching_stability_gate'] ??
              const <String, Object>{},
          'final_xp_reward_consolidation_gate':
              strictFindings['final_xp_reward_consolidation_gate'] ??
              const <String, Object>{},
          'rpg_gate': strictFindings['rpg_gate'] ?? const <String, Object>{},
          'rpg_consistency_gate':
              strictFindings['rpg_consistency_gate'] ??
              const <String, Object>{},
          'rpg_stability_snapshot_gate':
              strictFindings['rpg_stability_snapshot_gate'] ??
              const <String, Object>{},
          'xp_reward_rpg_interplay_gate':
              strictFindings['xp_reward_rpg_interplay_gate'] ??
              const <String, Object>{},
          'final_stability_consolidation_gate':
              strictFindings['final_stability_consolidation_gate'] ??
              const <String, Object>{},
          'strict_cross_domain_gate':
              strictFindings['strict_cross_domain_gate'] ??
              const <String, Object>{},
          'final_cross_domain_polish_gate':
              strictFindings['final_cross_domain_polish_gate'] ??
              const <String, Object>{},
          'global_regression_sweep_gate':
              strictFindings['global_regression_sweep_gate'] ??
              const <String, Object>{},
        }, gateErrors);
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'v4_final_cohesion_gate':
        final map = _checkV4FinalCohesionGate(
          strictFindings: strictFindings,
          cohesionView: appRoot.exportV4CohesionQAView(),
          tokenView: appRoot.exportV4TokenVerificationView(),
          personaMatView: appRoot.exportV4PersonaMatConsistencyView(),
          polishView: appRoot.exportV4FinalPolishView(),
          finalCoherenceView: appRoot.exportV4FinalCoherencePassV1(),
          cohesionReleaseSurface: appRoot.exportV4CohesionReleaseSurfaceV1(),
          errors: gateErrors,
        );
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'v4_token_final_verification_gate':
        final map = _checkV4TokenFinalVerificationGate(
          strictFindings: strictFindings,
          normalizedTokens:
              v4Qa['v4_normalized_tokens'] as Map<String, Object?>? ??
              const <String, Object?>{},
          tokenVerificationView: appRoot.exportV4TokenVerificationView(),
          polishBundle: v4Polish,
          errors: gateErrors,
        );
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'persona_v4_mat_final_gate':
        final map = _checkPersonaV4MatFinalGate(
          strictFindings: strictFindings,
          personaUx: appRoot.exportV4PersonaUXBundle(),
          v4Snapshot:
              v4Qa['v4_snapshot'] as Map<String, Object?>? ??
              const <String, Object?>{},
          v4Delta:
              v4Qa['v4_delta_report'] as Map<String, Object?>? ??
              const <String, Object?>{},
          matSnapshot: appRoot.exportMaterialAppThemeSnapshotV4(),
          personaMatView: appRoot.exportV4PersonaMatConsistencyView(),
          finalPolishView: appRoot.exportV4FinalPolishView(),
          tokenView: appRoot.exportV4TokenVerificationView(),
          cohesionView: appRoot.exportV4CohesionQAView(),
          errors: gateErrors,
        );
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'final_visual_polish_gate':
        final map = _checkFinalVisualPolishGate(
          strictFindings: strictFindings,
          finalPolishView: appRoot.exportV4FinalPolishView(),
          cohesionView: appRoot.exportV4CohesionQAView(),
          tokenView: appRoot.exportV4TokenVerificationView(),
          personaMatView: appRoot.exportV4PersonaMatConsistencyView(),
          finalCoherenceView: appRoot.exportV4FinalCoherencePassV1(),
          finalVisualPolishValidator: appRoot.exportFinalVisualPolishV1(),
          readinessSurface: appRoot.exportReleaseReadinessSurfaceV1(),
          omegaBridge: appRoot.exportFinalOmegaQABridgeV1(),
          errors: gateErrors,
        );
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
      case 'final_regression_platform_gate':
        final map = _checkFinalRegressionPlatformGate(
          strictFindings: strictFindings,
          gates: {
            'v4_final_cohesion_gate':
                strictFindings['v4_final_cohesion_gate'] ??
                const <String, Object>{},
            'v4_token_final_verification_gate':
                strictFindings['v4_token_final_verification_gate'] ??
                const <String, Object>{},
            'persona_v4_mat_final_gate':
                strictFindings['persona_v4_mat_final_gate'] ??
                const <String, Object>{},
            'final_visual_polish_gate':
                strictFindings['final_visual_polish_gate'] ??
                const <String, Object>{},
            'xp_reward_final_gate':
                strictFindings['xp_reward_final_gate'] ??
                const <String, Object>{},
            'xp_reward_persona_rpg_coaching_stability_gate':
                strictFindings['xp_reward_persona_rpg_coaching_stability_gate'] ??
                const <String, Object>{},
            'final_xp_reward_consolidation_gate':
                strictFindings['final_xp_reward_consolidation_gate'] ??
                const <String, Object>{},
            'global_regression_sweep_gate':
                strictFindings['global_regression_sweep_gate'] ??
                const <String, Object>{},
          },
          errors: gateErrors,
        );
        _assertAsciiMapV1(gate, map, gateErrors);
        _assertShapeNonEmptyV1(gate, map, gateErrors);
        return Map<String, Object>.from(map);
    }
    return const <String, Object>{};
  }

  for (final gate in ordered) {
    final gateErrors = <String>[];
    var attemptRaw = runGateAttempt(gate, null, gateErrors);
    final attemptIssues = _buildGateAttemptIssues(attemptRaw, gateErrors);
    gateAttempts[gate] = [
      {
        'raw': Map<String, Object>.unmodifiable(attemptRaw),
        'issues': attemptIssues,
      },
    ];
    var finalGateErrors = gateErrors;
    if (autoFix && gateErrors.isNotEmpty) {
      final fixedRaw = _attemptAutoFixV1(gate, attemptRaw);
      gateErrors.clear();
      attemptRaw = runGateAttempt(gate, fixedRaw, gateErrors);
      final fixedIssues = _buildGateAttemptIssues(attemptRaw, gateErrors);
      gateAttempts[gate]!.add({
        'raw': Map<String, Object>.unmodifiable(attemptRaw),
        'issues': fixedIssues,
      });
      finalGateErrors = gateErrors;
    }
    errors.addAll(finalGateErrors);
  }
  _assertCrossGateConsistencyV1({
    'rpg_gate':
        strictFindings['rpg_gate'] as Map<String, Object>? ??
        const <String, Object>{},
    'rpg_consistency_gate':
        strictFindings['rpg_consistency_gate'] as Map<String, Object>? ??
        const <String, Object>{},
    'rpg_stability_snapshot_gate':
        strictFindings['rpg_stability_snapshot_gate'] as Map<String, Object>? ??
        const <String, Object>{},
    'xp_reward_gate':
        strictFindings['xp_reward_gate'] as Map<String, Object>? ??
        const <String, Object>{},
    'xp_reward_surface_gate':
        strictFindings['xp_reward_surface_gate'] as Map<String, Object>? ??
        const <String, Object>{},
    'xp_curve_gate':
        strictFindings['xp_curve_gate'] as Map<String, Object>? ??
        const <String, Object>{},
    'xp_reward_rpg_interplay_gate':
        strictFindings['xp_reward_rpg_interplay_gate']
            as Map<String, Object>? ??
        const <String, Object>{},
    'v4_polish': v4Polish,
    'v4_cohesion': v4Cohesion,
    'v4_tokens': v4Tokens,
    'persona':
        strictFindings['persona_signals'] as Map<String, Object>? ??
        const <String, Object>{},
    'coaching':
        strictFindings['persona_final'] as Map<String, Object>? ??
        const <String, Object>{},
    'fusion':
        strictFindings['persona_aggregator'] as Map<String, Object>? ??
        const <String, Object>{},
  }, errors);

  final ok = errors.isEmpty;
  return <String, Object>{
    'ok': ok,
    'strict_findings': Map<String, Object>.unmodifiable(strictFindings),
    'conflict_explainer_v1': _buildDeterministicConflictExplainerV1(
      strictFindings,
    ),
    'gate_sequence': ordered,
    'gate_results': Map<String, Object>.unmodifiable(
      _buildGateResults(
        ordered: ordered,
        gateAttempts: gateAttempts,
        autoFix: autoFix,
      ),
    ),
  };
}

void _checkVisualQA(
  Map<String, Object?> qa,
  List<String> errors,
  Map<String, bool> checks,
) {
  const requiredKeys = <String>[
    'v3_snapshot',
    'v4_snapshot',
    'v4_normalized_tokens',
    'v4_delta_report',
    'v4_cohesion_report',
  ];
  for (final key in requiredKeys) {
    if (!qa.containsKey(key)) errors.add('v4_visual_qa_missing_$key');
  }
  final v3 = qa['v3_snapshot'];
  final v4 = qa['v4_snapshot'];
  if (!_mapStringNum(v3)) errors.add('v3_snapshot_shape');
  if (!_mapStringNum(v4)) errors.add('v4_snapshot_shape');

  final normalized = qa['v4_normalized_tokens'];
  if (normalized is Map) {
    final norm = normalized.cast<String, Object?>();
    checks['v4_tokens_count_ok'] = norm.length >= 20;
    if (norm.length < 20) errors.add('v4_tokens_too_small');
    norm.forEach((k, v) {
      if (!_isAsciiString(k) || !_isLowerUnderscore(k)) {
        errors.add('v4_token_key_invalid');
      }
      if (v is! String) errors.add('v4_token_value_not_string');
      if (v is String && !_isAsciiString(v))
        errors.add('v4_token_value_non_ascii');
    });
  } else {
    errors.add('v4_normalized_tokens_not_map');
  }

  final delta = qa['v4_delta_report'];
  if (delta is Map) {
    final d = delta.cast<String, Object?>();
    for (final field in ['added', 'removed', 'changed']) {
      final list = d[field];
      if (list is! List) {
        errors.add('delta_missing_$field');
        continue;
      }
      if (!_asciiStringList(list)) errors.add('delta_non_ascii_$field');
    }
  } else {
    errors.add('v4_delta_not_map');
  }

  final cohesion = qa['v4_cohesion_report'];
  if (cohesion is Map) {
    final c = cohesion.cast<String, Object?>();
    if (c['ok'] is! bool) errors.add('cohesion_ok_not_bool');
    for (final field in ['missing_tokens', 'mismatched_tokens']) {
      final list = c[field];
      if (list is! List) {
        errors.add('cohesion_missing_$field');
        continue;
      }
      if (!_asciiStringList(list)) errors.add('cohesion_non_ascii_$field');
    }
  } else {
    errors.add('v4_cohesion_not_map');
  }
}

void _checkPolish(
  Map<String, Object?> polish,
  List<String> errors,
  Map<String, bool> checks,
) {
  if (polish.isEmpty) return;
  final spacingKey = polish.containsKey('surface_spacing')
      ? 'surface_spacing'
      : 'spacing';
  final keys = <String>[spacingKey, 'radius', 'shadow', 'color'];
  for (final key in keys) {
    if (!polish.containsKey(key)) {
      errors.add('polish_missing_$key');
    } else {
      final v = polish[key];
      if (!(v is String || v is num)) {
        errors.add('polish_invalid_$key');
      }
    }
  }
  checks['polish_keys_ok'] = keys.every((k) => polish.containsKey(k));
}

void _checkVisualCohesionDeep({
  required Map<String, Object?> qa,
  required Map<String, Object?> cohesion,
  required Map<String, Object?> tokens,
  required Map<String, Object?> polish,
  required List<String> errors,
  required Map<String, bool> checks,
}) {
  final v4 = qa['v4_snapshot'];
  final normalized = qa['v4_normalized_tokens'];
  final delta = qa['v4_delta_report'];
  final coh = qa['v4_cohesion_report'];

  final missingTokens = <String>[];
  var categoryViolation = false;
  const categories = [
    'surface',
    'card',
    'table',
    'text',
    'radius',
    'shadow',
    'polish',
  ];
  if (normalized is Map && v4 is Map) {
    final snapshotKeys = v4.keys.map((e) => e.toString()).toSet();
    final changed = <String>{};
    if (delta is Map && delta['changed'] is List) {
      changed.addAll((delta['changed'] as List).map((e) => e.toString()));
    }
    for (final k in normalized.keys) {
      final key = k.toString();
      final matches = categories.where(key.startsWith).toList();
      if (matches.isEmpty) {
        errors.add('unknown_category:$key');
        categoryViolation = true;
      } else if (matches.length > 1) {
        errors.add('ambiguous_category:$key');
        categoryViolation = true;
      }
      if (!snapshotKeys.contains(key) && !changed.contains(key)) {
        missingTokens.add(key);
        if (matches.isNotEmpty &&
            (matches.first == 'surface' ||
                matches.first == 'card' ||
                matches.first == 'table')) {
          errors.add('orphan_surface_token:$key');
          categoryViolation = true;
        }
      }
      if (matches.isNotEmpty && matches.first == 'polish') {
        if (!(polish.containsKey(key))) {
          errors.add('missing_polish_token:$key');
          categoryViolation = true;
        }
      }
    }
  }
  if (missingTokens.isNotEmpty) {
    errors.addAll(missingTokens.map((e) => 'token_missing_in_snapshot:$e'));
  }

  if (coh is Map && normalized is Map) {
    for (final field in ['missing_tokens', 'mismatched_tokens']) {
      final list = coh[field];
      if (list is List) {
        for (final item in list) {
          final key = item.toString();
          if (!normalized.containsKey(key)) {
            errors.add('cohesion_token_not_normalized:$key');
          }
        }
      }
    }
  }

  if (v4 is Map) {
    for (final entry in v4.entries) {
      final key = entry.key.toString();
      final val = entry.value;
      if (!_isAsciiString(key)) errors.add('v4_snapshot_key_non_ascii');
      if (!(val is String || val is num)) {
        errors.add('v4_snapshot_value_invalid');
      }
      if (val is String && val.isEmpty) {
        errors.add('v4_snapshot_value_empty');
      }
      if (key.contains('__')) errors.add('v4_snapshot_key_double_underscore');
      if (!_prefixAllowed(key)) errors.add('v4_snapshot_key_prefix_invalid');
    }
  }

  if (coh is Map) {
    final ok = coh['ok'] == true;
    final mismatchDetected =
        missingTokens.isNotEmpty ||
        errors.any((e) => e.startsWith('cohesion_token_not_normalized'));
    if (ok && (mismatchDetected || categoryViolation)) {
      errors.add(
        mismatchDetected
            ? 'cohesion_ok_conflict'
            : 'cohesion_ok_conflict: category violations present',
      );
    }
  }
}

bool _isAsciiMap(Map<dynamic, dynamic> map) {
  bool ok = true;
  void walk(Object? value) {
    if (!ok) return;
    if (value is String) {
      for (final r in value.runes) {
        if (r > 127) {
          ok = false;
          return;
        }
      }
    } else if (value is Map) {
      for (final entry in value.entries) {
        if (entry.key is! String) {
          ok = false;
          return;
        }
        walk(entry.value);
        if (!ok) return;
      }
    } else if (value is Iterable) {
      for (final v in value) {
        walk(v);
        if (!ok) return;
      }
    }
  }

  walk(map);
  return ok;
}

bool _isAsciiString(String value) {
  for (final r in value.runes) {
    if (r > 127) return false;
  }
  return true;
}

bool _asciiStringList(List<Object?> list) {
  for (final v in list) {
    if (v is! String || !_isAsciiString(v)) return false;
  }
  return true;
}

bool _mapStringNum(Object? value) {
  if (value is! Map) return false;
  for (final entry in value.entries) {
    if (entry.key is! String) return false;
    final v = entry.value;
    if (!(v is String || v is num)) return false;
    if (v is String && !_isAsciiString(v)) return false;
  }
  return true;
}

bool _isLowerUnderscore(String key) {
  return RegExp(r'^[a-z0-9_]+$').hasMatch(key);
}

bool _prefixAllowed(String key) {
  const allowed = [
    'surface',
    'card',
    'table',
    'text',
    'radius',
    'shadow',
    'polish',
  ];
  return allowed.any((p) => key.startsWith(p));
}

void _checkSnapshotPersonaMat(
  Map<String, Object?> qa,
  Map<String, Object?> cohesion,
  Map<String, Object?> binder,
  List<String> errors,
  Map<String, bool> checks,
) {
  final persona = appRoot.exportV4PersonaUXBundle();
  final inlineSurface = binder['overlay'] as List<Object>? ?? const <Object>[];
  final v4Snap = qa['v4_snapshot'];
  final v3Snap = qa['v3_snapshot'];
  final delta = qa['v4_delta_report'];

  if (persona.isNotEmpty) {
    for (final key in ['title', 'short', 'hints']) {
      if (!persona.containsKey(key)) errors.add('persona_ux_missing_$key');
      final val = persona[key];
      if (val is String && val.isEmpty) errors.add('persona_ux_missing_$key');
      if (val is String && !_isAsciiString(val)) {
        errors.add('persona_ux_non_ascii_$key');
      }
    }
  }

  void checkSnapshot(String name, Object? snap) {
    if (snap is! Map) {
      errors.add('$name_not_map');
      return;
    }
    final required = ['color', 'radius', 'spacing'];
    for (final req in required) {
      if (!snap.containsKey(req)) {
        errors.add('mat_${name}_incomplete');
      }
    }
    snap.forEach((key, value) {
      if (!_isAsciiString(key.toString())) {
        errors.add('mat_${name}_key_non_ascii');
      }
    });
  }

  checkSnapshot('v4_snapshot', v4Snap);
  checkSnapshot('v3_snapshot', v3Snap);

  final deltaChanged = <String>{};
  if (delta is Map && delta['changed'] is List) {
    deltaChanged.addAll((delta['changed'] as List).map((e) => e.toString()));
  }

  final v4Keys = v4Snap is Map
      ? v4Snap.keys.map((e) => e.toString()).toSet()
      : <String>{};
  for (final entry in inlineSurface.whereType<Map>()) {
    final key = entry['id']?.toString() ?? '';
    if (key.isEmpty) continue;
    if (!v4Keys.contains(key) && !deltaChanged.contains(key)) {
      errors.add('persona_surface_snapshot_missing:$key');
    }
  }

  final cohOk = cohesion['ok'] == true;
  final personaIssues =
      errors.any((e) => e.startsWith('persona_ux')) ||
      errors.any((e) => e.startsWith('persona_surface_snapshot_missing')) ||
      errors.any((e) => e.startsWith('mat_'));
  if (cohOk && personaIssues) {
    errors.add('cohesion_ok_conflict: snapshot-persona-mat');
  }
  checks['snapshot_persona_mat_ok'] = !personaIssues;
}

void _strictCohesionGate({
  required Map<String, Object> strictFindings,
  required Map<String, Object?> v4Qa,
  required Map<String, Object?> v4Cohesion,
  required Map<String, Object?> v4Tokens,
  required Map<String, Object?> v4PersonaUX,
  required Map<String, Object?> v4Polish,
  required Map<String, Object?> binder,
  required Map<String, Object?> coachingConsistency,
  required List<String> errors,
  required Map<String, bool> checks,
}) {
  final findings = <String, Object>{};

  final tokens =
      v4Qa['v4_normalized_tokens'] as Map<String, Object?>? ??
      const <String, Object?>{};
  final categories = <String>{
    'surface',
    'card',
    'table',
    'text',
    'radius',
    'shadow',
    'polish',
  };
  final presentCategories = <String>{};
  final missingCategoryIssues = <String>[];
  for (final k in tokens.keys) {
    final key = k.toString();
    for (final cat in categories) {
      if (key.startsWith(cat)) presentCategories.add(cat);
    }
  }
  for (final cat in categories) {
    if (!presentCategories.contains(cat)) {
      missingCategoryIssues.add('missing_$cat');
    }
  }

  final cohOk = v4Cohesion['ok'] == true;
  if (missingCategoryIssues.isNotEmpty) {
    errors.add('strict_gate_missing_categories');
  }

  if ((v4PersonaUX.isEmpty || (binder['overlay'] ?? const []) is! List) &&
      v4Qa['v4_snapshot'] is Map) {
    errors.add('strict_gate_missing_persona_or_mat');
  }

  final surfaceMissing = errors.any(
    (e) => e.startsWith('persona_surface_snapshot_missing'),
  );
  if (surfaceMissing) {
    errors.add('strict_gate_missing_surface_snapshot');
  }

  final coachingIssues = (coachingConsistency['issues'] as List?) ?? const [];
  if (coachingIssues.isNotEmpty) {
    errors.add('strict_gate_coaching_consistency');
  }

  final subError = errors.any(
    (e) =>
        e.startsWith('strict_gate') ||
        e.startsWith('missing_') ||
        e.contains('persona_ux') ||
        e.contains('mat_'),
  );
  if (cohOk && subError) {
    errors.add('strict_gate_conflict: cohesion_vs_subsystems');
  }

  findings['tokens'] = tokens;
  findings['cohesion'] = v4Cohesion;
  findings['snapshots'] = {
    'v3': v4Qa['v3_snapshot'] ?? const <String, Object?>{},
    'v4': v4Qa['v4_snapshot'] ?? const <String, Object?>{},
    'delta': v4Qa['v4_delta_report'] ?? const <String, Object?>{},
  };
  findings['persona'] = v4PersonaUX;
  findings['mat'] = v4Polish;
  findings['explain_surface'] = binder;
  findings['coaching'] = coachingConsistency;

  final strictMaps = <String, Object>{
    'tokens': tokens,
    'snapshots': findings['snapshots'] as Map<String, Object>,
    'persona': v4PersonaUX,
    'polish': v4Polish,
    'cohesion': v4Cohesion,
    'coaching': coachingConsistency,
    'rpg': strictFindings['rpg_gate'] ?? const <String, Object>{},
    'xp_reward_surface':
        strictFindings['xp_reward_surface_gate'] ?? const <String, Object>{},
  };
  final missingKeys = strictMaps.entries.any(
    (e) => e.value is Map && (e.value as Map).isEmpty,
  );
  if (missingKeys) errors.add('strict_cohesion_missing_keys');

  final asciiViolation = strictMaps.values.any((v) {
    if (v is Map) return !_isAsciiMap(v);
    if (v is Iterable) {
      for (final x in v) {
        if (x is String && !_isAsciiString(x)) return true;
      }
    }
    return false;
  });
  if (asciiViolation) errors.add('strict_cohesion_ascii_violation');

  final shapeViolation = strictMaps.values.any((v) => v is Map && v.isEmpty);
  if (shapeViolation) errors.add('strict_cohesion_shape_violation');

  if (cohOk &&
      (missingCategoryIssues.isNotEmpty ||
          missingKeys ||
          asciiViolation ||
          shapeViolation)) {
    errors.add('strict_cohesion_mismatch_conflict');
  }

  checks['strict_cohesion_gate_v1'] = errors.isEmpty;
}

void _checkXpRewardGate(
  Map<String, Object> strictFindings,
  List<String> errors,
) {
  const xpCurve = <String, Object>{'linear': 0, 'mid': 0, 'late': 0};
  const rewardWeights = <String, Object>{
    'correct': 1.0,
    'streak': 1.0,
    'difficulty': 1.0,
  };
  const personaModifiers = <String, Object>{
    'focus': 0.0,
    'pressure': 0.0,
    'tone': 0.0,
    'engagement': 0.0,
  };

  void checkRequired(
    Map<String, Object> map,
    List<String> keys,
    String prefix,
  ) {
    for (final k in keys) {
      if (!map.containsKey(k))
        errors.add('xp_reward_gate_missing_key:$prefix$k');
    }
  }

  checkRequired(xpCurve, ['linear', 'mid', 'late'], 'xp_curve_');
  checkRequired(rewardWeights, ['correct', 'streak', 'difficulty'], 'reward_');
  checkRequired(personaModifiers, [
    'focus',
    'pressure',
    'tone',
    'engagement',
  ], 'persona_');

  bool inRangeNum(Object v, double min, double max) {
    if (v is num) {
      final d = v.toDouble();
      return d >= min && d <= max;
    }
    return false;
  }

  xpCurve.forEach((k, v) {
    if (!inRangeNum(v, 0, 500)) {
      errors.add('xp_reward_gate_out_of_range:xp_$k');
    }
  });
  rewardWeights.forEach((k, v) {
    if (!inRangeNum(v, 0.0, 3.0)) {
      errors.add('xp_reward_gate_out_of_range:reward_$k');
    }
  });
  personaModifiers.forEach((k, v) {
    if (!inRangeNum(v, -1.0, 1.0)) {
      errors.add('xp_reward_gate_out_of_range:persona_$k');
    }
  });

  strictFindings['xp_reward_gate'] = <String, Object>{
    'xp_curve': xpCurve,
    'reward_weights': rewardWeights,
    'persona_modifiers': personaModifiers,
  };
}

void _checkMarketingTelemetryGate(
  Map<String, Object> strictFindings,
  Map<String, Object?> telemetry,
  List<String> errors,
) {
  final funnel =
      telemetry['funnel'] as Map<String, Object?>? ?? const <String, Object?>{};
  final engagement =
      telemetry['engagement'] as Map<String, Object?>? ??
      const <String, Object?>{};
  final personaInfluence =
      telemetry['persona_influence'] as Map<String, Object?>? ??
      const <String, Object?>{};

  if (funnel.isEmpty || engagement.isEmpty || personaInfluence.isEmpty) {
    errors.add('marketing_telemetry_missing_key');
  }
  if (!_isAsciiMap(funnel)) {
    errors.add('marketing_telemetry_invalid_ascii:funnel');
  }
  if (!_isAsciiMap(engagement)) {
    errors.add('marketing_telemetry_invalid_ascii:engagement');
  }
  if (!_isAsciiMap(personaInfluence)) {
    errors.add('marketing_telemetry_invalid_ascii:persona_influence');
  }

  final stage = funnel['stage'];
  if (stage is! num || stage < 0 || stage > 10) {
    errors.add('marketing_telemetry_out_of_range:stage');
  }

  for (final key in ['delta_accuracy', 'delta_speed', 'friction']) {
    final v = engagement[key];
    if (v is! num || v < -1.0 || v > 1.0) {
      errors.add('marketing_telemetry_out_of_range:$key');
    }
  }

  final personaSignal = personaInfluence['persona_signal']?.toString() ?? '';
  final coachingStyle = personaInfluence['coaching_style']?.toString() ?? '';
  if (!_isAsciiString(personaSignal) || !_isAsciiString(coachingStyle)) {
    errors.add('marketing_telemetry_invalid_ascii:persona_influence_values');
  }

  strictFindings['marketing_telemetry_gate'] = <String, Object>{
    'funnel': funnel,
    'engagement': engagement,
    'persona_influence': personaInfluence,
  };
}

void _checkFunnelRetentionVisualQAGate(
  Map<String, Object> strictFindings,
  Map<String, Object?> qa,
  List<String> errors,
) {
  if (qa.isEmpty) {
    errors.add('funnel_retention_missing_key');
    return;
  }
  final required = [
    'funnel_surface_ok',
    'retention_surface_ok',
    'missing_keys',
    'warnings',
  ];
  for (final key in required) {
    if (!qa.containsKey(key)) {
      errors.add('funnel_retention_missing_key');
      break;
    }
  }
  if (!_isAsciiMap(qa)) {
    errors.add('funnel_retention_invalid_ascii');
  }
  final missing = qa['missing_keys'];
  final warnings = qa['warnings'];
  if (missing is! List || warnings is! List) {
    errors.add('funnel_retention_bad_shape');
  } else {
    if (!missing.every((e) => e is String && _isAsciiString(e))) {
      errors.add('funnel_retention_bad_shape');
    }
    if (!warnings.every((e) => e is String && _isAsciiString(e))) {
      errors.add('funnel_retention_bad_shape');
    }
  }
  strictFindings['funnel_retention_visual_qa_gate'] =
      Map<String, Object>.unmodifiable({'bundle': qa});
}

void _checkMarketingAnalyticsPolishGate(
  Map<String, Object> strictFindings,
  Map<String, Object?> surface,
  List<String> errors,
) {
  if (surface.isEmpty) {
    errors.add('marketing_polish_missing_key');
    return;
  }
  final required = [
    'analytics_ok',
    'marketing_score',
    'missing_keys',
    'warnings',
    'drivers',
  ];
  for (final key in required) {
    if (!surface.containsKey(key)) {
      errors.add('marketing_polish_missing_key');
      break;
    }
  }
  if (!_isAsciiMap(surface)) {
    errors.add('marketing_polish_invalid_ascii');
  }
  final score = surface['marketing_score'];
  if (score is! num || score < 0 || score > 100) {
    errors.add('marketing_polish_bad_range');
  }
  final missing = surface['missing_keys'];
  final warnings = surface['warnings'];
  final drivers = surface['drivers'];
  if (missing is! List || warnings is! List || drivers is! List) {
    errors.add('marketing_polish_bad_shape');
  } else {
    if (!missing.every((e) => e is String && _isAsciiString(e))) {
      errors.add('marketing_polish_bad_shape');
    }
    if (!warnings.every((e) => e is String && _isAsciiString(e))) {
      errors.add('marketing_polish_bad_shape');
    }
    if (!drivers.every((e) => e is String && _isAsciiString(e))) {
      errors.add('marketing_polish_bad_shape');
    }
  }
  strictFindings['marketing_analytics_polish_gate'] =
      Map<String, Object>.unmodifiable({'surface': surface});
}

void _checkRpgGate(
  Map<String, Object> strictFindings,
  Map<String, Object?> fusion,
  List<String> errors,
) {
  if (fusion.isEmpty) {
    errors.add('rpg_gate_missing_key');
    return;
  }
  final required = [
    'level',
    'xp',
    'xp_to_next',
    'soft_progress',
    'traits',
    'fusion',
    'summary',
  ];
  for (final key in required) {
    if (!fusion.containsKey(key)) {
      errors.add('rpg_gate_missing_key');
      break;
    }
  }
  if (!_isAsciiMap(fusion)) {
    errors.add('rpg_gate_invalid_ascii');
  }
  final level = fusion['level'];
  final xp = fusion['xp'];
  final xpToNext = fusion['xp_to_next'];
  final soft = fusion['soft_progress'];
  final traits = fusion['traits'];
  final fusionBlock =
      fusion['fusion'] as Map<String, Object?>? ?? const <String, Object?>{};
  final eff = fusionBlock['effective_power'];

  if (level is! num || level < 1 || level > 50) {
    errors.add('rpg_gate_out_of_range');
  }
  if (xp is! num || xp < 0) errors.add('rpg_gate_out_of_range');
  if (xpToNext is! num || xpToNext < 0) {
    errors.add('rpg_gate_out_of_range');
  }
  if (soft is! num || soft < 0 || soft > 1.0) {
    errors.add('rpg_gate_out_of_range');
  }
  if (eff is! num || eff < 0 || eff > 100.0) {
    errors.add('rpg_gate_out_of_range');
  }

  var traitInvalid = false;
  if (traits is Map) {
    for (final entry in traits.entries) {
      if (!_isAsciiString(entry.key.toString())) {
        traitInvalid = true;
        break;
      }
      final v = entry.value;
      if (v is! num || v < 0 || v > 1.0) {
        traitInvalid = true;
        break;
      }
    }
  } else {
    traitInvalid = true;
  }
  if (traitInvalid) {
    errors.add('rpg_gate_invalid_traits');
  }

  strictFindings['rpg_gate'] = Map<String, Object>.unmodifiable({
    'fusion': fusion,
  });
}

void _checkRpgConsistencyGate(
  Map<String, Object> strictFindings,
  Map<String, Object?> fusion,
  List<String> errors,
) {
  if (fusion.isEmpty) {
    errors.add('rpg_consistency_missing_key');
    return;
  }
  if (!_isAsciiMap(fusion)) {
    errors.add('rpg_consistency_invalid_ascii');
  }
  final mastery =
      (fusion['mastery'] as Map<String, Object?>?) ??
      <String, Object?>{
        'level': fusion['level'],
        'soft_progress': fusion['soft_progress'],
      };
  final traits =
      fusion['traits'] as Map<String, Object?>? ?? const <String, Object?>{};
  final fusionBlock =
      fusion['fusion'] as Map<String, Object?>? ?? const <String, Object?>{};
  final summary = fusion['summary']?.toString() ?? '';

  final level = mastery['level'];
  final soft = mastery['soft_progress'];
  final eff = fusionBlock['effective_power'];
  if (level is! num ||
      level < 1 ||
      level > 50 ||
      soft is! num ||
      soft < 0 ||
      soft > 1.0 ||
      eff is! num ||
      eff < 0 ||
      eff > 100.0) {
    errors.add('rpg_consistency_out_of_range');
  }

  var traitInvalid = false;
  if (traits.isEmpty && level is num && level >= 5) {
    traitInvalid = true;
  }
  for (final entry in traits.entries) {
    final v = entry.value;
    if (v is! num || v < -1.0 || v > 1.0) {
      traitInvalid = true;
      break;
    }
    if (!_isAsciiString(entry.key.toString())) {
      traitInvalid = true;
      break;
    }
  }
  if (traitInvalid) errors.add('rpg_consistency_invalid_ascii');

  if (level is num && eff is num) {
    final delta = (eff / 2.0 - level).abs();
    if (delta > 10.0) {
      errors.add('rpg_consistency_mismatch');
    }
  }
  if (level == 50 && soft != 0) {
    errors.add('rpg_consistency_mismatch');
  }
  if (summary.isEmpty || !_isAsciiString(summary)) {
    errors.add('rpg_consistency_invalid_ascii');
  }

  strictFindings['rpg_consistency_gate'] = Map<String, Object>.unmodifiable({
    'fusion': fusion,
  });
}

void _checkRpgStabilitySnapshotGate(
  Map<String, Object> strictFindings,
  Map<String, Object?> snapshot,
  List<String> errors,
) {
  if (snapshot.isEmpty) {
    errors.add('rpg_snapshot_missing_key');
    return;
  }
  final required = ['level', 'soft_progress', 'traits', 'stable', 'drivers'];
  for (final key in required) {
    if (!snapshot.containsKey(key)) {
      errors.add('rpg_snapshot_missing_key');
      break;
    }
  }
  if (!_isAsciiMap(snapshot)) {
    errors.add('rpg_snapshot_invalid_ascii');
  }
  final level = snapshot['level'];
  final soft = snapshot['soft_progress'];
  final traits = snapshot['traits'];
  final drivers = snapshot['drivers'];
  if (level is! num || level < 1 || level > 50) {
    errors.add('rpg_snapshot_out_of_range');
  }
  if (soft is! num || soft < 0 || soft > 1.0) {
    errors.add('rpg_snapshot_out_of_range');
  }
  var traitInvalid = false;
  if (traits is Map) {
    for (final entry in traits.entries) {
      final v = entry.value;
      if (v is! num || v < -1.0 || v > 1.0) {
        traitInvalid = true;
        break;
      }
      if (!_isAsciiString(entry.key.toString())) {
        traitInvalid = true;
        break;
      }
    }
  } else {
    traitInvalid = true;
  }
  if (traitInvalid) errors.add('rpg_snapshot_out_of_range');
  if (drivers is! List || drivers.isEmpty) {
    errors.add('rpg_snapshot_empty_drivers');
  } else {
    if (!drivers.every((e) => e is String && _isAsciiString(e))) {
      errors.add('rpg_snapshot_invalid_ascii');
    }
  }

  strictFindings['rpg_stability_snapshot_gate'] =
      Map<String, Object>.unmodifiable({'snapshot': snapshot});
}

void _checkXpRewardRpgInterplayGate(
  Map<String, Object> strictFindings,
  List<String> errors,
) {
  final rpgFusion =
      strictFindings['rpg_gate'] as Map<String, Object>? ?? const {};
  final fusion =
      rpgFusion['fusion'] as Map<String, Object?>? ?? const <String, Object?>{};
  final rpgSnapshot =
      strictFindings['rpg_stability_snapshot_gate'] as Map<String, Object>? ??
      const <String, Object>{};
  final snapshot =
      rpgSnapshot['snapshot'] as Map<String, Object?>? ??
      const <String, Object?>{};
  final xpSurfaceGate =
      strictFindings['xp_reward_surface_gate'] as Map<String, Object>? ??
      const <String, Object>{};
  final xpSurface =
      xpSurfaceGate['xp_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  final rewardSurface =
      xpSurfaceGate['reward_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  final personaSurface =
      xpSurfaceGate['persona_surface_modifiers'] as Map<String, Object>? ??
      const <String, Object>{};

  if (fusion.isEmpty || xpSurface.isEmpty || rewardSurface.isEmpty) {
    errors.add('xp_reward_rpg_interplay_gate_missing_data');
    return;
  }
  if (!_isAsciiMap(fusion) ||
      !_isAsciiMap(xpSurface) ||
      !_isAsciiMap(rewardSurface) ||
      !_isAsciiMap(personaSurface) ||
      !_isAsciiMap(snapshot)) {
    errors.add('xp_reward_rpg_interplay_gate_invalid_ascii');
  }

  final level = fusion['level'] as num? ?? 0;
  final eff = (fusion['fusion'] as Map?)?['effective_power'] as num? ?? 0.0;
  final stable = snapshot['stable'] == true;

  final xpRangeFail = xpSurface.values.any((v) {
    if (v is! num) return true;
    final d = v.toDouble();
    return d < 0 || d > 500;
  });
  final rewardRangeFail = rewardSurface.values.any((v) {
    if (v is! num) return true;
    final d = v.toDouble();
    return d < 0 || d > 3.0;
  });
  final personaRangeFail = personaSurface.values.any((v) {
    if (v is! num) return true;
    final d = v.toDouble();
    return d < -1.0 || d > 1.0;
  });
  if (xpRangeFail || rewardRangeFail || personaRangeFail) {
    errors.add('xp_reward_rpg_interplay_gate_out_of_range');
  }

  final expectedXp = min(500.0, level.toDouble() * 10.0);
  final xpMonoFail = xpSurface.values.any(
    (v) => v is num && v.toDouble() + 0.001 < expectedXp,
  );
  final expectedReward = (eff.clamp(0, 100) / 100.0) * 3.0;
  final rewardMonoFail = rewardSurface.values.any(
    (v) => v is num && v.toDouble() + 0.001 < expectedReward,
  );
  final personaMonoFail =
      !stable &&
      personaSurface.values.any((v) => v is num && v.toDouble().abs() > 0.1);
  if (xpMonoFail || rewardMonoFail || personaMonoFail) {
    errors.add('xp_reward_rpg_interplay_gate_monotonicity');
  }

  strictFindings['xp_reward_rpg_interplay_gate'] =
      Map<String, Object>.unmodifiable({
        'level': level,
        'effective_power': eff,
        'xp_surface': xpSurface,
        'reward_surface': rewardSurface,
        'persona_surface_modifiers': personaSurface,
        'stable': stable,
      });
}

Map<String, Object> _checkFinalCrossDomainPolishGate({
  required Map<String, Object> strictFindings,
  required Map<String, Object> v4CohesionView,
  required Map<String, Object> v4TokenVerificationView,
  required Map<String, Object> v4PolishView,
  required Map<String, Object> personaUX,
  required Map<String, Object> coachingStyle,
  required Map<String, Object> marketingPolish,
  required Map<String, Object?> rpgSnapshot,
  required Map<String, Object> xpRewardSurfaceGate,
  List<String>? errors,
}) {
  final errs = errors ?? <String>[];
  final participants = [
    v4CohesionView,
    v4TokenVerificationView,
    v4PolishView,
    personaUX,
    coachingStyle,
    marketingPolish,
    rpgSnapshot,
    xpRewardSurfaceGate,
  ];
  if (participants.any((p) => !_isAsciiMap(p))) {
    errs.add('final_polish_ascii_invalid');
  }
  if (participants.any((p) => p.isEmpty)) {
    errs.add('final_polish_empty');
  }

  final cohesionOk = v4CohesionView['ok'] == true;
  final tokenOk = v4TokenVerificationView['ok'] == true;
  final polishOk = v4PolishView['ok'] == true;
  if ((cohesionOk || tokenOk || polishOk) &&
      (personaUX.isEmpty || coachingStyle.isEmpty)) {
    errs.add('final_polish_conflict');
  }

  final rewardSurface =
      xpRewardSurfaceGate['reward_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  for (final entry in rewardSurface.entries) {
    final v = entry.value;
    if (v is num) {
      final d = v.toDouble();
      if (d < 0 || d > 3.0) {
        errs.add('final_polish_out_of_range');
        break;
      }
    }
  }

  final snapshotTraits =
      rpgSnapshot['traits'] as Map<String, Object?>? ??
      const <String, Object?>{};
  if (snapshotTraits.isNotEmpty && rewardSurface.isEmpty) {
    errs.add('final_polish_conflict');
  }

  final marketingScore = marketingPolish['marketing_score'];
  if (marketingScore is num) {
    final score = marketingScore.toDouble();
    if (score < 0 || score > 100) {
      errs.add('final_polish_out_of_range');
    } else if (score < 20 && polishOk) {
      errs.add('final_polish_conflict');
    }
  } else if (marketingPolish.isNotEmpty) {
    errs.add('final_polish_out_of_range');
  }

  strictFindings['final_cross_domain_polish_gate'] =
      Map<String, Object>.unmodifiable({
        'cohesion_view': v4CohesionView,
        'token_view': v4TokenVerificationView,
        'polish_view': v4PolishView,
        'persona': personaUX,
        'coaching': coachingStyle,
        'marketing': marketingPolish,
        'rpg_snapshot': rpgSnapshot,
        'xp_reward_surface_gate': xpRewardSurfaceGate,
        'ok': errs.isEmpty,
      });
  return strictFindings['final_cross_domain_polish_gate']
      as Map<String, Object>;
}

Map<String, Object> _checkAdaptiveRewardGate(
  Map<String, Object> strictFindings,
  Map<String, Object> raw,
  List<String> errors,
) {
  Map<String, Object> _asMap(Object? v) {
    if (v is Map) {
      return v.map(
        (key, value) => MapEntry(key.toString(), value as Object? ?? ''),
      );
    }
    return <String, Object>{};
  }

  final xpCurve = _asMap(raw['xp_curve']);
  final rewardSurface = _asMap(raw['reward_surface']);
  final personaSurface = _asMap(raw['persona_surface_modifiers']);
  final snapshot = _asMap(raw['rpg_snapshot']);
  final effectivePower = (raw['effective_power'] as num?)?.toDouble() ?? 0.0;

  if (!_isAsciiMap(xpCurve) ||
      !_isAsciiMap(rewardSurface) ||
      !_isAsciiMap(personaSurface) ||
      !_isAsciiMap(snapshot)) {
    errors.add('adaptive_reward_gate_invalid_ascii');
  }
  if (xpCurve.isEmpty || rewardSurface.isEmpty) {
    errors.add('adaptive_reward_gate_monotonicity');
  }

  final levels = (xpCurve['levels'] as List<Object?>? ?? const [])
      .whereType<num>()
      .map((e) => e.toDouble())
      .toList();
  final xpDeltas = <double>[];
  var prevDelta = -1.0;
  for (var i = 1; i < levels.length; i++) {
    final delta = (levels[i] - levels[i - 1]).toDouble();
    xpDeltas.add(delta);
    if (delta < prevDelta || delta < 0) {
      errors.add('adaptive_reward_gate_monotonicity');
      break;
    }
    prevDelta = delta;
  }

  final rewardTable = (rewardSurface['table'] as num?)?.toDouble() ?? 0.0;
  final rewardAction =
      (rewardSurface['action_buttons'] as num?)?.toDouble() ?? 0.0;
  final effNormalized = (effectivePower / 100.0).clamp(0.0, 1.0);
  final rewardNorm = (rewardTable / 3.0).clamp(0.0, 1.0);
  if ((rewardNorm - effNormalized).abs() > 0.15) {
    errors.add('adaptive_reward_gate_correlation');
  }

  var signConflict = false;
  personaSurface.forEach((key, value) {
    final mod = (value as num?)?.toDouble();
    final reward = (rewardSurface[key] as num?)?.toDouble();
    if (mod == null || reward == null) return;
    if ((reward > 0 && mod < 0) || (reward < 0 && mod > 0)) {
      signConflict = true;
    }
  });
  if (signConflict) {
    errors.add('adaptive_reward_gate_sign_conflict');
  }

  final weights = (xpCurve['weights'] as List<Object?>? ?? const [])
      .whereType<num>()
      .map((e) => e.toDouble())
      .toList();
  if (weights.isNotEmpty) {
    final avgWeight = weights.reduce((a, b) => a + b) / weights.length;
    final minReward = 0.5 * avgWeight;
    final maxReward = 2.0 * avgWeight;
    if (rewardAction < minReward || rewardAction > maxReward) {
      errors.add('adaptive_reward_gate_monotonicity');
    }
  }

  final findings = <String, Object>{
    'xp_curve': xpCurve,
    'reward_surface': rewardSurface,
    'persona_surface_modifiers': personaSurface,
    'effective_power': effectivePower,
    'rpg_snapshot': snapshot,
    'xp_deltas': xpDeltas,
    'stable': snapshot['stable'] == true,
  };
  strictFindings['adaptive_reward_gate'] = Map<String, Object>.unmodifiable(
    findings,
  );
  return strictFindings['adaptive_reward_gate'] as Map<String, Object>;
}

Map<String, Object> _checkFinalXpRewardCoherenceGate({
  required Map<String, Object> strictFindings,
  required Map<String, Object> xpCurve,
  required Map<String, Object> xpRewardSurfaceGate,
  required Map<String, Object?> rpgSnapshot,
  required Map<String, Object> tokenVerificationView,
  required Map<String, Object> coachingDirectives,
  List<String>? errors,
}) {
  final errs = errors ?? <String>[];
  if (!_isAsciiMap(xpCurve) || !_isAsciiMap(xpRewardSurfaceGate)) {
    errs.add('final_xp_reward_invalid_ascii');
  }
  final levels = xpCurve['levels'] as List<Object?>? ?? const [];
  if (levels.isEmpty || levels.any((e) => e is! num)) {
    errs.add('final_xp_reward_out_of_range');
  }
  final rewardSurface =
      xpRewardSurfaceGate['reward_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  for (final entry in rewardSurface.entries) {
    final v = entry.value;
    if (v is num) {
      final d = v.toDouble();
      if (d < 0 || d > 3.0) errs.add('final_xp_reward_out_of_range');
    }
  }
  final personaMods =
      xpRewardSurfaceGate['persona_surface_modifiers']
          as Map<String, Object>? ??
      const <String, Object>{};
  for (final key in personaMods.keys) {
    final reward = rewardSurface[key];
    final mod = personaMods[key];
    if (reward is num && mod is num) {
      if ((reward > 0 && mod < 0) || (reward < 0 && mod > 0)) {
        errs.add('final_xp_reward_conflict');
      }
    }
  }
  final xpSurface =
      xpRewardSurfaceGate['xp_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  final soft = (rpgSnapshot['soft_progress'] as num?)?.toDouble() ?? 0.0;
  final avgXp =
      xpSurface.values
          .whereType<num>()
          .map((e) => e.toDouble())
          .fold<double>(0, (a, b) => a + b) /
      (xpSurface.values.whereType<num>().isNotEmpty
          ? xpSurface.values.whereType<num>().length
          : 1);
  if (soft > 0.5 && avgXp < 50) {
    errs.add('final_xp_reward_coherence_mismatch');
  }
  if (tokenVerificationView['ok'] == false) {
    errs.add('final_xp_reward_conflict');
  }
  if (coachingDirectives.isEmpty) {
    errs.add('final_xp_reward_conflict');
  }
  strictFindings['final_xp_reward_coherence_gate'] =
      Map<String, Object>.unmodifiable({
        'xp_curve': xpCurve,
        'xp_reward_surface_gate': xpRewardSurfaceGate,
        'rpg_snapshot': rpgSnapshot,
        'token_view': tokenVerificationView,
        'coaching_directives': coachingDirectives,
        'ok': errs.isEmpty,
      });
  return strictFindings['final_xp_reward_coherence_gate']
      as Map<String, Object>;
}

Map<String, Object> _checkXpRewardPersonaRpgCoachingStabilityGate({
  required Map<String, Object> strictFindings,
  required Map<String, Object> xpCurve,
  required Map<String, Object> xpRewardSurfaceGate,
  required Map<String, Object?> rpgSnapshot,
  required Map<String, Object> personaSignals,
  required Map<String, Object> coachingDirectives,
  required Map<String, Object?> v4Snapshot,
  required Map<String, Object?> tierA,
  List<String>? errors,
}) {
  final errs = errors ?? <String>[];
  if (!_isAsciiMap(xpCurve) ||
      !_isAsciiMap(xpRewardSurfaceGate) ||
      !_isAsciiMap(personaSignals) ||
      !_isAsciiMap(coachingDirectives) ||
      !_isAsciiMap(v4Snapshot)) {
    errs.add('xp_reward_persona_rpg_coaching_stability_invalid_ascii');
  }

  final levels = xpCurve['levels'] as List<Object?>? ?? const [];
  if (levels.isEmpty)
    errs.add('xp_reward_persona_rpg_coaching_stability_missing');
  final rewardSurface =
      xpRewardSurfaceGate['reward_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  final personaSurface =
      xpRewardSurfaceGate['persona_surface_modifiers']
          as Map<String, Object>? ??
      const <String, Object>{};
  final xpSurface =
      xpRewardSurfaceGate['xp_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  if (rewardSurface.isEmpty || xpSurface.isEmpty) {
    errs.add('xp_reward_persona_rpg_coaching_stability_missing');
  }
  for (final entry in rewardSurface.entries) {
    final v = entry.value;
    if (v is num) {
      final d = v.toDouble();
      if (d < 0 || d > 3.0) {
        errs.add('xp_reward_persona_rpg_coaching_stability_out_of_range');
        break;
      }
    }
  }
  for (final entry in personaSurface.entries) {
    final mod = entry.value;
    final reward = rewardSurface[entry.key];
    if (mod is num && reward is num) {
      if ((reward > 0 && mod < -1.0) || (reward < 0 && mod > 1.0)) {
        errs.add('xp_reward_persona_rpg_coaching_stability_conflict');
      }
    }
  }
  final soft = (rpgSnapshot['soft_progress'] as num?)?.toDouble() ?? 0.0;
  final avgXp =
      xpSurface.values
          .whereType<num>()
          .map((e) => e.toDouble())
          .fold<double>(0, (a, b) => a + b) /
      (xpSurface.values.whereType<num>().isNotEmpty
          ? xpSurface.values.whereType<num>().length
          : 1);
  if (soft > 0.5 && avgXp < 50) {
    errs.add('xp_reward_persona_rpg_coaching_stability_conflict');
  }
  final pressure = (personaSignals['pressure'] as num?)?.toDouble() ?? 0.0;
  if (pressure.abs() > 2.0) {
    errs.add('xp_reward_persona_rpg_coaching_stability_out_of_range');
  }
  if (coachingDirectives.isEmpty) {
    errs.add('xp_reward_persona_rpg_coaching_stability_missing');
  }
  if (v4Snapshot.isEmpty || tierA.isEmpty) {
    errs.add('xp_reward_persona_rpg_coaching_stability_missing');
  }
  strictFindings['xp_reward_persona_rpg_coaching_stability_gate'] =
      Map<String, Object>.unmodifiable({
        'xp_curve': xpCurve,
        'xp_reward_surface_gate': xpRewardSurfaceGate,
        'rpg_snapshot': rpgSnapshot,
        'persona_signals': personaSignals,
        'coaching_directives': coachingDirectives,
        'v4_snapshot': v4Snapshot,
        'tierA': tierA,
        'ok': errs.isEmpty,
      });
  return strictFindings['xp_reward_persona_rpg_coaching_stability_gate']
      as Map<String, Object>;
}

Map<String, Object> _checkFinalXpRewardConsolidationGate({
  required Map<String, Object> strictFindings,
  required Map<String, Object> xpCurve,
  required Map<String, Object> xpRewardSurfaceGate,
  required Map<String, Object?> rpgFusion,
  required Map<String, Object?> rpgSnapshot,
  required Map<String, Object> coachingSurface,
  required Map<String, Object> coachingDirectives,
  required Map<String, Object?> v4Snapshot,
  required Map<String, Object> personaSignals,
  List<String>? errors,
}) {
  final errs = errors ?? <String>[];
  if (!_isAsciiMap(xpCurve) ||
      !_isAsciiMap(xpRewardSurfaceGate) ||
      !_isAsciiMap(coachingSurface) ||
      !_isAsciiMap(coachingDirectives) ||
      !_isAsciiMap(v4Snapshot) ||
      !_isAsciiMap(personaSignals)) {
    errs.add('final_xp_reward_consolidation_invalid_ascii');
  }

  final rewardSurface =
      xpRewardSurfaceGate['reward_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  final personaSurface =
      xpRewardSurfaceGate['persona_surface_modifiers']
          as Map<String, Object>? ??
      const <String, Object>{};
  final xpSurface =
      xpRewardSurfaceGate['xp_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  if (rewardSurface.isEmpty ||
      xpSurface.isEmpty ||
      coachingSurface.isEmpty ||
      coachingDirectives.isEmpty) {
    errs.add('final_xp_reward_consolidation_missing');
  }

  for (final entry in rewardSurface.entries) {
    final v = entry.value;
    if (v is num) {
      final d = v.toDouble();
      if (d < 0 || d > 3.0) {
        errs.add('final_xp_reward_consolidation_out_of_range');
        break;
      }
    }
  }
  for (final entry in personaSurface.entries) {
    final v = entry.value;
    if (v is num) {
      final d = v.toDouble();
      if (d < -1.0 || d > 1.0) {
        errs.add('final_xp_reward_consolidation_out_of_range');
        break;
      }
    }
  }

  final eff = (rpgFusion['fusion'] as Map?)?['effective_power'] as num? ?? 0.0;
  if (eff < 0 || eff > 200) {
    errs.add('final_xp_reward_consolidation_out_of_range');
  }
  final soft = (rpgSnapshot['soft_progress'] as num?)?.toDouble() ?? 0.0;
  if (soft < 0 || soft > 1.0) {
    errs.add('final_xp_reward_consolidation_out_of_range');
  }
  final pressure = (personaSignals['pressure'] as num?)?.toDouble() ?? 0.0;
  if (pressure.abs() > 2.0) {
    errs.add('final_xp_reward_consolidation_out_of_range');
  }
  if (v4Snapshot.isEmpty) {
    errs.add('final_xp_reward_consolidation_conflict');
  }

  strictFindings['final_xp_reward_consolidation_gate'] =
      Map<String, Object>.unmodifiable({
        'xp_curve': xpCurve,
        'xp_reward_surface_gate': xpRewardSurfaceGate,
        'rpg_fusion': rpgFusion,
        'rpg_snapshot': rpgSnapshot,
        'coaching_surface': coachingSurface,
        'coaching_directives': coachingDirectives,
        'v4_snapshot': v4Snapshot,
        'persona_signals': personaSignals,
        'ok': errs.isEmpty,
      });
  return strictFindings['final_xp_reward_consolidation_gate']
      as Map<String, Object>;
}

Map<String, Object> _checkGlobalRegressionSweepGate(
  Map<String, Object> strictFindings,
  Map<String, Object> sweep,
  List<String> errors,
) {
  const required = [
    'visual',
    'cohesion_view',
    'token_view',
    'persona_mat_view',
    'polish_view',
    'final_coherence',
    'mat_consistency',
    'persona_stack',
    'coaching_stack',
    'rpg_stack',
    'rpg_snapshot',
    'xp_reward_surface_gate',
    'xp_curve_gate',
    'xp_alignment_gate',
    'marketing',
    'funnel_retention',
    'release_readiness',
    'omega_bridge',
    'final_polish',
  ];

  if (!_isAsciiMap(sweep)) {
    errors.add('global_sweep_invalid_ascii');
  }
  for (final key in required) {
    final value = sweep[key];
    if (value is! Map || value.isEmpty) {
      errors.add('global_sweep_missing');
    } else if (!_isAsciiMap(value)) {
      errors.add('global_sweep_invalid_ascii');
    }
  }

  final rewardSurface =
      (sweep['xp_reward_surface_gate'] as Map?)?['reward_surface']
          as Map<String, Object>? ??
      const <String, Object>{};
  for (final v in rewardSurface.values) {
    if (v is num) {
      final d = v.toDouble();
      if (d < 0 || d > 3.0) {
        errors.add('global_sweep_out_of_range');
        break;
      }
    }
  }

  final ok = errors.isEmpty;
  final entries = sweep.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final ordered = Map<String, Object>.fromEntries(entries);

  strictFindings['global_regression_sweep_gate'] =
      Map<String, Object>.unmodifiable({'domains': ordered, 'ok': ok});
  return strictFindings['global_regression_sweep_gate'] as Map<String, Object>;
}

Map<String, Object> _checkFinalRegressionConsolidationGate(
  Map<String, Object> strictFindings,
  Map<String, Object> gates,
  List<String> errors,
) {
  const required = [
    'marketing',
    'funnel',
    'xp_reward_gate',
    'xp_reward_surface_gate',
    'xp_curve_gate',
    'xp_persona_alignment_gate',
    'adaptive_reward_gate',
    'final_xp_reward_coherence_gate',
    'xp_reward_persona_rpg_coaching_stability_gate',
    'final_xp_reward_consolidation_gate',
    'rpg_gate',
    'rpg_consistency_gate',
    'rpg_stability_snapshot_gate',
    'xp_reward_rpg_interplay_gate',
    'final_stability_consolidation_gate',
    'strict_cross_domain_gate',
    'final_cross_domain_polish_gate',
    'global_regression_sweep_gate',
  ];

  final conflicts = <String>[];
  final drivers = <String>[];

  if (!_isAsciiMap(gates)) {
    errors.add('final_regression_consolidation_invalid_ascii');
  }

  for (final key in required) {
    final value = gates[key];
    if (value is! Map || value.isEmpty) {
      errors.add('final_regression_consolidation_missing');
      conflicts.add('missing_$key');
      continue;
    }
    if (!_isAsciiMap(value)) {
      errors.add('final_regression_consolidation_invalid_ascii');
    }
    if (value['ok'] == false) {
      conflicts.add('$key_not_ok');
    }
  }

  final xpSurface =
      (gates['xp_reward_surface_gate'] as Map?)?['reward_surface']
          as Map<String, Object>? ??
      const <String, Object>{};
  for (final v in xpSurface.values) {
    if (v is num && (v.toDouble() < 0 || v.toDouble() > 3.0)) {
      errors.add('final_regression_consolidation_out_of_range');
      break;
    }
  }
  final personaSurface =
      (gates['xp_reward_surface_gate'] as Map?)?['persona_surface_modifiers']
          as Map<String, Object>? ??
      const <String, Object>{};
  for (final v in personaSurface.values) {
    if (v is num && (v.toDouble() < -1.0 || v.toDouble() > 1.0)) {
      errors.add('final_regression_consolidation_out_of_range');
      break;
    }
  }
  final xpCurve =
      (gates['xp_curve_gate'] as Map?)?['weights'] as List<Object?>? ??
      const <Object?>[];
  for (final weight in xpCurve.whereType<num>()) {
    final d = weight.toDouble();
    if (d < 0 || d > 10) {
      errors.add('final_regression_consolidation_out_of_range');
      break;
    }
  }
  final eff = (gates['rpg_gate'] as Map?)?['fusion'] is Map
      ? ((gates['rpg_gate'] as Map)['fusion'] as Map)['effective_power']
                as num? ??
            0
      : 0;
  if (eff < 0 || eff > 200) {
    errors.add('final_regression_consolidation_out_of_range');
  }
  final soft =
      (gates['rpg_stability_snapshot_gate'] as Map?)?['soft_progress']
          as num? ??
      0;
  if (soft < 0 || soft > 1) {
    errors.add('final_regression_consolidation_out_of_range');
  }

  if (conflicts.isNotEmpty) {
    drivers.addAll(conflicts);
  }
  if (errors.isNotEmpty) {
    drivers.addAll(errors);
  }

  final orderedSnapshot = _orderMapByKey(_sanitizeAsciiObject(gates));
  conflicts.sort();
  drivers.sort();
  final ok = errors.isEmpty && conflicts.isEmpty;
  strictFindings['final_regression_consolidation_gate'] =
      Map<String, Object>.unmodifiable({
        'final_regression_ok': ok,
        'final_regression_conflicts': List<String>.unmodifiable(conflicts),
        'final_regression_drivers': List<String>.unmodifiable(drivers),
        'final_regression_snapshot': orderedSnapshot,
      });
  return strictFindings['final_regression_consolidation_gate']
      as Map<String, Object>;
}

Map<String, Object> _checkV4FinalCohesionGate({
  required Map<String, Object> strictFindings,
  required Map<String, Object> cohesionView,
  required Map<String, Object> tokenView,
  required Map<String, Object> personaMatView,
  required Map<String, Object> polishView,
  required Map<String, Object> finalCoherenceView,
  required Map<String, Object> cohesionReleaseSurface,
  required List<String> errors,
}) {
  final conflicts = <String>[];
  final drivers = <String>[];

  final views = {
    'cohesion_view': cohesionView,
    'token_view': tokenView,
    'persona_mat_view': personaMatView,
    'polish_view': polishView,
    'final_coherence_view': finalCoherenceView,
    'cohesion_release_surface': cohesionReleaseSurface,
  };

  if (!_isAsciiMap(views)) {
    errors.add('v4_final_cohesion_invalid_ascii');
  }

  for (final entry in views.entries) {
    final value = entry.value;
    if (value.isEmpty) {
      errors.add('v4_final_cohesion_missing');
      conflicts.add('missing_${entry.key}');
    } else if (!_isAsciiMap(value)) {
      errors.add('v4_final_cohesion_invalid_ascii');
    }
  }

  final requiredFlags = <String, bool>{
    'cohesion_crosscheck_ok': cohesionView['cohesion_crosscheck_ok'] == true,
    'persona_mat_sync_ok': cohesionView['persona_mat_sync_ok'] == true,
    'token_polish_consistency_ok':
        cohesionView['token_polish_consistency_ok'] == true,
    'surface_binding_ok': cohesionView['surface_binding_ok'] == true,
  };
  requiredFlags.forEach((k, v) {
    if (!v) conflicts.add(k);
  });

  final conflictFlags =
      cohesionView['conflict_flags'] as List<Object>? ?? const <Object>[];
  if (conflictFlags.isNotEmpty) {
    conflicts.addAll(conflictFlags.map((e) => e.toString()).toList()..sort());
  }

  final snapshot = _orderMapByKey(_sanitizeAsciiObject(views));
  void clampSnapshot(Map<String, Object> target) {
    for (final entry in target.entries.toList()) {
      final value = entry.value;
      if (value is num) {
        target[entry.key] = value.toDouble().clamp(0, 100);
      } else if (value is Map<String, Object>) {
        final nested = Map<String, Object>.from(value);
        clampSnapshot(nested);
        target[entry.key] = nested;
      }
    }
  }

  final snapshotClamped = Map<String, Object>.from(snapshot);
  clampSnapshot(snapshotClamped);

  conflicts.sort();
  final ok = errors.isEmpty && conflicts.isEmpty;
  if (!ok) {
    drivers.addAll(conflicts);
    drivers.addAll(errors);
  }
  drivers.sort();

  strictFindings['v4_final_cohesion_gate'] = Map<String, Object>.unmodifiable({
    'v4_final_cohesion_ok': ok,
    'v4_final_cohesion_conflicts': List<String>.unmodifiable(conflicts),
    'v4_final_cohesion_drivers': List<String>.unmodifiable(drivers),
    'v4_final_cohesion_snapshot': snapshotClamped,
  });
  return strictFindings['v4_final_cohesion_gate'] as Map<String, Object>;
}

Map<String, Object> _checkV4TokenFinalVerificationGate({
  required Map<String, Object> strictFindings,
  required Map<String, Object?> normalizedTokens,
  required Map<String, Object> tokenVerificationView,
  required Map<String, Object?> polishBundle,
  required List<String> errors,
}) {
  final conflicts = <String>[];
  final drivers = <String>[];

  final tokens = normalizedTokens.map((k, v) => MapEntry(k.toString(), v));
  final polish = polishBundle.map((k, v) => MapEntry(k.toString(), v));

  if (!_isAsciiMap(tokens)) {
    errors.add('v4_token_final_invalid_ascii');
  }
  if (!_isAsciiMap(tokenVerificationView)) {
    errors.add('v4_token_final_invalid_ascii');
  }
  if (!_isAsciiMap(polish)) {
    errors.add('v4_token_final_invalid_ascii');
  }

  final requiredCategories = <String>{
    'color',
    'surface',
    'spacing',
    'radius',
    'shadow',
    'accent',
  };
  final presentCategories = <String>{};
  for (final key in tokens.keys) {
    final k = key.toString();
    for (final cat in requiredCategories) {
      if (k.startsWith(cat)) presentCategories.add(cat);
    }
  }
  for (final cat in requiredCategories) {
    if (!presentCategories.contains(cat)) {
      conflicts.add('missing_$cat');
      errors.add('v4_token_final_missing');
    }
  }

  final structureOk = tokenVerificationView['token_structure_ok'] == true;
  final polishOk = tokenVerificationView['token_polish_consistency_ok'] == true;
  final personaMatOk = tokenVerificationView['persona_mat_sync_ok'] != false;
  if (!structureOk) conflicts.add('token_structure');
  if (!polishOk) conflicts.add('token_polish_consistency');
  if (!personaMatOk) conflicts.add('persona_mat_sync');

  final snapshot = _orderMapByKey(
    _sanitizeAsciiObject(<String, Object>{
      'tokens': tokens,
      'token_view': tokenVerificationView,
      'polish': polish,
    }),
  );

  void clampSnapshot(Map<String, Object> target) {
    for (final entry in target.entries.toList()) {
      final value = entry.value;
      if (value is num) {
        target[entry.key] = value.toDouble().clamp(0, 100);
      } else if (value is Map<String, Object>) {
        final nested = Map<String, Object>.from(value);
        clampSnapshot(nested);
        target[entry.key] = nested;
      }
    }
  }

  final snapshotClamped = Map<String, Object>.from(snapshot);
  clampSnapshot(snapshotClamped);

  conflicts.sort();
  final ok = errors.isEmpty && conflicts.isEmpty;
  if (!ok) {
    drivers.addAll(conflicts);
    drivers.addAll(errors);
  }
  drivers.sort();

  strictFindings['v4_token_final_verification_gate'] =
      Map<String, Object>.unmodifiable({
        'v4_token_final_ok': ok,
        'v4_token_final_conflicts': List<String>.unmodifiable(conflicts),
        'v4_token_final_drivers': List<String>.unmodifiable(drivers),
        'v4_token_final_snapshot': snapshotClamped,
      });
  return strictFindings['v4_token_final_verification_gate']
      as Map<String, Object>;
}

Map<String, Object> _checkPersonaV4MatFinalGate({
  required Map<String, Object> strictFindings,
  required Map<String, Object?> personaUx,
  required Map<String, Object?> v4Snapshot,
  required Map<String, Object?> v4Delta,
  required Map<String, Object> matSnapshot,
  required Map<String, Object> personaMatView,
  required Map<String, Object> finalPolishView,
  required Map<String, Object> tokenView,
  required Map<String, Object> cohesionView,
  required List<String> errors,
}) {
  final conflicts = <String>[];
  final drivers = <String>[];

  final maps = {
    'persona': personaUx,
    'v4_snapshot': v4Snapshot,
    'v4_delta': v4Delta,
    'mat_snapshot': matSnapshot,
    'persona_mat_view': personaMatView,
    'final_polish_view': finalPolishView,
    'token_view': tokenView,
    'cohesion_view': cohesionView,
  };

  if (!_isAsciiMap(maps)) {
    errors.add('persona_v4_mat_invalid_ascii');
  }

  for (final entry in maps.entries) {
    final value = entry.value;
    if (value.isEmpty) {
      errors.add('persona_v4_mat_missing');
      conflicts.add('missing_${entry.key}');
    } else if (!_isAsciiMap(value)) {
      errors.add('persona_v4_mat_invalid_ascii');
    }
  }

  final requiredFlags = <String, bool>{
    'persona_mat_sync_ok': personaMatView['persona_mat_sync_ok'] == true,
    'token_structure_ok': tokenView['token_structure_ok'] == true,
    'v4_token_final_ok':
        (strictFindings['v4_token_final_verification_gate']
            as Map<String, Object>?)?['v4_token_final_ok'] ==
        true,
    'cohesion_crosscheck_ok': cohesionView['cohesion_crosscheck_ok'] == true,
    'mat_snapshot_consistency_ok':
        matSnapshot['ok'] == true ||
        matSnapshot['mat_snapshot_consistency_ok'] == true,
    'v4_final_polish_ok':
        finalPolishView['visual_polish_ok'] == true ||
        finalPolishView['ok'] == true,
  };
  requiredFlags.forEach((k, v) {
    if (!v) conflicts.add(k);
  });

  final personaMatConflicts =
      personaMatView['conflict_flags'] as List<Object>? ?? const <Object>[];
  final polishConflicts =
      finalPolishView['final_polish_conflict_flags'] as List<Object>? ??
      const <Object>[];
  final tokenConflicts =
      tokenView['conflict_flags'] as List<Object>? ?? const <Object>[];
  final cohesionConflicts =
      cohesionView['conflict_flags'] as List<Object>? ?? const <Object>[];

  conflicts.addAll(personaMatConflicts.map((e) => e.toString()));
  conflicts.addAll(polishConflicts.map((e) => e.toString()));
  conflicts.addAll(tokenConflicts.map((e) => e.toString()));
  conflicts.addAll(cohesionConflicts.map((e) => e.toString()));

  final snapshot = _orderMapByKey(
    _sanitizeAsciiObject(<String, Object>{
      'persona': personaUx,
      'v4_snapshot': v4Snapshot,
      'v4_delta': v4Delta,
      'mat_snapshot': matSnapshot,
      'persona_mat_view': personaMatView,
      'final_polish_view': finalPolishView,
      'token_view': tokenView,
      'cohesion_view': cohesionView,
    }),
  );

  void clampSnapshot(Map<String, Object> target) {
    for (final entry in target.entries.toList()) {
      final value = entry.value;
      if (value is num) {
        target[entry.key] = value.toDouble().clamp(0, 100);
      } else if (value is Map<String, Object>) {
        final nested = Map<String, Object>.from(value);
        clampSnapshot(nested);
        target[entry.key] = nested;
      }
    }
  }

  final snapshotClamped = Map<String, Object>.from(snapshot);
  clampSnapshot(snapshotClamped);

  conflicts.sort();
  final ok = errors.isEmpty && conflicts.isEmpty;
  if (!ok) {
    drivers.addAll(conflicts);
    drivers.addAll(errors);
  }
  drivers.sort();

  strictFindings['persona_v4_mat_final_gate'] =
      Map<String, Object>.unmodifiable({
        'persona_v4_mat_ok': ok,
        'persona_v4_mat_conflicts': List<String>.unmodifiable(conflicts),
        'persona_v4_mat_drivers': List<String>.unmodifiable(drivers),
        'persona_v4_mat_snapshot': snapshotClamped,
      });
  return strictFindings['persona_v4_mat_final_gate'] as Map<String, Object>;
}

Map<String, Object> _checkFinalVisualPolishGate({
  required Map<String, Object> strictFindings,
  required Map<String, Object> finalPolishView,
  required Map<String, Object> cohesionView,
  required Map<String, Object> tokenView,
  required Map<String, Object> personaMatView,
  required Map<String, Object> finalCoherenceView,
  required Map<String, Object> finalVisualPolishValidator,
  required Map<String, Object> readinessSurface,
  required Map<String, Object> omegaBridge,
  required List<String> errors,
}) {
  final conflicts = <String>[];
  final drivers = <String>[];

  final maps = {
    'final_polish_view': finalPolishView,
    'cohesion_view': cohesionView,
    'token_view': tokenView,
    'persona_mat_view': personaMatView,
    'final_coherence_view': finalCoherenceView,
    'final_visual_polish_validator': finalVisualPolishValidator,
    'readiness_surface': readinessSurface,
    'omega_bridge': omegaBridge,
  };

  if (!_isAsciiMap(maps)) {
    errors.add('final_visual_polish_invalid_ascii');
  }

  for (final entry in maps.entries) {
    final value = entry.value;
    if (value.isEmpty) {
      errors.add('final_visual_polish_missing');
      conflicts.add('missing_${entry.key}');
    } else if (!_isAsciiMap(value)) {
      errors.add('final_visual_polish_invalid_ascii');
    }
  }

  final requiredFlags = <String, bool>{
    'final_polish_ok':
        finalPolishView['visual_polish_ok'] == true ||
        finalPolishView['ok'] == true,
    'cohesion_ok': cohesionView['cohesion_crosscheck_ok'] == true,
    'token_ok':
        tokenView['token_structure_ok'] == true &&
        tokenView['token_polish_consistency_ok'] == true,
    'persona_mat_ok': personaMatView['persona_mat_sync_ok'] == true,
    'coherence_ok': finalCoherenceView['ok'] == true,
    'validator_ok':
        finalVisualPolishValidator['ok'] == true ||
        finalVisualPolishValidator['final_visual_polish_ok'] == true,
    'readiness_ok': readinessSurface['ok'] == true,
    'omega_ok': omegaBridge['ok'] == true,
  };
  requiredFlags.forEach((k, v) {
    if (!v) conflicts.add(k);
  });

  final extractConflicts = <List<Object>>[
    finalPolishView['final_polish_conflict_flags'] as List<Object>? ??
        const <Object>[],
    cohesionView['conflict_flags'] as List<Object>? ?? const <Object>[],
    tokenView['conflict_flags'] as List<Object>? ?? const <Object>[],
    personaMatView['conflict_flags'] as List<Object>? ?? const <Object>[],
    finalVisualPolishValidator['conflicts'] as List<Object>? ??
        const <Object>[],
    readinessSurface['conflicts'] as List<Object>? ?? const <Object>[],
    omegaBridge['conflicts'] as List<Object>? ?? const <Object>[],
  ];
  for (final list in extractConflicts) {
    conflicts.addAll(list.map((e) => e.toString()));
  }

  final snapshot = _orderMapByKey(
    _sanitizeAsciiObject(<String, Object>{
      'final_polish_view': finalPolishView,
      'cohesion_view': cohesionView,
      'token_view': tokenView,
      'persona_mat_view': personaMatView,
      'final_coherence_view': finalCoherenceView,
      'final_visual_polish_validator': finalVisualPolishValidator,
      'readiness_surface': readinessSurface,
      'omega_bridge': omegaBridge,
    }),
  );

  void clampSnapshot(Map<String, Object> target) {
    for (final entry in target.entries.toList()) {
      final value = entry.value;
      if (value is num) {
        target[entry.key] = value.toDouble().clamp(0, 100);
      } else if (value is Map<String, Object>) {
        final nested = Map<String, Object>.from(value);
        clampSnapshot(nested);
        target[entry.key] = nested;
      }
    }
  }

  final snapshotClamped = Map<String, Object>.from(snapshot);
  clampSnapshot(snapshotClamped);

  conflicts.sort();
  final ok = errors.isEmpty && conflicts.isEmpty;
  if (!ok) {
    drivers.addAll(conflicts);
    drivers.addAll(errors);
  }
  drivers.sort();

  strictFindings['final_visual_polish_gate'] =
      Map<String, Object>.unmodifiable({
        'final_visual_polish_ok': ok,
        'final_visual_polish_conflicts': List<String>.unmodifiable(conflicts),
        'final_visual_polish_drivers': List<String>.unmodifiable(drivers),
        'final_visual_polish_snapshot': snapshotClamped,
      });
  return strictFindings['final_visual_polish_gate'] as Map<String, Object>;
}

Map<String, Object> _checkFinalRegressionPlatformGate({
  required Map<String, Object> strictFindings,
  required Map<String, Object> gates,
  required List<String> errors,
}) {
  const requiredKeys = [
    'v4_final_cohesion_gate',
    'v4_token_final_verification_gate',
    'persona_v4_mat_final_gate',
    'final_visual_polish_gate',
    'xp_reward_final_gate',
    'xp_reward_persona_rpg_coaching_stability_gate',
    'final_xp_reward_consolidation_gate',
    'global_regression_sweep_gate',
  ];
  final missingSections = <String>[];
  final conflictFlags = <String>[];
  final drivers = <String>[];

  if (!_isAsciiMap(gates)) {
    errors.add('final_regression_platform_invalid_ascii');
  }

  for (final key in requiredKeys) {
    final value = gates[key];
    if (value is! Map || value.isEmpty) {
      missingSections.add(key);
      errors.add('final_regression_platform_missing');
      continue;
    }
    if (!_isAsciiMap(value)) {
      errors.add('final_regression_platform_invalid_ascii');
    }
    if (value['ok'] == false) conflictFlags.add('${key}_not_ok');
  }

  final snapshot = _orderMapByKey(_sanitizeAsciiObject(gates));

  final ok = errors.isEmpty && conflictFlags.isEmpty && missingSections.isEmpty;
  if (!ok) {
    drivers.addAll(errors);
    drivers.addAll(conflictFlags);
    drivers.addAll(missingSections);
  }
  conflictFlags.sort();
  missingSections.sort();
  drivers.sort();

  strictFindings['final_regression_platform_gate'] =
      Map<String, Object>.unmodifiable({
        'final_regression_platform_ok': ok,
        'missing_sections': List<String>.unmodifiable(missingSections),
        'conflict_flags': List<String>.unmodifiable(conflictFlags),
        'drivers': List<String>.unmodifiable(drivers),
        'snapshot': snapshot,
      });
  return strictFindings['final_regression_platform_gate']
      as Map<String, Object>;
}

Map<String, Object> _checkXpRewardFinalGate({
  required Map<String, Object> strictFindings,
  required Map<String, Object> xpRewardSurfaceGate,
  required Map<String, Object> xpCurveGate,
  required Map<String, Object> xpAlignmentGate,
  required Map<String, Object> xpRpgInterplayGate,
  required Map<String, Object> rpgFusion,
  required Map<String, Object> rpgSnapshot,
  required Map<String, Object> coachingSurface,
  required Map<String, Object> coachingDirectives,
  required Map<String, Object> personaSignals,
  required Map<String, Object> readinessSurface,
  required Map<String, Object> finalCoherenceView,
  required List<String> errors,
}) {
  final conflicts = <String>[];
  final drivers = <String>[];

  final snapshot = {
    'xp_reward_surface_gate': xpRewardSurfaceGate,
    'xp_curve_gate': xpCurveGate,
    'xp_alignment_gate': xpAlignmentGate,
    'xp_rpg_interplay_gate': xpRpgInterplayGate,
    'rpg_fusion': rpgFusion,
    'rpg_snapshot': rpgSnapshot,
    'coaching_surface': coachingSurface,
    'coaching_directives': coachingDirectives,
    'persona_signals': personaSignals,
    'readiness_surface': readinessSurface,
    'final_coherence_view': finalCoherenceView,
  };

  if (!_isAsciiMap(snapshot)) {
    errors.add('xp_reward_final_invalid_ascii');
  }

  for (final entry in snapshot.entries) {
    final value = entry.value;
    if (value.isEmpty) {
      errors.add('xp_reward_final_missing');
      conflicts.add('missing_${entry.key}');
    } else if (!_isAsciiMap(value)) {
      errors.add('xp_reward_final_invalid_ascii');
    }
  }

  final rewardSurface =
      xpRewardSurfaceGate['reward_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  for (final v in rewardSurface.values) {
    if (v is num && (v.toDouble() < 0 || v.toDouble() > 3.0)) {
      errors.add('xp_reward_final_out_of_range');
      break;
    }
  }
  final personaSurface =
      xpRewardSurfaceGate['persona_surface_modifiers']
          as Map<String, Object>? ??
      const <String, Object>{};
  for (final v in personaSurface.values) {
    if (v is num && (v.toDouble() < -1.0 || v.toDouble() > 1.0)) {
      errors.add('xp_reward_final_out_of_range');
      break;
    }
  }
  final xpSurface =
      xpRewardSurfaceGate['xp_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  for (final v in xpSurface.values) {
    if (v is num && (v.toDouble() < 0 || v.toDouble() > 500)) {
      errors.add('xp_reward_final_out_of_range');
      break;
    }
  }
  final weights = xpCurveGate['weights'] as List<Object>? ?? const <Object>[];
  for (final w in weights.whereType<num>()) {
    if (w.toDouble() < 0 || w.toDouble() > 10) {
      errors.add('xp_reward_final_out_of_range');
      break;
    }
  }
  final eff = (rpgFusion['fusion'] as Map?)?['effective_power'] as num? ?? 0.0;
  if (eff < 0 || eff > 200) {
    errors.add('xp_reward_final_out_of_range');
  }
  final soft = (rpgSnapshot['soft_progress'] as num?)?.toDouble() ?? 0.0;
  if (soft < 0 || soft > 1) {
    errors.add('xp_reward_final_out_of_range');
  }

  final alignmentOk = xpAlignmentGate['persona_reward_modifiers'] is Map;
  if (!alignmentOk) conflicts.add('alignment_missing');

  final interplayPower = xpRpgInterplayGate['effective_power'] as num? ?? eff;
  if (interplayPower.toDouble() < 0 || interplayPower.toDouble() > 200) {
    errors.add('xp_reward_final_out_of_range');
  }
  if (interplayPower.toDouble() < eff * 0.5 && eff > 0) {
    conflicts.add('interplay_power_mismatch');
  }

  final readinessOk = readinessSurface['ok'] == true;
  if (!readinessOk) conflicts.add('readiness_not_ok');
  final coherenceOk = finalCoherenceView['ok'] == true;
  if (!coherenceOk) conflicts.add('coherence_not_ok');

  final personaPressure =
      (personaSignals['pressure'] as num?)?.toDouble() ?? 0.0;
  if (personaPressure.abs() > 2.0) {
    errors.add('xp_reward_final_out_of_range');
  }

  final coachingOrderOk =
      coachingDirectives.isNotEmpty && coachingSurface.isNotEmpty;
  if (!coachingOrderOk) conflicts.add('coaching_missing');

  final orderedSnapshot = _orderMapByKey(_sanitizeAsciiObject(snapshot));

  conflicts.sort();
  final ok = errors.isEmpty && conflicts.isEmpty;
  if (!ok) {
    drivers.addAll(conflicts);
    drivers.addAll(errors);
  }
  drivers.sort();

  strictFindings['xp_reward_final_gate'] = Map<String, Object>.unmodifiable({
    'xp_reward_final_ok': ok,
    'xp_reward_final_conflicts': List<String>.unmodifiable(conflicts),
    'xp_reward_final_drivers': List<String>.unmodifiable(drivers),
    'xp_reward_final_snapshot': orderedSnapshot,
  });
  return strictFindings['xp_reward_final_gate'] as Map<String, Object>;
}

Map<String, Object> _checkStrictCrossDomain(
  Map<String, Object> strictFindings,
  List<String> errors,
) {
  final result = <String, Object>{};

  final personaUx =
      strictFindings['persona_signals'] as Map<String, Object>? ??
      const <String, Object>{};
  final coachingSurface =
      strictFindings['coaching_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  final mat =
      (strictFindings['v4_strict_cohesion_consolidation']
              as Map<String, Object>?)
          ?.cast<String, Object>() ??
      const <String, Object>{};
  final snapshots =
      mat['snapshots'] as Map<String, Object>? ?? const <String, Object>{};
  final v4Cohesion = strictFindings['v4_strict_cohesion_consolidation'] is Map
      ? ((strictFindings['v4_strict_cohesion_consolidation'] as Map)['cohesion']
                as Map<String, Object>? ??
            const <String, Object>{})
      : const <String, Object>{};
  final v4Polish = strictFindings['v4_strict_cohesion_consolidation'] is Map
      ? ((strictFindings['v4_strict_cohesion_consolidation'] as Map)['polish']
                as Map<String, Object>? ??
            const <String, Object>{})
      : const <String, Object>{};
  final rewardSurface =
      strictFindings['xp_reward_surface_gate'] as Map<String, Object>? ??
      const <String, Object>{};
  final reward =
      rewardSurface['reward_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  final weights =
      (strictFindings['xp_curve_gate'] as Map<String, Object>?)?['weights']
          as List<Object?>? ??
      const <Object?>{};
  final rpgFusion =
      strictFindings['rpg_gate'] as Map<String, Object>? ??
      const <String, Object>{};
  final eff = (rpgFusion['fusion'] as Map?)?['effective_power'] as num? ?? 0.0;

  if (!_isAsciiMap(personaUx) ||
      !_isAsciiMap(coachingSurface) ||
      !_isAsciiMap(v4Polish) ||
      !_isAsciiMap(reward) ||
      !_isAsciiMap(snapshots)) {
    errors.add('strict_cross_domain_ascii');
  }

  if (personaUx.isNotEmpty && snapshots.isNotEmpty) {
    final title = personaUx.keys.isNotEmpty ? personaUx.keys.first : '';
    if (!snapshots.keys.any((k) => k.toString().contains(title))) {
      errors.add('strict_cross_domain_persona_mat');
    }
  }

  if (v4Cohesion['ok'] == true && v4Polish.isEmpty) {
    errors.add('strict_cross_domain_polish_cohesion');
  }

  if (weights.isNotEmpty && reward.isNotEmpty) {
    final avgWeight =
        weights
            .whereType<num>()
            .map((e) => e.toDouble())
            .fold<double>(0, (a, b) => a + b) /
        (weights.whereType<num>().isNotEmpty
            ? weights.whereType<num>().length
            : 1);
    final action = (reward['action_buttons'] as num?)?.toDouble() ?? 0.0;
    final expectedMin = avgWeight * 0.5;
    final expectedMax = avgWeight * 2.0 + eff * 0.01;
    if (action < expectedMin || action > expectedMax) {
      errors.add('strict_cross_domain_reward_rpg');
    }
  }

  if (coachingSurface.isNotEmpty && personaUx.isNotEmpty) {
    final personaKeys = personaUx.keys.toSet();
    final coachingKeys = coachingSurface.keys.toSet();
    if (personaKeys.intersection(coachingKeys).isEmpty) {
      errors.add('strict_cross_domain_coaching_persona');
    }
  }

  result['persona'] = personaUx;
  result['snapshots'] = snapshots;
  result['polish'] = v4Polish;
  result['reward_surface'] = reward;
  result['weights'] = weights;
  result['effective_power'] = eff;
  result['coaching_surface'] = coachingSurface;
  strictFindings['strict_cross_domain'] = Map<String, Object>.unmodifiable(
    result,
  );
  return strictFindings['strict_cross_domain'] as Map<String, Object>;
}

void _checkFinalStabilityConsolidationGate({
  required Map<String, Object> strictFindings,
  required Map<String, Object?> v4Qa,
  required Map<String, Object?> v4Cohesion,
  required Map<String, Object?> v4Polish,
  required Map<String, Object?> personaUX,
  required List<String> errors,
}) {
  final domains = <String, Object?>{
    'v4_qa': v4Qa,
    'v4_cohesion': v4Cohesion,
    'v4_polish': v4Polish,
    'persona_ux': personaUX,
    'xp_reward_gate': strictFindings['xp_reward_gate'],
    'xp_reward_surface_gate': strictFindings['xp_reward_surface_gate'],
    'xp_curve_gate': strictFindings['xp_curve_gate'],
    'xp_persona_alignment_gate': strictFindings['xp_persona_alignment_gate'],
    'xp_reward_rpg_interplay_gate':
        strictFindings['xp_reward_rpg_interplay_gate'],
    'rpg_gate': strictFindings['rpg_gate'],
    'rpg_consistency_gate': strictFindings['rpg_consistency_gate'],
    'rpg_stability_snapshot_gate':
        strictFindings['rpg_stability_snapshot_gate'],
    'persona_signals': strictFindings['persona_signals'],
    'persona_aggregator': strictFindings['persona_aggregator'],
    'persona_advice': strictFindings['persona_advice'],
    'persona_explanation': strictFindings['persona_explanation'],
    'persona_heuristics': strictFindings['persona_heuristics'],
    'persona_hooks': strictFindings['persona_hooks'],
    'persona_final': strictFindings['persona_final'],
    'coaching_directives': strictFindings['coaching_directives'],
    'coaching_style': strictFindings['coaching_style'],
    'coaching_filters': strictFindings['coaching_filters'],
    'coaching_multi_stage': strictFindings['coaching_multi_stage'],
    'coaching_surface': strictFindings['coaching_surface'],
    'marketing_telemetry': strictFindings['marketing_telemetry'],
    'funnel_retention_visual_qa_gate':
        strictFindings['funnel_retention_visual_qa_gate'],
    'marketing_analytics_polish_gate':
        strictFindings['marketing_analytics_polish_gate'],
  };

  final missingDomain = domains.entries.any(
    (e) => e.value == null || (e.value is Map && (e.value as Map).isEmpty),
  );
  if (missingDomain) errors.add('final_stability_gate_missing_domain');

  final asciiViolation = domains.entries.any((e) {
    final v = e.value;
    if (v is Map) return !_isAsciiMap(v);
    if (v is Iterable) {
      for (final x in v) {
        if (x is String && !_isAsciiString(x)) return true;
      }
    }
    return false;
  });
  if (asciiViolation) errors.add('final_stability_gate_ascii_violation');

  bool _hasOk(Object? o) {
    if (o is Map && o.containsKey('ok')) {
      return o['ok'] == true;
    }
    return false;
  }

  final okCount = [
    v4Cohesion,
    strictFindings['xp_reward_gate'],
    strictFindings['xp_curve_gate'],
    strictFindings['rpg_consistency_gate'],
    strictFindings['marketing_analytics_polish_gate'],
  ].where(_hasOk).length;
  if (okCount == 0) errors.add('final_stability_gate_empty_map');

  final v4Conflict =
      v4Cohesion['ok'] == true &&
      (v4Qa['v4_delta_report'] == null || v4Polish.isEmpty);
  if (v4Conflict) errors.add('final_stability_gate_conflict');

  final personaFusion = strictFindings['persona_aggregator'];
  final rpgFusion = strictFindings['rpg_gate'];
  final rpgStable = strictFindings['rpg_stability_snapshot_gate'];
  if (personaFusion is Map &&
      rpgFusion is Map &&
      rpgStable is Map &&
      rpgStable['snapshot'] is Map) {
    final traits = (rpgFusion['fusion'] as Map?) ?? const {};
    if (traits.isEmpty) errors.add('final_stability_gate_conflict');
  }

  final marketing = strictFindings['marketing_analytics_polish_gate'];
  if (marketing is Map) {
    final surface =
        marketing['surface'] as Map<String, Object?>? ??
        const <String, Object?>{};
    if (surface['analytics_ok'] != true) {
      errors.add('final_stability_gate_conflict');
    }
  }

  strictFindings['final_stability_consolidation_gate'] =
      Map<String, Object>.unmodifiable({'domains': domains});
}

List<String> _orderedGateSequenceV1(List<String> gateNames) => gateNames;

void _assertAsciiMapV1(
  String gateName,
  Map<dynamic, dynamic> m,
  List<String> findings,
) {
  for (final entry in m.entries) {
    if (entry.key is! String || !_isAsciiString(entry.key as String)) {
      findings.add('${gateName}_invalid_ascii_key');
      break;
    }
    final value = entry.value;
    if (value is String && !_isAsciiString(value)) {
      findings.add('${gateName}_invalid_ascii_value');
      break;
    }
    if (value is Map && !_isAsciiMap(value)) {
      findings.add('${gateName}_invalid_ascii_value');
      break;
    }
    if (value is Iterable) {
      for (final v in value) {
        if (v is String && !_isAsciiString(v)) {
          findings.add('${gateName}_invalid_ascii_value');
          return;
        }
        if (v is Map && !_isAsciiMap(v)) {
          findings.add('${gateName}_invalid_ascii_value');
          return;
        }
      }
    }
  }
}

void _assertShapeNonEmptyV1(
  String gateName,
  Map<dynamic, dynamic> m,
  List<String> findings,
) {
  if (m.isEmpty) {
    findings.add('${gateName}_empty');
    return;
  }
  for (final entry in m.entries) {
    if (entry.value == null) {
      findings.add('${gateName}_null_value');
      break;
    }
  }
  final requiredKeys = <String, String>{
    'marketing_telemetry_gate': 'funnel',
    'funnel_retention_qa_gate': 'funnel_surface_ok',
    'marketing_analytics_polish_gate': 'analytics_ok',
    'xp_reward_gate': 'xp_curve',
    'xp_reward_surface_gate': 'xp_surface',
    'xp_curve_gate': 'levels',
    'xp_persona_alignment_gate': 'persona_reward_modifiers',
    'final_xp_reward_coherence_gate': 'xp_curve',
    'xp_reward_persona_rpg_coaching_stability_gate': 'xp_curve',
    'final_xp_reward_consolidation_gate': 'xp_curve',
    'rpg_gate': 'level',
    'rpg_consistency_gate': 'fusion',
    'rpg_stability_snapshot_gate': 'stable',
    'adaptive_reward_gate': 'reward_surface',
    'xp_reward_rpg_interplay_gate': 'level',
    'final_stability_consolidation_gate': 'domains',
    'strict_cohesion_gate': 'tokens',
    'strict_cross_domain_gate': 'persona',
    'final_cross_domain_polish_gate': 'cohesion_view',
    'global_regression_sweep_gate': 'visual',
    'final_regression_consolidation_gate': 'final_regression_snapshot',
    'v4_final_cohesion_gate': 'v4_final_cohesion_snapshot',
    'v4_token_final_verification_gate': 'v4_token_final_snapshot',
    'persona_v4_mat_final_gate': 'persona_v4_mat_snapshot',
    'final_visual_polish_gate': 'final_visual_polish_snapshot',
    'xp_reward_final_gate': 'xp_reward_final_snapshot',
    'final_regression_platform_gate': 'snapshot',
  };
  final req = requiredKeys[gateName];
  if (req != null && !m.containsKey(req)) {
    findings.add('${gateName}_missing_key');
  }
}

void _assertCrossGateConsistencyV1(
  Map<String, Map<String, Object>> gateOutputs,
  List<String> findings,
) {
  final personaMaps = [
    gateOutputs['persona'] ?? const <String, Object>{},
    gateOutputs['coaching'] ?? const <String, Object>{},
    gateOutputs['fusion'] ?? const <String, Object>{},
  ];
  final personaOk = personaMaps.any((m) => m['ok'] == true);
  if (personaOk && personaMaps.any((m) => m.isEmpty)) {
    findings.add('cross_gate_inconsistent_persona');
  }

  final rpg = gateOutputs['rpg_gate'] ?? const <String, Object>{};
  final rpgCons =
      gateOutputs['rpg_consistency_gate'] ?? const <String, Object>{};
  final rpgSnap =
      gateOutputs['rpg_stability_snapshot_gate'] ?? const <String, Object>{};
  final snap =
      rpgSnap['snapshot'] as Map<String, Object?>? ?? const <String, Object?>{};
  if (snap['stable'] == true) {
    final drivers = snap['drivers'] as List<Object>? ?? const <Object>[];
    if (drivers.isEmpty) findings.add('cross_gate_inconsistent_rpg');
  }
  if (rpg.isEmpty || rpgCons.isEmpty) {
    findings.add('cross_gate_inconsistent_rpg');
  }

  final xpGate = gateOutputs['xp_reward_gate'] ?? const <String, Object>{};
  final xpSurface =
      gateOutputs['xp_reward_surface_gate'] ?? const <String, Object>{};
  final xpCurve = gateOutputs['xp_curve_gate'] ?? const <String, Object>{};
  final xpInterplay =
      gateOutputs['xp_reward_rpg_interplay_gate'] ?? const <String, Object>{};
  final xpSurfaceMap =
      xpSurface['xp_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  final rewardSurfaceMap =
      xpSurface['reward_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  if (xpGate.isEmpty || xpSurfaceMap.isEmpty || rewardSurfaceMap.isEmpty) {
    findings.add('cross_gate_inconsistent_xp');
  }
  final xpValues = xpSurfaceMap.values.whereType<num>().map(
    (e) => e.toDouble(),
  );
  if (xpValues.any((v) => v <= 0)) {
    findings.add('cross_gate_inconsistent_xp');
  }
  final eff = xpInterplay['effective_power'] as num? ?? 0;
  if (eff > 0 && rewardSurfaceMap.values.whereType<num>().any((v) => v <= 0)) {
    findings.add('cross_gate_inconsistent_xp');
  }
  if (xpCurve.isEmpty) {
    findings.add('cross_gate_inconsistent_xp');
  }

  final v4Polish = gateOutputs['v4_polish'] ?? const <String, Object>{};
  final v4Cohesion = gateOutputs['v4_cohesion'] ?? const <String, Object>{};
  final v4Tokens = gateOutputs['v4_tokens'] ?? const <String, Object>{};
  if (v4Cohesion['ok'] == true) {
    if (v4Polish.isEmpty || v4Tokens.isEmpty) {
      findings.add('cross_gate_inconsistent_v4');
    }
  }
}

Map<String, Object> _buildDeterministicConflictExplainerV1(
  Map<String, Object> strictFindings,
) {
  List<String> _collect(String key) {
    final value = strictFindings[key];
    if (value is Map<String, Object>) {
      return value.keys.toList()..sort();
    }
    return const <String>[];
  }

  final domains = <String, List<String>>{
    'persona': _collect('persona_signals'),
    'coaching': _collect('persona_final'),
    'v4': _collect('v4_strict_cohesion_consolidation'),
    'xp_reward': [
      ..._collect('xp_reward_gate'),
      ..._collect('xp_reward_surface_gate'),
      ..._collect('xp_curve_gate'),
    ],
    'rpg': [
      ..._collect('rpg_gate'),
      ..._collect('rpg_consistency_gate'),
      ..._collect('rpg_stability_snapshot_gate'),
    ],
    'stability': _collect('final_stability_consolidation_gate'),
    'cross_gate': _collect('xp_reward_rpg_interplay_gate'),
  };

  final totalIssues = domains.values.fold<int>(
    0,
    (sum, list) => sum + list.length,
  );
  final summary = '$totalIssues issues across persona/v4/xp domains';

  final mappedDomains = domains.map(
    (k, v) => MapEntry(k, List<String>.unmodifiable(v)),
  );

  return Map<String, Object>.unmodifiable({
    'summary': summary,
    'domains': Map<String, Object>.unmodifiable(mappedDomains),
  });
}

List<String> _buildGateAttemptIssues(
  Map<String, Object> raw,
  List<String> gateErrors,
) {
  final issues = <String>[...raw.keys.map((e) => e.toString()), ...gateErrors]
    ..sort();
  return List<String>.unmodifiable(issues);
}

Map<String, Object> _buildGateResults({
  required List<String> ordered,
  required Map<String, List<Map<String, Object>>> gateAttempts,
  required bool autoFix,
}) {
  final gateResults = <String, Object>{};
  for (final gate in ordered) {
    final attempts = gateAttempts[gate] ?? const <Map<String, Object>>[];
    if (autoFix && attempts.length > 1) {
      final normalizedAttempts = attempts
          .map(
            (attempt) => Map<String, Object>.unmodifiable({
              'raw': Map<String, Object>.unmodifiable(
                attempt['raw'] as Map<String, Object>? ??
                    const <String, Object>{},
              ),
              'issues': List<String>.unmodifiable(
                attempt['issues'] as List<String>? ?? const <String>[],
              ),
            }),
          )
          .toList(growable: false);
      final lastIssues =
          attempts.last['issues'] as List<String>? ?? const <String>[];
      gateResults[gate] = Map<String, Object>.unmodifiable({
        'ok': lastIssues.isEmpty,
        'attempts': List<Map<String, Object>>.unmodifiable(normalizedAttempts),
      });
      continue;
    }
    final attempt = attempts.isNotEmpty
        ? attempts.last
        : const <String, Object>{};
    final raw =
        attempt['raw'] as Map<String, Object>? ?? const <String, Object>{};
    final issues = attempt['issues'] as List<String>? ?? const <String>[];
    gateResults[gate] = Map<String, Object>.unmodifiable({
      'ok': issues.isEmpty,
      'issues': List<String>.unmodifiable(issues),
      'raw': Map<String, Object>.unmodifiable(raw),
    });
  }
  return gateResults;
}

Map<String, Object> _attemptAutoFixV1(
  String gateName,
  Map<String, Object> rawGateOutput,
) {
  final sanitized = _sanitizeAsciiObject(rawGateOutput);
  final defaults = _gateDefaultShapeV1(gateName);
  final withDefaults = Map<String, Object>.from(sanitized);
  final defaultKeys = defaults.keys.toList()..sort();
  for (final key in defaultKeys) {
    withDefaults.putIfAbsent(key, () => defaults[key]!);
  }
  final clamped = _clampGateNumbersV1(gateName, withDefaults);
  return Map<String, Object>.unmodifiable(_orderMapByKey(clamped));
}

Map<String, Object> _gateDefaultShapeV1(String gateName) {
  switch (gateName) {
    case 'marketing_telemetry_gate':
      return const <String, Object>{
        'funnel': <String, Object>{'stage': 0},
        'engagement': <String, Object>{
          'delta_accuracy': 0.0,
          'delta_speed': 0.0,
          'friction': 0.0,
        },
        'persona_influence': <String, Object>{
          'persona_signal': '',
          'coaching_style': '',
        },
      };
    case 'funnel_retention_qa_gate':
      return const <String, Object>{
        'funnel_surface_ok': false,
        'retention_surface_ok': false,
        'missing_keys': <String>[],
        'warnings': <String>[],
      };
    case 'marketing_analytics_polish_gate':
      return const <String, Object>{
        'analytics_ok': false,
        'marketing_score': 0,
        'missing_keys': <String>[],
        'warnings': <String>[],
        'drivers': <String>[],
      };
    case 'xp_reward_gate':
      return const <String, Object>{
        'xp_curve': <String, Object>{'linear': 0, 'mid': 0, 'late': 0},
        'reward_weights': <String, Object>{
          'correct': 1.0,
          'streak': 1.0,
          'difficulty': 1.0,
        },
        'persona_modifiers': <String, Object>{
          'focus': 0.0,
          'pressure': 0.0,
          'tone': 0.0,
          'engagement': 0.0,
        },
      };
    case 'xp_reward_surface_gate':
      return const <String, Object>{
        'xp_surface': <String, Object>{
          'table': 0,
          'hole_cards': 0,
          'action_buttons': 0,
        },
        'reward_surface': <String, Object>{
          'table': 1.0,
          'hole_cards': 1.0,
          'action_buttons': 1.0,
        },
        'persona_surface_modifiers': <String, Object>{
          'table': 0.0,
          'hole_cards': 0.0,
          'action_buttons': 0.0,
        },
      };
    case 'xp_curve_gate':
      return const <String, Object>{
        'levels': <int>[0, 100, 200, 400, 800],
        'weights': <double>[1.0, 1.2, 1.4, 1.6, 1.8],
      };
    case 'xp_persona_alignment_gate':
      return const <String, Object>{
        'persona_reward_modifiers': <String, Object>{
          'focus': 0.0,
          'pressure': 0.0,
          'engagement': 0.0,
        },
        'xp_surface_table': 0.0,
        'reward_surface_table': 0.0,
      };
    case 'final_xp_reward_consolidation_gate':
      return const <String, Object>{
        'xp_curve': <String, Object>{
          'levels': <int>[0, 100, 200],
          'weights': <double>[1.0, 1.0, 1.0],
        },
        'xp_reward_surface_gate': <String, Object>{
          'reward_surface': <String, Object>{'table': 1.0},
          'persona_surface_modifiers': <String, Object>{'table': 0.0},
          'xp_surface': <String, Object>{'table': 0},
        },
        'rpg_fusion': <String, Object>{
          'fusion': <String, Object>{'effective_power': 0},
        },
        'rpg_snapshot': <String, Object>{'soft_progress': 0.0},
        'coaching_surface': <String, Object>{'table': 1},
        'coaching_directives': <String, Object>{'priority': 1},
        'v4_snapshot': <String, Object>{'table': 1},
        'persona_signals': <String, Object>{'pressure': 0.0},
      };
    case 'rpg_gate':
    case 'rpg_consistency_gate':
      return const <String, Object>{
        'level': 1,
        'xp': 0,
        'xp_to_next': 0,
        'soft_progress': 0.0,
        'traits': <String, Object>{},
        'fusion': <String, Object>{'effective_power': 0.0},
        'summary': '',
      };
    case 'rpg_stability_snapshot_gate':
      return const <String, Object>{
        'level': 1,
        'soft_progress': 0.0,
        'traits': <String, Object>{},
        'stable': false,
        'drivers': <String>[],
      };
    case 'xp_reward_rpg_interplay_gate':
      return const <String, Object>{
        'level': 1,
        'effective_power': 0.0,
        'xp_surface': <String, Object>{
          'table': 0,
          'hole_cards': 0,
          'action_buttons': 0,
        },
        'reward_surface': <String, Object>{
          'table': 1.0,
          'hole_cards': 1.0,
          'action_buttons': 1.0,
        },
        'persona_surface_modifiers': <String, Object>{
          'table': 0.0,
          'hole_cards': 0.0,
          'action_buttons': 0.0,
        },
        'stable': false,
      };
    case 'adaptive_reward_gate':
      return const <String, Object>{
        'xp_curve': <String, Object>{
          'levels': <int>[0, 100, 200],
          'weights': <double>[1.0, 1.0, 1.0],
        },
        'reward_surface': <String, Object>{
          'table': 1.0,
          'hole_cards': 1.0,
          'action_buttons': 1.0,
        },
        'persona_surface_modifiers': <String, Object>{
          'table': 0.0,
          'hole_cards': 0.0,
          'action_buttons': 0.0,
        },
        'effective_power': 0.0,
        'rpg_snapshot': <String, Object>{'stable': false},
      };
    case 'final_stability_consolidation_gate':
      return const <String, Object>{'domains': <String, Object>{}};
    case 'strict_cohesion_gate':
      return const <String, Object>{'tokens': <String, Object>{}};
    case 'strict_cross_domain_gate':
      return const <String, Object>{
        'persona': <String, Object>{'id': ''},
        'snapshots': <String, Object>{'v4': <String, Object>{}},
        'polish': <String, Object>{'color': ''},
        'reward_surface': <String, Object>{'table': 0.0},
        'weights': <Object>[1.0],
        'effective_power': 0.0,
        'coaching_surface': <String, Object>{'prompt': ''},
      };
    case 'final_cross_domain_polish_gate':
      return const <String, Object>{
        'cohesion_view': <String, Object>{},
        'token_view': <String, Object>{},
        'polish_view': <String, Object>{},
        'persona': <String, Object>{},
        'coaching': <String, Object>{},
        'marketing': <String, Object>{},
        'rpg_snapshot': <String, Object>{},
        'xp_reward_surface_gate': <String, Object>{},
        'ok': false,
      };
    case 'final_regression_consolidation_gate':
      return const <String, Object>{
        'final_regression_ok': false,
        'final_regression_conflicts': <String>[],
        'final_regression_drivers': <String>[],
        'final_regression_snapshot': <String, Object>{},
      };
    case 'v4_final_cohesion_gate':
      return const <String, Object>{
        'v4_final_cohesion_ok': false,
        'v4_final_cohesion_conflicts': <String>[],
        'v4_final_cohesion_drivers': <String>[],
        'v4_final_cohesion_snapshot': <String, Object>{},
      };
    case 'v4_token_final_verification_gate':
      return const <String, Object>{
        'v4_token_final_ok': false,
        'v4_token_final_conflicts': <String>[],
        'v4_token_final_drivers': <String>[],
        'v4_token_final_snapshot': <String, Object>{},
      };
    case 'persona_v4_mat_final_gate':
      return const <String, Object>{
        'persona_v4_mat_ok': false,
        'persona_v4_mat_conflicts': <String>[],
        'persona_v4_mat_drivers': <String>[],
        'persona_v4_mat_snapshot': <String, Object>{},
      };
    case 'final_visual_polish_gate':
      return const <String, Object>{
        'final_visual_polish_ok': false,
        'final_visual_polish_conflicts': <String>[],
        'final_visual_polish_drivers': <String>[],
        'final_visual_polish_snapshot': <String, Object>{},
      };
    case 'xp_reward_final_gate':
      return const <String, Object>{
        'xp_reward_final_ok': false,
        'xp_reward_final_conflicts': <String>[],
        'xp_reward_final_drivers': <String>[],
        'xp_reward_final_snapshot': <String, Object>{},
        'xp_reward_surface_gate': <String, Object>{
          'xp_surface': <String, Object>{
            'table': 0,
            'hole_cards': 0,
            'action_buttons': 0,
          },
          'reward_surface': <String, Object>{
            'table': 1.0,
            'hole_cards': 1.0,
            'action_buttons': 1.0,
          },
          'persona_surface_modifiers': <String, Object>{
            'table': 0.0,
            'hole_cards': 0.0,
            'action_buttons': 0.0,
          },
        },
        'xp_curve_gate': <String, Object>{
          'levels': <int>[0, 100, 200],
          'weights': <double>[1.0, 1.0, 1.0],
        },
        'xp_alignment_gate': <String, Object>{
          'persona_reward_modifiers': <String, Object>{
            'pressure': 0.0,
            'focus': 0.0,
          },
        },
        'xp_rpg_interplay_gate': <String, Object>{'effective_power': 0.0},
        'rpg_fusion': <String, Object>{
          'fusion': <String, Object>{'effective_power': 0.0},
        },
        'rpg_snapshot': <String, Object>{'soft_progress': 0.0},
        'coaching_surface': <String, Object>{'table': 0},
        'coaching_directives': <String, Object>{'priority': 1},
        'persona_signals': <String, Object>{'pressure': 0.0},
        'readiness_surface': <String, Object>{'ok': false},
        'final_coherence_view': <String, Object>{'ok': false},
      };
    case 'final_regression_platform_gate':
      return const <String, Object>{
        'final_regression_platform_ok': false,
        'missing_sections': <String>[],
        'conflict_flags': <String>[],
        'drivers': <String>[],
        'snapshot': <String, Object>{},
      };
  }
  return const <String, Object>{};
}

Map<String, Object> _clampGateNumbersV1(
  String gateName,
  Map<String, Object> input,
) {
  final map = Map<String, Object>.from(input);

  Object _coerceNumeric(num value, double min, double max) {
    final clamped = value.toDouble().clamp(min, max);
    if (value is int && clamped.roundToDouble() == clamped) {
      return clamped.toInt();
    }
    return clamped;
  }

  void clampField(
    Map<String, Object> target,
    String key,
    double min,
    double max,
  ) {
    final value = target[key];
    if (value is num) target[key] = _coerceNumeric(value, min, max);
  }

  void clampList(
    Map<String, Object> target,
    String key,
    double min,
    double max,
  ) {
    final value = target[key];
    if (value is List) {
      target[key] = value
          .map<Object>((v) => v is num ? _coerceNumeric(v, min, max) : v)
          .toList();
    }
  }

  switch (gateName) {
    case 'marketing_telemetry_gate':
      final funnel = Map<String, Object>.from(
        map['funnel'] as Map<String, Object>? ?? const <String, Object>{},
      );
      clampField(funnel, 'stage', 0, 10);
      map['funnel'] = funnel;
      final engagement = Map<String, Object>.from(
        map['engagement'] as Map<String, Object>? ?? const <String, Object>{},
      );
      for (final key in ['delta_accuracy', 'delta_speed', 'friction']) {
        clampField(engagement, key, -1.0, 1.0);
      }
      map['engagement'] = engagement;
      break;
    case 'marketing_analytics_polish_gate':
      clampField(map, 'marketing_score', 0, 100);
      break;
    case 'xp_reward_gate':
      final xpCurve = Map<String, Object>.from(
        map['xp_curve'] as Map<String, Object>? ?? const <String, Object>{},
      );
      for (final key in ['linear', 'mid', 'late']) {
        clampField(xpCurve, key, 0, 500);
      }
      map['xp_curve'] = xpCurve;
      final reward = Map<String, Object>.from(
        map['reward_weights'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in ['correct', 'streak', 'difficulty']) {
        clampField(reward, key, 0, 3);
      }
      map['reward_weights'] = reward;
      final persona = Map<String, Object>.from(
        map['persona_modifiers'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in ['focus', 'pressure', 'tone', 'engagement']) {
        clampField(persona, key, -1.0, 1.0);
      }
      map['persona_modifiers'] = persona;
      break;
    case 'xp_reward_surface_gate':
      final xpSurface = Map<String, Object>.from(
        map['xp_surface'] as Map<String, Object>? ?? const <String, Object>{},
      );
      for (final key in ['table', 'hole_cards', 'action_buttons']) {
        clampField(xpSurface, key, 0, 500);
      }
      map['xp_surface'] = xpSurface;

      final rewardSurface = Map<String, Object>.from(
        map['reward_surface'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in ['table', 'hole_cards', 'action_buttons']) {
        clampField(rewardSurface, key, 0, 3);
      }
      map['reward_surface'] = rewardSurface;

      final personaSurface = Map<String, Object>.from(
        map['persona_surface_modifiers'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in ['table', 'hole_cards', 'action_buttons']) {
        clampField(personaSurface, key, -1.0, 1.0);
      }
      map['persona_surface_modifiers'] = personaSurface;
      break;
    case 'xp_curve_gate':
      clampList(map, 'levels', 0, 100000);
      clampList(map, 'weights', 0, 10);
      break;
    case 'xp_persona_alignment_gate':
      final modifiers = Map<String, Object>.from(
        map['persona_reward_modifiers'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in ['focus', 'pressure', 'engagement']) {
        clampField(modifiers, key, -2.0, 2.0);
      }
      map['persona_reward_modifiers'] = modifiers;
      break;
    case 'rpg_gate':
    case 'rpg_consistency_gate':
      clampField(map, 'level', 1, 50);
      clampField(map, 'xp', 0, 1000000);
      clampField(map, 'xp_to_next', 0, 1000000);
      clampField(map, 'soft_progress', 0, 1);
      final fusion = Map<String, Object>.from(
        map['fusion'] as Map<String, Object>? ?? const <String, Object>{},
      );
      clampField(fusion, 'effective_power', 0, 100);
      map['fusion'] = fusion;
      final traits = Map<String, Object>.from(
        map['traits'] as Map<String, Object>? ?? const <String, Object>{},
      );
      const traitMax = 1.0;
      final traitMin = gateName == 'rpg_gate' ? 0.0 : -1.0;
      for (final entry in traits.entries.toList()) {
        final value = entry.value;
        if (value is num) {
          traits[entry.key] = _coerceNumeric(value, traitMin, traitMax);
        }
      }
      map['traits'] = traits;
      break;
    case 'rpg_stability_snapshot_gate':
      clampField(map, 'level', 1, 50);
      clampField(map, 'soft_progress', 0, 1);
      final traits = Map<String, Object>.from(
        map['traits'] as Map<String, Object>? ?? const <String, Object>{},
      );
      for (final entry in traits.entries.toList()) {
        final value = entry.value;
        if (value is num) {
          traits[entry.key] = _coerceNumeric(value, -1.0, 1.0);
        }
      }
      map['traits'] = traits;
      break;
    case 'xp_reward_rpg_interplay_gate':
      clampField(map, 'level', 0, 50);
      clampField(map, 'effective_power', 0, 100);
      final xpSurface = Map<String, Object>.from(
        map['xp_surface'] as Map<String, Object>? ?? const <String, Object>{},
      );
      for (final key in xpSurface.keys.toList()) {
        final value = xpSurface[key];
        if (value is num) {
          xpSurface[key] = _coerceNumeric(value, 0, 500);
        }
      }
      map['xp_surface'] = xpSurface;

      final rewardSurface = Map<String, Object>.from(
        map['reward_surface'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in rewardSurface.keys.toList()) {
        final value = rewardSurface[key];
        if (value is num) {
          rewardSurface[key] = _coerceNumeric(value, 0, 3);
        }
      }
      map['reward_surface'] = rewardSurface;

      final personaSurface = Map<String, Object>.from(
        map['persona_surface_modifiers'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in personaSurface.keys.toList()) {
        final value = personaSurface[key];
        if (value is num) {
          personaSurface[key] = _coerceNumeric(value, -1.0, 1.0);
        }
      }
      map['persona_surface_modifiers'] = personaSurface;
      break;
    case 'adaptive_reward_gate':
      final xpCurve = Map<String, Object>.from(
        map['xp_curve'] as Map<String, Object>? ?? const <String, Object>{},
      );
      clampList(xpCurve, 'levels', 0, 100000);
      clampList(xpCurve, 'weights', 0, 10);
      map['xp_curve'] = xpCurve;

      final rewardSurface = Map<String, Object>.from(
        map['reward_surface'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in rewardSurface.keys.toList()) {
        final value = rewardSurface[key];
        if (value is num) {
          rewardSurface[key] = _coerceNumeric(value, 0, 3);
        }
      }
      map['reward_surface'] = rewardSurface;

      final personaSurface = Map<String, Object>.from(
        map['persona_surface_modifiers'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in personaSurface.keys.toList()) {
        final value = personaSurface[key];
        if (value is num) {
          personaSurface[key] = _coerceNumeric(value, -1.0, 1.0);
        }
      }
      map['persona_surface_modifiers'] = personaSurface;

      clampField(map, 'effective_power', 0, 100);
      final snapshot = Map<String, Object>.from(
        map['rpg_snapshot'] as Map<String, Object>? ?? const <String, Object>{},
      );
      if (snapshot['stable'] is! bool) snapshot['stable'] = false;
      map['rpg_snapshot'] = snapshot;
      break;
    case 'final_xp_reward_coherence_gate':
      final xpCurve = Map<String, Object>.from(
        map['xp_curve'] as Map<String, Object>? ?? const <String, Object>{},
      );
      clampList(xpCurve, 'levels', 0, 100000);
      clampList(xpCurve, 'weights', 0, 10);
      map['xp_curve'] = xpCurve;

      final surfaceGate = Map<String, Object>.from(
        map['xp_reward_surface_gate'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in ['reward_surface', 'persona_surface_modifiers']) {
        final surf = Map<String, Object>.from(
          surfaceGate[key] as Map<String, Object>? ?? const <String, Object>{},
        );
        for (final entry in surf.entries.toList()) {
          final v = entry.value;
          if (v is num) {
            surf[entry.key] = _coerceNumeric(
              v,
              key == 'persona_surface_modifiers' ? -1.0 : 0.0,
              key == 'persona_surface_modifiers' ? 1.0 : 3.0,
            );
          }
        }
        surfaceGate[key] = surf;
      }
      map['xp_reward_surface_gate'] = surfaceGate;
      break;
    case 'xp_reward_persona_rpg_coaching_stability_gate':
      final xpCurve = Map<String, Object>.from(
        map['xp_curve'] as Map<String, Object>? ?? const <String, Object>{},
      );
      clampList(xpCurve, 'levels', 0, 100000);
      clampList(xpCurve, 'weights', 0, 10);
      map['xp_curve'] = xpCurve;

      final surfaceGate = Map<String, Object>.from(
        map['xp_reward_surface_gate'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in ['reward_surface', 'persona_surface_modifiers']) {
        final surf = Map<String, Object>.from(
          surfaceGate[key] as Map<String, Object>? ?? const <String, Object>{},
        );
        for (final entry in surf.entries.toList()) {
          final v = entry.value;
          if (v is num) {
            surf[entry.key] = _coerceNumeric(
              v,
              key == 'persona_surface_modifiers' ? -1.0 : 0.0,
              key == 'persona_surface_modifiers' ? 1.0 : 3.0,
            );
          }
        }
        surfaceGate[key] = surf;
      }
      final xpSurf = Map<String, Object>.from(
        surfaceGate['xp_surface'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final entry in xpSurf.entries.toList()) {
        final v = entry.value;
        if (v is num) xpSurf[entry.key] = _coerceNumeric(v, 0, 500);
      }
      surfaceGate['xp_surface'] = xpSurf;
      map['xp_reward_surface_gate'] = surfaceGate;
      break;
    case 'final_xp_reward_consolidation_gate':
      final xpCurve = Map<String, Object>.from(
        map['xp_curve'] as Map<String, Object>? ?? const <String, Object>{},
      );
      clampList(xpCurve, 'levels', 0, 100000);
      clampList(xpCurve, 'weights', 0, 10);
      map['xp_curve'] = xpCurve;

      final surfaceGate = Map<String, Object>.from(
        map['xp_reward_surface_gate'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in ['reward_surface', 'persona_surface_modifiers']) {
        final surf = Map<String, Object>.from(
          surfaceGate[key] as Map<String, Object>? ?? const <String, Object>{},
        );
        for (final entry in surf.entries.toList()) {
          final v = entry.value;
          if (v is num) {
            surf[entry.key] = _coerceNumeric(
              v,
              key == 'persona_surface_modifiers' ? -1.0 : 0.0,
              key == 'persona_surface_modifiers' ? 1.0 : 3.0,
            );
          }
        }
        surfaceGate[key] = surf;
      }
      final xpSurf = Map<String, Object>.from(
        surfaceGate['xp_surface'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final entry in xpSurf.entries.toList()) {
        final v = entry.value;
        if (v is num) xpSurf[entry.key] = _coerceNumeric(v, 0, 500);
      }
      surfaceGate['xp_surface'] = xpSurf;
      map['xp_reward_surface_gate'] = surfaceGate;

      final rpgFusion = Map<String, Object>.from(
        map['rpg_fusion'] as Map<String, Object>? ?? const <String, Object>{},
      );
      final fusion = Map<String, Object>.from(
        rpgFusion['fusion'] as Map<String, Object>? ?? const <String, Object>{},
      );
      clampField(fusion, 'effective_power', 0, 200);
      rpgFusion['fusion'] = fusion;
      map['rpg_fusion'] = rpgFusion;

      final rpgSnapshot = Map<String, Object>.from(
        map['rpg_snapshot'] as Map<String, Object>? ?? const <String, Object>{},
      );
      clampField(rpgSnapshot, 'soft_progress', 0, 1);
      map['rpg_snapshot'] = rpgSnapshot;
      break;
    case 'strict_cross_domain_gate':
      clampField(map, 'effective_power', 0, 100);
      final rewardSurface = Map<String, Object>.from(
        map['reward_surface'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in rewardSurface.keys.toList()) {
        final value = rewardSurface[key];
        if (value is num) {
          rewardSurface[key] = _coerceNumeric(value, 0, 3);
        }
      }
      map['reward_surface'] = rewardSurface;
      final weights = map['weights'];
      if (weights is List) {
        map['weights'] = weights
            .map<Object>((w) => w is num ? _coerceNumeric(w, 0, 10) : w)
            .toList();
      }
      break;
    case 'final_cross_domain_polish_gate':
      final polishView = Map<String, Object>.from(
        map['polish_view'] as Map<String, Object>? ?? const <String, Object>{},
      );
      clampField(polishView, 'marketing_score', 0, 100);
      map['polish_view'] = polishView;

      final xpSurface = Map<String, Object>.from(
        map['xp_reward_surface_gate'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final entry in xpSurface.entries.toList()) {
        final v = entry.value;
        if (v is num) {
          xpSurface[entry.key] = _coerceNumeric(v, 0, 3);
        }
      }
      map['xp_reward_surface_gate'] = xpSurface;
      break;
    case 'v4_final_cohesion_gate':
      final snapshot = Map<String, Object>.from(
        map['v4_final_cohesion_snapshot'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final entry in snapshot.entries.toList()) {
        final value = entry.value;
        if (value is Map) {
          final nested = Map<String, Object>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
          for (final nestedEntry in nested.entries.toList()) {
            final v = nestedEntry.value;
            if (v is num) {
              nested[nestedEntry.key] = _coerceNumeric(v, 0, 100);
            }
          }
          snapshot[entry.key] = nested;
        } else if (value is num) {
          snapshot[entry.key] = _coerceNumeric(value, 0, 100);
        }
      }
      map['v4_final_cohesion_snapshot'] = snapshot;
      break;
    case 'v4_token_final_verification_gate':
      final snapshot = Map<String, Object>.from(
        map['v4_token_final_snapshot'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final entry in snapshot.entries.toList()) {
        final value = entry.value;
        if (value is Map) {
          final nested = Map<String, Object>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
          for (final nestedEntry in nested.entries.toList()) {
            final v = nestedEntry.value;
            if (v is num) {
              nested[nestedEntry.key] = _coerceNumeric(v, 0, 100);
            }
          }
          snapshot[entry.key] = nested;
        } else if (value is num) {
          snapshot[entry.key] = _coerceNumeric(value, 0, 100);
        }
      }
      map['v4_token_final_snapshot'] = snapshot;
      break;
    case 'persona_v4_mat_final_gate':
      final snapshot = Map<String, Object>.from(
        map['persona_v4_mat_snapshot'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final entry in snapshot.entries.toList()) {
        final value = entry.value;
        if (value is Map) {
          final nested = Map<String, Object>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
          for (final nestedEntry in nested.entries.toList()) {
            final v = nestedEntry.value;
            if (v is num) {
              nested[nestedEntry.key] = _coerceNumeric(v, 0, 100);
            }
          }
          snapshot[entry.key] = nested;
        } else if (value is num) {
          snapshot[entry.key] = _coerceNumeric(value, 0, 100);
        }
      }
      map['persona_v4_mat_snapshot'] = snapshot;
      break;
    case 'final_visual_polish_gate':
      final snapshot = Map<String, Object>.from(
        map['final_visual_polish_snapshot'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final entry in snapshot.entries.toList()) {
        final value = entry.value;
        if (value is Map) {
          final nested = Map<String, Object>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
          for (final nestedEntry in nested.entries.toList()) {
            final v = nestedEntry.value;
            if (v is num) {
              nested[nestedEntry.key] = _coerceNumeric(v, 0, 100);
            }
          }
          snapshot[entry.key] = nested;
        } else if (value is num) {
          snapshot[entry.key] = _coerceNumeric(value, 0, 100);
        }
      }
      map['final_visual_polish_snapshot'] = snapshot;
      break;
    case 'xp_reward_final_gate':
      final xpSurfaceGate = Map<String, Object>.from(
        map['xp_reward_surface_gate'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final key in ['xp_surface', 'reward_surface']) {
        final surf = Map<String, Object>.from(
          xpSurfaceGate[key] as Map<String, Object>? ??
              const <String, Object>{},
        );
        for (final entry in surf.entries.toList()) {
          final v = entry.value;
          if (v is num) {
            surf[entry.key] = _coerceNumeric(
              v,
              key == 'xp_surface' ? 0 : 0,
              key == 'xp_surface' ? 500 : 3.0,
            );
          }
        }
        xpSurfaceGate[key] = surf;
      }
      final personaSurf = Map<String, Object>.from(
        xpSurfaceGate['persona_surface_modifiers'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final entry in personaSurf.entries.toList()) {
        final v = entry.value;
        if (v is num) personaSurf[entry.key] = _coerceNumeric(v, -1.0, 1.0);
      }
      xpSurfaceGate['persona_surface_modifiers'] = personaSurf;
      map['xp_reward_surface_gate'] = xpSurfaceGate;

      final xpCurveGate = Map<String, Object>.from(
        map['xp_curve_gate'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      clampList(xpCurveGate, 'levels', 0, 100000);
      clampList(xpCurveGate, 'weights', 0, 10);
      map['xp_curve_gate'] = xpCurveGate;

      final rpgFusion = Map<String, Object>.from(
        map['rpg_fusion'] as Map<String, Object>? ?? const <String, Object>{},
      );
      final fusion = Map<String, Object>.from(
        rpgFusion['fusion'] as Map<String, Object>? ?? const <String, Object>{},
      );
      clampField(fusion, 'effective_power', 0, 200);
      rpgFusion['fusion'] = fusion;
      map['rpg_fusion'] = rpgFusion;

      final rpgSnapshot = Map<String, Object>.from(
        map['rpg_snapshot'] as Map<String, Object>? ?? const <String, Object>{},
      );
      clampField(rpgSnapshot, 'soft_progress', 0, 1);
      map['rpg_snapshot'] = rpgSnapshot;
      break;
    case 'final_regression_platform_gate':
      final snapshot = Map<String, Object>.from(
        map['snapshot'] as Map<String, Object>? ?? const <String, Object>{},
      );
      void clampPlatform(Map<String, Object> target) {
        for (final entry in target.entries.toList()) {
          final value = entry.value;
          if (value is num) {
            target[entry.key] = _coerceNumeric(value, -1000, 1000);
          } else if (value is Map<String, Object>) {
            final nested = Map<String, Object>.from(value);
            clampPlatform(nested);
            target[entry.key] = nested;
          }
        }
      }

      clampPlatform(snapshot);
      map['snapshot'] = snapshot;
      break;
    case 'final_regression_consolidation_gate':
      final snapshot = Map<String, Object>.from(
        map['final_regression_snapshot'] as Map<String, Object>? ??
            const <String, Object>{},
      );
      for (final entry in snapshot.entries.toList()) {
        final value = entry.value;
        if (value is Map) {
          final nested = Map<String, Object>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
          for (final nestedEntry in nested.entries.toList()) {
            final v = nestedEntry.value;
            if (v is num) {
              nested[nestedEntry.key] = _coerceNumeric(v, -1000, 1000);
            }
          }
          snapshot[entry.key] = nested;
        } else if (value is num) {
          snapshot[entry.key] = _coerceNumeric(value, -1000, 1000);
        }
      }
      map['final_regression_snapshot'] = snapshot;
      break;
  }
  return map;
}

Map<String, Object> _sanitizeAsciiObject(Map<String, Object> raw) {
  final sanitized = _sanitizeAsciiValue(raw);
  if (sanitized is Map<String, Object>) return sanitized;
  return const <String, Object>{};
}

Object _sanitizeAsciiValue(Object? value) {
  if (value is String) return _stripNonAscii(value);
  if (value is Map) {
    final entries = <MapEntry<String, Object>>[];
    for (final entry in value.entries) {
      final key = _stripNonAscii(entry.key.toString());
      if (key.isEmpty) continue;
      entries.add(MapEntry(key, _sanitizeAsciiValue(entry.value)));
    }
    entries.sort((a, b) => a.key.compareTo(b.key));
    return Map<String, Object>.fromEntries(entries);
  }
  if (value is Iterable) {
    return value.map(_sanitizeAsciiValue).toList();
  }
  if (value == null) return '';
  return value;
}

Map<String, Object> _orderMapByKey(Map<String, Object> input) {
  final entries = input.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final ordered = <String, Object>{};
  for (final entry in entries) {
    final value = entry.value;
    if (value is Map<String, Object>) {
      ordered[entry.key] = _orderMapByKey(value);
    } else if (value is Map) {
      ordered[entry.key] = _orderMapByKey(
        value.map((k, v) => MapEntry(k.toString(), v)),
      );
    } else if (value is Iterable) {
      ordered[entry.key] = value
          .map<Object>(
            (e) => e is Map<String, Object>
                ? _orderMapByKey(e)
                : e is Map
                ? _orderMapByKey(e.map((k, v) => MapEntry(k.toString(), v)))
                : e,
          )
          .toList();
    } else {
      ordered[entry.key] = value;
    }
  }
  return ordered;
}

String _stripNonAscii(String input) {
  final buffer = StringBuffer();
  for (final code in input.runes) {
    if (code <= 127) buffer.writeCharCode(code);
  }
  return buffer.toString();
}

void _checkXpRewardSurfaceGate(
  Map<String, Object> strictFindings,
  List<String> errors,
) {
  final xpSurface = <String, Object>{
    'table': 0,
    'hole_cards': 0,
    'action_buttons': 0,
  };
  final rewardSurface = <String, Object>{
    'table': 1.0,
    'hole_cards': 1.0,
    'action_buttons': 1.0,
  };
  final personaSurfaceModifiers = <String, Object>{
    'table': 0.0,
    'hole_cards': 0.0,
    'action_buttons': 0.0,
  };

  void checkMapFields(
    Map<String, Object> map,
    List<String> required,
    String prefix,
    double min,
    double max,
  ) {
    for (final k in required) {
      if (!map.containsKey(k)) {
        errors.add('xp_reward_surface_gate_missing_key:$prefix$k');
        continue;
      }
      final v = map[k];
      if (v is! num) {
        errors.add('xp_reward_surface_gate_invalid_ascii:$prefix$k');
        continue;
      }
      final d = v.toDouble();
      if (d < min || d > max) {
        errors.add('xp_reward_surface_gate_out_of_range:$prefix$k');
      }
    }
  }

  const requiredKeys = ['table', 'hole_cards', 'action_buttons'];
  checkMapFields(xpSurface, requiredKeys, 'xp_', 0, 500);
  checkMapFields(rewardSurface, requiredKeys, 'reward_', 0.0, 3.0);
  checkMapFields(personaSurfaceModifiers, requiredKeys, 'persona_', -1.0, 1.0);

  strictFindings['xp_reward_surface_gate'] = <String, Object>{
    'xp_surface': xpSurface,
    'reward_surface': rewardSurface,
    'persona_surface_modifiers': personaSurfaceModifiers,
  };
}

void _checkXpCurveGate(
  Map<String, Object> strictFindings,
  List<String> errors,
) {
  final xpCurve = <String, Object>{
    'levels': <int>[0, 100, 200, 400, 800],
    'weights': <double>[1.0, 1.2, 1.4, 1.6, 1.8],
  };

  if (!xpCurve.containsKey('levels') || !xpCurve.containsKey('weights')) {
    errors.add('xp_curve_missing_key');
  }

  final levels = xpCurve['levels'];
  final weights = xpCurve['weights'];

  bool asciiOk = true;
  for (final entry in xpCurve.entries) {
    if (!_isAsciiString(entry.key)) asciiOk = false;
  }
  if (!asciiOk) errors.add('xp_curve_invalid_ascii');

  var levelsOk = true;
  if (levels is List) {
    if (levels.length < 5 || levels.length > 50) levelsOk = false;
    var previous = -1;
    for (final l in levels) {
      if (l is! int) {
        levelsOk = false;
        break;
      }
      if (l <= previous) {
        levelsOk = false;
        break;
      }
      if (l < 0 || l > 100000) {
        levelsOk = false;
        break;
      }
      previous = l;
    }
  } else {
    levelsOk = false;
  }
  if (!levelsOk) errors.add('xp_curve_invalid_levels');

  var weightsOk = true;
  if (weights is List) {
    if (levels is List && weights.length != levels.length) {
      errors.add('xp_curve_length_mismatch');
      weightsOk = false;
    }
    for (final w in weights) {
      if (w is! num) {
        weightsOk = false;
        break;
      }
      final d = w.toDouble();
      if (d.isNaN || d.isInfinite) {
        weightsOk = false;
        break;
      }
      if (d < 0.0 || d > 10.0) {
        weightsOk = false;
        break;
      }
    }
  } else {
    weightsOk = false;
  }
  if (!weightsOk) errors.add('xp_curve_invalid_weights');

  strictFindings['xp_curve_gate'] = <String, Object>{
    'levels': levels ?? const <Object>[],
    'weights': weights ?? const <Object>[],
  };
}

void _checkXpPersonaAlignmentGate(
  Map<String, Object> strictFindings,
  List<String> errors,
) {
  final personaRewardModifiers = <String, Object>{
    'focus': 0.0,
    'pressure': 0.0,
    'engagement': 0.0,
  };
  const required = ['focus', 'pressure', 'engagement'];

  for (final k in required) {
    if (!personaRewardModifiers.containsKey(k)) {
      errors.add('xp_persona_alignment_missing_key:$k');
    }
    final v = personaRewardModifiers[k];
    if (!_isAsciiString(k)) {
      errors.add('xp_persona_alignment_invalid_ascii:$k');
    }
    if (v is num) {
      final d = v.toDouble();
      if (d < -2.0 || d > 2.0) {
        errors.add('xp_persona_alignment_out_of_range:$k');
      }
    } else {
      errors.add('xp_persona_alignment_out_of_range:$k');
    }
  }

  final xpSurface =
      strictFindings['xp_reward_surface_gate'] as Map<String, Object>? ??
      const <String, Object>{};
  final xpSurfaceMap =
      xpSurface['xp_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  final rewardSurfaceMap =
      xpSurface['reward_surface'] as Map<String, Object>? ??
      const <String, Object>{};
  final xpTable = (xpSurfaceMap['table'] as num?)?.toDouble() ?? 0.0;
  final rewardTable = (rewardSurfaceMap['table'] as num?)?.toDouble() ?? 0.0;

  final focusMod = (personaRewardModifiers['focus'] as num?)?.toDouble() ?? 0.0;
  final pressureMod =
      (personaRewardModifiers['pressure'] as num?)?.toDouble() ?? 0.0;
  final engagementMod =
      (personaRewardModifiers['engagement'] as num?)?.toDouble() ?? 0.0;

  final xpCurveLevels =
      strictFindings['xp_curve_gate'] as Map<String, Object>? ??
      const <String, Object>{};
  final weights = xpCurveLevels['weights'] as List<Object>? ?? const <Object>[];

  if (engagementMod > 0 && rewardTable > 3.0) {
    errors.add('xp_persona_alignment_correlation_fail:engagement_reward');
  }
  if (pressureMod < 0 && xpTable < 0) {
    errors.add('xp_persona_alignment_correlation_fail:pressure_xp');
  }
  if (focusMod > 1.0) {
    final hasHighWeight = weights.any((w) => w is num && w.toDouble() >= 1.0);
    if (!hasHighWeight) {
      errors.add('xp_persona_alignment_correlation_fail:focus_weights');
    }
  }

  strictFindings['xp_persona_alignment_gate'] = <String, Object>{
    'persona_reward_modifiers': personaRewardModifiers,
    'xp_surface_table': xpTable,
    'reward_surface_table': rewardTable,
  };
}

void _v4StrictCohesionConsolidation(
  Map<String, Object> strictFindings,
  Map<String, Object?> v4Qa,
  Map<String, Object?> v4Cohesion,
  Map<String, Object?> v4Tokens,
  Map<String, Object?> v4PersonaUX,
  Map<String, Object?> v4Polish,
  Map<String, Object?> binder,
  List<String> errors,
) {
  final findings = <String, Object>{};
  final normalized =
      v4Qa['v4_normalized_tokens'] as Map<String, Object?>? ??
      const <String, Object?>{};
  final snapV3 =
      v4Qa['v3_snapshot'] as Map<String, Object?>? ?? const <String, Object?>{};
  final snapV4 =
      v4Qa['v4_snapshot'] as Map<String, Object?>? ?? const <String, Object?>{};
  final delta =
      v4Qa['v4_delta_report'] as Map<String, Object?>? ??
      const <String, Object?>{};
  final deltaChanged = <String>{};
  if (delta['changed'] is List) {
    deltaChanged.addAll((delta['changed'] as List).map((e) => e.toString()));
  }

  for (final k in normalized.keys) {
    final key = k.toString();
    final inV3 = snapV3.containsKey(key);
    final inV4 = snapV4.containsKey(key);
    if (!inV3 && !inV4 && !deltaChanged.contains(key)) {
      errors.add('v4_strict_cohesion_missing_token:$key');
    }
  }

  final overlay = binder['overlay'] as List<Object>? ?? const <Object>[];
  for (final entry in overlay.whereType<Map>()) {
    final id = entry['id']?.toString() ?? '';
    if (id.isEmpty) continue;
    if (!snapV4.containsKey(id) && !deltaChanged.contains(id)) {
      errors.add('v4_strict_cohesion_surface_missing:$id');
    }
  }

  for (final entry in v4Polish.entries) {
    final key = entry.key.toString();
    if (!_isAsciiString(key)) {
      errors.add('v4_strict_cohesion_polish_missing:$key');
    }
    if (!snapV4.containsKey(key)) {
      errors.add('v4_strict_cohesion_polish_missing:$key');
    }
  }

  final title = v4PersonaUX['title']?.toString() ?? '';
  if (appRoot.isV4Active) {
    if (title.isEmpty || !_isAsciiString(title)) {
      errors.add('v4_strict_cohesion_ux_invalid');
    }
  }

  final matHas =
      snapV4.containsKey('colorScheme') || snapV4.containsKey('themeMode');
  if (!matHas) {
    errors.add('v4_strict_cohesion_mat_missing');
  }

  final cohOk = v4Cohesion['ok'] == true;
  final hasCategoryIssues = errors.any(
    (e) => e.startsWith('v4_strict_cohesion') && !e.contains('ok_conflict'),
  );
  if (cohOk && hasCategoryIssues) {
    errors.add('v4_strict_cohesion_snapshot_mismatch');
  }

  findings['tokens'] = normalized;
  findings['snapshots'] = {'v3': snapV3, 'v4': snapV4, 'delta': delta};
  findings['persona'] = v4PersonaUX;
  findings['polish'] = v4Polish;
  findings['cohesion'] = v4Cohesion;
  strictFindings['v4_strict_cohesion_consolidation'] =
      Map<String, Object>.unmodifiable(findings);
}
