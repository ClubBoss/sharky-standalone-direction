import 'package:poker_analyzer/constants/telemetry_events.dart';

/// Classifies telemetry events by purpose and operational criticality.
class TelemetrySchema {
  TelemetrySchema._();

  static const List<TelemetryEventDefinition> events =
      <TelemetryEventDefinition>[
        TelemetryEventDefinition(
          id: TelemetryEvents.sessionStart,
          description: 'Training session launched',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.sessionEnd,
          description: 'Training session completed normally',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.sessionAbort,
          description: 'Session aborted unexpectedly',
          criticality: TelemetryCriticality.critical,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.smartTrainingStarted,
          description: 'Adaptive smart training flow initiated',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.loopProgressCompleted,
          description: 'Adaptive loop passed progress checkpoint',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.reviewCheckpointStarted,
          description: 'Review checkpoint begin marker',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.recapOpened,
          description: 'Post-session recap opened',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.aiDecisionLogged,
          description: 'AI coach recorded decision snapshot',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.performanceMetricsLogged,
          description: 'Performance metrics exported to telemetry',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.visualIntegrityAuditCompleted,
          description: 'Visual integrity audit run finished',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.visualPolishCompleted,
          description: 'Visual polish sweep completed',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.launchReadinessCompleted,
          description: 'Launch readiness audit result',
          criticality: TelemetryCriticality.critical,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.marketingAssetAuditCompleted,
          description: 'Marketing asset audit summary',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.governanceIntegrityAuditCompleted,
          description: 'Governance integrity audit status',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.releaseStakeholderReportCompleted,
          description: 'Release stakeholder report generated',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.chipsEarned,
          description: 'Player earned chips reward',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.chipsSpent,
          description: 'Player spent chips in shop',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.rewardPurchased,
          description: 'Reward purchase confirmation',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.adaptiveSessionRecorded,
          description: 'Adaptive session recorded for trend tracking',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.adaptiveDifficultyUpdated,
          description: 'Adaptive difficulty recalibrated',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.adaptiveFeedbackShown,
          description: 'Adaptive feedback hint surfaced to user',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.quarantineOrphansCompleted,
          description: 'Orphan quarantine cycle finished',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.duplicationIndexCompleted,
          description: 'Duplication index analysis ready',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.goalOrchestratorUpdated,
          description: 'Daily goal orchestrator updated state',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.dedupPass1Completed,
          description: 'First deduplication pass completed',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.telemetryDriftCleanupCompleted,
          description: 'Telemetry drift cleanup run completed',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.dedupPass2Completed,
          description: 'Second deduplication pass completed',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.finalStakeholderSweepCompleted,
          description: 'Final stakeholder sweep summary',
          criticality: TelemetryCriticality.critical,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.stabilityScalingAuditCompleted,
          description: 'Stability scaling audit output',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.archivalGovernanceCycleCompleted,
          description: 'Archival governance cycle report',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.telemetryConsistencyCompleted,
          description: 'Telemetry consistency guard result',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.marketingPrepCompleted,
          description: 'Ω7 marketing prep validator passed',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.releasePackagingCompleted,
          description: 'Ω8 release packaging audit summary event',
          criticality: TelemetryCriticality.critical,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.marketingAnalyticsCompleted,
          description: 'Ω9 marketing analytics aggregation result',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.publicReleaseCompleted,
          description: 'Ω11 public release automation summary',
          criticality: TelemetryCriticality.critical,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.previewPackaged,
          description: 'Preview packaging readiness summary',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.systemIntegritySweepCompleted,
          description: 'System integrity sweep cross-check results',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.designAuditCompleted,
          description: 'Φ-D designer simulation UX audit summary',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.uxPrioritizationCompleted,
          description: 'Φ-E UX prioritization matrix published',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.visualIterationCompleted,
          description: 'Φ-F visual iteration preview generated',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.designerFeedbackIntegrated,
          description: 'Φ-G designer feedback matrix synthesized',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.regressionConsistencyCompleted,
          description: 'Ω-series regression consistency sweep summary',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.telemetryDeltaCleanupCompleted,
          description: 'Ω26 telemetry delta cleanup report',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.timingDriftNormalized,
          description: 'Ω27 timing drift normalization results',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.uxMetricExported,
          description: 'Φ-H UX metric export summary',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.uxDashboardSynced,
          description: 'Φ-I UX dashboard sync status',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.designReviewSimulated,
          description: 'Φ-J design review simulation output',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.publicShowcaseFinalized,
          description: 'Φ-K public showcase ready overview',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.systemTelemetryHarmonized,
          description: 'Ω-28 system telemetry harmonization status',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.finalSystemAuditCompleted,
          description: 'Ω-29 final system audit summary',
          criticality: TelemetryCriticality.critical,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.maintenanceKickoffCompleted,
          description: 'Ω-30 maintenance kickoff plan',
          criticality: TelemetryCriticality.info,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.uxCalibrationCompleted,
          description: 'Φ-M continuous UX calibration report',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.telemetryRefinementCompleted,
          description: 'Ω-31 telemetry refinement loop summary',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.predictiveTrendCompleted,
          description: 'Stage Ψ-2 predictive retention/UX trend forecast',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.healthInsightCompleted,
          description: 'Stage Ψ-4 automated health/insight summary',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.selfOptimizationCompleted,
          description: 'Stage Ψ-5 self-optimization loop plan',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.stabilityPreservationCompleted,
          description: 'Stage Ω-31 stability preservation engine summary',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.maintenanceAutomationCompleted,
          description: 'Stage Ω-32 maintenance automation cycle planner',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.archivalRegressionCompleted,
          description: 'Stage Ω-33 archival regression loop status',
          criticality: TelemetryCriticality.monitor,
        ),
        TelemetryEventDefinition(
          id: TelemetryEvents.healthCrosscheckCompleted,
          description: 'Stage Ω-34 AI vs UX telemetry cross-check',
          criticality: TelemetryCriticality.monitor,
        ),
      ];

  static Map<String, TelemetryEventDefinition> get byId =>
      _cachedById ??= Map<String, TelemetryEventDefinition>.fromEntries(
        events.map((definition) => MapEntry(definition.id, definition)),
      );

  static Map<String, TelemetryEventDefinition>? _cachedById;
}

class TelemetryEventDefinition {
  const TelemetryEventDefinition({
    required this.id,
    required this.description,
    required this.criticality,
  });

  final String id;
  final String description;
  final TelemetryCriticality criticality;
}

enum TelemetryCriticality { info, monitor, critical }
