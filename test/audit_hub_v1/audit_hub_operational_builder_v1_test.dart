import 'dart:io';

import 'package:poker_analyzer/audit_hub_v1/audit_hub_operational_builder_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/audit_hub_operational_models_v1.dart';
import 'package:test/test.dart';

void main() {
  late ProjectReadinessSsotV1 ssot;
  late CanonicalReadinessV1 canonicalReadiness;
  late ReadinessRecalibrationCandidateV1 recalibrationCandidate;
  late Map<String, Object?> operationalSnapshot;
  late Map<String, Object> releaseReadinessSnapshot;

  setUpAll(() {
    final ssotContent = File(projectReadinessSsotPathV1).readAsStringSync();
    ssot = parseProjectReadinessSsotV1(ssotContent);
  });

  setUp(() {
    operationalSnapshot = <String, Object?>{
      'project_health': <String, Object?>{
        'what_blocks_hundred_now': <String>[
          'Production / release confidence still depends on governed human review.',
        ],
      },
      'latest_run': <String, Object?>{
        'key_blockers': <String>[
          'Current queue still holds on release-owner review.',
        ],
      },
      'codex_work_queue': <Object?>[
        <String, Object?>{
          'rank': 1,
          'title': 'Ops / Release Confidence',
          'cluster_id': 'ops_release_confidence',
          'reason': 'Human review still pending.',
          'likely_seam': 'manual residue',
          'blocker_level': 'active_risk',
          'readiness_blocks': <String>['H', 'M', 'N'],
          'epic_mappings': <String>[
            'H Anti-Recurrence / Guards / Audit Truth',
            'M Production / Release Confidence',
          ],
          'affected_worlds': <String>['W1'],
          'affected_surfaces': <String>['release confidence baseline'],
          'owner_files': <String>['tools/release_readiness_snapshot_v1.dart'],
          'rerun_commands': <String>[
            'dart run tools/release_readiness_snapshot_v1.dart',
          ],
          'proof_requirements': <String>['human_review_required'],
          'why_now': 'Still open and still active.',
        },
        <String, Object?>{
          'rank': 2,
          'title': 'Visual Proof Truth',
          'cluster_id': 'visual_proof_truth',
          'reason': 'Only when visual drift is red or yellow.',
          'likely_seam': 'visual drift',
          'blocker_level': 'bounded_residue',
          'readiness_blocks': <String>['A', 'B'],
          'epic_mappings': <String>['A Structural / Canonical Ownership'],
          'affected_worlds': <String>['W1'],
          'affected_surfaces': <String>['modern_table_default'],
          'owner_files': <String>[
            'tools/table_projection_acceptance_audit_v1.dart',
          ],
          'rerun_commands': <String>[
            'dart run tools/table_projection_acceptance_audit_v1.dart',
          ],
          'why_now': 'Only active when screenshot truth reopens.',
        },
      ],
      'top_wave_packet': <String, Object?>{
        'summary': 'Take one bounded ops/release confidence wave.',
      },
      'worlds': <Object?>[
        <String, Object?>{
          'world_id': 'W1',
          'title': 'Foundations',
          'readiness_status': 'human_proof_pending',
          'primary_readiness_links': <String>['D', 'E', 'F', 'J'],
          'top_open_gaps': <String>[
            'learner-language cleanup; release-grade human review',
          ],
          'release_grade_blocker_note':
              'Strongest live world, but still needs human proof.',
          'ownership_truth':
              'Shared/local ownership is explicit for representative World1 families.',
          'visual_health': 'pass',
          'screenshot_evidence_count': 2,
        },
        <String, Object?>{
          'world_id': 'W3',
          'title': 'Pot Odds Intro',
          'readiness_status': 'proof_pending',
          'primary_readiness_links': <String>['D', 'E', 'F', 'G'],
          'top_open_gaps': <String>['world-shape proof; pedagogy density'],
          'release_grade_blocker_note':
              'World exists, but proof surface is still coarse.',
          'ownership_truth':
              'No explicit shared/local inventory is wired yet for this world.',
          'visual_health': 'not_instrumented',
          'screenshot_evidence_count': 0,
        },
      ],
      'unification_matrix': <Object?>[
        <String, Object?>{
          'world_id': 'W3',
          'owner_seam_blocking_unification':
              'world/node family remains mixed or not instrumented for unification',
        },
      ],
      'world_truth_surfaces': <Object?>[
        <String, Object?>{
          'world_id': 'W3',
          'proof_surface_status': 'executable',
          'proof_surface_truth':
              'Executable session-world proof surface is wired for W3.',
          'owner_files': <String>[
            'content/worlds/world3/v1/world.md',
            'content/worlds/world3/v1/sessions/index.md',
            'content/_meta/world_sessions_manifest_v1.json',
            'content/_meta/world_drills_manifest_v1.json',
          ],
          'measurable_proof_path': <String>[
            'dart run tools/session_world_truth_surface_audit_v1.dart --world=3 --json',
          ],
          'blocking_gaps': <String>[],
        },
      ],
      'world_route_ownership_inventories': <Object?>[
        <String, Object?>{
          'world_id': 'W3',
          'inventory_status': 'missing',
          'summary':
              'No explicit repo-owned world route ownership inventory is wired yet for W3.',
          'owner_files': <String>[],
          'measurable_proof_path': <String>[
            'dart run tools/world_route_ownership_inventory_v1.dart --world=3 --json',
          ],
          'blocking_gaps': <String>[
            'W3 does not yet have a repo-owned representative route ownership inventory.',
          ],
        },
      ],
      'world_visual_instrumentation_surfaces': <Object?>[
        <String, Object?>{
          'world_id': 'W3',
          'instrumentation_status': 'missing',
          'proof_surface_truth':
              'No repo-owned representative visual instrumentation audit is wired yet for W3.',
          'owner_files': <String>[],
          'measurable_proof_path': <String>[
            'dart run tools/world_visual_instrumentation_audit_v1.dart --world=3 --json',
          ],
          'blocking_gaps': <String>[
            'W3 does not yet have a repo-owned representative visual instrumentation surface.',
          ],
        },
      ],
      'world_screenshot_evidence_surfaces': <Object?>[
        <String, Object?>{
          'world_id': 'W3',
          'evidence_status': 'missing',
          'screenshot_evidence_count': 0,
          'proof_surface_truth':
              'No repo-owned representative screenshot evidence is wired yet for W3.',
          'owner_files': <String>[],
          'measurable_proof_path': <String>[
            'dart run tools/world_screenshot_evidence_capture_v1.dart --world=3',
            'dart run tools/world_screenshot_evidence_audit_v1.dart --world=3 --json',
          ],
          'blocking_gaps': <String>[
            'W3 does not yet have repo-owned screenshot-backed evidence.',
          ],
        },
      ],
    };
    canonicalReadiness = buildCanonicalReadinessV1(
      ssot,
      operationalSnapshot: operationalSnapshot,
    );
    releaseReadinessSnapshot = <String, Object>{
      'baselineDocPresent': true,
      'releaseDryRunGateScriptPresent': true,
      'world1ReleaseGateScriptPresent': true,
      'goNoGoStateIsHold': true,
      'humanReviewStatePending': true,
      'rollbackTruthSaysUnresolved': true,
      'operationalDashboardTruthSaysNoCanonicalDashboard': true,
    };
    recalibrationCandidate = buildReadinessRecalibrationCandidateV1(
      ssot: ssot,
      canonicalReadiness: canonicalReadiness,
      operationalSnapshot: operationalSnapshot,
      releaseReadinessSnapshot: releaseReadinessSnapshot,
    );
  });

  test(
    'dashboard pretty json keeps canonical readiness and recalibration candidate side by side',
    () {
      final dashboard = buildAuditHubOperationalDashboardV1(
        operationalSnapshot: operationalSnapshot,
        releaseReadinessSnapshot: releaseReadinessSnapshot,
        projectReadinessSsotContent: File(
          projectReadinessSsotPathV1,
        ).readAsStringSync(),
      );

      final rendered = dashboard.toPrettyJson();
      expect(rendered, contains('"project_health"'));
      expect(rendered, contains('"readiness_recalibration_candidate"'));
      expect(rendered, contains('"completion_gap_synthesis"'));
      expect(rendered, contains('"source_ssot_path"'));
      expect(rendered, contains('"recalibration_candidate_status"'));
    },
  );

  test('completion gap synthesis classifies manual and truth-layer gaps', () {
    final synthesis = buildCompletionGapSynthesisV1(
      ssot: ssot,
      operationalSnapshot: operationalSnapshot,
      releaseReadinessSnapshot: releaseReadinessSnapshot,
      canonicalReadiness: canonicalReadiness,
      recalibrationCandidate: recalibrationCandidate,
      worldReadinessRegistryContent: File(
        worldReadinessRegistryPathV1,
      ).readAsStringSync(),
      productSurfaceReadinessContent: File(
        productSurfaceReadinessPathV1,
      ).readAsStringSync(),
      worldRegistrySourcePath: worldReadinessRegistryPathV1,
      productSurfaceSourcePath: productSurfaceReadinessPathV1,
      currentReviewPath: 'out/audit_hub_v1/reviews/test_review.md',
      currentTopWavePacketPath:
          'out/audit_hub_v1/top_wave_packets/test_packet.md',
    );

    expect(synthesis.gaps, isNotEmpty);
    expect(
      synthesis.gaps
          .firstWhere((gap) => gap.gapId == 'cluster_ops_release_confidence')
          .admissibility,
      CompletionGapAdmissibilityV1.proofManualOnly,
    );
    expect(
      synthesis.gaps
          .firstWhere((gap) => gap.gapId == 'world_gap_w3')
          .admissibility,
      CompletionGapAdmissibilityV1.truthLayerFirst,
    );
    expect(
      synthesis.gaps
          .firstWhere((gap) => gap.gapId == 'world_gap_w3')
          .measurableProofPath,
      contains(
        'dart run tools/session_world_truth_surface_audit_v1.dart --world=3 --json',
      ),
    );
    expect(
      synthesis.gaps
          .firstWhere((gap) => gap.gapId == 'world_gap_w3')
          .prerequisiteBlockers
          .join(' | '),
      contains('repo-owned representative route ownership inventory'),
    );
    expect(synthesis.topMachineFrontier, isNull);
    expect(
      synthesis.pausedManualClusters,
      contains('Ops / Release Confidence'),
    );
    expect(synthesis.allRemainingGapsCount, greaterThanOrEqualTo(3));
  });

  test(
    'later-world machine frontier is downgraded until earlier-world truth work is ruled out',
    () {
      final synthesis = buildCompletionGapSynthesisV1(
        ssot: ssot,
        operationalSnapshot: <String, Object?>{
          ...operationalSnapshot,
          'worlds': <Object?>[
            ...(operationalSnapshot['worlds'] as List<Object?>),
            <String, Object?>{
              'world_id': 'W10',
              'title': 'Mastery Integration',
              'readiness_status': 'proof_pending',
              'primary_readiness_links': <String>['D', 'F', 'G'],
              'top_open_gaps': <String>['mastery finish'],
              'release_grade_blocker_note':
                  'World exists, but it is a late-lane mastery surface.',
              'ownership_truth':
                  'Shared/local ownership is explicit for representative World10 routes.',
              'visual_health': 'pass',
              'screenshot_evidence_count': 3,
            },
          ],
          'world_truth_surfaces': <Object?>[
            ...(operationalSnapshot['world_truth_surfaces'] as List<Object?>),
            <String, Object?>{
              'world_id': 'W10',
              'proof_surface_status': 'executable',
              'proof_surface_truth':
                  'Executable session-world proof surface is wired for W10.',
              'owner_files': <String>['content/worlds/world10/v1/world.md'],
              'measurable_proof_path': <String>[
                'dart run tools/session_world_truth_surface_audit_v1.dart --world=10 --json',
              ],
              'blocking_gaps': <String>[],
            },
          ],
          'world_route_ownership_inventories': <Object?>[
            ...(operationalSnapshot['world_route_ownership_inventories']
                as List<Object?>),
            <String, Object?>{
              'world_id': 'W10',
              'inventory_status': 'executable',
              'summary':
                  'Shared/local ownership is explicit for representative World10 routes.',
              'owner_files': <String>[
                'test/tools/world10_registry_closure_truth_test.dart',
              ],
              'measurable_proof_path': <String>[
                'dart run tools/world_route_ownership_inventory_v1.dart --world=10 --json',
              ],
              'blocking_gaps': <String>[],
            },
          ],
          'world_visual_instrumentation_surfaces': <Object?>[
            ...(operationalSnapshot['world_visual_instrumentation_surfaces']
                as List<Object?>),
            <String, Object?>{
              'world_id': 'W10',
              'instrumentation_status': 'executable',
              'proof_surface_truth':
                  'Visual instrumentation is wired for representative World10 session-drill surfaces.',
              'owner_files': <String>[
                'content/worlds/world10/v1/sessions/w10.s04/session.md',
              ],
              'measurable_proof_path': <String>[
                'dart run tools/world_visual_instrumentation_audit_v1.dart --world=10 --json',
              ],
              'blocking_gaps': <String>[],
            },
          ],
          'world_screenshot_evidence_surfaces': <Object?>[
            ...(operationalSnapshot['world_screenshot_evidence_surfaces']
                as List<Object?>),
            <String, Object?>{
              'world_id': 'W10',
              'evidence_status': 'executable',
              'screenshot_evidence_count': 3,
              'proof_surface_truth':
                  'Screenshot-backed evidence is wired for representative World10 surfaces.',
              'owner_files': <String>[
                'assets/audit_hub_v1/world_screenshot_evidence_v1/world10',
              ],
              'measurable_proof_path': <String>[
                'dart run tools/world_screenshot_evidence_audit_v1.dart --world=10 --json',
              ],
              'blocking_gaps': <String>[],
            },
          ],
        },
        releaseReadinessSnapshot: releaseReadinessSnapshot,
        canonicalReadiness: canonicalReadiness,
        recalibrationCandidate: recalibrationCandidate,
        worldReadinessRegistryContent: File(
          worldReadinessRegistryPathV1,
        ).readAsStringSync(),
        productSurfaceReadinessContent: File(
          productSurfaceReadinessPathV1,
        ).readAsStringSync(),
        worldRegistrySourcePath: worldReadinessRegistryPathV1,
        productSurfaceSourcePath: productSurfaceReadinessPathV1,
        currentReviewPath: 'out/audit_hub_v1/reviews/test_review.md',
        currentTopWavePacketPath:
            'out/audit_hub_v1/top_wave_packets/test_packet.md',
      );

      final w10Gap = synthesis.gaps.firstWhere(
        (gap) => gap.gapId == 'world_gap_w10',
      );
      expect(w10Gap.admissibility, CompletionGapAdmissibilityV1.external);
      expect(
        w10Gap.prerequisiteBlockers.join(' | '),
        contains(
          'Routing normalization blockers: W3 Pot Odds Intro [truth_layer_first]',
        ),
      );
      expect(synthesis.topMachineFrontier, isNull);
      expect(synthesis.recommendedNextFrontier?.gapId, 'world_gap_w3');
    },
  );

  test(
    'later-world truth frontier is downgraded until earlier-world admissible truth is ruled out',
    () {
      final synthesis = buildCompletionGapSynthesisV1(
        ssot: ssot,
        operationalSnapshot: <String, Object?>{
          ...operationalSnapshot,
          'worlds': <Object?>[
            ...(operationalSnapshot['worlds'] as List<Object?>),
            <String, Object?>{
              'world_id': 'W10',
              'title': 'Mastery Integration',
              'readiness_status': 'proof_pending',
              'primary_readiness_links': <String>['D', 'F', 'G'],
              'top_open_gaps': <String>['mastery proof polish'],
              'release_grade_blocker_note':
                  'World exists, but its late-lane proof is still incomplete.',
              'ownership_truth':
                  'Shared/local ownership is explicit for representative World10 routes.',
              'visual_health': 'pass',
              'screenshot_evidence_count': 0,
            },
          ],
          'world_truth_surfaces': <Object?>[
            ...(operationalSnapshot['world_truth_surfaces'] as List<Object?>),
            <String, Object?>{
              'world_id': 'W10',
              'proof_surface_status': 'executable',
              'proof_surface_truth':
                  'Executable session-world proof surface is wired for W10.',
              'owner_files': <String>['content/worlds/world10/v1/world.md'],
              'measurable_proof_path': <String>[
                'dart run tools/session_world_truth_surface_audit_v1.dart --world=10 --json',
              ],
              'blocking_gaps': <String>[],
            },
          ],
          'world_route_ownership_inventories': <Object?>[
            ...(operationalSnapshot['world_route_ownership_inventories']
                as List<Object?>),
            <String, Object?>{
              'world_id': 'W10',
              'inventory_status': 'executable',
              'summary':
                  'Shared/local ownership is explicit for representative World10 routes.',
              'owner_files': <String>[
                'test/tools/world10_registry_closure_truth_test.dart',
              ],
              'measurable_proof_path': <String>[
                'dart run tools/world_route_ownership_inventory_v1.dart --world=10 --json',
              ],
              'blocking_gaps': <String>[],
            },
          ],
          'world_visual_instrumentation_surfaces': <Object?>[
            ...(operationalSnapshot['world_visual_instrumentation_surfaces']
                as List<Object?>),
            <String, Object?>{
              'world_id': 'W10',
              'instrumentation_status': 'executable',
              'proof_surface_truth':
                  'Visual instrumentation is wired for representative World10 session-drill surfaces.',
              'owner_files': <String>[
                'content/worlds/world10/v1/sessions/w10.s04/session.md',
              ],
              'measurable_proof_path': <String>[
                'dart run tools/world_visual_instrumentation_audit_v1.dart --world=10 --json',
              ],
              'blocking_gaps': <String>[],
            },
          ],
          'world_screenshot_evidence_surfaces': <Object?>[
            ...(operationalSnapshot['world_screenshot_evidence_surfaces']
                as List<Object?>),
            <String, Object?>{
              'world_id': 'W10',
              'evidence_status': 'missing',
              'screenshot_evidence_count': 0,
              'proof_surface_truth':
                  'No repo-owned representative screenshot evidence is wired yet for W10.',
              'owner_files': <String>[],
              'measurable_proof_path': <String>[
                'dart run tools/world_screenshot_evidence_audit_v1.dart --world=10 --json',
              ],
              'blocking_gaps': <String>[
                'W10 does not yet have repo-owned screenshot-backed evidence.',
              ],
            },
          ],
        },
        releaseReadinessSnapshot: releaseReadinessSnapshot,
        canonicalReadiness: canonicalReadiness,
        recalibrationCandidate: recalibrationCandidate,
        worldReadinessRegistryContent: File(
          worldReadinessRegistryPathV1,
        ).readAsStringSync(),
        productSurfaceReadinessContent: File(
          productSurfaceReadinessPathV1,
        ).readAsStringSync(),
        worldRegistrySourcePath: worldReadinessRegistryPathV1,
        productSurfaceSourcePath: productSurfaceReadinessPathV1,
        currentReviewPath: 'out/audit_hub_v1/reviews/test_review.md',
        currentTopWavePacketPath:
            'out/audit_hub_v1/top_wave_packets/test_packet.md',
      );

      final w10Gap = synthesis.gaps.firstWhere(
        (gap) => gap.gapId == 'world_gap_w10',
      );
      expect(w10Gap.admissibility, CompletionGapAdmissibilityV1.external);
      expect(
        w10Gap.prerequisiteBlockers.join(' | '),
        contains(
          'Routing normalization blockers: W3 Pot Odds Intro [truth_layer_first]',
        ),
      );
      expect(synthesis.recommendedNextFrontier?.gapId, 'world_gap_w3');
    },
  );

  test(
    'earlier-world machine frontier remains active over later-world machine frontier after normalization',
    () {
      final synthesis = buildCompletionGapSynthesisV1(
        ssot: ssot,
        operationalSnapshot: <String, Object?>{
          ...operationalSnapshot,
          'worlds': <Object?>[
            <String, Object?>{
              'world_id': 'W4',
              'title': 'Range Growth',
              'readiness_status': 'proof_pending',
              'primary_readiness_links': <String>['D', 'F', 'G'],
              'top_open_gaps': <String>['shared surface finish'],
              'release_grade_blocker_note':
                  'World exists and is ready for a bounded reduction wave.',
              'ownership_truth':
                  'Shared/local ownership is explicit for representative World4 routes.',
              'visual_health': 'pass',
              'screenshot_evidence_count': 2,
            },
            <String, Object?>{
              'world_id': 'W10',
              'title': 'Mastery Integration',
              'readiness_status': 'proof_pending',
              'primary_readiness_links': <String>['D', 'F', 'G'],
              'top_open_gaps': <String>['mastery finish'],
              'release_grade_blocker_note':
                  'Late-lane mastery world should not outrank an earlier live world.',
              'ownership_truth':
                  'Shared/local ownership is explicit for representative World10 routes.',
              'visual_health': 'pass',
              'screenshot_evidence_count': 3,
            },
          ],
          'world_truth_surfaces': <Object?>[
            for (final world in <int>[4, 10])
              <String, Object?>{
                'world_id': 'W$world',
                'proof_surface_status': 'executable',
                'proof_surface_truth':
                    'Executable session-world proof surface is wired for W$world.',
                'owner_files': <String>[
                  'content/worlds/world$world/v1/world.md',
                ],
                'measurable_proof_path': <String>[
                  'dart run tools/session_world_truth_surface_audit_v1.dart --world=$world --json',
                ],
                'blocking_gaps': <String>[],
              },
          ],
          'world_route_ownership_inventories': <Object?>[
            for (final world in <int>[4, 10])
              <String, Object?>{
                'world_id': 'W$world',
                'inventory_status': 'executable',
                'summary':
                    'Shared/local ownership is explicit for representative World$world routes.',
                'owner_files': <String>[
                  'test/tools/world${world}_session_explanation_quality_contract_test.dart',
                ],
                'measurable_proof_path': <String>[
                  'dart run tools/world_route_ownership_inventory_v1.dart --world=$world --json',
                ],
                'blocking_gaps': <String>[],
              },
          ],
          'world_visual_instrumentation_surfaces': <Object?>[
            for (final world in <int>[4, 10])
              <String, Object?>{
                'world_id': 'W$world',
                'instrumentation_status': 'executable',
                'proof_surface_truth':
                    'Visual instrumentation is wired for representative World$world session-drill surfaces.',
                'owner_files': <String>[
                  'content/worlds/world$world/v1/sessions/index.md',
                ],
                'measurable_proof_path': <String>[
                  'dart run tools/world_visual_instrumentation_audit_v1.dart --world=$world --json',
                ],
                'blocking_gaps': <String>[],
              },
          ],
          'world_screenshot_evidence_surfaces': <Object?>[
            for (final world in <int>[4, 10])
              <String, Object?>{
                'world_id': 'W$world',
                'evidence_status': 'executable',
                'screenshot_evidence_count': world == 4 ? 2 : 3,
                'proof_surface_truth':
                    'Screenshot-backed evidence is wired for representative World$world surfaces.',
                'owner_files': <String>[
                  'assets/audit_hub_v1/world_screenshot_evidence_v1/world$world',
                ],
                'measurable_proof_path': <String>[
                  'dart run tools/world_screenshot_evidence_audit_v1.dart --world=$world --json',
                ],
                'blocking_gaps': <String>[],
              },
          ],
          'unification_matrix': <Object?>[],
        },
        releaseReadinessSnapshot: releaseReadinessSnapshot,
        canonicalReadiness: canonicalReadiness,
        recalibrationCandidate: recalibrationCandidate,
        worldReadinessRegistryContent: File(
          worldReadinessRegistryPathV1,
        ).readAsStringSync(),
        productSurfaceReadinessContent: File(
          productSurfaceReadinessPathV1,
        ).readAsStringSync(),
        worldRegistrySourcePath: worldReadinessRegistryPathV1,
        productSurfaceSourcePath: productSurfaceReadinessPathV1,
        currentReviewPath: 'out/audit_hub_v1/reviews/test_review.md',
        currentTopWavePacketPath:
            'out/audit_hub_v1/top_wave_packets/test_packet.md',
      );

      expect(synthesis.topMachineFrontier?.gapId, 'world_gap_w4');
      expect(synthesis.recommendedNextFrontier?.gapId, 'world_gap_w4');
      expect(
        synthesis.gaps
            .firstWhere((gap) => gap.gapId == 'world_gap_w10')
            .admissibility,
        CompletionGapAdmissibilityV1.external,
      );
    },
  );

  test('world ownership inventory removes explicit ownership blocker once wired', () {
    final synthesis = buildCompletionGapSynthesisV1(
      ssot: ssot,
      operationalSnapshot: <String, Object?>{
        ...operationalSnapshot,
        'worlds': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'title': 'Foundations',
            'readiness_status': 'proof_pending',
            'primary_readiness_links': <String>['D', 'E', 'F', 'J'],
            'top_open_gaps': <String>[
              'visible world identity; learner-copy cleanup; first-world polish',
            ],
            'release_grade_blocker_note':
                'Present, but not yet polished or coherent enough to stand as a release-grade opener on its own.',
            'ownership_truth':
                'No explicit shared/local inventory is wired yet for this world.',
            'visual_health': 'not_instrumented',
            'screenshot_evidence_count': 0,
          },
        ],
        'unification_matrix': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'owner_seam_blocking_unification':
                'world/node family remains mixed or not instrumented for unification',
          },
        ],
        'world_truth_surfaces': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'proof_surface_status': 'executable',
            'proof_surface_truth':
                'Executable session-world proof surface is wired for W0.',
            'owner_files': <String>['content/worlds/world0/v1/world.md'],
            'measurable_proof_path': <String>[
              'dart run tools/session_world_truth_surface_audit_v1.dart --world=0 --json',
            ],
            'blocking_gaps': <String>[],
          },
        ],
        'world_route_ownership_inventories': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'inventory_status': 'executable',
            'summary':
                'Shared/local ownership is explicit for representative World0 routes.',
            'owner_files': <String>[
              'test/ui_v2/session_drill_player_world0_surface_contract_test.dart',
            ],
            'measurable_proof_path': <String>[
              'dart run tools/world_route_ownership_inventory_v1.dart --world=0 --json',
            ],
            'blocking_gaps': <String>[],
          },
        ],
        'world_visual_instrumentation_surfaces': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'instrumentation_status': 'missing',
            'proof_surface_truth':
                'No repo-owned representative visual instrumentation audit is wired yet for W0.',
            'owner_files': <String>[],
            'measurable_proof_path': <String>[
              'dart run tools/world_visual_instrumentation_audit_v1.dart --world=0 --json',
            ],
            'blocking_gaps': <String>[
              'W0 does not yet have a repo-owned representative visual instrumentation surface.',
            ],
          },
        ],
        'world_screenshot_evidence_surfaces': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'evidence_status': 'missing',
            'screenshot_evidence_count': 0,
            'proof_surface_truth':
                'No repo-owned representative screenshot evidence is wired yet for W0.',
            'owner_files': <String>[],
            'measurable_proof_path': <String>[
              'dart run tools/world_screenshot_evidence_capture_v1.dart --world=0',
              'dart run tools/world_screenshot_evidence_audit_v1.dart --world=0 --json',
            ],
            'blocking_gaps': <String>[
              'W0 does not yet have repo-owned screenshot-backed evidence.',
            ],
          },
        ],
      },
      releaseReadinessSnapshot: releaseReadinessSnapshot,
      canonicalReadiness: canonicalReadiness,
      recalibrationCandidate: recalibrationCandidate,
      worldReadinessRegistryContent: File(
        worldReadinessRegistryPathV1,
      ).readAsStringSync(),
      productSurfaceReadinessContent: File(
        productSurfaceReadinessPathV1,
      ).readAsStringSync(),
      worldRegistrySourcePath: worldReadinessRegistryPathV1,
      productSurfaceSourcePath: productSurfaceReadinessPathV1,
      currentReviewPath: 'out/audit_hub_v1/reviews/test_review.md',
      currentTopWavePacketPath:
          'out/audit_hub_v1/top_wave_packets/test_packet.md',
    );

    final gap = synthesis.gaps.firstWhere((gap) => gap.gapId == 'world_gap_w0');
    expect(
      gap.measurableProofPath,
      contains(
        'dart run tools/world_route_ownership_inventory_v1.dart --world=0 --json',
      ),
    );
    expect(
      gap.prerequisiteBlockers.join(' | '),
      isNot(contains('explicit shared/local ownership inventory')),
    );
    expect(
      gap.prerequisiteBlockers.join(' | '),
      contains('visual instrumentation'),
    );
  });

  test('world visual instrumentation removes instrumentation blocker once wired', () {
    final synthesis = buildCompletionGapSynthesisV1(
      ssot: ssot,
      operationalSnapshot: <String, Object?>{
        ...operationalSnapshot,
        'worlds': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'title': 'Foundations',
            'readiness_status': 'proof_pending',
            'primary_readiness_links': <String>['D', 'E', 'F', 'J'],
            'top_open_gaps': <String>[
              'visible world identity; learner-copy cleanup; first-world polish',
            ],
            'release_grade_blocker_note':
                'Present, but not yet polished or coherent enough to stand as a release-grade opener on its own.',
            'ownership_truth':
                'No explicit shared/local inventory is wired yet for this world.',
            'visual_health': 'not_instrumented',
            'screenshot_evidence_count': 0,
          },
        ],
        'unification_matrix': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'owner_seam_blocking_unification':
                'world/node family remains mixed or not instrumented for unification',
          },
        ],
        'world_truth_surfaces': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'proof_surface_status': 'executable',
            'proof_surface_truth':
                'Executable session-world proof surface is wired for W0.',
            'owner_files': <String>['content/worlds/world0/v1/world.md'],
            'measurable_proof_path': <String>[
              'dart run tools/session_world_truth_surface_audit_v1.dart --world=0 --json',
            ],
            'blocking_gaps': <String>[],
          },
        ],
        'world_route_ownership_inventories': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'inventory_status': 'executable',
            'summary':
                'Shared/local ownership is explicit for representative World0 routes.',
            'owner_files': <String>[
              'test/ui_v2/session_drill_player_world0_surface_contract_test.dart',
            ],
            'measurable_proof_path': <String>[
              'dart run tools/world_route_ownership_inventory_v1.dart --world=0 --json',
            ],
            'blocking_gaps': <String>[],
          },
        ],
        'world_visual_instrumentation_surfaces': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'instrumentation_status': 'executable',
            'proof_surface_truth':
                'Visual instrumentation is wired for representative World0 session-drill surfaces.',
            'owner_files': <String>[
              'content/worlds/world0/v1/sessions/spatial_projection_defaults_v1.json',
            ],
            'measurable_proof_path': <String>[
              'dart run tools/world_visual_instrumentation_audit_v1.dart --world=0 --json',
            ],
            'blocking_gaps': <String>[],
          },
        ],
        'world_screenshot_evidence_surfaces': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'evidence_status': 'missing',
            'screenshot_evidence_count': 0,
            'proof_surface_truth':
                'No repo-owned representative screenshot evidence is wired yet for W0.',
            'owner_files': <String>[],
            'measurable_proof_path': <String>[
              'dart run tools/world_screenshot_evidence_capture_v1.dart --world=0',
              'dart run tools/world_screenshot_evidence_audit_v1.dart --world=0 --json',
            ],
            'blocking_gaps': <String>[
              'W0 does not yet have repo-owned screenshot-backed evidence.',
            ],
          },
        ],
      },
      releaseReadinessSnapshot: releaseReadinessSnapshot,
      canonicalReadiness: canonicalReadiness,
      recalibrationCandidate: recalibrationCandidate,
      worldReadinessRegistryContent: File(
        worldReadinessRegistryPathV1,
      ).readAsStringSync(),
      productSurfaceReadinessContent: File(
        productSurfaceReadinessPathV1,
      ).readAsStringSync(),
      worldRegistrySourcePath: worldReadinessRegistryPathV1,
      productSurfaceSourcePath: productSurfaceReadinessPathV1,
      currentReviewPath: 'out/audit_hub_v1/reviews/test_review.md',
      currentTopWavePacketPath:
          'out/audit_hub_v1/top_wave_packets/test_packet.md',
    );

    final gap = synthesis.gaps.firstWhere((gap) => gap.gapId == 'world_gap_w0');
    expect(
      gap.measurableProofPath,
      contains(
        'dart run tools/world_visual_instrumentation_audit_v1.dart --world=0 --json',
      ),
    );
    expect(
      gap.prerequisiteBlockers.join(' | '),
      isNot(contains('visual instrumentation')),
    );
    expect(
      gap.prerequisiteBlockers.join(' | '),
      contains('screenshot-backed evidence'),
    );
  });

  test('world screenshot evidence unlocks machine-reducible W0 frontier', () {
    final synthesis = buildCompletionGapSynthesisV1(
      ssot: ssot,
      operationalSnapshot: <String, Object?>{
        ...operationalSnapshot,
        'worlds': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'title': 'Foundations',
            'readiness_status': 'proof_pending',
            'primary_readiness_links': <String>['D', 'E', 'F', 'J'],
            'top_open_gaps': <String>[
              'visible world identity; learner-copy cleanup; first-world polish',
            ],
            'release_grade_blocker_note':
                'Present, but not yet polished or coherent enough to stand as a release-grade opener on its own.',
            'ownership_truth':
                'No explicit shared/local inventory is wired yet for this world.',
            'visual_health': 'not_instrumented',
            'screenshot_evidence_count': 0,
          },
        ],
        'unification_matrix': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'owner_seam_blocking_unification':
                'world/node family remains mixed or not instrumented for unification',
          },
        ],
        'world_truth_surfaces': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'proof_surface_status': 'executable',
            'proof_surface_truth':
                'Executable session-world proof surface is wired for W0.',
            'owner_files': <String>['content/worlds/world0/v1/world.md'],
            'measurable_proof_path': <String>[
              'dart run tools/session_world_truth_surface_audit_v1.dart --world=0 --json',
            ],
            'blocking_gaps': <String>[],
          },
        ],
        'world_route_ownership_inventories': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'inventory_status': 'executable',
            'summary':
                'Shared/local ownership is explicit for representative World0 routes.',
            'owner_files': <String>[
              'test/ui_v2/session_drill_player_world0_surface_contract_test.dart',
            ],
            'measurable_proof_path': <String>[
              'dart run tools/world_route_ownership_inventory_v1.dart --world=0 --json',
            ],
            'blocking_gaps': <String>[],
          },
        ],
        'world_visual_instrumentation_surfaces': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'instrumentation_status': 'executable',
            'proof_surface_truth':
                'Visual instrumentation is wired for representative World0 session-drill surfaces.',
            'owner_files': <String>[
              'content/worlds/world0/v1/sessions/spatial_projection_defaults_v1.json',
            ],
            'measurable_proof_path': <String>[
              'dart run tools/world_visual_instrumentation_audit_v1.dart --world=0 --json',
            ],
            'blocking_gaps': <String>[],
          },
        ],
        'world_screenshot_evidence_surfaces': <Object?>[
          <String, Object?>{
            'world_id': 'W0',
            'evidence_status': 'executable',
            'screenshot_evidence_count': 3,
            'proof_surface_truth':
                'Screenshot-backed evidence is wired for representative World0 session-drill surfaces.',
            'owner_files': <String>[
              'assets/audit_hub_v1/world_screenshot_evidence_v1/world0/manifest.json',
            ],
            'measurable_proof_path': <String>[
              'dart run tools/world_screenshot_evidence_capture_v1.dart --world=0',
              'dart run tools/world_screenshot_evidence_audit_v1.dart --world=0 --json',
            ],
            'blocking_gaps': <String>[],
          },
        ],
      },
      releaseReadinessSnapshot: releaseReadinessSnapshot,
      canonicalReadiness: canonicalReadiness,
      recalibrationCandidate: recalibrationCandidate,
      worldReadinessRegistryContent: File(
        worldReadinessRegistryPathV1,
      ).readAsStringSync(),
      productSurfaceReadinessContent: File(
        productSurfaceReadinessPathV1,
      ).readAsStringSync(),
      worldRegistrySourcePath: worldReadinessRegistryPathV1,
      productSurfaceSourcePath: productSurfaceReadinessPathV1,
      currentReviewPath: 'out/audit_hub_v1/reviews/test_review.md',
      currentTopWavePacketPath:
          'out/audit_hub_v1/top_wave_packets/test_packet.md',
    );

    final gap = synthesis.gaps.firstWhere((gap) => gap.gapId == 'world_gap_w0');
    expect(gap.admissibility, CompletionGapAdmissibilityV1.machineReducibleNow);
    expect(
      gap.measurableProofPath,
      contains(
        'dart run tools/world_screenshot_evidence_audit_v1.dart --world=0 --json',
      ),
    );
    expect(
      gap.prerequisiteBlockers.join(' | '),
      isNot(contains('screenshot-backed evidence')),
    );
  });

  test('unchanged live truth yields no_change with zero deltas', () {
    final candidate = buildReadinessRecalibrationCandidateV1(
      ssot: ssot,
      canonicalReadiness: canonicalReadiness,
      operationalSnapshot: operationalSnapshot,
      releaseReadinessSnapshot: releaseReadinessSnapshot,
    );

    expect(candidate.status, ReadinessRecalibrationCandidateStatusV1.noChange);
    expect(candidate.candidateEpicMovements, isEmpty);
    expect(candidate.candidateBlockMovements, isEmpty);
    expect(candidate.candidateScoreDeltas.coreDelta, 0);
    expect(candidate.candidateScoreDeltas.shipDelta, 0);
    expect(candidate.candidateScoreDeltas.finalDelta, 0);
    expect(candidate.recalibrationJustifiedNow, isFalse);
  });

  test('explicit upward epic movement yields candidate increase', () {
    final candidate = buildReadinessRecalibrationCandidateV1(
      ssot: ssot,
      canonicalReadiness: canonicalReadiness,
      operationalSnapshot: operationalSnapshot,
      releaseReadinessSnapshot: releaseReadinessSnapshot,
      explicitEvidence: const <ReadinessEpicEvidenceV1>[
        ReadinessEpicEvidenceV1(
          epicId: 'M3',
          candidateStatus: ReadinessEpicStatusV1.proofPending,
          evidenceRefs: <String>[
            'tools/release_readiness_snapshot_v1.dart',
            'docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md',
          ],
          reason:
              'Synthetic test evidence proves M3 advanced from in_progress to proof_pending.',
        ),
      ],
    );

    expect(
      candidate.status,
      ReadinessRecalibrationCandidateStatusV1.candidateIncrease,
    );
    expect(candidate.recalibrationJustifiedNow, isTrue);
    expect(candidate.candidateEpicMovements, hasLength(1));
    expect(candidate.candidateEpicMovements.single.epicId, 'M3');
    expect(
      candidate.candidateEpicMovements.single.direction,
      ReadinessCandidateMovementDirectionV1.increase,
    );
    expect(candidate.candidateBlockMovements, isNotEmpty);
    expect(candidate.candidateScoreDeltas.finalDelta, greaterThan(0));
  });

  test('explicit contradictory evidence yields candidate decrease', () {
    final candidate = buildReadinessRecalibrationCandidateV1(
      ssot: ssot,
      canonicalReadiness: canonicalReadiness,
      operationalSnapshot: operationalSnapshot,
      releaseReadinessSnapshot: releaseReadinessSnapshot,
      explicitEvidence: const <ReadinessEpicEvidenceV1>[
        ReadinessEpicEvidenceV1(
          epicId: 'A1',
          candidateStatus: ReadinessEpicStatusV1.blocked,
          evidenceRefs: <String>['synthetic://contradiction'],
          reason: 'Synthetic contradiction shows A1 is no longer done.',
        ),
      ],
    );

    expect(
      candidate.status,
      ReadinessRecalibrationCandidateStatusV1.candidateDecrease,
    );
    expect(candidate.recalibrationJustifiedNow, isTrue);
    expect(candidate.candidateEpicMovements.single.epicId, 'A1');
    expect(
      candidate.candidateEpicMovements.single.direction,
      ReadinessCandidateMovementDirectionV1.decrease,
    );
    expect(candidate.candidateScoreDeltas.coreDelta, lessThan(0));
  });

  test('ambiguous evidence yields insufficient_proof without drift', () {
    final candidate = buildReadinessRecalibrationCandidateV1(
      ssot: ssot,
      canonicalReadiness: canonicalReadiness,
      operationalSnapshot: operationalSnapshot,
      releaseReadinessSnapshot: releaseReadinessSnapshot,
      explicitEvidence: const <ReadinessEpicEvidenceV1>[
        ReadinessEpicEvidenceV1(
          epicId: 'M3',
          candidateStatus: ReadinessEpicStatusV1.proofPending,
          evidenceRefs: <String>['synthetic://ambiguous'],
          reason:
              'Evidence is suggestive but not enough to justify exact movement.',
          justified: false,
        ),
      ],
    );

    expect(
      candidate.status,
      ReadinessRecalibrationCandidateStatusV1.insufficientProof,
    );
    expect(candidate.recalibrationJustifiedNow, isFalse);
    expect(candidate.candidateEpicMovements, isEmpty);
    expect(candidate.candidateScoreDeltas.finalDelta, 0);
    expect(candidate.proofGapsIfNotJustified, isNotEmpty);
  });
}
