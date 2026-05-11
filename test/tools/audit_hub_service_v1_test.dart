import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/audit_hub_v1/audit_hub_operational_models_v1.dart';
import 'package:test/test.dart';

import '../../tools/audit_hub_service_v1.dart';

void main() {
  test('review export includes canonical readiness and recalibration candidate', () {
    const canonical = CanonicalReadinessV1(
      sourceSsotPath: 'docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md',
      coreReadinessPercent: 65.9,
      shipReadinessPercent: 49.7,
      finalReadinessPercent: 62.0,
      topBottleneckBlock: 'M Production / Release Confidence',
      topBottleneckEpic:
          'M3 repeatable go/no-go, rollback, and release discipline',
      confidenceNote: 'Canonical readiness stays fixed until the SSOT changes.',
      whatBlocksHundredNow: <String>['Human review still pending.'],
      hardBlockers: <String>['M3'],
      softBlockers: <String>['Visual proof residue'],
      explanation: 'Canonical readiness is sourced from the SSOT.',
    );

    const dashboard = AuditHubOperationalDashboardV1(
      canonicalReadiness: canonical,
      recalibrationCandidate: ReadinessRecalibrationCandidateV1(
        canonicalReadinessSourcePath:
            'docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md',
        canonicalReadiness: canonical,
        status: ReadinessRecalibrationCandidateStatusV1.noChange,
        candidateBlockMovements: <CandidateBlockMovementV1>[],
        candidateEpicMovements: <CandidateEpicMovementV1>[],
        candidateScoreDeltas: CandidateScoreDeltasV1(
          coreDelta: 0,
          shipDelta: 0,
          finalDelta: 0,
        ),
        rawVsEffectiveNote:
            'Canonical readiness remains the reporting source of truth.',
        recalibrationJustifiedNow: false,
        recalibrationReason: 'No justified readiness change.',
        proofGapsIfNotJustified: <String>[
          'Human release review remains pending on current main.',
        ],
      ),
      completionGapSynthesis: CompletionGapSynthesisV1(
        sourceTruthOwners: <String>[
          'docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md',
          'docs/plan/WORLD_READINESS_REGISTRY_v1.md',
          'docs/plan/PRODUCT_SURFACE_READINESS_v1.md',
        ],
        gaps: <CompletionGapEntryV1>[
          CompletionGapEntryV1(
            gapId: 'cluster_ops_release_confidence',
            sourceTruthOwner:
                'out/audit_hub_v1/top_wave_packets/top_wave_packet_test.md',
            title: 'Ops / Release Confidence',
            category: 'cluster',
            worldScope: <String>['W1'],
            surfaceScope: <String>['release confidence baseline'],
            readinessBlocks: <String>['H', 'M', 'N'],
            epicMappings: <String>['M Production / Release Confidence'],
            currentStatus: 'paused_on_manual_boundary',
            admissibility: CompletionGapAdmissibilityV1.proofManualOnly,
            likelySeam: 'manual residue',
            ownerFiles: <String>['tools/release_readiness_snapshot_v1.dart'],
            measurableProofPath: <String>[
              'dart run tools/session_world_truth_surface_audit_v1.dart --world=0 --json',
            ],
            prerequisiteBlockers: <String>[
              'Human release review remains pending.',
            ],
            evPriorityOrder: 1,
            nextFrontierReason: 'Still open and still active.',
          ),
        ],
        topMachineFrontier: null,
        recommendedNextFrontier: CompletionGapEntryV1(
          gapId: 'cluster_ops_release_confidence',
          sourceTruthOwner:
              'out/audit_hub_v1/top_wave_packets/top_wave_packet_test.md',
          title: 'Ops / Release Confidence',
          category: 'cluster',
          worldScope: <String>['W1'],
          surfaceScope: <String>['release confidence baseline'],
          readinessBlocks: <String>['H', 'M', 'N'],
          epicMappings: <String>['M Production / Release Confidence'],
          currentStatus: 'paused_on_manual_boundary',
          admissibility: CompletionGapAdmissibilityV1.proofManualOnly,
          likelySeam: 'manual residue',
          ownerFiles: <String>['tools/release_readiness_snapshot_v1.dart'],
          measurableProofPath: <String>[
            'dart run tools/session_world_truth_surface_audit_v1.dart --world=0 --json',
          ],
          prerequisiteBlockers: <String>[
            'Human release review remains pending.',
            'Routing truth was normalized before route acceptance.',
          ],
          evPriorityOrder: 1,
          nextFrontierReason: 'Still open and still active.',
        ),
        pausedManualClusters: <String>['Ops / Release Confidence'],
        nextBestMachineFrontiers: <CompletionGapEntryV1>[],
        why100NotReached: <String>['Human release review remains pending.'],
        allRemainingGapsCount: 1,
        machineReducibleRemainingCount: 0,
        manualBoundRemainingCount: 1,
      ),
    );

    final markdown = renderAuditHubReviewExportV1(
      snapshot: <String, Object?>{
        'version': 'v1',
        'generated_at_utc': '2026-04-04T12:45:00Z',
        'top_wave_packet': <String, Object?>{
          'title': 'Ops / Release Confidence',
          'likely_seam': 'manual residue',
        },
        'latest_run': <String, Object?>{
          'run_id': '20260404T124500Z',
          'completed_at_utc': '2026-04-04T12:45:00Z',
          'git': <String, Object?>{
            'branch': 'main',
            'head': 'deadbeef',
            'is_clean_tree': false,
            'dirty_file_count': 4,
          },
          'summary': <String, Object?>{'total_results': 3},
          'full_audit_trace': <String, Object?>{
            'run_type': 'full_audit_snapshot_pipeline',
            'duration_ms': 214,
            'previous_run_id': '20260404T123000Z',
            'current_run_id': '20260404T124500Z',
            'executed_steps': <String>[
              'read previous snapshot/latest run',
              'derive release-readiness snapshot',
              'build operational dashboard',
            ],
            'regenerated_artifacts': <String>[
              'operational_snapshot.json',
              'latest_run.json',
              'history_index.json',
            ],
          },
        },
        'codex_work_queue': <Object?>[
          <String, Object?>{
            'rank': 1,
            'title': 'Ops / Release Confidence',
            'reason': 'Human review still pending.',
          },
        ],
        'finding_inventory': <String, Object?>{
          'worlds_with_open_findings_count': 2,
          'coverage_note':
              'Per-world admissibility counts cover routed completion-gap entries plus pedagogical findings.',
          'biggest_open_world_buckets': <Object?>[
            <String, Object?>{
              'world_id': 'W0',
              'total_open_findings': 6,
              'dominant_bucket_label': 'pedagogical_finish',
            },
            <String, Object?>{
              'world_id': 'W1',
              'total_open_findings': 4,
              'dominant_bucket_label': 'unification',
            },
          ],
          'current_frontier_visible_bucket': <String, Object?>{
            'world_id': 'W0',
            'dominant_bucket_label': 'pedagogical_finish',
            'dominant_bucket_count': 2,
            'total_open_findings': 6,
            'machine_reducible_findings': 1,
            'truth_layer_first_findings': 3,
            'proof_manual_only_findings': 1,
            'pedagogical_total_count': 4,
            'unification_count': 1,
            'other_world_quality_count': 1,
          },
          'unification_drift_breakdown': <String, Object?>{
            'mixed_family_count': 2,
            'shared_owner_missing_count': 3,
            'local_override_count': 1,
            'route_inventory_missing_count': 4,
            'visual_instrumentation_missing_count': 4,
            'screenshot_evidence_missing_count': 4,
          },
          'world_breakdown': <Object?>[
            <String, Object?>{'world_id': 'W0', 'total_open_findings': 6},
            <String, Object?>{'world_id': 'W1', 'total_open_findings': 4},
          ],
        },
      },
      dashboard: dashboard,
      timestampUtc: '2026-04-04T12:45:00Z',
      previousSnapshot: <String, Object?>{
        'completion_gap_synthesis': <String, Object?>{
          'top_machine_frontier': <String, Object?>{'title': 'none'},
          'machine_reducible_remaining_count': 2,
          'manual_bound_remaining_count': 3,
        },
        'readiness_recalibration_candidate': <String, Object?>{
          'recalibration_candidate_status': 'no_change',
        },
      },
    );

    expect(markdown, contains('## Latest Reduction Delta'));
    expect(markdown, contains('## Previous vs Current Snapshot'));
    expect(markdown, contains('## Run Integrity'));
    expect(markdown, contains('## Route-to-100 Progress Signal'));
    expect(markdown, contains('## Current Operational Context'));
    expect(markdown, contains('## Finding Inventory'));
    expect(markdown, contains('## Full Audit Trace'));
    expect(markdown, contains('## Project Health Snapshot'));
    expect(markdown, contains('## Readiness Recalibration Candidate'));
    expect(markdown, contains('## Completion Gap Synthesis'));
    expect(markdown, contains('Top machine frontier: `none -> none`'));
    expect(
      markdown,
      contains(
        'Recommended next wave (normalized): `Ops / Release Confidence`',
      ),
    );
    expect(
      markdown,
      contains('Routing truth normalized before recommendation: `yes`'),
    );
    expect(
      markdown,
      contains('Recommended next frontier: `Ops / Release Confidence`'),
    );
    expect(markdown, contains('Machine-reducible remaining count: `2 -> 0`'));
    expect(markdown, contains('Manual-bound remaining count: `3 -> 1`'));
    expect(markdown, contains('Latest run id: `20260404T124500Z`'));
    expect(markdown, contains('Tree classification: `dirty (4 files)`'));
    expect(markdown, contains('Run type: `full_audit_snapshot_pipeline`'));
    expect(markdown, contains('Duration ms: `214`'));
    expect(
      markdown,
      contains('Run ids: `20260404T123000Z -> 20260404T124500Z`'),
    );
    expect(
      markdown,
      contains(
        'Executed steps: read previous snapshot/latest run | derive release-readiness snapshot | build operational dashboard',
      ),
    );
    expect(markdown, contains('Worlds with open findings: `2` / `2`'));
    expect(
      markdown,
      contains(
        'Biggest open world buckets: W0=6 (pedagogical_finish) | W1=4 (unification)',
      ),
    );
    expect(
      markdown,
      contains(
        'Highest-EV visible bucket inside current frontier: W0 pedagogical_finish=2 (total=6)',
      ),
    );
    expect(
      markdown,
      contains(
        'Unification drift breakdown: mixed_family=2 | shared_owner_missing=3 | local_override=1 | route_inventory_missing=4 | visual_instrumentation_missing=4 | screenshot_evidence_missing=4',
      ),
    );
    expect(markdown, contains('Signal: `improved`'));
    expect(markdown, contains('Reason: one measurable family closed'));
    expect(markdown, contains('docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md'));
    expect(markdown, contains('no_change'));
    expect(markdown, contains('No justified readiness change.'));
    expect(markdown, contains('cluster_ops_release_confidence'));
    expect(markdown, contains('proof_manual_only'));
    expect(
      markdown,
      contains(
        'dart run tools/session_world_truth_surface_audit_v1.dart --world=0 --json',
      ),
    );
  });

  test('service exposes online health and dashboard endpoints', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'audit_hub_service_v1_test_',
    );
    addTearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    _seedAuditHubTempRepo(tempDir);

    final server = await startAuditHubServiceV1(
      rootPath: tempDir.path,
      host: '127.0.0.1',
      port: 0,
    );
    addTearDown(() async => server.close(force: true));

    final client = HttpClient();
    addTearDown(client.close);

    final healthRequest = await client.getUrl(
      Uri.parse('http://127.0.0.1:${server.port}/health'),
    );
    final healthResponse = await healthRequest.close();
    expect(healthResponse.statusCode, HttpStatus.ok);
    final healthBody =
        jsonDecode(await utf8.decodeStream(healthResponse))
            as Map<String, Object?>;
    expect(healthBody['status'], 'online');
    expect(healthBody['mode'], 'snapshot_backed_service');
    expect(healthBody['top_machine_frontier'], 'world_gap_w0');

    final rootRequest = await client.getUrl(
      Uri.parse('http://127.0.0.1:${server.port}/'),
    );
    final rootResponse = await rootRequest.close();
    expect(rootResponse.statusCode, HttpStatus.ok);
    final rootBody = await utf8.decodeStream(rootResponse);
    expect(rootBody, contains('Audit Hub Test Bundle'));

    final dashboardRequest = await client.getUrl(
      Uri.parse('http://127.0.0.1:${server.port}/dashboard'),
    );
    final dashboardResponse = await dashboardRequest.close();
    expect(dashboardResponse.statusCode, HttpStatus.ok);
    final dashboardBody =
        jsonDecode(await utf8.decodeStream(dashboardResponse))
            as Map<String, Object?>;
    expect(dashboardBody, contains('project_health'));
    expect(dashboardBody, contains('completion_gap_synthesis'));

    final snapshotRequest = await client.getUrl(
      Uri.parse('http://127.0.0.1:${server.port}/api/snapshot'),
    );
    final snapshotResponse = await snapshotRequest.close();
    expect(snapshotResponse.statusCode, HttpStatus.ok);
    final snapshotBody =
        jsonDecode(await utf8.decodeStream(snapshotResponse))
            as Map<String, Object?>;
    expect(snapshotBody['service_status'], 'online');
    expect(snapshotBody['mode'], 'snapshot_backed_service');
    expect(snapshotBody['snapshot'], isA<Map>());
  });

  test(
    'service full audit and export actions refresh operator truth',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'audit_hub_service_v1_actions_',
      );
      addTearDown(() async {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      _seedAuditHubTempRepo(tempDir);

      final server = await startAuditHubServiceV1(
        rootPath: tempDir.path,
        host: '127.0.0.1',
        port: 0,
      );
      addTearDown(() async => server.close(force: true));

      final client = HttpClient();
      addTearDown(client.close);

      final runRequest = await client.postUrl(
        Uri.parse('http://127.0.0.1:${server.port}/api/run/full'),
      );
      runRequest.headers.contentType = ContentType.json;
      runRequest.write('{}');
      final runResponse = await runRequest.close();
      expect(runResponse.statusCode, HttpStatus.ok);
      final runBody =
          jsonDecode(await utf8.decodeStream(runResponse))
              as Map<String, Object?>;
      expect(runBody['ok'], true);
      expect(runBody['message'], contains('Full audit snapshot pipeline'));
      final fullAuditTrace = Map<String, Object?>.from(
        runBody['full_audit_trace'] as Map,
      );
      expect(fullAuditTrace['run_type'], 'full_audit_snapshot_pipeline');
      expect(fullAuditTrace['duration_ms'], isA<int>());
      expect(
        fullAuditTrace['executed_steps'],
        contains('read previous snapshot/latest run'),
      );
      expect(
        fullAuditTrace['regenerated_artifacts'],
        contains('operational_snapshot.json'),
      );
      final refreshedSnapshot = Map<String, Object?>.from(
        runBody['snapshot'] as Map,
      );
      expect(refreshedSnapshot['generated_at_utc'] as String?, isNotNull);
      expect(
        Map<String, Object?>.from(
          refreshedSnapshot['latest_run'] as Map,
        )['run_id'],
        isNotNull,
      );
      expect(
        File(
          '${tempDir.path}${Platform.pathSeparator}$auditHubLatestRunPathV1',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}${Platform.pathSeparator}$auditHubHistoryIndexPathV1',
        ).existsSync(),
        isTrue,
      );
      final dossierDir = Directory(
        '${tempDir.path}${Platform.pathSeparator}$auditHubDossierDirV1',
      );
      expect(dossierDir.existsSync(), isTrue);
      final dossierFiles = dossierDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.md'))
          .toList();
      expect(dossierFiles, isNotEmpty);
      dossierFiles.sort((left, right) => right.path.compareTo(left.path));
      final dossierMarkdown = dossierFiles.first.readAsStringSync();
      expect(dossierMarkdown, contains('## 1. Executive Summary'));
      expect(dossierMarkdown, contains('## 2. What Was Completed Recently'));
      expect(
        dossierMarkdown,
        contains('## 3. Current Project State by Major Block'),
      );
      expect(dossierMarkdown, contains('## 4. World-by-World Status'));
      expect(
        dossierMarkdown,
        contains('## 5. Unification / Architecture State'),
      );
      expect(dossierMarkdown, contains('## 6. Remaining-to-100'));
      expect(dossierMarkdown, contains('## 7. Best Current Route'));
      expect(dossierMarkdown, contains('## 8. Freshness / Trust / Integrity'));
      expect(dossierMarkdown, contains('## 9. Evidence / Source Index'));
      final refreshedRunId =
          Map<String, Object?>.from(
                refreshedSnapshot['latest_run'] as Map,
              )['run_id']
              as String?;
      expect(
        Map<String, Object?>.from(
          refreshedSnapshot['latest_run'] as Map,
        )['full_audit_trace'],
        isA<Map>(),
      );

      final refreshRequest = await client.postUrl(
        Uri.parse('http://127.0.0.1:${server.port}/api/run/refresh'),
      );
      refreshRequest.headers.contentType = ContentType.json;
      refreshRequest.write('{}');
      final refreshResponse = await refreshRequest.close();
      expect(refreshResponse.statusCode, HttpStatus.ok);
      final refreshBody =
          jsonDecode(await utf8.decodeStream(refreshResponse))
              as Map<String, Object?>;
      expect(refreshBody['ok'], true);
      expect(refreshBody.containsKey('full_audit_trace'), isFalse);
      expect(
        refreshBody['message'],
        contains('Existing snapshot reloaded. No audit pipeline rerun.'),
      );
      final reloadedSnapshot = Map<String, Object?>.from(
        refreshBody['snapshot'] as Map,
      );
      expect(
        Map<String, Object?>.from(
          reloadedSnapshot['latest_run'] as Map,
        )['run_id'],
        refreshedRunId,
      );

      final exportRequest = await client.postUrl(
        Uri.parse('http://127.0.0.1:${server.port}/api/export/chatgpt-review'),
      );
      exportRequest.headers.contentType = ContentType.json;
      exportRequest.write('{}');
      final exportResponse = await exportRequest.close();
      expect(exportResponse.statusCode, HttpStatus.ok);
      final exportBody =
          jsonDecode(await utf8.decodeStream(exportResponse))
              as Map<String, Object?>;
      expect(exportBody['ok'], true);
      final downloadUrl = exportBody['download_url'] as String?;
      expect(downloadUrl, isNotNull);

      final downloadRequest = await client.getUrl(Uri.parse(downloadUrl!));
      final downloadResponse = await downloadRequest.close();
      expect(downloadResponse.statusCode, HttpStatus.ok);
      final downloadBody = await utf8.decodeStream(downloadResponse);
      expect(downloadBody, contains('Audit Hub Review Export'));
    },
  );

  test('refresh hydration reconciles world rows from executable truth surfaces', () {
    final hydrated = hydrateWorldsWithTruthSurfacesForSnapshotV1(
      worlds: <Map<String, Object?>>[
        <String, Object?>{
          'world_id': 'W10',
          'visual_family_status': 'not_instrumented',
          'active_runner_families': <Object?>[],
          'visual_health': 'not_instrumented',
          'ownership_truth':
              'No explicit shared/local inventory is wired yet for this world.',
          'screenshot_evidence_count': 0,
          'screenshot_artifacts': <Object?>[],
        },
      ],
      routeInventories: <Map<String, Object?>>[
        <String, Object?>{
          'world_id': 'W10',
          'inventory_status': 'executable',
          'summary':
              'Shared/local ownership is explicit for representative World10 routes.',
          'rows': <Object?>[
            <String, Object?>{'route': 'session_drill_surface'},
          ],
        },
      ],
      visualInstrumentationSurfaces: <Map<String, Object?>>[
        <String, Object?>{
          'world_id': 'W10',
          'instrumentation_status': 'executable',
        },
      ],
      screenshotEvidenceSurfaces: <Map<String, Object?>>[
        <String, Object?>{
          'world_id': 'W10',
          'evidence_status': 'executable',
          'screenshot_evidence_count': 3,
          'entries': <Object?>[
            <String, Object?>{
              'session_id': 'cash.s01',
              'path':
                  'assets/audit_hub_v1/world_screenshot_evidence_v1/world10/cash.s01.png',
            },
          ],
        },
      ],
    );

    final world10 = hydrated.single;
    expect(
      world10['ownership_truth'],
      'Shared/local ownership is explicit for representative World10 routes.',
    );
    expect(world10['visual_health'], 'pass');
    expect(world10['visual_family_status'], 'shared');
    expect(
      world10['active_runner_families'],
      contains('session_drill_surface'),
    );
    expect(world10['screenshot_evidence_count'], 3);
    expect(world10['screenshot_artifacts'], isNotEmpty);
  });
}

void _seedAuditHubTempRepo(Directory tempDir) {
  final snapshotDir = Directory(
    '${tempDir.path}${Platform.pathSeparator}assets${Platform.pathSeparator}audit_hub_v1',
  )..createSync(recursive: true);
  final buildDir = Directory(
    '${tempDir.path}${Platform.pathSeparator}build${Platform.pathSeparator}audit_hub_web',
  )..createSync(recursive: true);
  File('${buildDir.path}${Platform.pathSeparator}index.html').writeAsStringSync(
    '<!DOCTYPE html><html><body>Audit Hub Test Bundle</body></html>',
  );
  File(
    '${buildDir.path}${Platform.pathSeparator}main.dart.js',
  ).writeAsStringSync('console.log("audit hub test bundle");');
  final snapshotFile = File(
    '${snapshotDir.path}${Platform.pathSeparator}operational_snapshot.json',
  );

  final seedRun = <String, Object?>{
    'version': 'v1',
    'run_id': 'seed_run',
    'started_at_utc': '2026-04-04T00:00:00Z',
    'completed_at_utc': '2026-04-04T00:00:00Z',
    'repo_root': tempDir.path,
    'git': <String, Object?>{
      'branch': 'main',
      'head': 'seedhead',
      'is_clean_tree': false,
      'dirty_file_count': 1,
    },
    'summary': <String, Object?>{
      'total_results': 1,
      'status_counts': <String, Object?>{'pass': 1},
      'category_counts': <String, Object?>{'surface_readiness': 1},
      'open_fail_count': 0,
      'open_warning_count': 0,
    },
    'key_blockers': <String>['seed blocker'],
    'results': <Object?>[],
  };

  final snapshotPayload = <String, Object?>{
    'version': 'v1.3',
    'generated_at_utc': '2026-04-04T00:00:00Z',
    'latest_run': seedRun,
    'recent_runs': <Object?>[seedRun],
    'trust': <String, Object?>{
      'last_full_run_at_utc': '2026-04-04T00:00:00Z',
      'snapshot_generated_at_utc': '2026-04-04T00:00:00Z',
      'branch': 'main',
      'head': 'seedhead',
      'is_clean_tree': false,
      'dirty_file_count': 1,
      'blocker_summary': 'seed blocker',
    },
    'project_health': <String, Object?>{
      'source_ssot_path': 'docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md',
      'core_readiness_percent': 65.9,
      'ship_readiness_percent': 49.7,
      'final_readiness_percent': 62.0,
      'top_bottleneck_block': 'M Production / Release Confidence',
      'top_bottleneck_epic':
          'M3 repeatable go/no-go, rollback, and release discipline',
      'confidence_note': 'seed',
      'what_blocks_hundred_now': <String>['seed blocker'],
      'hard_blockers': <String>['M3'],
      'soft_blockers': <String>[],
      'explanation': 'seed',
    },
    'readiness_recalibration_candidate': <String, Object?>{
      'canonical_readiness_source_path':
          'docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md',
      'canonical_readiness': <String, Object?>{
        'source_ssot_path': 'docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md',
        'core_readiness_percent': 65.9,
        'ship_readiness_percent': 49.7,
        'final_readiness_percent': 62.0,
        'top_bottleneck_block': 'M Production / Release Confidence',
        'top_bottleneck_epic':
            'M3 repeatable go/no-go, rollback, and release discipline',
      },
      'recalibration_candidate_status': 'no_change',
      'candidate_block_movements': <Object?>[],
      'candidate_epic_movements': <Object?>[],
      'candidate_score_deltas': <String, Object?>{
        'core_delta': 0,
        'ship_delta': 0,
        'final_delta': 0,
      },
      'raw_vs_effective_note': 'seed',
      'recalibration_justified_now': false,
      'recalibration_reason': 'seed',
      'proof_gaps_if_not_justified': <String>['seed blocker'],
    },
    'completion_gap_synthesis': <String, Object?>{
      'source_truth_owners': <String>[
        'docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md',
      ],
      'gaps': <Object?>[
        <String, Object?>{
          'gap_id': 'world_gap_w0',
          'source_truth_owner': 'snapshot',
          'title': 'W0 Foundations',
          'category': 'world',
          'world_scope': <String>['W0'],
          'surface_scope': <String>['learner copy'],
          'readiness_blocks': <String>['D'],
          'epic_mappings': <String>['D Content Trust'],
          'current_status': 'proof_pending',
          'admissibility': 'machine_reducible_now',
          'likely_seam': 'copy cleanup',
          'owner_files': <String>['content/worlds/world0/v1/'],
          'measurable_proof_path': <String>[
            'dart run tools/validate_world_content_v1.dart',
          ],
          'prerequisite_blockers': <String>[],
          'ev_priority_order': 1,
          'next_frontier_reason': 'Open machine frontier',
        },
      ],
      'top_machine_frontier': <String, Object?>{
        'gap_id': 'world_gap_w0',
        'source_truth_owner': 'snapshot',
        'title': 'W0 Foundations',
        'category': 'world',
        'world_scope': <String>['W0'],
        'surface_scope': <String>['learner copy'],
        'readiness_blocks': <String>['D'],
        'epic_mappings': <String>['D Content Trust'],
        'current_status': 'proof_pending',
        'admissibility': 'machine_reducible_now',
        'likely_seam': 'copy cleanup',
        'owner_files': <String>['content/worlds/world0/v1/'],
        'measurable_proof_path': <String>[
          'dart run tools/validate_world_content_v1.dart',
        ],
        'prerequisite_blockers': <String>[],
        'ev_priority_order': 1,
        'next_frontier_reason': 'Open machine frontier',
      },
      'recommended_next_frontier': <String, Object?>{
        'gap_id': 'world_gap_w0',
        'source_truth_owner': 'snapshot',
        'title': 'W0 Foundations',
        'category': 'world',
        'world_scope': <String>['W0'],
        'surface_scope': <String>['learner copy'],
        'readiness_blocks': <String>['D'],
        'epic_mappings': <String>['D Content Trust'],
        'current_status': 'proof_pending',
        'admissibility': 'machine_reducible_now',
        'likely_seam': 'copy cleanup',
        'owner_files': <String>['content/worlds/world0/v1/'],
        'measurable_proof_path': <String>[
          'dart run tools/validate_world_content_v1.dart',
        ],
        'prerequisite_blockers': <String>[
          'Routing truth was normalized before route acceptance.',
        ],
        'ev_priority_order': 1,
        'next_frontier_reason': 'Open machine frontier',
      },
      'paused_manual_clusters': <String>['Ops / Release Confidence'],
      'next_best_machine_frontiers': <Object?>[],
      'why_100_not_reached': <String>['Human review still pending.'],
      'all_remaining_gaps_count': 1,
      'machine_reducible_remaining_count': 1,
      'manual_bound_remaining_count': 1,
    },
    'blocker_clusters': <Object?>[],
    'alignments': <Object?>[],
    'unification_matrix': <Object?>[],
    'worlds': <Object?>[],
    'codex_work_queue': <Object?>[],
    'top_wave_packet': <String, Object?>{},
    'chatgpt_summary': 'seed summary',
    'last_export': <String, Object?>{},
  };
  snapshotFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(snapshotPayload)}\n',
  );

  for (final relativePath in <String>[
    'docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md',
    'docs/plan/WORLD_READINESS_REGISTRY_v1.md',
    'docs/plan/PRODUCT_SURFACE_READINESS_v1.md',
  ]) {
    final source = File(relativePath);
    final destination = File(
      '${tempDir.path}${Platform.pathSeparator}${relativePath.replaceAll('/', Platform.pathSeparator)}',
    );
    destination.parent.createSync(recursive: true);
    destination.writeAsStringSync(source.readAsStringSync());
  }
}
