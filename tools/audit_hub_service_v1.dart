import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:poker_analyzer/audit_hub_v1/audit_hub_operational_builder_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/audit_hub_operational_models_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/session_world_truth_surface_audit_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/world_pedagogical_progression_audit_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/world_screenshot_evidence_audit_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/world_visual_instrumentation_audit_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/world_route_ownership_inventory_v1.dart';

import 'release_readiness_snapshot_v1.dart';

const auditHubServiceDefaultHostV1 = '127.0.0.1';
const auditHubServiceDefaultPortV1 = 8787;
const auditHubOperationalSnapshotPathV1 =
    'assets/audit_hub_v1/operational_snapshot.json';
const auditHubLatestRunPathV1 = 'assets/audit_hub_v1/latest_run.json';
const auditHubHistoryIndexPathV1 = 'assets/audit_hub_v1/history_index.json';
const auditHubReviewDirV1 = 'out/audit_hub_v1/reviews';
const auditHubTopWavePacketDirV1 = 'out/audit_hub_v1/top_wave_packets';
const auditHubDossierDirV1 = 'out/audit_hub_v1/dossiers';
const auditHubFixPacketDirV1 = 'out/audit_hub_v1/fix_packets';
const auditHubBundleDirV1 = 'out/audit_hub_v1/bundles';
const auditHubWebBundleDirV1 = 'build/audit_hub_web';

class AuditHubRefreshResultV1 {
  const AuditHubRefreshResultV1({
    required this.snapshotPath,
    required this.reviewPath,
    required this.topWavePacketPath,
    required this.dossierPath,
    required this.latestRunPath,
    required this.historyIndexPath,
    required this.dashboard,
  });

  final String snapshotPath;
  final String reviewPath;
  final String topWavePacketPath;
  final String dossierPath;
  final String latestRunPath;
  final String historyIndexPath;
  final AuditHubOperationalDashboardV1 dashboard;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'snapshot_path': snapshotPath,
      'review_path': reviewPath,
      'top_wave_packet_path': topWavePacketPath,
      'dossier_path': dossierPath,
      'latest_run_path': latestRunPath,
      'history_index_path': historyIndexPath,
      'recalibration_candidate_status':
          dashboard.recalibrationCandidate.status.wireValue,
      'recalibration_justified_now':
          dashboard.recalibrationCandidate.recalibrationJustifiedNow,
      'top_machine_frontier':
          dashboard.completionGapSynthesis.topMachineFrontier?.gapId,
      'recommended_next_frontier':
          dashboard.completionGapSynthesis.recommendedNextFrontier?.gapId,
      'machine_reducible_remaining_count':
          dashboard.completionGapSynthesis.machineReducibleRemainingCount,
    };
  }
}

AuditHubRefreshResultV1 refreshAuditHubReadinessCalibrationSupportV1({
  String rootPath = '.',
  required String timestampUtc,
  String serviceBaseUrl =
      'http://$auditHubServiceDefaultHostV1:$auditHubServiceDefaultPortV1',
}) {
  final stopwatch = Stopwatch()..start();
  final root = Directory(rootPath);
  final snapshotFile = File(
    '${root.path}${Platform.pathSeparator}$auditHubOperationalSnapshotPathV1',
  );
  if (!snapshotFile.existsSync()) {
    throw StateError(
      'Missing operational snapshot at ${snapshotFile.path}. '
      'Run the Audit Hub pipeline first.',
    );
  }

  final previousSnapshot = _readJsonMap(snapshotFile);
  final snapshot = Map<String, Object?>.from(previousSnapshot);
  final previousLatestRun = Map<String, Object?>.from(
    previousSnapshot['latest_run'] as Map? ?? const <String, Object?>{},
  );
  final previousProjectHealth = Map<String, Object?>.from(
    previousSnapshot['project_health'] as Map? ?? const <String, Object?>{},
  );
  final previousCompletionGapSynthesis = Map<String, Object?>.from(
    previousSnapshot['completion_gap_synthesis'] as Map? ??
        const <String, Object?>{},
  );
  final previousCandidate = Map<String, Object?>.from(
    previousSnapshot['readiness_recalibration_candidate'] as Map? ??
        const <String, Object?>{},
  );
  final sessionWorldTruthSurfaces = buildSessionWorldTruthSurfaceReportsV1(
    rootPath: rootPath,
    worlds: (snapshot['worlds'] as List<Object?>? ?? const [])
        .whereType<Map>()
        .map(Map<String, Object?>.from)
        .map((world) => world['world_id'] as String? ?? '')
        .map(_parseWorldNumberV1)
        .whereType<int>(),
  );
  snapshot['world_truth_surfaces'] = sessionWorldTruthSurfaces
      .map((report) => report.toJson())
      .toList();
  snapshot['world_route_ownership_inventories'] =
      (snapshot['worlds'] as List<Object?>? ?? const [])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .map((world) => world['world_id'] as String? ?? '')
          .map(_parseWorldNumberV1)
          .whereType<int>()
          .map(
            (world) => buildWorldRouteOwnershipInventoryReportV1(
              world: world,
            ).toJson(),
          )
          .toList();
  snapshot['world_visual_instrumentation_surfaces'] =
      (snapshot['worlds'] as List<Object?>? ?? const [])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .map((world) => world['world_id'] as String? ?? '')
          .map(_parseWorldNumberV1)
          .whereType<int>()
          .map(
            (world) =>
                buildWorldVisualInstrumentationReportV1(world: world).toJson(),
          )
          .toList();
  snapshot['world_screenshot_evidence_surfaces'] =
      (snapshot['worlds'] as List<Object?>? ?? const [])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .map((world) => world['world_id'] as String? ?? '')
          .map(_parseWorldNumberV1)
          .whereType<int>()
          .map(
            (world) =>
                buildWorldScreenshotEvidenceReportV1(world: world).toJson(),
          )
          .toList();
  snapshot['worlds'] = hydrateWorldsWithTruthSurfacesForSnapshotV1(
    worlds: (snapshot['worlds'] as List<Object?>? ?? const <Object?>[])
        .whereType<Map>()
        .map(Map<String, Object?>.from)
        .toList(growable: false),
    routeInventories:
        (snapshot['world_route_ownership_inventories'] as List<Object?>? ??
                const <Object?>[])
            .whereType<Map>()
            .map(Map<String, Object?>.from)
            .toList(growable: false),
    visualInstrumentationSurfaces:
        (snapshot['world_visual_instrumentation_surfaces'] as List<Object?>? ??
                const <Object?>[])
            .whereType<Map>()
            .map(Map<String, Object?>.from)
            .toList(growable: false),
    screenshotEvidenceSurfaces:
        (snapshot['world_screenshot_evidence_surfaces'] as List<Object?>? ??
                const <Object?>[])
            .whereType<Map>()
            .map(Map<String, Object?>.from)
            .toList(growable: false),
  );
  final pedagogicalProgressionReports =
      buildWorldPedagogicalProgressionReportsV1(
        rootPath: rootPath,
        worlds: (snapshot['worlds'] as List<Object?>? ?? const <Object?>[])
            .whereType<Map>()
            .map(Map<String, Object?>.from)
            .toList(growable: false),
      );
  snapshot['world_pedagogical_progression_surfaces'] =
      pedagogicalProgressionReports
          .map((report) => report.toJson())
          .toList(growable: false);
  snapshot['pedagogical_progression_truth'] =
      buildPedagogicalProgressionTruthSummaryJsonV1(
        reports: pedagogicalProgressionReports,
      );
  final ssotFile = File(
    '${root.path}${Platform.pathSeparator}$projectReadinessSsotPathV1',
  );
  final worldRegistryFile = File(
    '${root.path}${Platform.pathSeparator}$worldReadinessRegistryPathV1',
  );
  final worldRegistryContent = worldRegistryFile.existsSync()
      ? worldRegistryFile.readAsStringSync()
      : '';
  final worldRegistryById = <String, WorldReadinessRegistryRowV1>{
    for (final row in parseWorldReadinessRegistryRowsV1(worldRegistryContent))
      row.worldId: row,
  };
  snapshot['worlds'] = _syncWorldsFromRegistryForSnapshotV1(
    worlds: (snapshot['worlds'] as List<Object?>? ?? const <Object?>[])
        .whereType<Map>()
        .map(Map<String, Object?>.from)
        .toList(growable: false),
    worldRegistryById: worldRegistryById,
  );
  final productSurfaceFile = File(
    '${root.path}${Platform.pathSeparator}$productSurfaceReadinessPathV1',
  );
  final previousTopWavePacketPath = _findLatestMarkdownFilePathV1(
    '${root.path}${Platform.pathSeparator}$auditHubTopWavePacketDirV1',
  );
  final releaseReadinessSnapshot = buildReleaseReadinessSnapshot(
    rootPath: rootPath,
  );
  final dashboard = buildAuditHubOperationalDashboardV1(
    operationalSnapshot: snapshot,
    releaseReadinessSnapshot: releaseReadinessSnapshot,
    projectReadinessSsotContent: ssotFile.readAsStringSync(),
    worldReadinessRegistryContent: worldRegistryContent,
    productSurfaceReadinessContent: productSurfaceFile.existsSync()
        ? productSurfaceFile.readAsStringSync()
        : '',
    currentTopWavePacketPath: previousTopWavePacketPath,
  );

  snapshot['project_health'] = dashboard.canonicalReadiness
      .toProjectHealthJson();
  snapshot['readiness_recalibration_candidate'] = dashboard
      .recalibrationCandidate
      .toJson();
  snapshot['completion_gap_synthesis'] = dashboard.completionGapSynthesis
      .toJson();

  final reviewDir = Directory(
    '${root.path}${Platform.pathSeparator}$auditHubReviewDirV1',
  )..createSync(recursive: true);
  final reviewPath =
      '${reviewDir.path}${Platform.pathSeparator}chatgpt_review_${_normalizeTimestampForFileV1(timestampUtc)}.md';
  final topWavePacketDir = Directory(
    '${root.path}${Platform.pathSeparator}$auditHubTopWavePacketDirV1',
  )..createSync(recursive: true);
  final topWavePacketPath =
      '${topWavePacketDir.path}${Platform.pathSeparator}top_wave_packet_${_normalizeTimestampForFileV1(timestampUtc)}.md';
  final dossierDir = Directory(
    '${root.path}${Platform.pathSeparator}$auditHubDossierDirV1',
  )..createSync(recursive: true);
  final dossierPath =
      '${dossierDir.path}${Platform.pathSeparator}project_status_dossier_${_normalizeTimestampForFileV1(timestampUtc)}.md';
  final rebuiltDashboard = buildAuditHubOperationalDashboardV1(
    operationalSnapshot: snapshot,
    releaseReadinessSnapshot: releaseReadinessSnapshot,
    projectReadinessSsotContent: ssotFile.readAsStringSync(),
    worldReadinessRegistryContent: worldRegistryContent,
    productSurfaceReadinessContent: productSurfaceFile.existsSync()
        ? productSurfaceFile.readAsStringSync()
        : '',
    currentReviewPath: reviewPath,
    currentTopWavePacketPath: topWavePacketPath,
  );
  snapshot['project_health'] = rebuiltDashboard.canonicalReadiness
      .toProjectHealthJson();
  snapshot['readiness_recalibration_candidate'] = rebuiltDashboard
      .recalibrationCandidate
      .toJson();
  snapshot['completion_gap_synthesis'] = rebuiltDashboard.completionGapSynthesis
      .toJson();
  snapshot['finding_inventory'] = _buildFindingInventoryV1(
    snapshot: snapshot,
    dashboard: rebuiltDashboard,
  );
  final latestRun = _buildLatestRunV1(
    rootPath: rootPath,
    timestampUtc: timestampUtc,
    snapshot: snapshot,
    dashboard: rebuiltDashboard,
    releaseReadinessSnapshot: releaseReadinessSnapshot,
    previousLatestRun: previousLatestRun,
  );
  snapshot['generated_at_utc'] = timestampUtc;
  snapshot['latest_run'] = latestRun;
  snapshot['recent_runs'] = _buildRecentRunsV1(
    latestRun: latestRun,
    previousSnapshot: previousSnapshot,
  );
  snapshot['trust'] = _buildTrustStateV1(
    previousSnapshot: previousSnapshot,
    latestRun: latestRun,
    timestampUtc: timestampUtc,
  );
  snapshot['chatgpt_summary'] = _buildChatSummaryV1(
    dashboard: rebuiltDashboard,
    timestampUtc: timestampUtc,
    previousProjectHealth: previousProjectHealth,
    previousCompletionGapSynthesis: previousCompletionGapSynthesis,
    previousCandidate: previousCandidate,
  );
  final topWavePacket = _buildTopWavePacketV1(
    dashboard: rebuiltDashboard,
    reviewPath: reviewPath,
    topWavePacketPath: topWavePacketPath,
    timestampUtc: timestampUtc,
  );
  snapshot['top_wave_packet'] = topWavePacket;
  final currentRunId = latestRun['run_id'] as String? ?? 'unknown';
  final previousRunId = previousLatestRun['run_id'] as String? ?? 'none';
  latestRun['full_audit_trace'] = _buildFullAuditTraceV1(
    durationMs: 0,
    previousRunId: previousRunId,
    currentRunId: currentRunId,
    reviewPath: reviewPath,
    topWavePacketPath: topWavePacketPath,
    dossierPath: dossierPath,
  );
  final reviewMarkdown = renderAuditHubReviewExportV1(
    snapshot: snapshot,
    dashboard: rebuiltDashboard,
    timestampUtc: timestampUtc,
    previousSnapshot: previousSnapshot,
  );
  final dossierMarkdown = renderProjectStatusDossierV1(
    snapshot: snapshot,
    dashboard: rebuiltDashboard,
    timestampUtc: timestampUtc,
    reviewPath: reviewPath,
    topWavePacketPath: topWavePacketPath,
    dossierPath: dossierPath,
    previousSnapshot: previousSnapshot,
  );
  File(reviewPath).writeAsStringSync(reviewMarkdown);
  File(dossierPath).writeAsStringSync(dossierMarkdown);
  File(topWavePacketPath).writeAsStringSync(
    renderTopWavePacketMarkdownV1(
      packet: topWavePacket,
      dashboard: rebuiltDashboard,
      timestampUtc: timestampUtc,
    ),
  );
  snapshot['last_export'] = _buildLastExportV1(
    bundleId: 'top_wave_packet_${_normalizeTimestampForFileV1(timestampUtc)}',
    generatedAtUtc: timestampUtc,
    directoryPath: topWavePacketDir.path,
    exportType: 'top_wave_packet_markdown',
    markdownPath: topWavePacketPath,
    serviceBaseUrl: serviceBaseUrl,
  );

  final latestRunFile = File(
    '${root.path}${Platform.pathSeparator}$auditHubLatestRunPathV1',
  );
  latestRunFile.parent.createSync(recursive: true);
  latestRunFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(latestRun)}\n',
  );

  final historyIndexFile = File(
    '${root.path}${Platform.pathSeparator}$auditHubHistoryIndexPathV1',
  );
  historyIndexFile.parent.createSync(recursive: true);
  historyIndexFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'generated_at_utc': timestampUtc, 'runs': snapshot['recent_runs']})}\n',
  );

  stopwatch.stop();
  latestRun['full_audit_trace'] = _buildFullAuditTraceV1(
    durationMs: stopwatch.elapsedMilliseconds,
    previousRunId: previousRunId,
    currentRunId: currentRunId,
    reviewPath: reviewPath,
    topWavePacketPath: topWavePacketPath,
    dossierPath: dossierPath,
  );
  final finalizedReviewMarkdown = renderAuditHubReviewExportV1(
    snapshot: snapshot,
    dashboard: rebuiltDashboard,
    timestampUtc: timestampUtc,
    previousSnapshot: previousSnapshot,
  );
  final finalizedDossierMarkdown = renderProjectStatusDossierV1(
    snapshot: snapshot,
    dashboard: rebuiltDashboard,
    timestampUtc: timestampUtc,
    reviewPath: reviewPath,
    topWavePacketPath: topWavePacketPath,
    dossierPath: dossierPath,
    previousSnapshot: previousSnapshot,
  );
  File(reviewPath).writeAsStringSync(finalizedReviewMarkdown);
  File(dossierPath).writeAsStringSync(finalizedDossierMarkdown);
  latestRunFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(latestRun)}\n',
  );
  snapshotFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(snapshot)}\n',
  );

  return AuditHubRefreshResultV1(
    snapshotPath: snapshotFile.path,
    reviewPath: reviewPath,
    topWavePacketPath: topWavePacketPath,
    dossierPath: dossierPath,
    latestRunPath: latestRunFile.path,
    historyIndexPath: historyIndexFile.path,
    dashboard: rebuiltDashboard,
  );
}

List<Map<String, Object?>> hydrateWorldsWithTruthSurfacesForSnapshotV1({
  required List<Map<String, Object?>> worlds,
  required List<Map<String, Object?>> routeInventories,
  required List<Map<String, Object?>> visualInstrumentationSurfaces,
  required List<Map<String, Object?>> screenshotEvidenceSurfaces,
}) {
  final routeInventoryByWorldId = <String, Map<String, Object?>>{
    for (final item in routeInventories)
      if ((item['world_id'] as String?)?.isNotEmpty ?? false)
        item['world_id'] as String: item,
  };
  final visualInstrumentationByWorldId = <String, Map<String, Object?>>{
    for (final item in visualInstrumentationSurfaces)
      if ((item['world_id'] as String?)?.isNotEmpty ?? false)
        item['world_id'] as String: item,
  };
  final screenshotEvidenceByWorldId = <String, Map<String, Object?>>{
    for (final item in screenshotEvidenceSurfaces)
      if ((item['world_id'] as String?)?.isNotEmpty ?? false)
        item['world_id'] as String: item,
  };

  return worlds
      .map((world) {
        final hydrated = Map<String, Object?>.from(world);
        final worldId = hydrated['world_id'] as String? ?? '';
        final routeInventory = routeInventoryByWorldId[worldId];
        final visualInstrumentation = visualInstrumentationByWorldId[worldId];
        final screenshotEvidence = screenshotEvidenceByWorldId[worldId];
        final activeRunnerFamilies = <String>{
          ...((hydrated['active_runner_families'] as List<Object?>? ?? const [])
              .whereType<String>()),
        };

        final routeInventoryStatus =
            routeInventory?['inventory_status'] as String? ?? '';
        if (routeInventoryStatus == 'executable') {
          final summary = routeInventory?['summary'] as String? ?? '';
          if (summary.isNotEmpty) {
            hydrated['ownership_truth'] = summary;
          }
          final rows =
              (routeInventory?['rows'] as List<Object?>? ?? const <Object?>[])
                  .whereType<Map>()
                  .map(Map<String, Object?>.from);
          for (final row in rows) {
            final route = row['route'] as String?;
            if (route != null && route.isNotEmpty) {
              activeRunnerFamilies.add(route);
            }
          }
        }

        final visualInstrumentationStatus =
            visualInstrumentation?['instrumentation_status'] as String? ?? '';
        if (visualInstrumentationStatus == 'executable') {
          hydrated['visual_health'] = 'pass';
          hydrated['visual_family_status'] = 'shared';
        }

        final screenshotEvidenceStatus =
            screenshotEvidence?['evidence_status'] as String? ?? '';
        if (screenshotEvidenceStatus == 'executable') {
          hydrated['visual_health'] = 'pass';
          hydrated['screenshot_evidence_count'] =
              (screenshotEvidence?['screenshot_evidence_count'] as num?)
                  ?.toInt() ??
              0;
          hydrated['screenshot_artifacts'] =
              (screenshotEvidence?['entries'] as List<Object?>? ?? const [])
                  .whereType<Map>()
                  .map(Map<String, Object?>.from)
                  .map((entry) {
                    final sessionId =
                        entry['session_id'] as String? ?? 'unknown';
                    final path = entry['path'] as String? ?? '';
                    return <String, Object?>{
                      'label': 'Preview: $sessionId.png',
                      'path': path,
                      'type': 'screenshot',
                      'exists': path.isNotEmpty
                          ? File(path).existsSync()
                          : false,
                      'note': null,
                      'is_primary_evidence': true,
                    };
                  })
                  .toList(growable: false);
        }

        if (activeRunnerFamilies.isNotEmpty) {
          hydrated['active_runner_families'] = activeRunnerFamilies.toList()
            ..sort();
        }

        return hydrated;
      })
      .toList(growable: false);
}

List<Map<String, Object?>> _syncWorldsFromRegistryForSnapshotV1({
  required List<Map<String, Object?>> worlds,
  required Map<String, WorldReadinessRegistryRowV1> worldRegistryById,
}) {
  return worlds
      .map((world) {
        final synced = Map<String, Object?>.from(world);
        final worldId = synced['world_id'] as String? ?? '';
        final registryRow = worldRegistryById[worldId];
        if (registryRow == null) {
          return synced;
        }

        synced['quality_summary'] = registryRow.qualitySummary;
        synced['readiness_status'] = registryRow.readinessStatus;
        synced['primary_readiness_links'] = registryRow.readinessLinks;
        synced['top_open_gaps'] = registryRow.topOpenGaps;
        synced['release_grade_blocker_note'] =
            registryRow.releaseGradeBlockerNote;
        synced['lens_statuses'] = <String, Object?>{
          'content_clarity': registryRow.contentClarity,
          'pedagogy_learning_effect': registryRow.pedagogyLearningEffect,
          'feedback_explanation_quality':
              registryRow.feedbackExplanationQuality,
          'learner_language_naturalness':
              registryRow.learnerLanguageNaturalness,
          'content_runtime_alignment': registryRow.contentRuntimeAlignment,
          'cross_world_consistency_fit': registryRow.crossWorldConsistencyFit,
        };
        synced['content_health'] = registryRow.contentClarity == 'done'
            ? 'done'
            : 'in_progress';
        synced['pedagogy_health'] =
            (registryRow.pedagogyLearningEffect == 'done' &&
                registryRow.feedbackExplanationQuality == 'done')
            ? 'done'
            : 'in_progress';
        synced['sequencing_health'] =
            registryRow.crossWorldConsistencyFit == 'done'
            ? 'done'
            : 'in_progress';

        return synced;
      })
      .toList(growable: false);
}

String renderAuditHubReviewExportV1({
  required Map<String, Object?> snapshot,
  required AuditHubOperationalDashboardV1 dashboard,
  required String timestampUtc,
  Map<String, Object?> previousSnapshot = const <String, Object?>{},
}) {
  final latestRun = Map<String, Object?>.from(
    snapshot['latest_run'] as Map? ?? const <String, Object?>{},
  );
  final git = Map<String, Object?>.from(
    latestRun['git'] as Map? ?? const <String, Object?>{},
  );
  final summary = Map<String, Object?>.from(
    latestRun['summary'] as Map? ?? const <String, Object?>{},
  );
  final fullAuditTrace = Map<String, Object?>.from(
    latestRun['full_audit_trace'] as Map? ?? const <String, Object?>{},
  );
  final topQueue = (snapshot['codex_work_queue'] as List<Object?>? ?? const [])
      .whereType<Map>()
      .take(3)
      .map(Map<String, Object?>.from)
      .toList();
  final candidate = dashboard.recalibrationCandidate;
  final canonical = dashboard.canonicalReadiness;
  final completionGapSynthesis = dashboard.completionGapSynthesis;
  final previousCompletionGapSynthesis = Map<String, Object?>.from(
    previousSnapshot['completion_gap_synthesis'] as Map? ??
        const <String, Object?>{},
  );
  final previousCandidate = Map<String, Object?>.from(
    previousSnapshot['readiness_recalibration_candidate'] as Map? ??
        const <String, Object?>{},
  );
  final previousTopFrontier = Map<String, Object?>.from(
    previousCompletionGapSynthesis['top_machine_frontier'] as Map? ??
        const <String, Object?>{},
  );
  final previousTopFrontierLabel =
      previousTopFrontier['title'] as String? ??
      previousTopFrontier['gap_id'] as String? ??
      'none';
  final recommendedNextGap = _bestNextGapV1(completionGapSynthesis);
  final currentTopFrontierLabel =
      completionGapSynthesis.topMachineFrontier?.title ?? 'none';
  final currentRecommendedLabel = recommendedNextGap?.title ?? 'none';
  final previousMachineReducible =
      previousCompletionGapSynthesis['machine_reducible_remaining_count']
          as int? ??
      completionGapSynthesis.machineReducibleRemainingCount;
  final previousManualBound =
      previousCompletionGapSynthesis['manual_bound_remaining_count'] as int? ??
      completionGapSynthesis.manualBoundRemainingCount;
  final previousCandidateStatus =
      previousCandidate['recalibration_candidate_status'] as String? ??
      candidate.status.wireValue;
  final latestRunId = latestRun['run_id'] as String? ?? 'unknown';
  final latestRunCompletedAtUtc =
      latestRun['completed_at_utc'] as String? ?? 'unknown';
  final executedSteps =
      (fullAuditTrace['executed_steps'] as List<Object?>? ?? const <Object?>[])
          .map((value) => '$value')
          .toList();
  final regeneratedArtifacts =
      (fullAuditTrace['regenerated_artifacts'] as List<Object?>? ??
              const <Object?>[])
          .map((value) => '$value')
          .toList();
  final snapshotTimestamp =
      snapshot['generated_at_utc'] as String? ?? latestRunCompletedAtUtc;
  final reflectsLatestKnownSnapshotRun =
      snapshotTimestamp == latestRunCompletedAtUtc &&
      latestRunCompletedAtUtc != 'unknown';
  final dirtyFileCount = (git['dirty_file_count'] as num?)?.toInt();
  final treeClassification = (git['is_clean_tree'] as bool? ?? false)
      ? 'clean'
      : dirtyFileCount == null
      ? 'dirty'
      : 'dirty ($dirtyFileCount files)';
  final topWavePacket = Map<String, Object?>.from(
    snapshot['top_wave_packet'] as Map? ?? const <String, Object?>{},
  );
  final pedagogicalProgressionTruth = Map<String, Object?>.from(
    snapshot['pedagogical_progression_truth'] as Map? ??
        const <String, Object?>{},
  );
  final pedagogicalReports =
      (snapshot['world_pedagogical_progression_surfaces'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final pedagogicalOpenFindingCount =
      (pedagogicalProgressionTruth['open_finding_count'] as num?)?.toInt() ?? 0;
  final pedagogicalAffectedWorlds =
      (pedagogicalProgressionTruth['affected_worlds'] as List<Object?>? ??
              const <Object?>[])
          .whereType<String>()
          .toList(growable: false);
  final pedagogicalTopCategories =
      (pedagogicalProgressionTruth['top_categories'] as List<Object?>? ??
              const <Object?>[])
          .whereType<String>()
          .toList(growable: false);
  final pedagogicalTopFindings =
      pedagogicalReports
          .expand(
            (report) =>
                (report['findings'] as List<Object?>? ?? const <Object?>[])
                    .whereType<Map>()
                    .map(Map<String, Object?>.from),
          )
          .toList(growable: false)
        ..sort(
          (left, right) =>
              ((left['ev_priority_order'] as num?)?.toInt() ?? 9999).compareTo(
                (right['ev_priority_order'] as num?)?.toInt() ?? 9999,
              ),
        );
  final findingInventory = Map<String, Object?>.from(
    snapshot['finding_inventory'] as Map? ?? const <String, Object?>{},
  );
  final worldFindingBreakdowns =
      (findingInventory['world_breakdown'] as List<Object?>? ?? const [])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final biggestOpenWorldBuckets =
      (findingInventory['biggest_open_world_buckets'] as List<Object?>? ??
              const [])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final currentFrontierBucket = Map<String, Object?>.from(
    findingInventory['current_frontier_visible_bucket'] as Map? ??
        const <String, Object?>{},
  );
  final unificationDriftBreakdown = Map<String, Object?>.from(
    findingInventory['unification_drift_breakdown'] as Map? ??
        const <String, Object?>{},
  );
  final topWaveLabel =
      topWavePacket['title'] as String? ??
      recommendedNextGap?.title ??
      currentTopFrontierLabel;
  final boundedFamilyLabel = topWavePacket['likely_seam'] as String?;
  final lastSurfacedTruthLayerFrontier =
      completionGapSynthesis.gaps
          .where(
            (gap) =>
                gap.admissibility ==
                CompletionGapAdmissibilityV1.truthLayerFirst,
          )
          .toList()
        ..sort(
          (left, right) =>
              left.evPriorityOrder.compareTo(right.evPriorityOrder),
        );
  final routeSignal = _buildRouteTo100ProgressSignalV1(
    previousTopMachineFrontier: previousTopFrontierLabel,
    currentTopMachineFrontier: currentTopFrontierLabel,
    previousMachineReducibleRemainingCount: previousMachineReducible,
    currentMachineReducibleRemainingCount:
        completionGapSynthesis.machineReducibleRemainingCount,
    previousManualBoundRemainingCount: previousManualBound,
    currentManualBoundRemainingCount:
        completionGapSynthesis.manualBoundRemainingCount,
  );
  final latestReductionDelta = _buildLatestReductionDeltaV1(
    previousTopMachineFrontier: previousTopFrontierLabel,
    currentTopMachineFrontier: currentTopFrontierLabel,
    previousMachineReducibleRemainingCount: previousMachineReducible,
    currentMachineReducibleRemainingCount:
        completionGapSynthesis.machineReducibleRemainingCount,
    previousManualBoundRemainingCount: previousManualBound,
    currentManualBoundRemainingCount:
        completionGapSynthesis.manualBoundRemainingCount,
    boundedFamilyLabel: boundedFamilyLabel,
    waveLabel: topWaveLabel,
  );

  final buffer = StringBuffer()
    ..writeln('# Audit Hub Review Export $timestampUtc')
    ..writeln()
    ..writeln('## Run Metadata')
    ..writeln()
    ..writeln('- Timestamp: `$timestampUtc`')
    ..writeln(
      '- Last full run: `${latestRun['completed_at_utc'] ?? 'unknown'}`',
    )
    ..writeln('- Branch: `${git['branch'] ?? 'unknown'}`')
    ..writeln('- HEAD: `${git['head'] ?? 'unknown'}`')
    ..writeln(
      '- Tree: `${(git['is_clean_tree'] as bool? ?? false) ? 'clean' : 'dirty'}`',
    )
    ..writeln('- Audit version: `${snapshot['version'] ?? 'unknown'}`')
    ..writeln('- Normalized result count: `${summary['total_results'] ?? 0}`')
    ..writeln()
    ..writeln('## Full Audit Trace')
    ..writeln()
    ..writeln('- Run type: `${fullAuditTrace['run_type'] ?? 'not_recorded'}`')
    ..writeln(
      '- Duration ms: `${fullAuditTrace['duration_ms'] ?? 'not_recorded'}`',
    )
    ..writeln(
      '- Run ids: `${fullAuditTrace['previous_run_id'] ?? 'unknown'} -> ${fullAuditTrace['current_run_id'] ?? latestRunId}`',
    )
    ..writeln(
      '- Executed steps: ${executedSteps.isEmpty ? 'none recorded' : executedSteps.join(' | ')}',
    )
    ..writeln(
      '- Regenerated artifacts: ${regeneratedArtifacts.isEmpty ? 'none recorded' : regeneratedArtifacts.join(' | ')}',
    )
    ..writeln()
    ..writeln('## Latest Reduction Delta')
    ..writeln()
    ..writeln('- Last admitted wave: `$topWaveLabel`')
    ..writeln(
      '- Exact bounded family reduced or surfaced: `${latestReductionDelta.familyLabel}`',
    )
    ..writeln(
      '- Primary measurable before -> after delta: `${latestReductionDelta.primaryDelta}`',
    )
    ..writeln('- Frontier movement: `${latestReductionDelta.frontierDelta}`')
    ..writeln()
    ..writeln('## Previous vs Current Snapshot')
    ..writeln()
    ..writeln(
      '- Top machine frontier: `$previousTopFrontierLabel -> $currentTopFrontierLabel`',
    )
    ..writeln(
      '- Machine-reducible remaining count: `$previousMachineReducible -> ${completionGapSynthesis.machineReducibleRemainingCount}`',
    )
    ..writeln(
      '- Manual-bound remaining count: `$previousManualBound -> ${completionGapSynthesis.manualBoundRemainingCount}`',
    )
    ..writeln(
      '- Readiness recalibration candidate status: `$previousCandidateStatus -> ${candidate.status.wireValue}`',
    )
    ..writeln()
    ..writeln('## Run Integrity')
    ..writeln()
    ..writeln('- Latest run id: `$latestRunId`')
    ..writeln('- Reviewed HEAD: `${git['head'] ?? 'unknown'}`')
    ..writeln('- Snapshot timestamp: `$snapshotTimestamp`')
    ..writeln('- Review timestamp: `$timestampUtc`')
    ..writeln(
      '- Reflects latest known snapshot/run: `${reflectsLatestKnownSnapshotRun ? 'yes' : 'no'}`',
    )
    ..writeln('- Tree classification: `$treeClassification`')
    ..writeln()
    ..writeln('## Route-to-100 Progress Signal')
    ..writeln()
    ..writeln('- Signal: `${routeSignal.signal}`')
    ..writeln('- Reason: ${routeSignal.reason}')
    ..writeln()
    ..writeln('## Current Operational Context')
    ..writeln()
    ..writeln(
      '- Current paused manual clusters: ${completionGapSynthesis.pausedManualClusters.isEmpty ? 'none' : completionGapSynthesis.pausedManualClusters.join(' | ')}',
    )
    ..writeln(
      '- Last surfaced truth-layer frontier: ${lastSurfacedTruthLayerFrontier.isEmpty ? 'none' : lastSurfacedTruthLayerFrontier.first.title}',
    )
    ..writeln('- Last closed family: ${latestReductionDelta.closedFamilyLabel}')
    ..writeln()
    ..writeln('## Pedagogical / Progression Truth')
    ..writeln()
    ..writeln(
      '- Status: `${pedagogicalProgressionTruth['status'] ?? 'grounded_data_limited'}`',
    )
    ..writeln('- Open finding count: `$pedagogicalOpenFindingCount`')
    ..writeln(
      '- Affected worlds: ${pedagogicalAffectedWorlds.isEmpty ? 'none' : pedagogicalAffectedWorlds.join(' | ')}',
    )
    ..writeln(
      '- Top categories: ${pedagogicalTopCategories.isEmpty ? 'none' : pedagogicalTopCategories.take(5).join(' | ')}',
    )
    ..writeln(
      '- Summary: ${pedagogicalProgressionTruth['summary'] ?? 'No pedagogical/progression summary is available.'}',
    )
    ..writeln(
      '- Top surfaced findings: ${pedagogicalTopFindings.isEmpty ? 'none' : pedagogicalTopFindings.take(4).map((finding) => '${finding['gap_id']}: ${finding['reason']}').join(' | ')}',
    )
    ..writeln()
    ..writeln('## Finding Inventory')
    ..writeln()
    ..writeln(
      '- Worlds with open findings: `${(findingInventory['worlds_with_open_findings_count'] as num?)?.toInt() ?? 0}` / `${worldFindingBreakdowns.length}`',
    )
    ..writeln(
      '- Biggest open world buckets: ${biggestOpenWorldBuckets.isEmpty ? 'none surfaced' : biggestOpenWorldBuckets.map((bucket) => '${bucket['world_id']}=${bucket['total_open_findings']} (${bucket['dominant_bucket_label']})').join(' | ')}',
    )
    ..writeln(
      '- Highest-EV visible bucket inside current frontier: ${currentFrontierBucket.isEmpty ? 'none surfaced' : '${currentFrontierBucket['world_id']} ${currentFrontierBucket['dominant_bucket_label']}=${currentFrontierBucket['dominant_bucket_count']} (total=${currentFrontierBucket['total_open_findings']})'}',
    )
    ..writeln(
      '- Current frontier residue summary: ${currentFrontierBucket.isEmpty ? 'none surfaced' : 'machine=${currentFrontierBucket['machine_reducible_findings']}, truth=${currentFrontierBucket['truth_layer_first_findings']}, proof/manual=${currentFrontierBucket['proof_manual_only_findings']}, pedagogical=${currentFrontierBucket['pedagogical_total_count']}, unification=${currentFrontierBucket['unification_count']}, other_world_quality=${currentFrontierBucket['other_world_quality_count']}'}',
    )
    ..writeln(
      '- Unification drift breakdown: mixed_family=${unificationDriftBreakdown['mixed_family_count'] ?? 0} | shared_owner_missing=${unificationDriftBreakdown['shared_owner_missing_count'] ?? 0} | local_override=${unificationDriftBreakdown['local_override_count'] ?? 0} | route_inventory_missing=${unificationDriftBreakdown['route_inventory_missing_count'] ?? 0} | visual_instrumentation_missing=${unificationDriftBreakdown['visual_instrumentation_missing_count'] ?? 0} | screenshot_evidence_missing=${unificationDriftBreakdown['screenshot_evidence_missing_count'] ?? 0}',
    )
    ..writeln(
      '- Coverage note: ${findingInventory['coverage_note'] ?? 'No explicit inventory coverage note is available.'}',
    )
    ..writeln()
    ..writeln('## Project Health Snapshot')
    ..writeln()
    ..writeln('- Source SSOT: `${canonical.sourceSsotPath}`')
    ..writeln(
      '- Core readiness: `${canonical.coreReadinessPercent.toStringAsFixed(1)} / 100`',
    )
    ..writeln(
      '- Ship readiness: `${canonical.shipReadinessPercent.toStringAsFixed(1)} / 100`',
    )
    ..writeln(
      '- Final readiness: `${canonical.finalReadinessPercent.toStringAsFixed(1)} / 100`',
    )
    ..writeln('- Top bottleneck block: `${canonical.topBottleneckBlock}`')
    ..writeln('- Top bottleneck epic: `${canonical.topBottleneckEpic}`')
    ..writeln('- Confidence note: `${canonical.confidenceNote}`')
    ..writeln()
    ..writeln('## Readiness Recalibration Candidate')
    ..writeln()
    ..writeln(
      '- Canonical readiness source path: `${candidate.canonicalReadinessSourcePath}`',
    )
    ..writeln('- Current canonical scores:')
    ..writeln(
      '  - Core: `${candidate.canonicalReadiness.coreReadinessPercent.toStringAsFixed(1)} / 100`',
    )
    ..writeln(
      '  - Ship: `${candidate.canonicalReadiness.shipReadinessPercent.toStringAsFixed(1)} / 100`',
    )
    ..writeln(
      '  - Final: `${candidate.canonicalReadiness.finalReadinessPercent.toStringAsFixed(1)} / 100`',
    )
    ..writeln(
      '- Recalibration candidate status: `${candidate.status.wireValue}`',
    )
    ..writeln(
      '- Recalibration justified now: `${candidate.recalibrationJustifiedNow ? 'yes' : 'no'}`',
    )
    ..writeln('- Recalibration reason: `${candidate.recalibrationReason}`')
    ..writeln('- Raw vs effective note: `${candidate.rawVsEffectiveNote}`')
    ..writeln(
      '- Candidate score deltas: `core=${candidate.candidateScoreDeltas.coreDelta.toStringAsFixed(1)}`, `ship=${candidate.candidateScoreDeltas.shipDelta.toStringAsFixed(1)}`, `final=${candidate.candidateScoreDeltas.finalDelta.toStringAsFixed(1)}`',
    )
    ..writeln()
    ..writeln('### Candidate Block Movements')
    ..writeln();

  if (candidate.candidateBlockMovements.isEmpty) {
    buffer.writeln('- none justified');
  } else {
    for (final movement in candidate.candidateBlockMovements) {
      final capSuffix = movement.effectiveCapReason == null
          ? ''
          : ' | cap=`${movement.effectiveCapReason}`';
      buffer.writeln(
        '- `${movement.blockId}` ${movement.blockTitle}: raw `${movement.rawScoreBefore.toStringAsFixed(2)} -> ${movement.rawScoreAfter.toStringAsFixed(2)}`, effective `${movement.effectiveScoreBefore.toStringAsFixed(2)} -> ${movement.effectiveScoreAfter.toStringAsFixed(2)}`$capSuffix',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('### Candidate Epic Movements')
    ..writeln();
  if (candidate.candidateEpicMovements.isEmpty) {
    buffer.writeln('- none justified');
  } else {
    for (final movement in candidate.candidateEpicMovements) {
      buffer.writeln(
        '- `${movement.epicId}` `${movement.canonicalStatus.wireValue} -> ${movement.candidateStatus.wireValue}` (${movement.direction.wireValue})',
      );
      buffer.writeln('  - reason: ${movement.reason}');
      if (movement.evidenceRefs.isNotEmpty) {
        buffer.writeln('  - evidence: ${movement.evidenceRefs.join(' | ')}');
      }
    }
  }

  buffer
    ..writeln()
    ..writeln('### Proof Gaps If Not Justified')
    ..writeln();
  if (candidate.proofGapsIfNotJustified.isEmpty) {
    buffer.writeln('- none');
  } else {
    for (final gap in candidate.proofGapsIfNotJustified) {
      buffer.writeln('- $gap');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Top Work Queue')
    ..writeln();
  for (final entry in topQueue) {
    buffer.writeln(
      '- `#${entry['rank']}` `${entry['title']}`: ${entry['reason'] ?? ''}',
    );
  }
  buffer.writeln(
    '- Recommended next wave (normalized): `${recommendedNextGap?.title ?? 'none'}`',
  );
  buffer.writeln('- Routing truth normalized before recommendation: `yes`');

  buffer
    ..writeln()
    ..writeln('## Completion Gap Synthesis')
    ..writeln()
    ..writeln(
      '- All remaining gaps count: `${completionGapSynthesis.allRemainingGapsCount}`',
    )
    ..writeln(
      '- Machine-reducible remaining count: `${completionGapSynthesis.machineReducibleRemainingCount}`',
    )
    ..writeln(
      '- Manual-bound remaining count: `${completionGapSynthesis.manualBoundRemainingCount}`',
    )
    ..writeln(
      '- Top machine frontier: `${completionGapSynthesis.topMachineFrontier?.title ?? 'none'}`',
    )
    ..writeln(
      '- Recommended next frontier: `${recommendedNextGap?.title ?? 'none'}`',
    )
    ..writeln()
    ..writeln('### Paused Manual Clusters')
    ..writeln();
  if (completionGapSynthesis.pausedManualClusters.isEmpty) {
    buffer.writeln('- none');
  } else {
    for (final cluster in completionGapSynthesis.pausedManualClusters) {
      buffer.writeln('- $cluster');
    }
  }

  buffer
    ..writeln()
    ..writeln('### Why 100 Not Reached')
    ..writeln();
  for (final reason in completionGapSynthesis.why100NotReached) {
    buffer.writeln('- $reason');
  }

  buffer
    ..writeln()
    ..writeln('### Gap Candidates')
    ..writeln();
  for (final gap in completionGapSynthesis.gaps) {
    buffer.writeln(
      '- `${gap.gapId}` `${gap.title}` | category=`${gap.category}` | status=`${gap.currentStatus}` | admissibility=`${gap.admissibility.wireValue}` | priority=`${gap.evPriorityOrder}`',
    );
    buffer.writeln('  - source: ${gap.sourceTruthOwner}');
    if (gap.readinessBlocks.isNotEmpty) {
      buffer.writeln('  - readiness: ${gap.readinessBlocks.join(', ')}');
    }
    if (gap.epicMappings.isNotEmpty) {
      buffer.writeln('  - epics: ${gap.epicMappings.join(' | ')}');
    }
    if (gap.worldScope.isNotEmpty) {
      buffer.writeln('  - worlds: ${gap.worldScope.join(', ')}');
    }
    if (gap.surfaceScope.isNotEmpty) {
      buffer.writeln('  - scope: ${gap.surfaceScope.join(' | ')}');
    }
    buffer.writeln('  - seam: ${gap.likelySeam}');
    if (gap.ownerFiles.isNotEmpty) {
      buffer.writeln('  - owners: ${gap.ownerFiles.join(' | ')}');
    }
    if (gap.measurableProofPath.isNotEmpty) {
      buffer.writeln(
        '  - measurable path: ${gap.measurableProofPath.join(' | ')}',
      );
    }
    if (gap.prerequisiteBlockers.isNotEmpty) {
      buffer.writeln(
        '  - prerequisites: ${gap.prerequisiteBlockers.join(' | ')}',
      );
    }
    buffer.writeln('  - frontier reason: ${gap.nextFrontierReason}');
  }

  return buffer.toString();
}

String renderProjectStatusDossierV1({
  required Map<String, Object?> snapshot,
  required AuditHubOperationalDashboardV1 dashboard,
  required String timestampUtc,
  required String reviewPath,
  required String topWavePacketPath,
  required String dossierPath,
  Map<String, Object?> previousSnapshot = const <String, Object?>{},
}) {
  final latestRun = Map<String, Object?>.from(
    snapshot['latest_run'] as Map? ?? const <String, Object?>{},
  );
  final git = Map<String, Object?>.from(
    latestRun['git'] as Map? ?? const <String, Object?>{},
  );
  final summary = Map<String, Object?>.from(
    latestRun['summary'] as Map? ?? const <String, Object?>{},
  );
  final candidate = dashboard.recalibrationCandidate;
  final canonical = dashboard.canonicalReadiness;
  final completionGapSynthesis = dashboard.completionGapSynthesis;
  final previousCompletionGapSynthesis = Map<String, Object?>.from(
    previousSnapshot['completion_gap_synthesis'] as Map? ??
        const <String, Object?>{},
  );
  final previousCandidate = Map<String, Object?>.from(
    previousSnapshot['readiness_recalibration_candidate'] as Map? ??
        const <String, Object?>{},
  );
  final previousTopFrontier = Map<String, Object?>.from(
    previousCompletionGapSynthesis['top_machine_frontier'] as Map? ??
        const <String, Object?>{},
  );
  final previousTopFrontierLabel =
      previousTopFrontier['title'] as String? ??
      previousTopFrontier['gap_id'] as String? ??
      'none';
  final recommendedNextGap = _bestNextGapV1(completionGapSynthesis);
  final currentTopFrontierLabel =
      completionGapSynthesis.topMachineFrontier?.title ?? 'none';
  final currentRecommendedLabel = recommendedNextGap?.title ?? 'none';
  final previousMachineReducible =
      previousCompletionGapSynthesis['machine_reducible_remaining_count']
          as int? ??
      completionGapSynthesis.machineReducibleRemainingCount;
  final previousManualBound =
      previousCompletionGapSynthesis['manual_bound_remaining_count'] as int? ??
      completionGapSynthesis.manualBoundRemainingCount;
  final previousCandidateStatus =
      previousCandidate['recalibration_candidate_status'] as String? ??
      candidate.status.wireValue;
  final routeSignal = _buildRouteTo100ProgressSignalV1(
    previousTopMachineFrontier: previousTopFrontierLabel,
    currentTopMachineFrontier: currentTopFrontierLabel,
    previousMachineReducibleRemainingCount: previousMachineReducible,
    currentMachineReducibleRemainingCount:
        completionGapSynthesis.machineReducibleRemainingCount,
    previousManualBoundRemainingCount: previousManualBound,
    currentManualBoundRemainingCount:
        completionGapSynthesis.manualBoundRemainingCount,
  );
  final latestReductionDelta = _buildLatestReductionDeltaV1(
    previousTopMachineFrontier: previousTopFrontierLabel,
    currentTopMachineFrontier: currentTopFrontierLabel,
    previousMachineReducibleRemainingCount: previousMachineReducible,
    currentMachineReducibleRemainingCount:
        completionGapSynthesis.machineReducibleRemainingCount,
    previousManualBoundRemainingCount: previousManualBound,
    currentManualBoundRemainingCount:
        completionGapSynthesis.manualBoundRemainingCount,
    boundedFamilyLabel: recommendedNextGap?.likelySeam,
    waveLabel: currentRecommendedLabel,
  );

  final blockerClusters =
      (snapshot['blocker_clusters'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();
  final worlds =
      (snapshot['worlds'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList()
        ..sort(
          (left, right) =>
              _parseWorldNumberV1(left['world_id'] as String? ?? '')!.compareTo(
                _parseWorldNumberV1(right['world_id'] as String? ?? '')!,
              ),
        );
  final auditResults =
      (latestRun['results'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();

  final contentTrust = _findAuditResultByIdV1(
    auditResults,
    'content_trust_state_v1',
  );
  final unificationAudit = _findAuditResultByIdV1(
    auditResults,
    'world_runner_unification_state_v1',
  );
  final productSurfaceAudit = _findAuditResultByIdV1(
    auditResults,
    'product_surface_state_v1',
  );
  final visualProofAudit = _findAuditResultByIdV1(
    auditResults,
    'visual_proof_state_v1',
  );
  final opsAudit = _findAuditResultByIdV1(
    auditResults,
    'ops_release_confidence_state_v1',
  );
  final firstUserCluster = _findBlockerClusterByIdV1(
    blockerClusters,
    'first_user_surface_trust',
  );
  final contentTrustCluster = _findBlockerClusterByIdV1(
    blockerClusters,
    'content_trust',
  );
  final opsCluster = _findBlockerClusterByIdV1(
    blockerClusters,
    'ops_release_confidence',
  );
  final visualCluster = _findBlockerClusterByIdV1(
    blockerClusters,
    'visual_proof_truth',
  );
  final topTruthLayerFrontier =
      completionGapSynthesis.gaps
          .where(
            (gap) =>
                gap.admissibility ==
                CompletionGapAdmissibilityV1.truthLayerFirst,
          )
          .toList()
        ..sort(
          (left, right) =>
              left.evPriorityOrder.compareTo(right.evPriorityOrder),
        );
  final unificationRows =
      (snapshot['unification_matrix'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();
  final compatibleRows = unificationRows.where(
    (row) => row['compatible_for_normalization'] == true,
  );
  final mixedOrPartialRows = unificationRows.where(
    (row) =>
        (row['current_status'] as String? ?? '').contains('partial') ||
        (row['visual_family_status'] as String? ?? '').contains('mixed') ||
        (row['old_path_residue'] as bool? ?? false),
  );
  final worldTruthSurfaces =
      (snapshot['world_truth_surfaces'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();
  final routeInventories =
      (snapshot['world_route_ownership_inventories'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();
  final visualInstrumentation =
      (snapshot['world_visual_instrumentation_surfaces'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();
  final screenshotEvidence =
      (snapshot['world_screenshot_evidence_surfaces'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();
  final pedagogicalProgressionTruth = Map<String, Object?>.from(
    snapshot['pedagogical_progression_truth'] as Map? ??
        const <String, Object?>{},
  );
  final pedagogicalReports =
      (snapshot['world_pedagogical_progression_surfaces'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();
  final pedagogicalReportByWorldId = <String, Map<String, Object?>>{
    for (final report in pedagogicalReports)
      if ((report['world_id'] as String?)?.isNotEmpty ?? false)
        report['world_id'] as String: report,
  };
  final pedagogicalOpenFindingCount =
      (pedagogicalProgressionTruth['open_finding_count'] as num?)?.toInt() ?? 0;
  final findingInventory = Map<String, Object?>.from(
    snapshot['finding_inventory'] as Map? ?? const <String, Object?>{},
  );
  final worldFindingBreakdowns =
      (findingInventory['world_breakdown'] as List<Object?>? ?? const [])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final worldFindingBreakdownByWorldId = <String, Map<String, Object?>>{
    for (final entry in worldFindingBreakdowns)
      if ((entry['world_id'] as String?)?.isNotEmpty ?? false)
        entry['world_id'] as String: entry,
  };
  final biggestOpenWorldBuckets =
      (findingInventory['biggest_open_world_buckets'] as List<Object?>? ??
              const [])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final currentFrontierBucket = Map<String, Object?>.from(
    findingInventory['current_frontier_visible_bucket'] as Map? ??
        const <String, Object?>{},
  );
  final unificationDriftBreakdown = Map<String, Object?>.from(
    findingInventory['unification_drift_breakdown'] as Map? ??
        const <String, Object?>{},
  );
  final pedagogicalTopCategories =
      (pedagogicalProgressionTruth['top_categories'] as List<Object?>? ??
              const <Object?>[])
          .whereType<String>()
          .toList(growable: false);
  final pedagogicalAffectedWorlds =
      (pedagogicalProgressionTruth['affected_worlds'] as List<Object?>? ??
              const <Object?>[])
          .whereType<String>()
          .toList(growable: false);
  final proofSurfaceExecutableCount = worldTruthSurfaces
      .where((item) => item['proof_surface_status'] == 'executable')
      .length;
  final routeInventoryExecutableCount = routeInventories
      .where((item) => item['inventory_status'] == 'executable')
      .length;
  final visualInstrumentationExecutableCount = visualInstrumentation
      .where((item) => item['instrumentation_status'] == 'executable')
      .length;
  final screenshotEvidenceExecutableCount = screenshotEvidence
      .where((item) => item['evidence_status'] == 'executable')
      .length;
  final latestRunId = latestRun['run_id'] as String? ?? 'unknown';
  final latestRunCompletedAtUtc =
      latestRun['completed_at_utc'] as String? ?? 'unknown';
  final snapshotTimestamp =
      snapshot['generated_at_utc'] as String? ?? latestRunCompletedAtUtc;
  final dirtyFileCount = (git['dirty_file_count'] as num?)?.toInt();
  final treeClassification = (git['is_clean_tree'] as bool? ?? false)
      ? 'clean'
      : dirtyFileCount == null
      ? 'dirty'
      : 'dirty ($dirtyFileCount files)';
  final reflectsLatestKnownSnapshotRun =
      snapshotTimestamp == latestRunCompletedAtUtc &&
      latestRunCompletedAtUtc != 'unknown';
  final strongestLiveWorld = worlds.firstWhere(
    (world) => (world['world_id'] as String? ?? '') == 'W1',
    orElse: () => worlds.isEmpty ? const <String, Object?>{} : worlds.first,
  );
  final executiveSummary =
      'The project is a multi-world poker-learning product with W1 as the strongest live learner path, W0 as the current machine-reducible release-grade opener frontier, and ops/release confidence still paused on a manual boundary.';

  final buffer = StringBuffer()
    ..writeln('# Project Status Dossier $timestampUtc')
    ..writeln()
    ..writeln('## 1. Executive Summary')
    ..writeln()
    ..writeln(
      '- Canonical readiness: `core ${canonical.coreReadinessPercent.toStringAsFixed(1)} / ship ${canonical.shipReadinessPercent.toStringAsFixed(1)} / final ${canonical.finalReadinessPercent.toStringAsFixed(1)}`',
    )
    ..writeln(
      '- Top bottleneck: `${canonical.topBottleneckBlock}` / `${canonical.topBottleneckEpic}`',
    )
    ..writeln('- Top machine frontier: `$currentTopFrontierLabel`')
    ..writeln(
      '- Manual-bound clusters: ${completionGapSynthesis.pausedManualClusters.isEmpty ? 'none' : completionGapSynthesis.pausedManualClusters.join(' | ')}',
    )
    ..writeln(
      '- Route-to-100 signal: `${routeSignal.signal}` because ${routeSignal.reason}.',
    )
    ..writeln('- Plain-language state: $executiveSummary')
    ..writeln()
    ..writeln('## 2. What Was Completed Recently')
    ..writeln()
    ..writeln(
      '- Latest measurable reductions: ${latestReductionDelta.primaryDelta == 'no measurable delta in canonical frontier/count truth' ? 'No measurable reduction is explicit in current vs previous canonical truth.' : '${latestReductionDelta.familyLabel} (${latestReductionDelta.primaryDelta}).'}',
    )
    ..writeln(
      '- Latest surfaced truth layers: ${topTruthLayerFrontier.isEmpty ? 'No truth-layer-first frontier is explicit in current canonical truth.' : 'Current highest surfaced truth-layer frontier remains `${topTruthLayerFrontier.first.title}`.'}',
    )
    ..writeln(
      '- Latest restored operator/infrastructure seams: none explicit in current snapshot truth.',
    )
    ..writeln()
    ..writeln('## 3. Current Project State by Major Block')
    ..writeln()
    ..write(
      _renderDossierMajorBlockV1(
        title: 'Readiness / Release',
        status:
            '${candidate.status.wireValue}; canonical readiness remains ${canonical.finalReadinessPercent.toStringAsFixed(1)} / 100.',
        alreadyDone:
            'Readiness reporting is anchored to the active SSOT and live truth is being re-evaluated into snapshot, review, top packet, and history artifacts.',
        stillOpen:
            'Canonical hard blockers remain open and no SSOT epic-state movement is yet justified.',
        keyBlockers: canonical.hardBlockers,
        bestNextStep:
            'Keep routing through the current machine frontier until live proof justifies an explicit SSOT movement.',
      ),
    )
    ..write(
      _renderDossierMajorBlockV1(
        title: 'First-User Trust / Onboarding',
        status:
            '${firstUserCluster['blocker_level'] ?? 'grounded_data_limited'}; W0 is still the visible release-grade opener frontier.',
        alreadyDone:
            '${strongestLiveWorld['world_id'] ?? 'W1'} is the strongest live learner path today, and W0 is structurally real and playable.',
        stillOpen:
            'The first-user route still needs clearer visible identity, learner-copy cleanup, and opener polish before it feels fully release-grade.',
        keyBlockers: <String>[
          ...((completionGapSynthesis.topMachineFrontier?.surfaceScope ??
              const <String>[])),
        ],
        bestNextStep:
            firstUserCluster['recommended_wave'] as String? ??
            'Take one bounded first-user trust wave on the active opener surface.',
      ),
    )
    ..write(
      _renderDossierMajorBlockV1(
        title: 'Pedagogical Correctness / Progression',
        status:
            '${pedagogicalProgressionTruth['status'] ?? 'grounded_data_limited'}; $pedagogicalOpenFindingCount surfaced teaching/progression finding(s) across ${pedagogicalAffectedWorlds.length} world(s).',
        alreadyDone:
            'The hub now surfaces repo-owned truth for progression correctness, wrong-answer feedback quality, intro/framing quality, session/drill semantic fit, and pedagogical finish completeness.',
        stillOpen:
            pedagogicalProgressionTruth['summary'] as String? ??
            'No pedagogical/progression summary is available.',
        keyBlockers: <String>[
          ...pedagogicalTopCategories.take(4),
          ...((pedagogicalProgressionTruth['coverage_notes']
                      as List<Object?>? ??
                  const <Object?>[])
              .whereType<String>()
              .take(1)),
        ],
        bestNextStep: pedagogicalOpenFindingCount == 0
            ? 'Keep this block quiet unless new teaching/progression truth reappears.'
            : 'Use the surfaced pedagogical/progression findings to decide when a truth-layer wave should outrank later-world or polish work.',
      ),
    )
    ..write(
      _renderDossierMajorBlockV1(
        title: 'Content Trust',
        status:
            '${contentTrust['status'] ?? 'grounded_data_limited'}; ${contentTrust['summary'] ?? 'No explicit content-trust summary is available.'}',
        alreadyDone:
            'Current canonical truth maps `0` content-trust gaps into completion-gap synthesis.',
        stillOpen:
            'No separate content-trust frontier outranks the current world-quality route; remaining risk is mostly folded into world quality rather than validator breakage.',
        keyBlockers: const <String>[],
        bestNextStep:
            (contentTrustCluster['recommended_wave'] as String?) ??
            (contentTrust['recommended_action'] as String? ??
                'Keep content trust quiet unless a failing validator family reappears.'),
      ),
    )
    ..write(
      _renderDossierMajorBlockV1(
        title: 'World Quality',
        status:
            '${completionGapSynthesis.machineReducibleRemainingCount} machine-reducible frontier and ${completionGapSynthesis.allRemainingGapsCount} total remaining gaps.',
        alreadyDone:
            'All eleven worlds are present in current truth, W1 is strongly live, W0 is fully proof-backed enough to be machine-reducible, and later worlds are materially scaffolded.',
        stillOpen:
            'W0 still needs release-grade opener finish, W1/W2 remain manual-bound for human-proof closure, and later worlds still need stronger proof layers before honest reduction waves.',
        keyBlockers: completionGapSynthesis.why100NotReached.take(4).toList(),
        bestNextStep:
            recommendedNextGap?.nextFrontierReason ??
            'No admissible bounded frontier remains after routing normalization.',
      ),
    )
    ..write(
      _renderDossierMajorBlockV1(
        title: 'Runner / World Unification',
        status:
            '${unificationAudit['status'] ?? 'grounded_data_limited'}; ${compatibleRows.length} / ${unificationRows.length} rows are compatible for normalization.',
        alreadyDone:
            'The W1 Act0 seat-quiz trio is live on a shared runner family and W0 route ownership proof is explicit.',
        stillOpen:
            '${mixedOrPartialRows.length} rows still show partial/mixed or legacy residue, and shared ownership proof is only executable for $routeInventoryExecutableCount / ${routeInventories.length} worlds.',
        keyBlockers: <String>[
          ...mixedOrPartialRows
              .take(3)
              .map(
                (row) =>
                    '${row['world_id']} ${row['family_label']}: ${row['owner_seam_blocking_unification']}',
              ),
        ],
        bestNextStep:
            unificationAudit['recommended_action'] as String? ??
            'Keep unification waves bounded to route-critical residue only.',
      ),
    )
    ..write(
      _renderDossierMajorBlockV1(
        title: 'Visual Proof Truth',
        status:
            '${visualProofAudit['status'] ?? 'grounded_data_limited'}; screenshot evidence is executable for $screenshotEvidenceExecutableCount / ${screenshotEvidence.length} worlds and instrumentation is executable for $visualInstrumentationExecutableCount / ${visualInstrumentation.length}.',
        alreadyDone:
            'World 0 has executable visual instrumentation and screenshot-backed evidence for representative session-drill surfaces.',
        stillOpen:
            'Most worlds still lack representative screenshot proof or instrumentation truth, and visual-proof gaps remain open in the current gap map.',
        keyBlockers: <String>[
          ...(visualCluster['affected_surfaces'] as List<Object?>? ??
                  const <Object?>[])
              .take(4)
              .map((value) => '$value'),
        ],
        bestNextStep:
            visualCluster['recommended_wave'] as String? ??
            (visualProofAudit['recommended_action'] as String? ??
                'Resume visual proof only when it honestly outranks the current machine frontier.'),
      ),
    )
    ..write(
      _renderDossierMajorBlockV1(
        title: 'Ops / Release Confidence',
        status:
            '${opsAudit['status'] ?? 'grounded_data_limited'}; go/hold remains hold and manual review is still required.',
        alreadyDone:
            'Release-readiness truth, ops packet generation, and pause-state reporting are live in the hub.',
        stillOpen:
            'Human review is pending, rollback truth is unresolved, and the operational dashboard still lacks a governed decision owner.',
        keyBlockers: completionGapSynthesis.pausedManualClusters,
        bestNextStep:
            opsCluster['recommended_wave'] as String? ??
            (opsAudit['recommended_action'] as String? ??
                'Do not reopen this lane while the current machine frontier remains available.'),
      ),
    )
    ..write(
      _renderDossierMajorBlockV1(
        title: 'Audit Hub / Operator Tooling',
        status:
            'snapshot-backed live operator tooling; latest run captured ${summary['total_results'] ?? 0} normalized audit results.',
        alreadyDone:
            'The current operator path emits snapshot, review, top wave packet, latest run, history index, and this dossier from one refresh pipeline.',
        stillOpen:
            'Tooling maturity is not scored as a separate readiness system, and the operator surface remains intentionally snapshot-backed rather than realtime-streaming.',
        keyBlockers: const <String>[],
        bestNextStep:
            'Keep the operator path honest, compact, and additive only when it improves route clarity or trust.',
      ),
    )
    ..writeln('### Finding Inventory')
    ..writeln()
    ..writeln(
      '- Biggest open world buckets: ${biggestOpenWorldBuckets.isEmpty ? 'none surfaced' : biggestOpenWorldBuckets.map((bucket) => '${bucket['world_id']}=${bucket['total_open_findings']} (${bucket['dominant_bucket_label']})').join(' | ')}',
    )
    ..writeln(
      '- Highest-EV visible bucket inside current frontier: ${currentFrontierBucket.isEmpty ? 'none surfaced' : '${currentFrontierBucket['world_id']} ${currentFrontierBucket['dominant_bucket_label']}=${currentFrontierBucket['dominant_bucket_count']} (total=${currentFrontierBucket['total_open_findings']})'}',
    )
    ..writeln(
      '- Unification drift breakdown: mixed_family=${unificationDriftBreakdown['mixed_family_count'] ?? 0} | shared_owner_missing=${unificationDriftBreakdown['shared_owner_missing_count'] ?? 0} | local_override=${unificationDriftBreakdown['local_override_count'] ?? 0} | route_inventory_missing=${unificationDriftBreakdown['route_inventory_missing_count'] ?? 0} | visual_instrumentation_missing=${unificationDriftBreakdown['visual_instrumentation_missing_count'] ?? 0} | screenshot_evidence_missing=${unificationDriftBreakdown['screenshot_evidence_missing_count'] ?? 0}',
    )
    ..writeln(
      '- Coverage note: ${findingInventory['coverage_note'] ?? 'No explicit inventory coverage note is available.'}',
    )
    ..writeln()
    ..writeln('## 4. World-by-World Status')
    ..writeln();

  for (final world in worlds) {
    final worldId = world['world_id'] as String? ?? 'unknown';
    final findingBreakdown =
        worldFindingBreakdownByWorldId[worldId] ?? const <String, Object?>{};
    final matchingGap = _preferredWorldGapForWorldV1(
      gaps: completionGapSynthesis.gaps,
      worldId: worldId,
    );
    final admissibilityLabel =
        matchingGap?.admissibility.wireValue ?? 'external';
    final bestNextNeed = matchingGap == null
        ? 'No explicit completion-gap entry is mapped for this world in current truth.'
        : _bestNextNeedForGapV1(matchingGap);
    final missingSummary = <String>[
      ...(world['top_open_gaps'] as List<Object?>? ?? const <Object?>[]).map(
        (value) => '$value',
      ),
      if ((world['release_grade_blocker_note'] as String?)?.isNotEmpty ?? false)
        world['release_grade_blocker_note'] as String,
    ].join(' | ');
    buffer
      ..writeln('### ${world['world_id']} ${world['title'] ?? ''}'.trim())
      ..writeln()
      ..writeln(
        '- Status: `${matchingGap?.currentStatus ?? world['readiness_status'] ?? 'unknown'}`',
      )
      ..writeln('- Admissibility: `$admissibilityLabel`')
      ..writeln(
        '- Finding inventory: total=`${findingBreakdown['total_open_findings'] ?? 0}` | machine=`${findingBreakdown['machine_reducible_findings'] ?? 0}` | truth=`${findingBreakdown['truth_layer_first_findings'] ?? 0}` | proof/manual=`${findingBreakdown['proof_manual_only_findings'] ?? 0}` | progression=`${findingBreakdown['progression_count'] ?? 0}` | feedback=`${findingBreakdown['feedback_count'] ?? 0}` | intro=`${findingBreakdown['intro_count'] ?? 0}` | semantic_fit=`${findingBreakdown['semantic_fit_count'] ?? 0}` | pedagogical_finish=`${findingBreakdown['pedagogical_finish_count'] ?? 0}` | unification=`${findingBreakdown['unification_count'] ?? 0}` | other_world_quality=`${findingBreakdown['other_world_quality_count'] ?? 0}`',
      )
      ..writeln(
        '- Dominant bucket: `${findingBreakdown['dominant_bucket_label'] ?? 'none'}${(findingBreakdown['dominant_bucket_count'] as num?) != null ? ' (${findingBreakdown['dominant_bucket_count']})' : ''}`',
      )
      ..writeln(
        '- Already real: ${world['quality_summary'] ?? 'No grounded summary available.'}',
      )
      ..writeln(
        '- Still missing: ${missingSummary.isEmpty ? 'none explicit in current snapshot truth' : missingSummary}',
      )
      ..writeln(
        '- Pedagogical / progression truth: ${(() {
          final report = pedagogicalReportByWorldId[worldId];
          if (report == null) return 'grounded_data_limited';
          return '${report['status']} | progression=${report['progression_correctness_status']} | feedback=${report['wrong_answer_feedback_quality_status']} | intro=${report['intro_framing_onboarding_quality_status']} | semantic_fit=${report['session_drill_semantic_fit_status']} | finish=${report['world_pedagogical_finish_status']}';
        })()}',
      )
      ..writeln('- Classification: `$admissibilityLabel`')
      ..writeln('- Best next bounded need: $bestNextNeed')
      ..writeln();
  }

  final machineReducible = completionGapSynthesis.gaps
      .where(
        (gap) =>
            gap.admissibility ==
            CompletionGapAdmissibilityV1.machineReducibleNow,
      )
      .toList();
  final truthLayerFirst = completionGapSynthesis.gaps
      .where(
        (gap) =>
            gap.admissibility == CompletionGapAdmissibilityV1.truthLayerFirst,
      )
      .toList();
  final proofManualOnly = completionGapSynthesis.gaps
      .where(
        (gap) =>
            gap.admissibility == CompletionGapAdmissibilityV1.proofManualOnly,
      )
      .toList();
  final externalGaps = completionGapSynthesis.gaps
      .where(
        (gap) => gap.admissibility == CompletionGapAdmissibilityV1.external,
      )
      .toList();

  buffer
    ..writeln('## 5. Unification / Architecture State')
    ..writeln()
    ..writeln(
      '- Already unified: ${compatibleRows.length} / ${unificationRows.length} unification rows are compatible for normalization, the W1 Act0 shared family is the strongest live shared runner surface, and session-world truth surfaces are executable for $proofSurfaceExecutableCount / ${worldTruthSurfaces.length} worlds.',
    )
    ..writeln(
      '- Still has drift: ${mixedOrPartialRows.length} unification rows remain partial, mixed, or legacy-backed.',
    )
    ..writeln(
      '- Shared ownership proof still needed: route ownership inventories are executable for $routeInventoryExecutableCount / ${routeInventories.length} worlds.',
    )
    ..writeln(
      '- Visual instrumentation / screenshot proof still needed: instrumentation is executable for $visualInstrumentationExecutableCount / ${visualInstrumentation.length} worlds and screenshot evidence is executable for $screenshotEvidenceExecutableCount / ${screenshotEvidence.length} worlds.',
    )
    ..writeln(
      '- Convergence toward one canonical runner family: partial. The project is converging, but mixed World 0 family truth, legacy World 1 shells, and later-world proof gaps still prevent a single fully governed runner family claim.',
    )
    ..writeln()
    ..writeln('## 6. Remaining-to-100')
    ..writeln()
    ..writeln(
      '- Canonical hard blockers: ${canonical.hardBlockers.isEmpty ? 'none' : canonical.hardBlockers.join(', ')}',
    )
    ..writeln(
      '- Machine-reducible remaining frontiers: ${machineReducible.isEmpty ? 'none' : machineReducible.map((gap) => gap.title).join(' | ')}',
    )
    ..writeln(
      '- Truth-layer-first gaps: ${truthLayerFirst.isEmpty ? 'none' : truthLayerFirst.map((gap) => gap.title).join(' | ')}',
    )
    ..writeln(
      '- Proof/manual-only gaps: ${proofManualOnly.isEmpty ? 'none' : proofManualOnly.map((gap) => gap.title).join(' | ')}',
    )
    ..writeln(
      '- External/conditional gaps: ${externalGaps.isEmpty ? 'none' : externalGaps.map((gap) => gap.title).join(' | ')}',
    )
    ..writeln()
    ..writeln('## 7. Best Current Route')
    ..writeln()
    ..writeln('- Best next wave: `$currentRecommendedLabel`')
    ..writeln(
      '- Why it is the best next wave: ${recommendedNextGap?.nextFrontierReason ?? 'No admissible bounded frontier remains after routing normalization.'}',
    )
    ..writeln(
      '- What should explicitly not be worked on right now: ${completionGapSynthesis.pausedManualClusters.isEmpty ? 'No paused manual cluster is explicit.' : completionGapSynthesis.pausedManualClusters.join(' | ')}',
    )
    ..writeln(
      '- What would cause drift if resumed too early: reopening proof-only/manual-bound ops work or accepting under-normalized later-world work before reranking proves `${currentRecommendedLabel == 'none' ? 'a real admissible frontier' : currentRecommendedLabel}` still wins after earlier-world and higher-criticality candidates are ruled out.',
    )
    ..writeln(
      '- Top machine frontier interpretation: `${completionGapSynthesis.topMachineFrontier?.title ?? 'none'}` means `${completionGapSynthesis.topMachineFrontier == null ? 'no machine-reducible frontier survived routing normalization; use the normalized recommendation or stop honestly' : 'a machine-reducible frontier still exists after routing normalization'}`.',
    )
    ..writeln(
      '- Routing normalization proof: ${recommendedNextGap?.prerequisiteBlockers.isNotEmpty == true ? recommendedNextGap!.prerequisiteBlockers.join(' | ') : 'Routing truth was normalized before route acceptance.'}',
    )
    ..writeln()
    ..writeln('## 8. Freshness / Trust / Integrity')
    ..writeln()
    ..writeln('- Current HEAD: `${git['head'] ?? 'unknown'}`')
    ..writeln('- Snapshot timestamp: `$snapshotTimestamp`')
    ..writeln('- Dossier timestamp: `$timestampUtc`')
    ..writeln('- Latest run id: `$latestRunId`')
    ..writeln('- Tree classification: `$treeClassification`')
    ..writeln(
      '- Reflects latest known hub truth: `${reflectsLatestKnownSnapshotRun ? 'yes' : 'no'}`',
    )
    ..writeln()
    ..writeln('## 9. Evidence / Source Index')
    ..writeln()
    ..writeln('- Latest review: `$reviewPath`')
    ..writeln('- Latest top wave packet: `$topWavePacketPath`')
    ..writeln('- Operational snapshot: `$auditHubOperationalSnapshotPathV1`')
    ..writeln('- Latest run: `$auditHubLatestRunPathV1`')
    ..writeln('- History index: `$auditHubHistoryIndexPathV1`')
    ..writeln('- Readiness SSOT: `$projectReadinessSsotPathV1`')
    ..writeln(
      '- Progression prerequisite matrix: `$progressionPrerequisiteMatrixPathV1`',
    )
    ..writeln('- World readiness registry: `$worldReadinessRegistryPathV1`')
    ..writeln('- Product surface readiness: `$productSurfaceReadinessPathV1`')
    ..writeln(
      '- Other live truth used: blocker clusters, completion-gap synthesis, world pedagogical/progression surfaces, unification matrix, world truth surfaces, route ownership inventories, visual instrumentation surfaces, screenshot evidence surfaces embedded in the operational snapshot.',
    );

  return buffer.toString();
}

class _ReviewDeltaSummaryV1 {
  const _ReviewDeltaSummaryV1({
    required this.familyLabel,
    required this.primaryDelta,
    required this.frontierDelta,
    required this.closedFamilyLabel,
  });

  final String familyLabel;
  final String primaryDelta;
  final String frontierDelta;
  final String closedFamilyLabel;
}

class _RouteProgressSignalV1 {
  const _RouteProgressSignalV1({required this.signal, required this.reason});

  final String signal;
  final String reason;
}

_ReviewDeltaSummaryV1 _buildLatestReductionDeltaV1({
  required String previousTopMachineFrontier,
  required String currentTopMachineFrontier,
  required int previousMachineReducibleRemainingCount,
  required int currentMachineReducibleRemainingCount,
  required int previousManualBoundRemainingCount,
  required int currentManualBoundRemainingCount,
  required String? boundedFamilyLabel,
  required String waveLabel,
}) {
  final frontierDelta = previousTopMachineFrontier == currentTopMachineFrontier
      ? 'unchanged'
      : '$previousTopMachineFrontier -> $currentTopMachineFrontier';

  if (currentMachineReducibleRemainingCount <
      previousMachineReducibleRemainingCount) {
    return _ReviewDeltaSummaryV1(
      familyLabel:
          boundedFamilyLabel ??
          '$waveLabel measurable machine-side family reduction',
      primaryDelta:
          '$previousMachineReducibleRemainingCount -> $currentMachineReducibleRemainingCount (machine_reducible_remaining_count)',
      frontierDelta: frontierDelta,
      closedFamilyLabel:
          boundedFamilyLabel ?? 'one measurable family closed under $waveLabel',
    );
  }

  if (currentManualBoundRemainingCount < previousManualBoundRemainingCount) {
    return _ReviewDeltaSummaryV1(
      familyLabel:
          boundedFamilyLabel ?? '$waveLabel manual-bound residue reduction',
      primaryDelta:
          '$previousManualBoundRemainingCount -> $currentManualBoundRemainingCount (manual_bound_remaining_count)',
      frontierDelta: frontierDelta,
      closedFamilyLabel:
          boundedFamilyLabel ??
          'one manual-bound residue family reduced under $waveLabel',
    );
  }

  if (previousTopMachineFrontier == 'none' &&
      currentTopMachineFrontier != 'none') {
    return _ReviewDeltaSummaryV1(
      familyLabel:
          boundedFamilyLabel ??
          '$currentTopMachineFrontier surfaced as the first machine frontier',
      primaryDelta:
          '$previousTopMachineFrontier -> $currentTopMachineFrontier (top_machine_frontier)',
      frontierDelta: frontierDelta,
      closedFamilyLabel: 'none explicit in current snapshot truth',
    );
  }

  return _ReviewDeltaSummaryV1(
    familyLabel:
        boundedFamilyLabel ??
        'no explicit bounded family delta recorded in canonical snapshot truth',
    primaryDelta: 'no measurable delta in canonical frontier/count truth',
    frontierDelta: frontierDelta,
    closedFamilyLabel: 'none explicit in current snapshot truth',
  );
}

_RouteProgressSignalV1 _buildRouteTo100ProgressSignalV1({
  required String previousTopMachineFrontier,
  required String currentTopMachineFrontier,
  required int previousMachineReducibleRemainingCount,
  required int currentMachineReducibleRemainingCount,
  required int previousManualBoundRemainingCount,
  required int currentManualBoundRemainingCount,
}) {
  if (previousTopMachineFrontier == 'none' &&
      currentTopMachineFrontier != 'none') {
    return const _RouteProgressSignalV1(
      signal: 'improved',
      reason: 'new machine frontier surfaced',
    );
  }
  if (currentMachineReducibleRemainingCount <
      previousMachineReducibleRemainingCount) {
    return const _RouteProgressSignalV1(
      signal: 'improved',
      reason: 'one measurable family closed',
    );
  }
  if (currentManualBoundRemainingCount < previousManualBoundRemainingCount) {
    return const _RouteProgressSignalV1(
      signal: 'improved',
      reason: 'manual-bound gap count decreased',
    );
  }
  if (currentMachineReducibleRemainingCount >
          previousMachineReducibleRemainingCount ||
      currentManualBoundRemainingCount > previousManualBoundRemainingCount ||
      (previousTopMachineFrontier != 'none' &&
          currentTopMachineFrontier == 'none')) {
    return const _RouteProgressSignalV1(
      signal: 'regressed',
      reason: 'canonical frontier/count truth worsened',
    );
  }
  return const _RouteProgressSignalV1(
    signal: 'unchanged',
    reason: 'no measurable delta',
  );
}

Map<String, Object?> _buildFullAuditTraceV1({
  required int durationMs,
  required String previousRunId,
  required String currentRunId,
  required String reviewPath,
  required String topWavePacketPath,
  required String dossierPath,
}) {
  return <String, Object?>{
    'run_type': 'full_audit_snapshot_pipeline',
    'duration_ms': durationMs,
    'previous_run_id': previousRunId,
    'current_run_id': currentRunId,
    'executed_steps': <String>[
      'read previous snapshot/latest run',
      'derive release-readiness snapshot',
      'build operational dashboard',
      'compute project health / recalibration / completion-gap synthesis',
      'build latest run / recent runs / chatgpt summary',
      'render review',
      'render top wave packet',
      'write snapshot/latest_run/history_index',
    ],
    'regenerated_artifacts': <String>[
      _relativeArtifactLabelV1(auditHubOperationalSnapshotPathV1),
      _relativeArtifactLabelV1(auditHubLatestRunPathV1),
      _relativeArtifactLabelV1(auditHubHistoryIndexPathV1),
      _relativeArtifactLabelV1(reviewPath),
      _relativeArtifactLabelV1(topWavePacketPath),
      _relativeArtifactLabelV1(dossierPath),
    ],
  };
}

Map<String, Object?> _buildFindingInventoryV1({
  required Map<String, Object?> snapshot,
  required AuditHubOperationalDashboardV1 dashboard,
}) {
  final worlds =
      (snapshot['worlds'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false)
        ..sort(
          (left, right) =>
              (_parseWorldNumberV1(left['world_id'] as String? ?? '') ?? 999)
                  .compareTo(
                    _parseWorldNumberV1(right['world_id'] as String? ?? '') ??
                        999,
                  ),
        );
  final pedagogicalReports =
      (snapshot['world_pedagogical_progression_surfaces'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final pedagogicalReportsByWorldId = <String, Map<String, Object?>>{
    for (final report in pedagogicalReports)
      if ((report['world_id'] as String?)?.isNotEmpty ?? false)
        report['world_id'] as String: report,
  };
  final routeInventories =
      (snapshot['world_route_ownership_inventories'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final routeInventoryByWorldId = <String, Map<String, Object?>>{
    for (final item in routeInventories)
      if ((item['world_id'] as String?)?.isNotEmpty ?? false)
        item['world_id'] as String: item,
  };
  final visualInstrumentation =
      (snapshot['world_visual_instrumentation_surfaces'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final visualInstrumentationByWorldId = <String, Map<String, Object?>>{
    for (final item in visualInstrumentation)
      if ((item['world_id'] as String?)?.isNotEmpty ?? false)
        item['world_id'] as String: item,
  };
  final screenshotEvidence =
      (snapshot['world_screenshot_evidence_surfaces'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final screenshotEvidenceByWorldId = <String, Map<String, Object?>>{
    for (final item in screenshotEvidence)
      if ((item['world_id'] as String?)?.isNotEmpty ?? false)
        item['world_id'] as String: item,
  };
  final unificationRows =
      (snapshot['unification_matrix'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final worldBreakdown = worlds
      .map(
        (world) => _buildWorldFindingInventoryEntryV1(
          worldId: world['world_id'] as String? ?? 'unknown',
          report:
              pedagogicalReportsByWorldId[world['world_id'] as String? ?? ''],
          routeInventory:
              routeInventoryByWorldId[world['world_id'] as String? ?? ''],
          visualInstrumentation:
              visualInstrumentationByWorldId[world['world_id'] as String? ??
                  ''],
          screenshotEvidence:
              screenshotEvidenceByWorldId[world['world_id'] as String? ?? ''],
          unificationRows: unificationRows,
          gaps: dashboard.completionGapSynthesis.gaps,
        ),
      )
      .toList(growable: false);
  final biggestOpenWorldBuckets =
      worldBreakdown
          .where(
            (entry) =>
                ((entry['total_open_findings'] as num?)?.toInt() ?? 0) > 0,
          )
          .toList(growable: false)
        ..sort(
          (left, right) =>
              ((right['total_open_findings'] as num?)?.toInt() ?? 0).compareTo(
                (left['total_open_findings'] as num?)?.toInt() ?? 0,
              ),
        );
  final currentFrontierWorlds =
      _bestNextGapV1(dashboard.completionGapSynthesis)?.worldScope ??
      dashboard.completionGapSynthesis.topMachineFrontier?.worldScope ??
      const <String>[];
  final currentFrontierVisibleBucket =
      currentFrontierWorlds
          .map(
            (worldId) => worldBreakdown.firstWhere(
              (entry) => entry['world_id'] == worldId,
              orElse: () => const <String, Object?>{},
            ),
          )
          .where((entry) => entry.isNotEmpty)
          .toList(growable: false)
        ..sort(
          (left, right) =>
              ((right['dominant_bucket_count'] as num?)?.toInt() ?? 0)
                  .compareTo(
                    (left['dominant_bucket_count'] as num?)?.toInt() ?? 0,
                  ),
        );
  return <String, Object?>{
    'worlds_with_open_findings_count': worldBreakdown
        .where(
          (entry) => ((entry['total_open_findings'] as num?)?.toInt() ?? 0) > 0,
        )
        .length,
    'coverage_note':
        'Per-world admissibility counts cover routed completion-gap entries plus pedagogical findings. Unification drift counts are grounded and separate, but current unification surfaces do not emit per-finding admissibility wires.',
    'world_breakdown': worldBreakdown,
    'biggest_open_world_buckets': biggestOpenWorldBuckets.take(5).toList(),
    'current_frontier_visible_bucket': currentFrontierVisibleBucket.isEmpty
        ? const <String, Object?>{}
        : currentFrontierVisibleBucket.first,
    'unification_drift_breakdown': _buildUnificationDriftBreakdownV1(
      unificationRows: unificationRows,
      routeInventories: routeInventories,
      visualInstrumentation: visualInstrumentation,
      screenshotEvidence: screenshotEvidence,
    ),
  };
}

Map<String, Object?> _buildWorldFindingInventoryEntryV1({
  required String worldId,
  required Map<String, Object?>? report,
  required Map<String, Object?>? routeInventory,
  required Map<String, Object?>? visualInstrumentation,
  required Map<String, Object?>? screenshotEvidence,
  required List<Map<String, Object?>> unificationRows,
  required List<CompletionGapEntryV1> gaps,
}) {
  final findings = (report?['findings'] as List<Object?>? ?? const <Object?>[])
      .whereType<Map>()
      .map(Map<String, Object?>.from)
      .toList(growable: false);
  final progressionCount = findings
      .where((finding) => finding['category'] == 'progression_correctness')
      .length;
  final feedbackCount = findings
      .where(
        (finding) => finding['category'] == 'wrong_answer_feedback_quality',
      )
      .length;
  final introCount = findings
      .where(
        (finding) => finding['category'] == 'intro_framing_onboarding_quality',
      )
      .length;
  final semanticFitCount = findings
      .where((finding) => finding['category'] == 'session_drill_semantic_fit')
      .length;
  final pedagogicalFinishCount = findings
      .where(
        (finding) =>
            finding['category'] == 'world_pedagogical_finish_completeness',
      )
      .length;
  final pedagogicalTotalCount =
      progressionCount +
      feedbackCount +
      introCount +
      semanticFitCount +
      pedagogicalFinishCount;
  final worldSpecificGaps = gaps
      .where((gap) => gap.worldScope.contains(worldId))
      .where((gap) => !_isPedagogicalClusterGapV1(gap))
      .where((gap) => !_isUnificationGapV1(gap))
      .toList(growable: false);
  final machineReducibleFindings = worldSpecificGaps
      .where(
        (gap) =>
            gap.admissibility ==
            CompletionGapAdmissibilityV1.machineReducibleNow,
      )
      .length;
  final truthLayerFirstFindings =
      worldSpecificGaps
          .where(
            (gap) =>
                gap.admissibility ==
                CompletionGapAdmissibilityV1.truthLayerFirst,
          )
          .length +
      findings
          .where(
            (finding) =>
                finding['admissibility'] ==
                CompletionGapAdmissibilityV1.truthLayerFirst.wireValue,
          )
          .length;
  final proofManualOnlyFindings = worldSpecificGaps
      .where(
        (gap) =>
            gap.admissibility == CompletionGapAdmissibilityV1.proofManualOnly,
      )
      .length;
  final externalFindings = worldSpecificGaps
      .where(
        (gap) => gap.admissibility == CompletionGapAdmissibilityV1.external,
      )
      .length;
  final otherWorldQualityCount = worldSpecificGaps.length;
  final unificationCount = _buildWorldUnificationCountV1(
    worldId: worldId,
    routeInventory: routeInventory,
    visualInstrumentation: visualInstrumentation,
    screenshotEvidence: screenshotEvidence,
    unificationRows: unificationRows,
  );
  final bucketCounts = <String, int>{
    'progression': progressionCount,
    'feedback': feedbackCount,
    'intro': introCount,
    'semantic_fit': semanticFitCount,
    'pedagogical_finish': pedagogicalFinishCount,
    'unification': unificationCount,
    'other_world_quality': otherWorldQualityCount,
  };
  final dominantBucket = bucketCounts.entries.toList(growable: false)
    ..sort((left, right) => right.value.compareTo(left.value));
  final dominantBucketLabel =
      dominantBucket.isEmpty || dominantBucket.first.value <= 0
      ? 'none'
      : dominantBucket.first.key;
  final dominantBucketCount = dominantBucket.isEmpty
      ? 0
      : dominantBucket.first.value;
  return <String, Object?>{
    'world_id': worldId,
    'total_open_findings':
        machineReducibleFindings +
        truthLayerFirstFindings +
        proofManualOnlyFindings +
        externalFindings +
        unificationCount,
    'machine_reducible_findings': machineReducibleFindings,
    'truth_layer_first_findings': truthLayerFirstFindings,
    'proof_manual_only_findings': proofManualOnlyFindings,
    'progression_count': progressionCount,
    'feedback_count': feedbackCount,
    'intro_count': introCount,
    'semantic_fit_count': semanticFitCount,
    'pedagogical_finish_count': pedagogicalFinishCount,
    'pedagogical_total_count': pedagogicalTotalCount,
    'unification_count': unificationCount,
    'other_world_quality_count': otherWorldQualityCount,
    'dominant_bucket_label': dominantBucketLabel,
    'dominant_bucket_count': dominantBucketCount,
  };
}

int _buildWorldUnificationCountV1({
  required String worldId,
  required Map<String, Object?>? routeInventory,
  required Map<String, Object?>? visualInstrumentation,
  required Map<String, Object?>? screenshotEvidence,
  required List<Map<String, Object?>> unificationRows,
}) {
  var count = 0;
  final rowsForWorld = unificationRows
      .where((row) => row['world_id'] == worldId)
      .toList(growable: false);
  final hasMixedFamily = rowsForWorld.any(
    (row) =>
        (row['runner_family'] as String? ?? '').contains('mixed') ||
        (row['visual_family_status'] as String? ?? '') == 'mixed',
  );
  final hasSharedOwnerMissing = rowsForWorld.any(
    (row) => row['ownership_truth'] == 'not_instrumented',
  );
  final hasLocalOverride = rowsForWorld.any(
    (row) => row['old_path_residue'] == true,
  );
  if (hasMixedFamily) count += 1;
  if (hasSharedOwnerMissing) count += 1;
  if (hasLocalOverride) count += 1;
  if ((routeInventory?['inventory_status'] as String? ?? 'missing') !=
      'executable') {
    count += 1;
  }
  if ((visualInstrumentation?['instrumentation_status'] as String? ??
          'missing') !=
      'executable') {
    count += 1;
  }
  if ((screenshotEvidence?['evidence_status'] as String? ?? 'missing') !=
      'executable') {
    count += 1;
  }
  return count;
}

Map<String, Object?> _buildUnificationDriftBreakdownV1({
  required List<Map<String, Object?>> unificationRows,
  required List<Map<String, Object?>> routeInventories,
  required List<Map<String, Object?>> visualInstrumentation,
  required List<Map<String, Object?>> screenshotEvidence,
}) {
  return <String, Object?>{
    'mixed_family_count': unificationRows
        .where(
          (row) =>
              (row['runner_family'] as String? ?? '').contains('mixed') ||
              (row['visual_family_status'] as String? ?? '') == 'mixed',
        )
        .length,
    'shared_owner_missing_count': unificationRows
        .where((row) => row['ownership_truth'] == 'not_instrumented')
        .length,
    'local_override_count': unificationRows
        .where((row) => row['old_path_residue'] == true)
        .length,
    'route_inventory_missing_count': routeInventories
        .where((item) => item['inventory_status'] != 'executable')
        .length,
    'visual_instrumentation_missing_count': visualInstrumentation
        .where((item) => item['instrumentation_status'] != 'executable')
        .length,
    'screenshot_evidence_missing_count': screenshotEvidence
        .where((item) => item['evidence_status'] != 'executable')
        .length,
  };
}

bool _isPedagogicalClusterGapV1(CompletionGapEntryV1 gap) {
  return gap.gapId == 'cluster_pedagogical_progression_truth';
}

bool _isUnificationGapV1(CompletionGapEntryV1 gap) {
  final searchText = <String>[
    gap.title,
    gap.category,
    gap.likelySeam,
    gap.sourceTruthOwner,
    ...gap.surfaceScope,
    ...gap.epicMappings,
  ].join(' ').toLowerCase();
  return searchText.contains('unification') ||
      searchText.contains('route ownership') ||
      searchText.contains('shared/local') ||
      searchText.contains('visual proof') ||
      searchText.contains('screenshot') ||
      searchText.contains('instrumentation');
}

String _renderDossierMajorBlockV1({
  required String title,
  required String status,
  required String alreadyDone,
  required String stillOpen,
  required List<String> keyBlockers,
  required String bestNextStep,
}) {
  final buffer = StringBuffer()
    ..writeln('### $title')
    ..writeln()
    ..writeln('- Current status: $status')
    ..writeln('- What is already done: $alreadyDone')
    ..writeln('- What is still open: $stillOpen')
    ..writeln(
      '- Key blockers: ${keyBlockers.isEmpty ? 'none explicit in current truth' : keyBlockers.join(' | ')}',
    )
    ..writeln('- Best next step: $bestNextStep')
    ..writeln();
  return buffer.toString();
}

Map<String, Object?> _findAuditResultByIdV1(
  List<Map<String, Object?>> results,
  String auditId,
) {
  for (final result in results) {
    if (result['audit_id'] == auditId) {
      return result;
    }
  }
  return const <String, Object?>{};
}

Map<String, Object?> _findBlockerClusterByIdV1(
  List<Map<String, Object?>> clusters,
  String clusterId,
) {
  for (final cluster in clusters) {
    if (cluster['cluster_id'] == clusterId) {
      return cluster;
    }
  }
  return const <String, Object?>{};
}

CompletionGapEntryV1? _preferredWorldGapForWorldV1({
  required List<CompletionGapEntryV1> gaps,
  required String worldId,
}) {
  for (final gap in gaps) {
    if (gap.gapId.startsWith('world_gap_') &&
        gap.worldScope.contains(worldId)) {
      return gap;
    }
  }
  for (final gap in gaps) {
    if (gap.worldScope.contains(worldId)) {
      return gap;
    }
  }
  return null;
}

String _bestNextNeedForGapV1(CompletionGapEntryV1 gap) {
  switch (gap.admissibility) {
    case CompletionGapAdmissibilityV1.machineReducibleNow:
      return 'Reduce `${gap.likelySeam}` on `${gap.title}`.';
    case CompletionGapAdmissibilityV1.truthLayerFirst:
      if (gap.prerequisiteBlockers.isNotEmpty) {
        return 'Surface prerequisite truth for `${gap.title}`: ${gap.prerequisiteBlockers.first}.';
      }
      return 'Surface the next truth layer for `${gap.title}` around `${gap.likelySeam}`.';
    case CompletionGapAdmissibilityV1.proofManualOnly:
      return 'Resolve the current manual/human proof boundary for `${gap.title}` before further reduction.';
    case CompletionGapAdmissibilityV1.external:
      return 'Wait for the external or upstream condition currently governing `${gap.title}`.';
  }
}

Map<String, Object?> _buildLatestRunV1({
  required String rootPath,
  required String timestampUtc,
  required Map<String, Object?> snapshot,
  required AuditHubOperationalDashboardV1 dashboard,
  required Map<String, Object> releaseReadinessSnapshot,
  required Map<String, Object?> previousLatestRun,
}) {
  final results = _buildAuditRunResultsV1(
    snapshot: snapshot,
    dashboard: dashboard,
    releaseReadinessSnapshot: releaseReadinessSnapshot,
    timestampUtc: timestampUtc,
  );
  final statusCounts = <String, int>{};
  final categoryCounts = <String, int>{};
  var openFailCount = 0;
  var openWarningCount = 0;
  for (final result in results) {
    final status = result['status'] as String? ?? 'info';
    final category = result['category'] as String? ?? 'uncategorized';
    statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    if (status == 'fail') {
      openFailCount += 1;
    } else if (status == 'warning') {
      openWarningCount += 1;
    }
  }

  return <String, Object?>{
    'version': 'v1',
    'run_id': _normalizeTimestampForFileV1(timestampUtc),
    'started_at_utc': timestampUtc,
    'completed_at_utc': timestampUtc,
    'repo_root': Directory(rootPath).absolute.path,
    'git': _readGitSnapshotV1(
      rootPath: rootPath,
      fallback: previousLatestRun['git'] as Map?,
    ),
    'summary': <String, Object?>{
      'total_results': results.length,
      'status_counts': statusCounts,
      'category_counts': categoryCounts,
      'open_fail_count': openFailCount,
      'open_warning_count': openWarningCount,
    },
    'key_blockers': _buildKeyBlockersV1(
      dashboard: dashboard,
      releaseReadinessSnapshot: releaseReadinessSnapshot,
    ),
    'results': results,
  };
}

List<Map<String, Object?>> _buildAuditRunResultsV1({
  required Map<String, Object?> snapshot,
  required AuditHubOperationalDashboardV1 dashboard,
  required Map<String, Object> releaseReadinessSnapshot,
  required String timestampUtc,
}) {
  final gapSummary = dashboard.completionGapSynthesis;
  final topFrontier = gapSummary.topMachineFrontier;
  final recommendedNextGap = _bestNextGapV1(gapSummary);
  final unificationRows =
      (snapshot['unification_matrix'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();
  final partialUnificationCount = unificationRows
      .where((row) => (row['current_status'] as String? ?? '') != 'live')
      .length;
  final blockerClusters =
      (snapshot['blocker_clusters'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();
  final productSurfaceFamilies = blockerClusters
      .map((cluster) => cluster['title'] as String? ?? '')
      .where((title) => title.isNotEmpty)
      .toList();
  final pedagogicalProgressionTruth = Map<String, Object?>.from(
    snapshot['pedagogical_progression_truth'] as Map? ??
        const <String, Object?>{},
  );
  final pedagogicalCategoryCounts = Map<String, Object?>.from(
    pedagogicalProgressionTruth['category_counts'] as Map? ??
        const <String, Object?>{},
  );
  final pedagogicalAffectedWorlds =
      (pedagogicalProgressionTruth['affected_worlds'] as List<Object?>? ??
              const <Object?>[])
          .whereType<String>()
          .toList(growable: false);
  final pedagogicalTopCategories =
      (pedagogicalProgressionTruth['top_categories'] as List<Object?>? ??
              const <Object?>[])
          .whereType<String>()
          .toList(growable: false);
  final pedagogicalOpenFindingCount =
      (pedagogicalProgressionTruth['open_finding_count'] as num?)?.toInt() ?? 0;
  final findingInventory = Map<String, Object?>.from(
    snapshot['finding_inventory'] as Map? ?? const <String, Object?>{},
  );
  final biggestOpenWorldBuckets =
      (findingInventory['biggest_open_world_buckets'] as List<Object?>? ??
              const [])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final currentFrontierBucket = Map<String, Object?>.from(
    findingInventory['current_frontier_visible_bucket'] as Map? ??
        const <String, Object?>{},
  );
  final visualGapCount = gapSummary.gaps.where((gap) {
    final surfaceText = gap.surfaceScope.join(' ').toLowerCase();
    final blockerText = gap.prerequisiteBlockers.join(' ').toLowerCase();
    return surfaceText.contains('visual') ||
        surfaceText.contains('screenshot') ||
        blockerText.contains('visual') ||
        blockerText.contains('screenshot') ||
        gap.admissibility == CompletionGapAdmissibilityV1.external;
  }).length;
  final contentTrustGapCount = gapSummary.gaps.where((gap) {
    return gap.epicMappings.any(
      (mapping) => mapping.toLowerCase().contains('content trust'),
    );
  }).length;
  final canonical = dashboard.canonicalReadiness;
  final candidate = dashboard.recalibrationCandidate;

  return <Map<String, Object?>>[
    _buildRunResultV1(
      auditId: 'canonical_readiness_snapshot_v1',
      auditName: 'Canonical readiness snapshot',
      category: 'surface_readiness',
      status: 'pass',
      severity: 'info',
      scope: 'Core / Ship / Final readiness SSOT',
      summary:
          'Canonical readiness is ${canonical.coreReadinessPercent.toStringAsFixed(1)} / ${canonical.shipReadinessPercent.toStringAsFixed(1)} / ${canonical.finalReadinessPercent.toStringAsFixed(1)}.',
      recommendedAction:
          'Keep readiness reporting sourced from the active SSOT until explicit epic-state proof justifies recalibration.',
      timestampUtc: timestampUtc,
      command:
          'dart run tools/audit_hub_refresh_v1.dart --timestamp $timestampUtc',
      details:
          'Top bottleneck block: ${canonical.topBottleneckBlock}. Top bottleneck epic: ${canonical.topBottleneckEpic}.',
      affectedSurfaces: canonical.whatBlocksHundredNow,
      ownerFiles: <String>[canonical.sourceSsotPath],
      likelySeam: 'canonical readiness reporting',
      metrics: <String, Object?>{
        'core_readiness_percent': canonical.coreReadinessPercent,
        'ship_readiness_percent': canonical.shipReadinessPercent,
        'final_readiness_percent': canonical.finalReadinessPercent,
      },
    ),
    _buildRunResultV1(
      auditId: 'readiness_recalibration_candidate_v1',
      auditName: 'Readiness recalibration candidate',
      category: 'surface_readiness',
      status:
          candidate.status == ReadinessRecalibrationCandidateStatusV1.noChange
          ? 'pass'
          : 'warning',
      severity:
          candidate.status == ReadinessRecalibrationCandidateStatusV1.noChange
          ? 'info'
          : 'warning',
      scope: 'Candidate movement against canonical readiness SSOT',
      summary:
          'Recalibration candidate is `${candidate.status.wireValue}` with reason: ${candidate.recalibrationReason}',
      recommendedAction:
          'Only advance the SSOT when proof moves explicit epic state, not on local score drift alone.',
      timestampUtc: timestampUtc,
      command:
          'dart run tools/audit_hub_refresh_v1.dart --timestamp $timestampUtc',
      details: candidate.rawVsEffectiveNote,
      affectedSurfaces: candidate.proofGapsIfNotJustified,
      ownerFiles: <String>[candidate.canonicalReadinessSourcePath],
      likelySeam: 'readiness recalibration proof boundary',
      metrics: <String, Object?>{
        'core_delta': candidate.candidateScoreDeltas.coreDelta,
        'ship_delta': candidate.candidateScoreDeltas.shipDelta,
        'final_delta': candidate.candidateScoreDeltas.finalDelta,
      },
    ),
    _buildRunResultV1(
      auditId: 'completion_gap_synthesis_v1',
      auditName: 'Completion-gap synthesis',
      category: 'surface_readiness',
      status: gapSummary.allRemainingGapsCount == 0 ? 'pass' : 'warning',
      severity: gapSummary.allRemainingGapsCount == 0 ? 'info' : 'warning',
      scope: 'Remaining-to-100 map and frontier ranking',
      summary:
          'Top machine frontier: ${topFrontier?.title ?? 'none'}. Remaining gaps: ${gapSummary.allRemainingGapsCount}.',
      recommendedAction:
          'Use normalized routing truth: prefer the strongest admissible frontier after criticality, cohesion, and world-lane reranking.',
      timestampUtc: timestampUtc,
      command:
          'dart run tools/audit_hub_refresh_v1.dart --timestamp $timestampUtc',
      details:
          'machine_reducible=${gapSummary.machineReducibleRemainingCount}, manual_bound=${gapSummary.manualBoundRemainingCount}, recommended_next=${recommendedNextGap?.title ?? 'none'}, paused_manual_clusters=${gapSummary.pausedManualClusters.join(' | ')}, top_machine_frontier_none_interpretation=${topFrontier == null ? 'no machine-reducible frontier remains after routing normalization; continue with the strongest remaining admissible frontier if one exists' : 'n/a'}',
      affectedSurfaces: <String>[
        ...?recommendedNextGap?.surfaceScope,
        ...gapSummary.pausedManualClusters,
      ],
      ownerFiles: gapSummary.sourceTruthOwners,
      likelySeam: recommendedNextGap?.likelySeam ?? 'remaining-to-100 routing',
      metrics: <String, Object?>{
        'all_remaining_gaps_count': gapSummary.allRemainingGapsCount,
        'machine_reducible_remaining_count':
            gapSummary.machineReducibleRemainingCount,
        'manual_bound_remaining_count': gapSummary.manualBoundRemainingCount,
      },
    ),
    _buildRunResultV1(
      auditId: 'pedagogical_progression_truth_v1',
      auditName: 'Pedagogical / progression truth',
      category: 'pedagogical_correctness',
      status: pedagogicalOpenFindingCount == 0 ? 'pass' : 'warning',
      severity: pedagogicalOpenFindingCount == 0 ? 'info' : 'warning',
      scope:
          'Progression correctness, feedback quality, onboarding/framing, semantic fit, and pedagogical finish',
      summary:
          pedagogicalProgressionTruth['summary'] as String? ??
          'No pedagogical/progression truth summary is available.',
      recommendedAction:
          'Use surfaced pedagogical/progression findings to decide when a teaching-quality truth layer should outrank later-world or polish work.',
      timestampUtc: timestampUtc,
      command:
          'dart run tools/world_pedagogical_progression_audit_v1.dart --world=0 --json',
      details:
          'affected_worlds=${pedagogicalAffectedWorlds.join(' | ')}, top_categories=${pedagogicalTopCategories.join(' | ')}',
      affectedSurfaces: pedagogicalAffectedWorlds,
      ownerFiles: <String>[
        progressionPrerequisiteMatrixPathV1,
        worldPedagogicalProgressionAuditSourcePathV1,
      ],
      likelySeam: pedagogicalTopCategories.isEmpty
          ? 'pedagogical/progression truth'
          : pedagogicalTopCategories.join(' | '),
      metrics: <String, Object?>{
        'open_finding_count': pedagogicalOpenFindingCount,
        'category_count': pedagogicalCategoryCounts.length,
      },
    ),
    _buildRunResultV1(
      auditId: 'finding_inventory_visibility_v1',
      auditName: 'Finding inventory visibility',
      category: 'world_quality',
      status:
          ((findingInventory['worlds_with_open_findings_count'] as num?)
                      ?.toInt() ??
                  0) ==
              0
          ? 'pass'
          : 'warning',
      severity:
          ((findingInventory['worlds_with_open_findings_count'] as num?)
                      ?.toInt() ??
                  0) ==
              0
          ? 'info'
          : 'warning',
      scope: 'Per-world residue volume and category composition',
      summary:
          'Open finding inventory covers ${(findingInventory['worlds_with_open_findings_count'] as num?)?.toInt() ?? 0} world(s); largest buckets: ${biggestOpenWorldBuckets.isEmpty ? 'none' : biggestOpenWorldBuckets.take(3).map((bucket) => '${bucket['world_id']}=${bucket['total_open_findings']}').join(' | ')}.',
      recommendedAction:
          'Use the count inventory to choose the dominant bounded residue family inside the current frontier before starting the next wave.',
      timestampUtc: timestampUtc,
      command:
          'dart run tools/audit_hub_refresh_v1.dart --timestamp $timestampUtc',
      details:
          'current_frontier_bucket=${currentFrontierBucket.isEmpty ? 'none' : '${currentFrontierBucket['world_id']} ${currentFrontierBucket['dominant_bucket_label']}=${currentFrontierBucket['dominant_bucket_count']}'}, coverage=${findingInventory['coverage_note'] ?? 'none'}',
      affectedSurfaces: biggestOpenWorldBuckets
          .take(5)
          .map(
            (bucket) =>
                '${bucket['world_id']}: ${bucket['dominant_bucket_label']}',
          )
          .toList(growable: false),
      ownerFiles: <String>[
        auditHubOperationalSnapshotPathV1,
        worldPedagogicalProgressionAuditSourcePathV1,
      ],
      likelySeam: currentFrontierBucket.isEmpty
          ? 'finding inventory visibility'
          : '${currentFrontierBucket['world_id']} ${currentFrontierBucket['dominant_bucket_label']}',
      metrics: <String, Object?>{
        'worlds_with_open_findings_count':
            (findingInventory['worlds_with_open_findings_count'] as num?)
                ?.toInt() ??
            0,
        'largest_world_bucket_count': biggestOpenWorldBuckets.isEmpty
            ? 0
            : ((biggestOpenWorldBuckets.first['total_open_findings'] as num?)
                      ?.toInt() ??
                  0),
      },
    ),
    _buildRunResultV1(
      auditId: 'content_trust_state_v1',
      auditName: 'Content trust state',
      category: 'content_validators',
      status: contentTrustGapCount == 0 ? 'pass' : 'warning',
      severity: contentTrustGapCount == 0 ? 'info' : 'warning',
      scope: 'Current content-trust blockers on latest repo truth',
      summary:
          '$contentTrustGapCount content-trust mapped gap(s) remain open in completion-gap synthesis.',
      recommendedAction:
          'Keep learner-facing content residue and validator drift out of the current route.',
      timestampUtc: timestampUtc,
      command: 'dart run tools/validate_world_content_v1.dart',
      details:
          'Current top frontier: ${topFrontier?.gapId ?? 'none'}; paused manual clusters: ${gapSummary.pausedManualClusters.join(' | ')}',
      affectedSurfaces: gapSummary.gaps
          .where(
            (gap) => gap.epicMappings.any(
              (mapping) => mapping.toLowerCase().contains('content trust'),
            ),
          )
          .expand((gap) => gap.surfaceScope)
          .toSet()
          .toList(),
      ownerFiles: gapSummary.gaps
          .where(
            (gap) => gap.epicMappings.any(
              (mapping) => mapping.toLowerCase().contains('content trust'),
            ),
          )
          .expand((gap) => gap.ownerFiles)
          .toSet()
          .toList(),
      likelySeam: 'content trust / learner copy / validator alignment',
      metrics: <String, Object?>{
        'content_trust_gap_count': contentTrustGapCount,
      },
    ),
    _buildRunResultV1(
      auditId: 'world_runner_unification_state_v1',
      auditName: 'World / runner unification state',
      category: 'shared_source_propagation',
      status: partialUnificationCount == 0 ? 'pass' : 'warning',
      severity: partialUnificationCount == 0 ? 'info' : 'warning',
      scope: 'World-family compatibility and runner unification',
      summary:
          '$partialUnificationCount world family row(s) remain partial or mixed in the unification matrix.',
      recommendedAction:
          'Continue runner-family unification until mixed ownership and instrumentation residue disappears from the current route.',
      timestampUtc: timestampUtc,
      command:
          'dart run tools/runner_unification_readiness_audit_v1.dart --json',
      details:
          'Compatible rows: ${unificationRows.where((row) => row['compatible_for_normalization'] == true).length} / ${unificationRows.length}',
      affectedSurfaces: unificationRows
          .where((row) => (row['current_status'] as String? ?? '') != 'live')
          .map((row) => row['family_label'] as String? ?? '')
          .where((label) => label.isNotEmpty)
          .toList(),
      ownerFiles: <String>['tools/runner_unification_readiness_audit_v1.dart'],
      likelySeam: 'world / runner unification',
      metrics: <String, Object?>{
        'partial_unification_count': partialUnificationCount,
        'row_count': unificationRows.length,
      },
    ),
    _buildRunResultV1(
      auditId: 'product_surface_state_v1',
      auditName: 'Product / surface state',
      category: 'surface_readiness',
      status: productSurfaceFamilies.isEmpty ? 'pass' : 'warning',
      severity: productSurfaceFamilies.isEmpty ? 'info' : 'warning',
      scope: 'Product blocker clusters and launch-surface families',
      summary:
          '${productSurfaceFamilies.length} blocker cluster family entry(s) remain active in the current snapshot.',
      recommendedAction:
          'Keep the browser hub focused on current project truth instead of standalone roadmap overlays.',
      timestampUtc: timestampUtc,
      command:
          'dart run tools/audit_hub_refresh_v1.dart --timestamp $timestampUtc',
      details: productSurfaceFamilies.join(' | '),
      affectedSurfaces: productSurfaceFamilies,
      ownerFiles: <String>[productSurfaceReadinessPathV1],
      likelySeam: 'product / surface readiness',
      metrics: <String, Object?>{
        'blocker_cluster_count': blockerClusters.length,
      },
    ),
    _buildRunResultV1(
      auditId: 'visual_proof_state_v1',
      auditName: 'Visual proof state',
      category: 'visual',
      status: visualGapCount == 0 ? 'pass' : 'warning',
      severity: visualGapCount == 0 ? 'info' : 'warning',
      scope: 'Screenshot-backed and visual proof truth',
      summary: visualGapCount == 0
          ? 'No active visual-proof blockers were detected in the current gap map.'
          : '$visualGapCount visual-proof gap(s) remain open in the current gap map.',
      recommendedAction:
          'Keep screenshot-backed evidence and visual instrumentation aligned with the current top frontier.',
      timestampUtc: timestampUtc,
      command:
          'dart run tools/world_screenshot_evidence_audit_v1.dart --world=0 --json',
      details:
          'Visual proof status is derived from current completion-gap scope and screenshot truth surfaces.',
      affectedSurfaces: gapSummary.gaps
          .where((gap) {
            final scope = gap.surfaceScope.join(' ').toLowerCase();
            final blockers = gap.prerequisiteBlockers.join(' ').toLowerCase();
            return scope.contains('visual') ||
                scope.contains('screenshot') ||
                blockers.contains('visual') ||
                blockers.contains('screenshot') ||
                gap.admissibility == CompletionGapAdmissibilityV1.external;
          })
          .expand((gap) => gap.surfaceScope)
          .toSet()
          .toList(),
      ownerFiles: <String>[
        'tools/world_screenshot_evidence_audit_v1.dart',
        'tools/world_visual_instrumentation_audit_v1.dart',
      ],
      likelySeam: 'visual proof / screenshot evidence',
      metrics: <String, Object?>{'visual_gap_count': visualGapCount},
    ),
    _buildRunResultV1(
      auditId: 'ops_release_confidence_state_v1',
      auditName: 'Ops / release confidence state',
      category: 'release_ops',
      status:
          releaseReadinessSnapshot['goNoGoStateIsHold'] == true ||
              gapSummary.pausedManualClusters.isNotEmpty
          ? 'warning'
          : 'pass',
      severity:
          releaseReadinessSnapshot['goNoGoStateIsHold'] == true ||
              gapSummary.pausedManualClusters.isNotEmpty
          ? 'warning'
          : 'info',
      scope: 'Operational confidence, human review, and paused manual clusters',
      summary:
          'go/hold=${releaseReadinessSnapshot['goNoGoStateIsHold'] == true ? 'hold' : 'not_hold'}, paused_manual_clusters=${gapSummary.pausedManualClusters.length}.',
      recommendedAction:
          'Do not route back into proof-only ops replay while the current machine frontier remains available.',
      timestampUtc: timestampUtc,
      command: 'dart run tools/release_readiness_snapshot_v1.dart',
      details:
          'human_review_pending=${releaseReadinessSnapshot['humanReviewStatePending']}, rollback_unresolved=${releaseReadinessSnapshot['rollbackTruthSaysUnresolved']}, dashboard_owner_missing=${releaseReadinessSnapshot['operationalDashboardTruthSaysNoCanonicalDashboard']}',
      affectedSurfaces: gapSummary.pausedManualClusters,
      ownerFiles: <String>[
        'tools/release_readiness_snapshot_v1.dart',
        'tools/operational_review_packet_v1.dart',
      ],
      likelySeam: 'ops / release confidence',
      metrics: <String, Object?>{
        'paused_manual_cluster_count': gapSummary.pausedManualClusters.length,
        'go_no_go_hold': releaseReadinessSnapshot['goNoGoStateIsHold'] == true,
      },
    ),
  ];
}

Map<String, Object?> _buildRunResultV1({
  required String auditId,
  required String auditName,
  required String category,
  required String status,
  required String severity,
  required String scope,
  required String summary,
  required String recommendedAction,
  required String timestampUtc,
  required String command,
  required String details,
  required List<String> affectedSurfaces,
  required List<String> ownerFiles,
  required String likelySeam,
  required Map<String, Object?> metrics,
}) {
  return <String, Object?>{
    'audit_id': auditId,
    'audit_name': auditName,
    'category': category,
    'scope': scope,
    'status': status,
    'severity': severity,
    'summary': summary,
    'recommended_action': recommendedAction,
    'last_run_at_utc': timestampUtc,
    'command': command,
    'details': details,
    'affected_surfaces': affectedSurfaces,
    'owner_files': ownerFiles,
    'likely_seam': likelySeam,
    'artifacts': <Object?>[],
    'metrics': metrics,
    'raw_stdout_path': null,
    'raw_structured_path': null,
    'duration_ms': 0,
    'evidence_mismatch': false,
  };
}

List<Object?> _buildRecentRunsV1({
  required Map<String, Object?> latestRun,
  required Map<String, Object?> previousSnapshot,
}) {
  final currentRunId = latestRun['run_id'] as String?;
  final previousRuns =
      (previousSnapshot['recent_runs'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .where(
            (run) =>
                (run['run_id'] as String?) != null &&
                run['run_id'] != currentRunId,
          )
          .take(7)
          .toList();
  return <Object?>[latestRun, ...previousRuns];
}

Map<String, Object?> _buildTrustStateV1({
  required Map<String, Object?> previousSnapshot,
  required Map<String, Object?> latestRun,
  required String timestampUtc,
}) {
  final previousTrust = Map<String, Object?>.from(
    previousSnapshot['trust'] as Map? ?? const <String, Object?>{},
  );
  final git = Map<String, Object?>.from(
    latestRun['git'] as Map? ?? const <String, Object?>{},
  );
  final keyBlockers =
      (latestRun['key_blockers'] as List<Object?>? ?? const <Object?>[])
          .whereType<String>()
          .toList();
  return <String, Object?>{
    ...previousTrust,
    'last_full_run_at_utc': latestRun['completed_at_utc'],
    'snapshot_generated_at_utc': timestampUtc,
    'branch': git['branch'],
    'head': git['head'],
    'is_clean_tree': git['is_clean_tree'],
    'dirty_file_count': git['dirty_file_count'],
    'blocker_summary': keyBlockers.join(' | '),
  };
}

String _buildChatSummaryV1({
  required AuditHubOperationalDashboardV1 dashboard,
  required String timestampUtc,
  required Map<String, Object?> previousProjectHealth,
  required Map<String, Object?> previousCompletionGapSynthesis,
  required Map<String, Object?> previousCandidate,
}) {
  final currentFrontier =
      dashboard.completionGapSynthesis.topMachineFrontier?.gapId ?? 'none';
  final previousFrontier =
      Map<String, Object?>.from(
            previousCompletionGapSynthesis['top_machine_frontier'] as Map? ??
                const <String, Object?>{},
          )['gap_id']
          as String? ??
      'none';
  final currentCount =
      dashboard.completionGapSynthesis.machineReducibleRemainingCount;
  final previousCount =
      previousCompletionGapSynthesis['machine_reducible_remaining_count']
          as int? ??
      0;
  final previousCandidateStatus =
      previousCandidate['recalibration_candidate_status'] as String? ??
      'unknown';
  final currentCandidateStatus =
      dashboard.recalibrationCandidate.status.wireValue;
  final previousFinal =
      (previousProjectHealth['final_readiness_percent'] as num?)?.toDouble() ??
      dashboard.canonicalReadiness.finalReadinessPercent;
  final currentFinal = dashboard.canonicalReadiness.finalReadinessPercent;
  final frontierDelta = currentFrontier == previousFrontier
      ? 'unchanged'
      : '$previousFrontier -> $currentFrontier';
  final candidateDelta = currentCandidateStatus == previousCandidateStatus
      ? 'unchanged'
      : '$previousCandidateStatus -> $currentCandidateStatus';
  final machineDelta = '$previousCount -> $currentCount';
  final readinessDelta = previousFinal == currentFinal
      ? 'unchanged'
      : '${previousFinal.toStringAsFixed(1)} -> ${currentFinal.toStringAsFixed(1)}';
  return 'Latest audit refresh at $timestampUtc. Final readiness is $readinessDelta. '
      'Recalibration candidate is $candidateDelta. '
      'Top machine frontier is $frontierDelta. '
      'Machine-reducible remaining count moved $machineDelta. '
      'Paused manual clusters: ${dashboard.completionGapSynthesis.pausedManualClusters.isEmpty ? 'none' : dashboard.completionGapSynthesis.pausedManualClusters.join(' | ')}.';
}

Map<String, Object?> _buildTopWavePacketV1({
  required AuditHubOperationalDashboardV1 dashboard,
  required String reviewPath,
  required String topWavePacketPath,
  required String timestampUtc,
}) {
  final recommendedNextGap = _bestNextGapV1(dashboard.completionGapSynthesis);
  final title =
      recommendedNextGap?.title ??
      (dashboard.completionGapSynthesis.pausedManualClusters.isNotEmpty
          ? dashboard.completionGapSynthesis.pausedManualClusters.first
          : 'No machine frontier');
  final clusterId =
      recommendedNextGap?.gapId ??
      _slugifyV1(title.isEmpty ? 'no_machine_frontier' : title);
  final summary =
      recommendedNextGap?.nextFrontierReason ??
      (dashboard.completionGapSynthesis.pausedManualClusters.isNotEmpty
          ? 'Manual-only cluster remains paused until stronger machine proof reopens the seam.'
          : 'No admissible bounded frontier remains after routing normalization on latest truth.');
  return <String, Object?>{
    'title': title,
    'cluster_id': clusterId,
    'rank': 1,
    'summary': summary,
    'why_ranked_first': summary,
    'blocker_level':
        recommendedNextGap?.admissibility.wireValue ?? 'manual_only',
    'readiness_blocks': recommendedNextGap?.readinessBlocks ?? const <String>[],
    'epic_mappings': recommendedNextGap?.epicMappings ?? const <String>[],
    'master_plan_lanes': const <String>['Route-to-100 operator path'],
    'affected_worlds': recommendedNextGap?.worldScope ?? const <String>[],
    'affected_surfaces':
        recommendedNextGap?.surfaceScope ??
        dashboard.completionGapSynthesis.pausedManualClusters,
    'likely_seam': recommendedNextGap?.likelySeam ?? 'manual frontier boundary',
    'owner_files': recommendedNextGap?.ownerFiles ?? const <String>[],
    'primary_audit_ids': <String>[
      'completion_gap_synthesis_v1',
      'readiness_recalibration_candidate_v1',
    ],
    'primary_evidence_links': <String>[reviewPath, topWavePacketPath],
    'rerun_commands': recommendedNextGap?.measurableProofPath.isNotEmpty == true
        ? recommendedNextGap!.measurableProofPath
        : <String>[
            'dart run tools/audit_hub_refresh_v1.dart --timestamp $timestampUtc',
          ],
    'close_criteria':
        recommendedNextGap?.prerequisiteBlockers.isNotEmpty == true
        ? recommendedNextGap!.prerequisiteBlockers
        : <String>[
            'Advance the current frontier until a different remaining gap honestly outranks it on canonical truth.',
          ],
    'proof_requirements': <String>[
      recommendedNextGap?.admissibility.wireValue ?? 'manual_only',
    ],
    'routing_truth_normalized': true,
    'recommended_next_wave': recommendedNextGap?.title ?? 'none',
    'routing_proof':
        recommendedNextGap?.prerequisiteBlockers ?? const <String>[],
    'must_not_be_declared_closed_yet_note': recommendedNextGap == null
        ? 'No machine-reducible frontier remains after routing normalization; use the strongest remaining admissible truth/manual frontier or stop honestly.'
        : 'This frontier remains open until its proof path and visible residue are both closed.',
    'canonical_next_wave': summary,
  };
}

String renderTopWavePacketMarkdownV1({
  required Map<String, Object?> packet,
  required AuditHubOperationalDashboardV1 dashboard,
  required String timestampUtc,
}) {
  final topFrontier = dashboard.completionGapSynthesis.topMachineFrontier;
  final buffer = StringBuffer()
    ..writeln('# Top Wave Packet $timestampUtc')
    ..writeln()
    ..writeln('- Title: `${packet['title']}`')
    ..writeln('- Cluster id: `${packet['cluster_id']}`')
    ..writeln('- Summary: ${packet['summary']}')
    ..writeln(
      '- Recalibration candidate: `${dashboard.recalibrationCandidate.status.wireValue}`',
    )
    ..writeln('- Top machine frontier: `${topFrontier?.gapId ?? 'none'}`')
    ..writeln(
      '- Recommended next frontier: `${packet['recommended_next_wave']}`',
    )
    ..writeln(
      '- Machine-reducible remaining count: `${dashboard.completionGapSynthesis.machineReducibleRemainingCount}`',
    )
    ..writeln(
      '- Paused manual clusters: `${dashboard.completionGapSynthesis.pausedManualClusters.join(' | ')}`',
    )
    ..writeln()
    ..writeln('## Routing Proof')
    ..writeln(
      _markdownList(
        (packet['routing_proof'] as List<Object?>? ?? const <Object?>[]),
      ),
    )
    ..writeln()
    ..writeln('## Surface Scope')
    ..writeln(
      _markdownList(
        (packet['affected_surfaces'] as List<Object?>? ?? const <Object?>[]),
      ),
    )
    ..writeln()
    ..writeln('## Owner Files')
    ..writeln(
      _markdownList(
        (packet['owner_files'] as List<Object?>? ?? const <Object?>[]),
      ),
    )
    ..writeln()
    ..writeln('## Rerun Commands')
    ..writeln(
      _markdownList(
        (packet['rerun_commands'] as List<Object?>? ?? const <Object?>[]),
      ),
    );
  return buffer.toString();
}

CompletionGapEntryV1? _bestNextGapV1(CompletionGapSynthesisV1 synthesis) {
  return synthesis.recommendedNextFrontier ?? synthesis.topMachineFrontier;
}

Map<String, Object?> _buildLastExportV1({
  required String bundleId,
  required String generatedAtUtc,
  required String directoryPath,
  required String exportType,
  String? zipPath,
  String? markdownPath,
  required String serviceBaseUrl,
}) {
  return <String, Object?>{
    'bundle_id': bundleId,
    'generated_at_utc': generatedAtUtc,
    'directory_path': directoryPath,
    'export_type': exportType,
    'zip_path': zipPath,
    'markdown_path': markdownPath,
    'download_url':
        '$serviceBaseUrl/api/export/download/${Uri.encodeComponent(bundleId)}',
  };
}

Map<String, Object?> _readGitSnapshotV1({
  required String rootPath,
  Map? fallback,
}) {
  final fallbackMap = Map<String, Object?>.from(
    fallback ?? const <String, Object?>{},
  );
  final branch =
      _runGitOutputV1(rootPath, <String>[
        'rev-parse',
        '--abbrev-ref',
        'HEAD',
      ]) ??
      fallbackMap['branch'] as String? ??
      'unknown';
  final head =
      _runGitOutputV1(rootPath, <String>['rev-parse', 'HEAD']) ??
      fallbackMap['head'] as String? ??
      'unknown';
  final status = _runGitOutputV1(rootPath, <String>['status', '--porcelain']);
  final dirtyLines = status == null
      ? (fallbackMap['dirty_file_count'] as int? ?? 0)
      : const LineSplitter()
            .convert(status)
            .where((line) => line.trim().isNotEmpty)
            .length;
  return <String, Object?>{
    'branch': branch,
    'head': head,
    'is_clean_tree': dirtyLines == 0,
    'dirty_file_count': dirtyLines,
  };
}

String? _runGitOutputV1(String rootPath, List<String> args) {
  try {
    final result = Process.runSync('git', args, workingDirectory: rootPath);
    if (result.exitCode != 0) {
      return null;
    }
    final output = (result.stdout as String).trim();
    return output.isEmpty ? null : output;
  } on ProcessException {
    return null;
  }
}

List<String> _buildKeyBlockersV1({
  required AuditHubOperationalDashboardV1 dashboard,
  required Map<String, Object> releaseReadinessSnapshot,
}) {
  final blockers = <String>[
    ...dashboard.canonicalReadiness.whatBlocksHundredNow,
  ];
  final recommendedNextGap = _bestNextGapV1(dashboard.completionGapSynthesis);
  if (recommendedNextGap != null) {
    blockers.add(
      'Normalized next frontier remains `${recommendedNextGap.title}`.',
    );
  } else if (dashboard.completionGapSynthesis.topMachineFrontier == null) {
    blockers.add(
      'No machine-reducible frontier survived routing normalization on latest truth.',
    );
  }
  if (dashboard.completionGapSynthesis.pausedManualClusters.isNotEmpty) {
    blockers.add(
      'Paused manual clusters: ${dashboard.completionGapSynthesis.pausedManualClusters.join(' | ')}.',
    );
  }
  if (releaseReadinessSnapshot['goNoGoStateIsHold'] == true) {
    blockers.add(
      'Release readiness snapshot still reports HOLD on current main.',
    );
  }
  return blockers.toSet().take(6).toList();
}

String _slugifyV1(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

class AuditHubServiceRuntimeStatusV1 {
  const AuditHubServiceRuntimeStatusV1({
    required this.status,
    required this.mode,
    required this.snapshotPath,
    required this.topMachineFrontier,
    required this.machineReducibleRemainingCount,
    required this.recalibrationCandidateStatus,
  });

  final String status;
  final String mode;
  final String snapshotPath;
  final String? topMachineFrontier;
  final int machineReducibleRemainingCount;
  final String recalibrationCandidateStatus;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'status': status,
      'mode': mode,
      'snapshot_path': snapshotPath,
      'top_machine_frontier': topMachineFrontier,
      'machine_reducible_remaining_count': machineReducibleRemainingCount,
      'recalibration_candidate_status': recalibrationCandidateStatus,
    };
  }
}

AuditHubServiceRuntimeStatusV1 readAuditHubServiceRuntimeStatusV1({
  String rootPath = '.',
}) {
  final snapshotPath =
      '$rootPath${Platform.pathSeparator}$auditHubOperationalSnapshotPathV1';
  final dashboard = readAuditHubOperationalDashboardFromSnapshotFileV1(
    snapshotPath,
  );
  return AuditHubServiceRuntimeStatusV1(
    status: 'online',
    mode: 'snapshot_backed_service',
    snapshotPath: snapshotPath,
    topMachineFrontier:
        dashboard.completionGapSynthesis.topMachineFrontier?.gapId,
    machineReducibleRemainingCount:
        dashboard.completionGapSynthesis.machineReducibleRemainingCount,
    recalibrationCandidateStatus:
        dashboard.recalibrationCandidate.status.wireValue,
  );
}

Future<HttpServer> startAuditHubServiceV1({
  String rootPath = '.',
  String host = auditHubServiceDefaultHostV1,
  int port = auditHubServiceDefaultPortV1,
}) async {
  final server = await HttpServer.bind(host, port);
  server.listen((request) {
    _handleAuditHubServiceRequestV1(request, rootPath: rootPath);
  });
  return server;
}

Future<void> _handleAuditHubServiceRequestV1(
  HttpRequest request, {
  required String rootPath,
}) async {
  final response = request.response;
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set('Cache-Control', 'no-store');

  if (request.method == 'OPTIONS') {
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    response.headers.set('Access-Control-Allow-Headers', 'Content-Type');
    response.statusCode = HttpStatus.noContent;
    await response.close();
    return;
  }

  try {
    final path = request.uri.path;
    final serviceBaseUrl = _serviceBaseUrlForRequestV1(request);
    if (request.method == 'POST') {
      response.headers.contentType = ContentType.json;
      if (path == '/api/run/full') {
        final result = refreshAuditHubReadinessCalibrationSupportV1(
          rootPath: rootPath,
          timestampUtc: DateTime.now().toUtc().toIso8601String(),
          serviceBaseUrl: serviceBaseUrl,
        );
        await _writeAuditHubJsonResponseV1(
          response,
          payload: _buildApiActionResponseV1(
            ok: true,
            message:
                'Full audit snapshot pipeline completed: snapshot, review, top packet, latest run, and history were regenerated.',
            snapshot: _readJsonMap(File(result.snapshotPath)),
            includeFullAuditTrace: true,
          ),
        );
        return;
      }
      if (path == '/api/run/refresh') {
        final snapshotFile = File(
          '$rootPath${Platform.pathSeparator}$auditHubOperationalSnapshotPathV1',
        );
        if (!snapshotFile.existsSync()) {
          await _writeAuditHubJsonResponseV1(
            response,
            statusCode: HttpStatus.conflict,
            payload: <String, Object?>{
              'ok': false,
              'error': 'snapshot_missing',
              'message':
                  'No current snapshot exists yet. Run the canonical full audit pipeline first.',
            },
          );
          return;
        }
        await _writeAuditHubJsonResponseV1(
          response,
          payload: _buildApiActionResponseV1(
            ok: true,
            message: 'Existing snapshot reloaded. No audit pipeline rerun.',
            snapshot: _readJsonMap(snapshotFile),
          ),
        );
        return;
      }
      if (path == '/api/run/changed') {
        final result = refreshAuditHubReadinessCalibrationSupportV1(
          rootPath: rootPath,
          timestampUtc: DateTime.now().toUtc().toIso8601String(),
          serviceBaseUrl: serviceBaseUrl,
        );
        await _writeAuditHubJsonResponseV1(
          response,
          payload: _buildApiActionResponseV1(
            ok: true,
            message:
                'Changed-only selection is aliased to the canonical full audit snapshot pipeline in snapshot-backed mode.',
            snapshot: _readJsonMap(File(result.snapshotPath)),
          ),
        );
        return;
      }
      if (path == '/api/export/chatgpt-review') {
        final payload = _exportChatGptReviewV1(
          rootPath: rootPath,
          timestampUtc: DateTime.now().toUtc().toIso8601String(),
          serviceBaseUrl: serviceBaseUrl,
        );
        await _writeAuditHubJsonResponseV1(response, payload: payload);
        return;
      }
      if (path == '/api/export/top-wave-packet') {
        final payload = _exportTopWavePacketV1(
          rootPath: rootPath,
          timestampUtc: DateTime.now().toUtc().toIso8601String(),
          serviceBaseUrl: serviceBaseUrl,
        );
        await _writeAuditHubJsonResponseV1(response, payload: payload);
        return;
      }
      if (path == '/api/export/fix-packet') {
        final payload = _exportFixPacketV1(
          rootPath: rootPath,
          timestampUtc: DateTime.now().toUtc().toIso8601String(),
          serviceBaseUrl: serviceBaseUrl,
        );
        await _writeAuditHubJsonResponseV1(response, payload: payload);
        return;
      }
      if (path == '/api/export/full-review-bundle') {
        final payload = _exportFullReviewBundleV1(
          rootPath: rootPath,
          timestampUtc: DateTime.now().toUtc().toIso8601String(),
          serviceBaseUrl: serviceBaseUrl,
        );
        await _writeAuditHubJsonResponseV1(response, payload: payload);
        return;
      }
      await _writeAuditHubJsonResponseV1(
        response,
        statusCode: HttpStatus.methodNotAllowed,
        payload: <String, Object?>{
          'ok': false,
          'error': 'method_not_allowed',
          'allowed_methods': <String>['GET', 'POST', 'OPTIONS'],
        },
      );
      return;
    }

    if (request.method != 'GET' && request.method != 'HEAD') {
      response.headers.contentType = ContentType.json;
      await _writeAuditHubJsonResponseV1(
        response,
        statusCode: HttpStatus.methodNotAllowed,
        payload: <String, Object?>{
          'ok': false,
          'error': 'method_not_allowed',
          'allowed_methods': <String>['GET', 'POST', 'OPTIONS'],
        },
      );
      return;
    }

    if (path == '/health') {
      response.headers.contentType = ContentType.json;
      final status = readAuditHubServiceRuntimeStatusV1(rootPath: rootPath);
      await _writeAuditHubJsonResponseV1(response, payload: status.toJson());
      return;
    }
    if (path == '/dashboard') {
      response.headers.contentType = ContentType.json;
      final snapshotPath =
          '$rootPath${Platform.pathSeparator}$auditHubOperationalSnapshotPathV1';
      final snapshot = _readJsonMap(File(snapshotPath));
      final dashboard = readAuditHubOperationalDashboardFromSnapshotFileV1(
        snapshotPath,
      );
      final payload = Map<String, Object?>.from(
        jsonDecode(dashboard.toPrettyJson()) as Map,
      );
      if (snapshot['pedagogical_progression_truth'] is Map) {
        payload['pedagogical_progression_truth'] =
            snapshot['pedagogical_progression_truth'];
      }
      if (snapshot['world_pedagogical_progression_surfaces'] is List) {
        payload['world_pedagogical_progression_surfaces'] =
            snapshot['world_pedagogical_progression_surfaces'];
      }
      if (snapshot['finding_inventory'] is Map) {
        payload['finding_inventory'] = snapshot['finding_inventory'];
      }
      await _writeAuditHubJsonResponseV1(response, payload: payload);
      return;
    }
    if (path == '/api/snapshot') {
      response.headers.contentType = ContentType.json;
      final snapshotFile = File(
        '$rootPath${Platform.pathSeparator}$auditHubOperationalSnapshotPathV1',
      );
      await _writeAuditHubJsonResponseV1(
        response,
        payload: <String, Object?>{
          'ok': true,
          'snapshot': _readJsonMap(snapshotFile),
          'mode': 'snapshot_backed_service',
          'service_status': 'online',
        },
      );
      return;
    }
    if (path == '/snapshot') {
      response.headers.contentType = ContentType.json;
      final snapshotFile = File(
        '$rootPath${Platform.pathSeparator}$auditHubOperationalSnapshotPathV1',
      );
      await _writeAuditHubJsonResponseV1(
        response,
        payload: _readJsonMap(snapshotFile),
      );
      return;
    }
    if (path.startsWith('/api/export/download/')) {
      final bundleId = Uri.decodeComponent(path.split('/').last);
      final exportFilePath = _resolveExportFileForBundleIdV1(
        rootPath: rootPath,
        bundleId: bundleId,
      );
      if (exportFilePath == null || !File(exportFilePath).existsSync()) {
        response.headers.contentType = ContentType.json;
        await _writeAuditHubJsonResponseV1(
          response,
          statusCode: HttpStatus.notFound,
          payload: <String, Object?>{
            'ok': false,
            'error': 'export_missing',
            'bundle_id': bundleId,
          },
        );
        return;
      }
      await _serveFileV1(
        request,
        file: File(exportFilePath),
        downloadName: exportFilePath.split(Platform.pathSeparator).last,
      );
      return;
    }
    final servedStatic = await _tryServeStaticAuditHubUiV1(
      request,
      rootPath: rootPath,
    );
    if (servedStatic) {
      return;
    }
    await _writeAuditHubJsonResponseV1(
      response,
      statusCode: HttpStatus.notFound,
      payload: <String, Object?>{'error': 'not_found', 'path': path},
    );
  } on Object catch (error) {
    response.headers.contentType = ContentType.json;
    await _writeAuditHubJsonResponseV1(
      response,
      statusCode: HttpStatus.serviceUnavailable,
      payload: <String, Object?>{
        'status': 'offline',
        'error': '$error',
        'mode': 'snapshot_backed_service',
      },
    );
  }
}

Future<void> _writeAuditHubJsonResponseV1(
  HttpResponse response, {
  int statusCode = HttpStatus.ok,
  required Map<String, Object?> payload,
}) async {
  response.statusCode = statusCode;
  response.write('${const JsonEncoder.withIndent('  ').convert(payload)}\n');
  await response.close();
}

Map<String, Object?> _buildApiActionResponseV1({
  required bool ok,
  required String message,
  required Map<String, Object?> snapshot,
  String? downloadUrl,
  String? error,
  bool includeFullAuditTrace = false,
}) {
  final auditIds =
      (snapshot['latest_run'] as Map? ?? const <String, Object?>{})['results']
          as List<Object?>? ??
      const <Object?>[];
  final latestRun = Map<String, Object?>.from(
    snapshot['latest_run'] as Map? ?? const <String, Object?>{},
  );
  return <String, Object?>{
    'ok': ok,
    'message': message,
    'snapshot': snapshot,
    'download_url': downloadUrl,
    'error': error,
    if (includeFullAuditTrace)
      'full_audit_trace': latestRun['full_audit_trace'],
    'audit_ids': auditIds
        .whereType<Map>()
        .map((result) => result['audit_id'])
        .whereType<String>()
        .toList(),
  };
}

Map<String, Object?> _exportChatGptReviewV1({
  required String rootPath,
  required String timestampUtc,
  required String serviceBaseUrl,
}) {
  final result = refreshAuditHubReadinessCalibrationSupportV1(
    rootPath: rootPath,
    timestampUtc: timestampUtc,
    serviceBaseUrl: serviceBaseUrl,
  );
  final bundleId =
      'chatgpt_review_${_normalizeTimestampForFileV1(timestampUtc)}';
  final snapshot = _readJsonMap(File(result.snapshotPath));
  snapshot['last_export'] = _buildLastExportV1(
    bundleId: bundleId,
    generatedAtUtc: timestampUtc,
    directoryPath: File(result.reviewPath).parent.path,
    exportType: 'chatgpt_review_markdown',
    markdownPath: result.reviewPath,
    serviceBaseUrl: serviceBaseUrl,
  );
  _writeSnapshotAndSupportFilesV1(rootPath: rootPath, snapshot: snapshot);
  return _buildApiActionResponseV1(
    ok: true,
    message: 'ChatGPT review export ready.',
    snapshot: snapshot,
    downloadUrl: (snapshot['last_export'] as Map)['download_url'] as String?,
  );
}

Map<String, Object?> _exportTopWavePacketV1({
  required String rootPath,
  required String timestampUtc,
  required String serviceBaseUrl,
}) {
  final result = refreshAuditHubReadinessCalibrationSupportV1(
    rootPath: rootPath,
    timestampUtc: timestampUtc,
    serviceBaseUrl: serviceBaseUrl,
  );
  final bundleId =
      'top_wave_packet_${_normalizeTimestampForFileV1(timestampUtc)}';
  final snapshot = _readJsonMap(File(result.snapshotPath));
  snapshot['last_export'] = _buildLastExportV1(
    bundleId: bundleId,
    generatedAtUtc: timestampUtc,
    directoryPath: File(result.topWavePacketPath).parent.path,
    exportType: 'top_wave_packet_markdown',
    markdownPath: result.topWavePacketPath,
    serviceBaseUrl: serviceBaseUrl,
  );
  _writeSnapshotAndSupportFilesV1(rootPath: rootPath, snapshot: snapshot);
  return _buildApiActionResponseV1(
    ok: true,
    message: 'Top wave packet export ready.',
    snapshot: snapshot,
    downloadUrl: (snapshot['last_export'] as Map)['download_url'] as String?,
  );
}

Map<String, Object?> _exportFixPacketV1({
  required String rootPath,
  required String timestampUtc,
  required String serviceBaseUrl,
}) {
  final result = refreshAuditHubReadinessCalibrationSupportV1(
    rootPath: rootPath,
    timestampUtc: timestampUtc,
    serviceBaseUrl: serviceBaseUrl,
  );
  final snapshot = _readJsonMap(File(result.snapshotPath));
  final dashboard = result.dashboard;
  final packetDir = Directory(
    '$rootPath${Platform.pathSeparator}$auditHubFixPacketDirV1',
  )..createSync(recursive: true);
  final bundleId = 'fix_packet_${_normalizeTimestampForFileV1(timestampUtc)}';
  final markdownPath = '${packetDir.path}${Platform.pathSeparator}$bundleId.md';
  final previousRun =
      (snapshot['recent_runs'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .skip(1)
          .cast<Map>()
          .isNotEmpty
      ? Map<String, Object?>.from(
          (snapshot['recent_runs'] as List<Object?>)
              .whereType<Map>()
              .skip(1)
              .cast<Map>()
              .first,
        )
      : const <String, Object?>{};
  File(markdownPath).writeAsStringSync(
    _renderFixPacketMarkdownV1(
      snapshot: snapshot,
      dashboard: dashboard,
      timestampUtc: timestampUtc,
      previousRun: Map<String, Object?>.from(previousRun),
    ),
  );
  snapshot['last_export'] = _buildLastExportV1(
    bundleId: bundleId,
    generatedAtUtc: timestampUtc,
    directoryPath: packetDir.path,
    exportType: 'fix_packet_markdown',
    markdownPath: markdownPath,
    serviceBaseUrl: serviceBaseUrl,
  );
  _writeSnapshotAndSupportFilesV1(rootPath: rootPath, snapshot: snapshot);
  return _buildApiActionResponseV1(
    ok: true,
    message: 'Fix packet export ready.',
    snapshot: snapshot,
    downloadUrl: (snapshot['last_export'] as Map)['download_url'] as String?,
  );
}

Map<String, Object?> _exportFullReviewBundleV1({
  required String rootPath,
  required String timestampUtc,
  required String serviceBaseUrl,
}) {
  final result = refreshAuditHubReadinessCalibrationSupportV1(
    rootPath: rootPath,
    timestampUtc: timestampUtc,
    serviceBaseUrl: serviceBaseUrl,
  );
  final snapshot = _readJsonMap(File(result.snapshotPath));
  final bundleDir = Directory(
    '$rootPath${Platform.pathSeparator}$auditHubBundleDirV1',
  )..createSync(recursive: true);
  final bundleId =
      'full_review_bundle_${_normalizeTimestampForFileV1(timestampUtc)}';
  final zipPath = '${bundleDir.path}${Platform.pathSeparator}$bundleId.zip';
  final encoder = ZipFileEncoder();
  encoder.create(zipPath);
  for (final filePath in <String>[
    result.snapshotPath,
    result.reviewPath,
    result.topWavePacketPath,
    result.dossierPath,
    result.latestRunPath,
    result.historyIndexPath,
  ]) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }
    encoder.addFile(
      file,
      _relativePathWithinRootV1(rootPath: rootPath, filePath: file.path),
    );
  }
  encoder.close();
  snapshot['last_export'] = _buildLastExportV1(
    bundleId: bundleId,
    generatedAtUtc: timestampUtc,
    directoryPath: bundleDir.path,
    exportType: 'full_review_bundle_zip',
    zipPath: zipPath,
    serviceBaseUrl: serviceBaseUrl,
  );
  _writeSnapshotAndSupportFilesV1(rootPath: rootPath, snapshot: snapshot);
  return _buildApiActionResponseV1(
    ok: true,
    message: 'Full review bundle export ready.',
    snapshot: snapshot,
    downloadUrl: (snapshot['last_export'] as Map)['download_url'] as String?,
  );
}

String _renderFixPacketMarkdownV1({
  required Map<String, Object?> snapshot,
  required AuditHubOperationalDashboardV1 dashboard,
  required String timestampUtc,
  required Map<String, Object?> previousRun,
}) {
  final currentRun = Map<String, Object?>.from(
    snapshot['latest_run'] as Map? ?? const <String, Object?>{},
  );
  final currentFrontier =
      _bestNextGapV1(dashboard.completionGapSynthesis)?.gapId ?? 'none';
  final previousFrontier =
      ((previousRun['results'] as List<Object?>? ?? const <Object?>[])
              .whereType<Map>()
              .firstWhere(
                (result) => result['audit_id'] == 'completion_gap_synthesis_v1',
                orElse: () => const <String, Object?>{},
              )['details']
          as String?) ??
      'unknown';
  final buffer = StringBuffer()
    ..writeln('# Audit Hub Fix Packet $timestampUtc')
    ..writeln()
    ..writeln('- Recommended next frontier: `$currentFrontier`')
    ..writeln(
      '- Recalibration candidate: `${dashboard.recalibrationCandidate.status.wireValue}`',
    )
    ..writeln(
      '- Machine-reducible remaining count: `${dashboard.completionGapSynthesis.machineReducibleRemainingCount}`',
    )
    ..writeln(
      '- Paused manual clusters: `${dashboard.completionGapSynthesis.pausedManualClusters.join(' | ')}`',
    )
    ..writeln('- Previous run comparison seed: `$previousFrontier`')
    ..writeln()
    ..writeln('## Current Key Blockers')
    ..writeln(
      _markdownList(
        (currentRun['key_blockers'] as List<Object?>? ?? const <Object?>[]),
      ),
    )
    ..writeln()
    ..writeln('## Next Honest Commands')
    ..writeln(
      _markdownList(
        topMachineFrontierCommandsV1(
          dashboard: dashboard,
          timestampUtc: timestampUtc,
        ),
      ),
    );
  return buffer.toString();
}

List<Object?> topMachineFrontierCommandsV1({
  required AuditHubOperationalDashboardV1 dashboard,
  required String timestampUtc,
}) {
  final recommendedNextGap = _bestNextGapV1(dashboard.completionGapSynthesis);
  if (recommendedNextGap != null &&
      recommendedNextGap.measurableProofPath.isNotEmpty) {
    return recommendedNextGap.measurableProofPath;
  }
  return <Object?>[
    'dart run tools/audit_hub_refresh_v1.dart --timestamp $timestampUtc',
  ];
}

void _writeSnapshotAndSupportFilesV1({
  required String rootPath,
  required Map<String, Object?> snapshot,
}) {
  final snapshotFile = File(
    '$rootPath${Platform.pathSeparator}$auditHubOperationalSnapshotPathV1',
  );
  snapshotFile.parent.createSync(recursive: true);
  snapshotFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(snapshot)}\n',
  );
  final latestRunFile = File(
    '$rootPath${Platform.pathSeparator}$auditHubLatestRunPathV1',
  );
  latestRunFile.parent.createSync(recursive: true);
  latestRunFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(snapshot['latest_run'])}\n',
  );
  final historyIndexFile = File(
    '$rootPath${Platform.pathSeparator}$auditHubHistoryIndexPathV1',
  );
  historyIndexFile.parent.createSync(recursive: true);
  historyIndexFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'generated_at_utc': snapshot['generated_at_utc'], 'runs': snapshot['recent_runs']})}\n',
  );
}

Map<String, Object?> _readCurrentLastExportV1({required String rootPath}) {
  final snapshot = _readJsonMap(
    File(
      '$rootPath${Platform.pathSeparator}$auditHubOperationalSnapshotPathV1',
    ),
  );
  return Map<String, Object?>.from(
    snapshot['last_export'] as Map? ?? const <String, Object?>{},
  );
}

String? _resolveExportFileForBundleIdV1({
  required String rootPath,
  required String bundleId,
}) {
  final currentLastExport = _readCurrentLastExportV1(rootPath: rootPath);
  if ((currentLastExport['bundle_id'] as String?) == bundleId) {
    return currentLastExport['zip_path'] as String? ??
        currentLastExport['markdown_path'] as String?;
  }
  for (final dirPath in <String>[
    auditHubBundleDirV1,
    auditHubFixPacketDirV1,
    auditHubTopWavePacketDirV1,
    auditHubReviewDirV1,
  ]) {
    final dir = Directory('$rootPath${Platform.pathSeparator}$dirPath');
    if (!dir.existsSync()) {
      continue;
    }
    final matches =
        dir
            .listSync()
            .whereType<File>()
            .where(
              (file) => file.path
                  .split(Platform.pathSeparator)
                  .last
                  .startsWith(bundleId),
            )
            .toList()
          ..sort(
            (left, right) =>
                right.statSync().modified.compareTo(left.statSync().modified),
          );
    if (matches.isNotEmpty) {
      return matches.first.path;
    }
  }
  return null;
}

String _serviceBaseUrlForRequestV1(HttpRequest request) {
  final origin = request.requestedUri.origin;
  return origin.isEmpty
      ? 'http://$auditHubServiceDefaultHostV1:$auditHubServiceDefaultPortV1'
      : origin;
}

Future<bool> _tryServeStaticAuditHubUiV1(
  HttpRequest request, {
  required String rootPath,
}) async {
  final bundleRoot = Directory(
    '$rootPath${Platform.pathSeparator}$auditHubWebBundleDirV1',
  );
  if (!bundleRoot.existsSync()) {
    return false;
  }

  final relativePath = request.uri.path == '/' || request.uri.path.isEmpty
      ? 'index.html'
      : request.uri.path.replaceFirst(RegExp(r'^/+'), '');
  final requestedFile = File(
    '${bundleRoot.path}${Platform.pathSeparator}${relativePath.replaceAll('/', Platform.pathSeparator)}',
  );
  if (requestedFile.existsSync()) {
    await _serveFileV1(request, file: requestedFile);
    return true;
  }

  if (!relativePath.contains('.')) {
    final indexFile = File(
      '${bundleRoot.path}${Platform.pathSeparator}index.html',
    );
    if (indexFile.existsSync()) {
      await _serveFileV1(request, file: indexFile);
      return true;
    }
  }
  return false;
}

Future<void> _serveFileV1(
  HttpRequest request, {
  required File file,
  String? downloadName,
}) async {
  final response = request.response;
  response.headers.contentType = _contentTypeForPathV1(file.path);
  if (downloadName != null) {
    response.headers.set(
      'Content-Disposition',
      'attachment; filename="$downloadName"',
    );
  }
  if (request.method == 'HEAD') {
    response.statusCode = HttpStatus.ok;
    await response.close();
    return;
  }
  await file.openRead().pipe(response);
}

ContentType _contentTypeForPathV1(String path) {
  if (path.endsWith('.html')) {
    return ContentType.html;
  }
  if (path.endsWith('.js')) {
    return ContentType('application', 'javascript', charset: 'utf-8');
  }
  if (path.endsWith('.json')) {
    return ContentType.json;
  }
  if (path.endsWith('.css')) {
    return ContentType('text', 'css', charset: 'utf-8');
  }
  if (path.endsWith('.png')) {
    return ContentType('image', 'png');
  }
  if (path.endsWith('.svg')) {
    return ContentType('image', 'svg+xml');
  }
  if (path.endsWith('.wasm')) {
    return ContentType('application', 'wasm');
  }
  if (path.endsWith('.txt') || path.endsWith('.md')) {
    return ContentType.text;
  }
  if (path.endsWith('.zip')) {
    return ContentType('application', 'zip');
  }
  return ContentType.binary;
}

String _relativePathWithinRootV1({
  required String rootPath,
  required String filePath,
}) {
  final normalizedRoot = Directory(
    rootPath,
  ).absolute.path.replaceAll('\\', '/');
  final normalizedFile = File(filePath).absolute.path.replaceAll('\\', '/');
  if (!normalizedFile.startsWith(normalizedRoot)) {
    return normalizedFile.split('/').last;
  }
  return normalizedFile.substring(normalizedRoot.length + 1);
}

String _relativeArtifactLabelV1(String path) =>
    path.replaceAll('\\', '/').split('/').last;

String _markdownList(List<Object?> values) =>
    values.map((value) => '- $value').join('\n');

void main(List<String> args) async {
  var rootPath = '.';
  var host = auditHubServiceDefaultHostV1;
  var port = auditHubServiceDefaultPortV1;

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--root' && i + 1 < args.length) {
      rootPath = args[++i];
    } else if (arg == '--host' && i + 1 < args.length) {
      host = args[++i];
    } else if (arg == '--port' && i + 1 < args.length) {
      port = int.tryParse(args[++i]) ?? auditHubServiceDefaultPortV1;
    } else if (arg == '--help') {
      stdout.writeln(
        'Usage: dart run tools/audit_hub_service_v1.dart '
        '[--root <path>] [--host <host>] [--port <port>]',
      );
      stdout.writeln(
        'Canonical operator path: start this service, then open http://$host:$port in a browser.',
      );
      stdout.writeln(
        'Endpoints: /health, /dashboard, /snapshot, /api/snapshot, /api/run/full, /api/run/refresh',
      );
      return;
    }
  }

  final server = await startAuditHubServiceV1(
    rootPath: rootPath,
    host: host,
    port: port,
  );
  stdout.writeln(
    'Audit Hub service online at http://${server.address.address}:${server.port}',
  );
  stdout.writeln(
    'Open Audit Hub UI: http://${server.address.address}:${server.port}',
  );
}

Map<String, Object?> _readJsonMap(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw StateError('Expected JSON object at ${file.path}');
  }
  return Map<String, Object?>.from(decoded);
}

String _normalizeTimestampForFileV1(String timestampUtc) {
  return timestampUtc
      .replaceAll('-', '')
      .replaceAll(':', '')
      .replaceAll('.', '_');
}

String _findLatestMarkdownFilePathV1(String dirPath) {
  final dir = Directory(dirPath);
  if (!dir.existsSync()) {
    return '';
  }
  final entries =
      dir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.md'))
          .toList()
        ..sort(
          (left, right) =>
              right.statSync().modified.compareTo(left.statSync().modified),
        );
  return entries.isEmpty ? '' : entries.first.path;
}

int? _parseWorldNumberV1(String worldId) {
  final match = RegExp(r'^W(\d+)$').firstMatch(worldId);
  if (match == null) {
    return null;
  }
  final world = int.tryParse(match.group(1)!);
  if (world == null || world < 0) {
    return null;
  }
  return world;
}
