/// Central registry of telemetry event names used across the app.
class TelemetryEvents {
  TelemetryEvents._();

  static const String sessionStart = 'session_start';
  static const String sessionStartTiming = 'session_start_timing';
  static const String sessionEnd = 'session_end';
  static const String sessionAbort = 'session_abort';
  static const String campaignPackStart = 'campaign_pack_start';
  static const String campaignPackEnd = 'campaign_pack_end';
  static const String campaignHandResult = 'campaign_hand_result';
  static const String campaignBust = 'campaign_bust';
  static const String campaignBackerUsed = 'campaign_backer_used';
  static const String campaignCalibrationResolved =
      'campaign_calibration_resolved';
  static const String campaignComplete = 'campaign_complete';
  static const String intakeStart = 'intake_start';
  static const String intakeComplete = 'intake_complete';
  static const String placementSkillBandSet = 'placement_skill_band_set';
  static const String placementTestCompleted = 'placement_test_completed';
  static const String firstSessionTrustImpressionV1 =
      'first_session_trust_impression_v1';
  static const String firstSessionTrustStartedV1 =
      'first_session_trust_started_v1';
  static const String firstSessionAhaImpressionV1 =
      'first_session_aha_impression_v1';
  static const String bankrollFreeRollUsed = 'bankroll_free_roll_used';
  static const String skillCardCopied = 'skill_card_copied';
  static const String duelCodeCopied = 'duel_code_copied';
  static const String duelCodeUsed = 'duel_code_used';
  static const String focusLabelApplied = 'focus_label_applied';
  static const String recommendationImpressionV1 =
      'recommendation_impression_v1';
  static const String recommendationSelectedV1 = 'recommendation_selected_v1';
  static const String reviewQueueCreatedV1 = 'review_queue_created_v1';
  static const String reviewQueueStartedV1 = 'review_queue_started_v1';
  static const String reviewQueueCompletedV1 = 'review_queue_completed_v1';
  static const String bankrollBuyInCharged = 'bankroll_buy_in_charged';
  static const String bankrollRakebackEarned = 'bankroll_rakeback_earned';
  static const String bankrollRegenApplied = 'bankroll_regen_applied';
  static const String bankrollBackerUsed = 'bankroll_backer_used';
  static const String bankrollBlockedInsufficient =
      'bankroll_blocked_insufficient';
  static const String legalOpened = 'legal_opened';
  static const String deleteDataRequested = 'delete_data_requested';
  static const String deleteDataConfirmed = 'delete_data_confirmed';
  static const String deleteDataCompleted = 'delete_data_completed';
  static const String privacyOpened = 'privacy_opened';
  static const String termsOpened = 'terms_opened';
  static const String smartTrainingStarted = 'smart_training_started';
  static const String loopProgressCompleted = 'loop_progress_completed';
  static const String reviewCheckpointStarted = 'review_checkpoint_started';
  static const String recapOpened = 'recap_opened';
  static const String aiDecisionLogged =
      'analytics_telemetry_ai_decision_logged';
  static const String performanceMetricsLogged = 'performance_metrics_logged';
  static const String visualIntegrityAuditCompleted =
      'visual_integrity_audit_completed';
  static const String visualPolishCompleted = 'visual_polish_completed';
  static const String launchReadinessCompleted = 'launch_readiness_completed';
  static const String marketingAssetAuditCompleted =
      'marketing_asset_audit_completed';
  static const String governanceIntegrityAuditCompleted =
      'governance_integrity_audit_completed';
  static const String releaseStakeholderReportCompleted =
      'release_stakeholder_report_completed';
  static const String chipsEarned = 'chips_earned';
  static const String chipsSpent = 'chips_spent';
  static const String chipsEarnedV1 = 'chips_earned_v1';
  static const String chipsSpentV1 = 'chips_spent_v1';
  static const String rewardPurchased = 'reward_purchased';
  static const String adaptiveSessionRecorded = 'adaptive_session_recorded';
  static const String adaptiveDifficultyUpdated = 'adaptive_difficulty_updated';
  static const String adaptiveFeedbackShown = 'adaptive_feedback_shown';
  static const String quarantineOrphansCompleted =
      'quarantine_orphans_completed';
  static const String duplicationIndexCompleted = 'duplication_index_completed';
  static const String goalOrchestratorUpdated = 'goal_orchestrator_updated';
  static const String dedupPass1Completed = 'dedup_pass1_completed';
  static const String telemetryDriftCleanupCompleted =
      'telemetry_drift_cleanup_completed';
  static const String dedupPass2Completed = 'dedup_pass2_completed';
  static const String finalStakeholderSweepCompleted =
      'final_stakeholder_sweep_completed';
  static const String stabilityScalingAuditCompleted =
      'stability_scaling_audit_completed';
  static const String archivalGovernanceCycleCompleted =
      'archival_governance_cycle_completed';
  static const String telemetryConsistencyCompleted =
      'telemetry_consistency_completed';
  static const String marketingPrepCompleted = 'marketing_prep_completed';
  static const String releasePackagingCompleted = 'release_packaging_completed';
  static const String marketingAnalyticsCompleted =
      'marketing_analytics_completed';
  static const String publicReleaseCompleted = 'public_release_completed';
  static const String aiReliabilityCalibrated = 'ai_reliability_calibrated';
  static const String visualSweepCompleted = 'visual_sweep_completed';
  static const String aiReliabilityAuditCompleted =
      'ai_reliability_audit_completed';
  static const String aiAutotunerCycleCompleted =
      'ai_autotuner_cycle_completed';
  static const String publicDocsPackagingCompleted =
      'public_docs_packaging_completed';
  static const String autoRecoveryTriggered = 'auto_recovery_triggered';
  static const String postlaunchDashboardCompleted =
      'postlaunch_dashboard_completed';
  static const String postFixReadinessCompleted =
      'post_fix_readiness_completed';
  static const String designerHandoffPackaged = 'designer_handoff_packaged';
  static const String finalReleaseVerified = 'final_release_verified';
  static const String uxStressRecoveryCompleted =
      'ux_stress_recovery_completed';
  static const String finalArchivalLockCompleted =
      'final_archival_lock_completed';
  static const String postReleaseValidationCompleted =
      'post_release_validation_completed';
  static const String previewPackaged = 'preview_packaged';
  static const String systemIntegritySweepCompleted =
      'system_integrity_sweep_completed';
  static const String designAuditCompleted = 'design_audit_completed';
  static const String uxPrioritizationCompleted = 'ux_prioritization_completed';
  static const String visualIterationCompleted = 'visual_iteration_completed';
  static const String designerFeedbackIntegrated =
      'designer_feedback_integrated';
  static const String regressionConsistencyCompleted =
      'regression_consistency_completed';
  static const String telemetryDeltaCleanupCompleted =
      'telemetry_delta_cleanup_completed';
  static const String timingDriftNormalized = 'timing_drift_normalized';
  static const String uxMetricExported = 'ux_metric_exported';
  static const String uxDashboardSynced = 'ux_dashboard_synced';
  static const String designReviewSimulated = 'design_review_simulated';
  static const String publicShowcaseFinalized = 'public_showcase_finalized';
  static const String systemTelemetryHarmonized = 'system_telemetry_harmonized';
  static const String finalSystemAuditCompleted =
      'final_system_audit_completed';
  static const String maintenanceKickoffCompleted =
      'maintenance_kickoff_completed';
  static const String uxCalibrationCompleted = 'ux_calibration_completed';
  static const String telemetryRefinementCompleted =
      'telemetry_refinement_completed';
  static const String predictiveTrendCompleted = 'predictive_trend_completed';
  static const String healthInsightCompleted = 'health_insight_completed';
  static const String selfOptimizationCompleted = 'self_optimization_completed';
  static const String stabilityPreservationCompleted =
      'stability_preservation_completed';
  static const String maintenanceAutomationCompleted =
      'maintenance_automation_completed';
  static const String archivalRegressionCompleted =
      'archival_regression_completed';
  static const String healthCrosscheckCompleted = 'health_crosscheck_completed';

  static const List<String> all = <String>[
    sessionStart,
    sessionStartTiming,
    sessionEnd,
    sessionAbort,
    campaignPackStart,
    campaignPackEnd,
    campaignHandResult,
    campaignBust,
    campaignBackerUsed,
    campaignCalibrationResolved,
    campaignComplete,
    intakeStart,
    intakeComplete,
    placementSkillBandSet,
    placementTestCompleted,
    firstSessionTrustImpressionV1,
    firstSessionTrustStartedV1,
    firstSessionAhaImpressionV1,
    bankrollFreeRollUsed,
    skillCardCopied,
    duelCodeCopied,
    duelCodeUsed,
    focusLabelApplied,
    recommendationImpressionV1,
    recommendationSelectedV1,
    reviewQueueCreatedV1,
    reviewQueueStartedV1,
    reviewQueueCompletedV1,
    bankrollBuyInCharged,
    bankrollRakebackEarned,
    bankrollRegenApplied,
    bankrollBackerUsed,
    bankrollBlockedInsufficient,
    legalOpened,
    deleteDataRequested,
    deleteDataConfirmed,
    deleteDataCompleted,
    privacyOpened,
    termsOpened,
    smartTrainingStarted,
    loopProgressCompleted,
    reviewCheckpointStarted,
    recapOpened,
    aiDecisionLogged,
    performanceMetricsLogged,
    visualIntegrityAuditCompleted,
    visualPolishCompleted,
    launchReadinessCompleted,
    marketingAssetAuditCompleted,
    governanceIntegrityAuditCompleted,
    releaseStakeholderReportCompleted,
    chipsEarned,
    chipsSpent,
    chipsEarnedV1,
    chipsSpentV1,
    rewardPurchased,
    adaptiveSessionRecorded,
    adaptiveDifficultyUpdated,
    adaptiveFeedbackShown,
    quarantineOrphansCompleted,
    duplicationIndexCompleted,
    goalOrchestratorUpdated,
    dedupPass1Completed,
    telemetryDriftCleanupCompleted,
    dedupPass2Completed,
    finalStakeholderSweepCompleted,
    stabilityScalingAuditCompleted,
    archivalGovernanceCycleCompleted,
    telemetryConsistencyCompleted,
    marketingPrepCompleted,
    releasePackagingCompleted,
    marketingAnalyticsCompleted,
    publicReleaseCompleted,
    visualSweepCompleted,
    aiReliabilityCalibrated,
    aiReliabilityAuditCompleted,
    aiAutotunerCycleCompleted,
    publicDocsPackagingCompleted,
    autoRecoveryTriggered,
    postlaunchDashboardCompleted,
    postFixReadinessCompleted,
    designerHandoffPackaged,
    finalReleaseVerified,
    uxStressRecoveryCompleted,
    finalArchivalLockCompleted,
    postReleaseValidationCompleted,
    previewPackaged,
    systemIntegritySweepCompleted,
    designAuditCompleted,
    uxPrioritizationCompleted,
    visualIterationCompleted,
    designerFeedbackIntegrated,
    regressionConsistencyCompleted,
    telemetryDeltaCleanupCompleted,
    timingDriftNormalized,
    uxMetricExported,
    uxDashboardSynced,
    designReviewSimulated,
    publicShowcaseFinalized,
    systemTelemetryHarmonized,
    finalSystemAuditCompleted,
    maintenanceKickoffCompleted,
    uxCalibrationCompleted,
    telemetryRefinementCompleted,
    predictiveTrendCompleted,
    healthInsightCompleted,
    selfOptimizationCompleted,
    stabilityPreservationCompleted,
    maintenanceAutomationCompleted,
    archivalRegressionCompleted,
    healthCrosscheckCompleted,
  ];

  static final Map<String, String> releaseCriticalMap = <String, String>{
    'sessionStart': sessionStart,
    'sessionStartTiming': sessionStartTiming,
    'sessionEnd': sessionEnd,
    'sessionAbort': sessionAbort,
    'focusLabelApplied': focusLabelApplied,
    'legalOpened': legalOpened,
    'deleteDataRequested': deleteDataRequested,
    'deleteDataConfirmed': deleteDataConfirmed,
    'deleteDataCompleted': deleteDataCompleted,
    'privacyOpened': privacyOpened,
    'termsOpened': termsOpened,
  };
}
