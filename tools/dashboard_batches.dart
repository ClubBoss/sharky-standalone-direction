// === Dashboard Core Split (Stage59A) ===
//
// Batch execution logic for health_dashboard.dart:
// - Orchestrates all parallel Future.wait batches
// - Returns aggregated results map
//
// Batches:
// - Batch 1: Core (analyzer, tests, export)
// - Batch 2: Content tooling (7 tools)
// - Batch 3: Adaptive/telemetry (3 tools)
// - Batch 4: Baseline/perf/UX (4 tools)
//
// All tool invocations use _safeRunTool with 60s timeout protection.

part of 'health_dashboard.dart';

/// Run all dashboard batches in parallel and return aggregated results.
///
/// This orchestrates the 4 main batches plus additional sequential checks
/// for adaptive systems, player progress, and service statuses.
///
/// Returns a complete Map<String, dynamic> with all health check results.
///
/// Stage D13b: Added refreshFlutter parameter to force Flutter cache refresh.
Future<Map<String, dynamic>> runAllBatches({
  bool fastMode = false,
  bool refreshFlutter = false,
}) async {
  int maxConcurrent = min(Platform.numberOfProcessors, 4);
  if (maxConcurrent < 1) maxConcurrent = 1;

  Future<List<dynamic>> runChunked(
    List<Future<dynamic> Function()> tasks,
  ) async {
    final results = <dynamic>[];
    if (tasks.isEmpty) return results;
    for (var i = 0; i < tasks.length; i += maxConcurrent) {
      final chunk = tasks.sublist(i, min(i + maxConcurrent, tasks.length));
      final chunkResults = await Future.wait(chunk.map((fn) => fn()));
      results.addAll(chunkResults);
    }
    return results;
  }

  Future<Map<String, dynamic>> skipped(
    String tool, [
    Map<String, dynamic>? seed,
  ]) async {
    return {
      'pass': true,
      'skipped': true,
      'reason': 'fast_mode',
      'tool': tool,
      if (seed != null) ...seed,
    };
  }

  bool shouldSkipContentChecks() {
    final flag = Platform.environment['CI_HAS_CONTENT_CHANGES'];
    if (flag == null) return false;
    final normalized = flag.trim().toLowerCase();
    return normalized == '0' || normalized == 'false' || normalized == 'no';
  }

  Future<Map<String, dynamic>> skippedContent(
    String tool, [
    Map<String, dynamic>? seed,
  ]) async {
    return {
      'pass': true,
      'skipped': true,
      'reason': 'no_content_changes',
      'tool': tool,
      if (seed != null) ...seed,
    };
  }

  List<Map<String, dynamic>> toMapList(List<dynamic> raw) => raw
      .cast<Map>()
      .map<Map<String, dynamic>>(Map<String, dynamic>.from)
      .toList(growable: false);

  // Batch 1: Core analyzer/tests/export validation
  // Stage D13b: Use Flutter cache in fast mode to skip expensive SDK operations
  Map<String, dynamic> analyze;
  Map<String, dynamic> tests;

  if (fastMode) {
    // Try to use cached Flutter results
    final flutterResults = await flutter_cache.runFlutterChecks(
      forceRefresh: refreshFlutter,
    );

    if (flutterResults['cached'] == true) {
      // Use cached results
      analyze = Map<String, dynamic>.from(
        flutterResults['analyze'] as Map? ?? {},
      );
      tests = Map<String, dynamic>.from(flutterResults['tests'] as Map? ?? {});

      // Mark as cached for visibility
      analyze['cached'] = true;
      tests['cached'] = true;
    } else {
      // Cache miss, run normally
      final batch1 = toMapList(await runChunked([_runAnalyze, _runTests]));
      analyze = batch1[0];
      tests = batch1[1];
    }
  } else {
    // Full mode: always run fresh
    final batch1 = toMapList(await runChunked([_runAnalyze, _runTests]));
    analyze = batch1[0];
    tests = batch1[1];
  }

  // Export metrics always run (fast operation)
  final export = await _readExportMetrics();

  final coverage = await _readCoverage();
  final uiV2 = await _detectUiV2State();
  final uiPerf = await _readUiMetrics();
  final uiNav = (uiPerf['navigation'] is Map)
      ? uiPerf['navigation'] as Map
      : const {};
  final uiConsistency = await _scanUiConsistency();
  final uxQa = await _readUxQaReport();
  final sdks = await _detectSdks();

  Future<Map<String, dynamic>> contentValidationSafeWrap(
    String label,
    Future<Map<String, dynamic>> Function() runner,
  ) {
    if (fastMode) {
      return _runToolCached(label, ['lib/content', 'lib/models'], runner);
    }
    return runner();
  }

  Map<String, dynamic>? contentValidationReadCached(String path) {
    final map = _readJsonCached(path);
    return map.isEmpty ? null : map;
  }

  final skipContentChecks = shouldSkipContentChecks();

  Map<String, dynamic> contentValidation = {};
  Map<String, dynamic> contentCoverage = {};
  Map<String, dynamic> xpDifficultyBalance = {};

  if (skipContentChecks) {
    contentValidation = {
      'valid': 0,
      'total': 0,
      'pass': true,
      'skipped': true,
      'reason': 'no_content_changes',
    };
    contentCoverage = {
      'tagged': 0,
      'total': 0,
      'pass': true,
      'skipped': true,
      'reason': 'no_content_changes',
    };
    xpDifficultyBalance = {
      'avg': 0.0,
      'count': 0,
      'pass': true,
      'skipped': true,
      'reason': 'no_content_changes',
    };
  } else {
    final contentValidationResult = await content_validation_v2
        .runContentValidationV2(
          safeWrap: contentValidationSafeWrap,
          readJsonCached: contentValidationReadCached,
        );

    contentValidation = _asMap(contentValidationResult['content_validation']);
    contentCoverage = _asMap(contentValidationResult['content_xp_coverage']);
    xpDifficultyBalance = _asMap(
      contentValidationResult['xp_difficulty_balance'],
    );
  }

  // Batch 2: Content tooling
  // Stage D13b Phase 2: Wrap heavy content tools with cache
  Future<Map<String, dynamic>> contentToolWrap(
    String label,
    Future<Map<String, dynamic>> Function() runner,
  ) {
    if (fastMode) {
      if (label == 'content_semantic_audit') {
        return skipped('tools/content_semantic_audit.dart', {
          'collisions': 0,
          'ambiguous': 0,
        });
      }
      if (label == 'content_semantic_autofix') {
        return skipped('tools/content_semantic_autofix.dart');
      }
      return _runToolCached(label, ['lib/content'], runner);
    }
    return runner();
  }

  Map<String, dynamic> contentIdAutofix = {};
  Map<String, dynamic> contentConsistency = {};
  Map<String, dynamic> contentSemantic = {};
  Map<String, dynamic> contentSemanticAutofix = {};

  if (skipContentChecks) {
    contentIdAutofix = {
      'pass': true,
      'skipped': true,
      'fixed': 0,
      'total': 0,
      'reason': 'no_content_changes',
    };
    contentConsistency = {
      'pass': true,
      'skipped': true,
      'duplicates': 0,
      'deprecated': 0,
      'broken': 0,
      'reason': 'no_content_changes',
    };
    contentSemantic = {
      'pass': true,
      'skipped': true,
      'collisions': 0,
      'ambiguous': 0,
      'reason': 'no_content_changes',
    };
    contentSemanticAutofix = {
      'pass': true,
      'skipped': true,
      'packs_bridged': 0,
      'rationales_tagged': 0,
      'reason': 'no_content_changes',
    };
  } else {
    final contentConsistencyResult = await content_consistency_v2
        .runContentConsistencyV2(
          safeWrap: contentToolWrap,
          readJsonCached: contentValidationReadCached,
        );

    contentIdAutofix = _asMap(
      contentConsistencyResult['content_id_autofix_status'],
    );
    contentConsistency = _asMap(
      contentConsistencyResult['content_consistency_status'],
    );

    final contentSemanticResult = await content_semantic_v2
        .runContentSemanticV2(
          safeWrap: contentToolWrap,
          readJsonCached: contentValidationReadCached,
        );

    contentSemantic = _asMap(
      contentSemanticResult['content_semantic_audit_status'],
    );
    contentSemanticAutofix = _asMap(
      contentSemanticResult['content_semantic_autofix_status'],
    );
  }

  Future<Map<String, dynamic>> adaptiveWrap(
    String label,
    Future<Map<String, dynamic>> Function() runner,
  ) {
    return runner();
  }

  final adaptiveCoreResult = await adaptive_checks_v2.runAdaptiveChecksV2(
    safeWrap: adaptiveWrap,
    readJsonCached: contentValidationReadCached,
  );

  final adaptiveLoopV2 = _asMap(adaptiveCoreResult['adaptive_loop_v2_status']);
  final adaptiveLoopV3 = _asMap(adaptiveCoreResult['adaptive_loop_v3_status']);
  final miniAiTuner = _asMap(adaptiveCoreResult['mini_ai_tuner_status']);

  Map<String, dynamic> contentDriftForecast = {};
  Map<String, dynamic> contentDriftFeedback = {};
  Map<String, dynamic> contentRemediation = {};
  Map<String, dynamic> contentEvolution = {};

  if (skipContentChecks) {
    contentDriftForecast = await skippedContent(
      'tools/content_drift_forecast.dart',
      {'risk': 0.0, 'trend': 'skipped'},
    );
    contentDriftFeedback = await skippedContent(
      'tools/content_drift_feedback.dart',
      {'alerts': 0},
    );
    contentRemediation = await skippedContent(
      'tools/content_remediation_engine.dart',
      {'suggested': 0, 'applied': 0},
    );
    contentEvolution = await skippedContent(
      'tools/content_evolution_pipeline.dart',
      {'stages': 0},
    );
  } else {
    final contentBatch = toMapList(
      await runChunked([
        _checkContentDriftForecastStatus,
        _checkContentDriftFeedbackStatus,
        _checkContentRemediationStatus,
        _checkContentEvolutionPipelineStatus,
      ]),
    );
    contentDriftForecast = contentBatch[0];
    contentDriftFeedback = contentBatch[1];
    contentRemediation = contentBatch[2];
    contentEvolution = contentBatch[3];
  }
  // Batch 3: Adaptive / telemetry tooling
  final adaptiveBatch = toMapList(
    await runChunked([
      _checkTelemetryBetaStatus,
      _checkSmartEconomyStatus,
      () => fastMode
          ? skipped('tools/economy_telemetry_loop.dart', {
              'drift_percent': 0.0,
              'trend': 'skipped',
            })
          : _checkEconomyTelemetryLoopStatus(),
    ]),
  );
  final telemetryBeta = adaptiveBatch[0];
  final smartEconomy = adaptiveBatch[1];
  final economyTelemetry = adaptiveBatch[2];

  // Batch 4: Baseline, perf, UX, player sync
  // Stage D13b Phase 2: Wrap heavy tools with cache and parallel limiter
  final baselineBatch = toMapList(
    await runChunked([
      _checkUiPerformanceStatus,
      () => fastMode
          ? skipped('tools/ux_qa_scanner.dart', {
              'hardcoded': 0,
              'inline_colors': 0,
            })
          : _runToolCached('ux_qa_scanner', [
              'lib/ui',
              'lib/screens',
              'lib/widgets',
            ], _checkUxQaStatus),
      () => fastMode
          ? _runToolCached('baseline_synthesizer', [
              'lib',
              'test',
            ], _checkBaselineStatus)
          : _checkBaselineStatus(),
      _checkPlayerSyncStatus,
    ]),
  );
  final uiPerfProfile = baselineBatch[0];
  final uxQaScan = baselineBatch[1];
  final baselineSynth = baselineBatch[2];
  final playerSync = baselineBatch[3];

  // Sequential adaptive and service checks
  final playerProgress = await _readPlayerProgress();
  final playerLevel = (playerProgress['level'] as num?)?.toInt() ?? 1;
  final adaptiveDrift = await are.computeAdaptiveRewardDrift(
    playerLevel: playerLevel,
  );
  final adaptiveLoop = await alo.runAdaptiveLoop();
  final adaptiveLearning = await alc.runAdaptiveLearningCore();
  final behaviorTuning = await abt.runAdaptiveBehaviorTuner();
  final contentFeedback = await acf.applyAdaptiveFeedback();

  final profilesStatus = await _checkUserProfilesStatus();
  final paymentGatewayStatus = await _checkPaymentGatewayStatus();
  final revenueMetrics = await rde.computeRevenueMetrics(
    totalUsersHint: (profilesStatus['count'] as num?)?.toInt() ?? 0,
    paymentGatewayStatus: paymentGatewayStatus,
  );
  final uiV2Demo = await _checkUiV2DemoStatus();
  final energyStatus = await _checkEnergyStatus();
  final chipsStatus = await _checkChipsStatus();
  final triggersStatus = await _checkAdaptiveTriggersStatus();
  final designTokens = await _checkDesignTokensStatus();
  final codebaseAudit = await _checkCodebaseAuditStatus();
  final userNotifications = await _checkUserNotificationsStatus();
  final dailyChallenge = await _checkDailyChallengeStatus();
  final streakTracker = await _checkStreakTrackerStatus();
  final premiumStatus = await _checkPremiumStatus();
  final leaderboardStatus = await _checkLeaderboardStatus();
  final adaptivePlannerMode = await _computeAdaptivePlannerMode();

  // Build complete results map
  return {
    'analyze': analyze,
    'tests': tests,
    'coverage': coverage,
    'ui_v2': uiV2,
    'ui_performance': uiPerf,
    'ui_animations': (uiPerf['animations'] is Map)
        ? uiPerf['animations']
        : const {},
    'ui_navigation': uiNav,
    'ui_consistency': uiConsistency,
    'ux_qa': uxQa,
    'ux_qa_scan': uxQaScan,
    'sdks': sdks,
    'export_validation': export,
    'content_validation': contentValidation,
    'content_xp_coverage': contentCoverage,
    'xp_difficulty_balance': xpDifficultyBalance,
    'adaptive_reward_drift': adaptiveDrift,
    'adaptive_loop': adaptiveLoop,
    'adaptive_learning_core': adaptiveLearning,
    'adaptive_behavior_tuning': behaviorTuning,
    'adaptive_loop_v2_status': adaptiveLoopV2,
    'adaptive_loop_v3_status': adaptiveLoopV3,
    'mini_ai_tuner_status': miniAiTuner,
    'adaptive_planner_mode': adaptivePlannerMode,
    'adaptive_content_feedback': contentFeedback,
    'content_id_autofix_status': contentIdAutofix,
    'content_consistency_status': contentConsistency,
    'content_semantic_status': contentSemantic,
    'content_semantic_autofix_status': contentSemanticAutofix,
    'content_drift_forecast_status': contentDriftForecast,
    'content_drift_feedback_status': contentDriftFeedback,
    'content_remediation_status': contentRemediation,
    'content_evolution_pipeline_status': contentEvolution,
    'telemetry_beta_status': telemetryBeta,
    'smart_economy_status': smartEconomy,
    'economy_telemetry_loop_status': economyTelemetry,
    'ui_perf_profile': uiPerfProfile,
    'baseline_synthesizer': baselineSynth,
    'player_sync_status': playerSync,
    'user_profiles_status': profilesStatus,
    'leaderboard_status': leaderboardStatus,
    'payment_gateway_status': paymentGatewayStatus,
    'revenue_metrics': revenueMetrics,
    'ui_v2_demo': uiV2Demo,
    'energy_status': energyStatus,
    'chips_status': chipsStatus,
    'adaptive_triggers_status': triggersStatus,
    'design_tokens_status': designTokens,
    'codebase_audit_status': codebaseAudit,
    'user_notifications_status': userNotifications,
    'daily_challenge_status': dailyChallenge,
    'streak_tracker_status': streakTracker,
    'premium_status': premiumStatus,
    'player_progress': playerProgress,
    'fast_mode': fastMode,
    'mode': fastMode ? 'fast' : 'full',
    'timestamp': DateTime.now().toIso8601String(),
  };
}
