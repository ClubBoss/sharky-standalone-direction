import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _outputRootPathV1 = 'output/screen_review/current';
const _schemaV1 = 'screen_review_fast_v1';
const _routeVisualAuditValidityV1 = 'legacy_reference_not_for_audit';
const _routeAllowedUseV1 = 'route_state_smoke_evidence_only';

const _realTextAllowedClaimsV1 = <String>[
  'copy',
  'content_clarity',
  'tone',
  'readability',
  'feedback_quality',
  'payoff_quality',
  'product_readiness_evidence',
  'surface_identity',
];

const _realTextUnsupportedClaimsBaseV1 = <String>[
  'human_qa_approval',
  'public_readiness',
  'launch_readiness',
  '10_10_claim',
  'durable_learning_effect',
  'beginner_mastery',
];

class _CaptureSurfaceV1 {
  const _CaptureSurfaceV1(
    this.name,
    this.debugSurface, {
    this.scrollViewport = 'top',
  });

  final String name;
  final String debugSurface;
  final String scrollViewport;
}

class _RouteCaptureSurfaceV1 {
  const _RouteCaptureSurfaceV1(
    this.name,
    this.packId,
    this.moduleTitle, {
    this.startHandIndex = 0,
  });

  final String name;
  final String packId;
  final String moduleTitle;
  final int startHandIndex;
}

class _ActiveRouteCaptureSurfaceV1 {
  const _ActiveRouteCaptureSurfaceV1(
    this.name,
    this.world,
    this.taskIndex,
    this.captureKind,
  );

  final String name;
  final int world;
  final int taskIndex;
  final String captureKind;
}

const _captureGroupsV1 = <String, List<_CaptureSurfaceV1>>{
  'alpha_journey': <_CaptureSurfaceV1>[
    _CaptureSurfaceV1('placement', 'placement'),
    _CaptureSurfaceV1('welcome', 'welcome'),
    _CaptureSurfaceV1('home', 'firstWeekHome'),
    _CaptureSurfaceV1('learn', 'firstWeekLearn'),
    _CaptureSurfaceV1('learn_detail', 'firstWeekLearn'),
    _CaptureSurfaceV1('play', 'runnerDrill'),
    _CaptureSurfaceV1('feedback', 'runnerFirstWrongFeedback'),
    _CaptureSurfaceV1('practice_repair', 'day2PracticeRepairTarget'),
    _CaptureSurfaceV1('completion_payoff', 'worldCompletion'),
    _CaptureSurfaceV1('summary', 'sessionSummary'),
    _CaptureSurfaceV1('review_profile', 'profileEvidence'),
    _CaptureSurfaceV1('w12_terminal', 'w12Terminal'),
  ],
  'core': <_CaptureSurfaceV1>[
    _CaptureSurfaceV1('home', 'firstWeekHome'),
    _CaptureSurfaceV1('learn', 'firstWeekLearn'),
    _CaptureSurfaceV1('learn_detail', 'firstWeekLearn'),
    _CaptureSurfaceV1('practice', 'practice'),
    _CaptureSurfaceV1('review_empty', 'reviewEmpty'),
    _CaptureSurfaceV1('review', 'firstWeekReview'),
    _CaptureSurfaceV1('profile', 'firstWeekProfile'),
  ],
  'runner': <_CaptureSurfaceV1>[
    _CaptureSurfaceV1('decision', 'runnerDrill'),
    _CaptureSurfaceV1('correct_feedback', 'runnerFirstCorrectFeedback'),
    _CaptureSurfaceV1('wrong_feedback', 'runnerFirstWrongFeedback'),
  ],
  'first_week': <_CaptureSurfaceV1>[
    _CaptureSurfaceV1('placement', 'placement'),
    _CaptureSurfaceV1('welcome_decision', 'welcome'),
    _CaptureSurfaceV1('welcome_feedback', 'welcome'),
    _CaptureSurfaceV1('welcome_handoff', 'welcome'),
    _CaptureSurfaceV1('decision', 'runnerDrill'),
    _CaptureSurfaceV1('correct_feedback', 'runnerFirstCorrectFeedback'),
    _CaptureSurfaceV1('wrong_feedback', 'runnerFirstWrongFeedback'),
    _CaptureSurfaceV1('repair_focus', 'repairFocus'),
    _CaptureSurfaceV1('repair_result', 'repairResult'),
    _CaptureSurfaceV1('session_repair', 'sessionRepair'),
    _CaptureSurfaceV1('session_summary', 'sessionSummary'),
    _CaptureSurfaceV1('review_handoff', 'firstWeekReview'),
    _CaptureSurfaceV1('profile_return', 'firstWeekProfile'),
  ],
  'day2_return': <_CaptureSurfaceV1>[
    _CaptureSurfaceV1('open_repair_source', 'repairFocus'),
    _CaptureSurfaceV1('return_home', 'day2ReturnHome'),
    _CaptureSurfaceV1('practice_repair_target', 'day2PracticeRepairTarget'),
    _CaptureSurfaceV1('review_continuation', 'day2ReviewContinuation'),
    _CaptureSurfaceV1('profile_not_clear', 'day2ProfileActiveRepair'),
  ],
  'profile_evidence': <_CaptureSurfaceV1>[
    _CaptureSurfaceV1(
      'profile_evidence',
      'profileEvidence',
      scrollViewport: 'mid',
    ),
  ],
  'full_scroll': <_CaptureSurfaceV1>[
    _CaptureSurfaceV1('home.scroll_01_top', 'firstWeekHome'),
    _CaptureSurfaceV1(
      'home.scroll_02_mid',
      'firstWeekHome',
      scrollViewport: 'mid',
    ),
    _CaptureSurfaceV1(
      'home.scroll_03_bottom',
      'firstWeekHome',
      scrollViewport: 'bottom',
    ),
    _CaptureSurfaceV1('learn.scroll_01_top', 'firstWeekLearn'),
    _CaptureSurfaceV1(
      'learn.scroll_02_mid',
      'firstWeekLearn',
      scrollViewport: 'mid',
    ),
    _CaptureSurfaceV1(
      'learn.scroll_03_bottom',
      'firstWeekLearn',
      scrollViewport: 'bottom',
    ),
    _CaptureSurfaceV1('practice.scroll_01_top', 'practice'),
    _CaptureSurfaceV1(
      'practice.scroll_02_mid',
      'practice',
      scrollViewport: 'mid',
    ),
    _CaptureSurfaceV1(
      'practice.scroll_03_bottom',
      'practice',
      scrollViewport: 'bottom',
    ),
    _CaptureSurfaceV1('review.scroll_01_top', 'firstWeekReview'),
    _CaptureSurfaceV1(
      'review.scroll_02_mid',
      'firstWeekReview',
      scrollViewport: 'mid',
    ),
    _CaptureSurfaceV1(
      'review.scroll_03_bottom',
      'firstWeekReview',
      scrollViewport: 'bottom',
    ),
    _CaptureSurfaceV1('profile.scroll_01_top', 'firstWeekProfile'),
    _CaptureSurfaceV1(
      'profile.scroll_02_mid',
      'firstWeekProfile',
      scrollViewport: 'mid',
    ),
    _CaptureSurfaceV1(
      'profile.scroll_03_bottom',
      'firstWeekProfile',
      scrollViewport: 'bottom',
    ),
    _CaptureSurfaceV1('session_summary.scroll_01_top', 'sessionSummary'),
    _CaptureSurfaceV1(
      'session_summary.scroll_02_mid',
      'sessionSummary',
      scrollViewport: 'mid',
    ),
    _CaptureSurfaceV1(
      'session_summary.scroll_03_bottom',
      'sessionSummary',
      scrollViewport: 'bottom',
    ),
  ],
};

const _presentationClosureSurfacesV1 = <String>[
  'normal_three_option_decision',
  'correct_feedback',
  'normal_four_option_table_read',
  'accessibility_evidence',
  'accessibility_answer',
];

const _reviewReturnSurfacesV1 = <String>[
  'review_list',
  'review_focused_rep',
  'review_feedback',
  'review_return_updated',
  'review_full_shell_authority',
];

const _routeW7W12CaptureSurfacesV1 = <_RouteCaptureSurfaceV1>[
  _RouteCaptureSurfaceV1(
    'w7_first_route_task',
    'world7_spine_campaign_v1',
    'W7 Visible Cards Narrow Ranges',
  ),
  _RouteCaptureSurfaceV1(
    'w8_first_route_task',
    'world8_spine_campaign_v1',
    'W8 Draws Can Improve',
  ),
  _RouteCaptureSurfaceV1(
    'w9_first_route_task',
    'world9_spine_campaign_v1',
    'W9 Call Price',
  ),
  _RouteCaptureSurfaceV1(
    'w10_first_route_task',
    'world10_spine_campaign_v1',
    'W10 Bet Purpose',
  ),
  _RouteCaptureSurfaceV1(
    'w11_danger_texture_task',
    'world11_spine_campaign_v1',
    'W11 Texture Danger',
  ),
  _RouteCaptureSurfaceV1(
    'w12_first_review_task',
    'world12_spine_campaign_v1',
    'W12 Review Payoff',
  ),
  _RouteCaptureSurfaceV1(
    'w12_payoff_completion',
    'world12_spine_campaign_v1',
    'W12 Review Payoff',
    startHandIndex: 3,
  ),
  _RouteCaptureSurfaceV1(
    'volume_i_terminal_review',
    'volume_i_terminal_review_v1',
    'Volume I review',
  ),
  _RouteCaptureSurfaceV1(
    'no_w13_terminal_state',
    'volume_i_terminal_review_v1',
    'Volume I review',
    startHandIndex: 3,
  ),
];

const _activeRouteW7W12CaptureSurfacesV1 = <_ActiveRouteCaptureSurfaceV1>[
  _ActiveRouteCaptureSurfaceV1('w7_first_route_task_table', 7, 0, 'table'),
  _ActiveRouteCaptureSurfaceV1(
    'w7_first_route_task_copy_detail',
    7,
    0,
    'copy_detail',
  ),
  _ActiveRouteCaptureSurfaceV1('w8_route_task_table', 8, 0, 'table'),
  _ActiveRouteCaptureSurfaceV1(
    'w8_route_task_copy_detail',
    8,
    0,
    'copy_detail',
  ),
  _ActiveRouteCaptureSurfaceV1('w9_first_route_task_table', 9, 0, 'table'),
  _ActiveRouteCaptureSurfaceV1(
    'w9_first_route_task_copy_detail',
    9,
    0,
    'copy_detail',
  ),
  _ActiveRouteCaptureSurfaceV1('w10_route_task_table', 10, 0, 'table'),
  _ActiveRouteCaptureSurfaceV1(
    'w10_route_task_copy_detail',
    10,
    0,
    'copy_detail',
  ),
  _ActiveRouteCaptureSurfaceV1('w11_danger_texture_task_table', 11, 1, 'table'),
  _ActiveRouteCaptureSurfaceV1(
    'w11_danger_texture_task_copy_detail',
    11,
    1,
    'copy_detail',
  ),
  _ActiveRouteCaptureSurfaceV1('w12_first_review_task_table', 12, 0, 'table'),
  _ActiveRouteCaptureSurfaceV1(
    'w12_first_review_task_copy_detail',
    12,
    0,
    'copy_detail',
  ),
  _ActiveRouteCaptureSurfaceV1('w12_payoff_completion_table', 12, 3, 'table'),
  _ActiveRouteCaptureSurfaceV1(
    'w12_payoff_completion_copy_detail',
    12,
    3,
    'copy_detail',
  ),
  _ActiveRouteCaptureSurfaceV1('volume_i_terminal_review_table', 0, 0, 'table'),
  _ActiveRouteCaptureSurfaceV1(
    'terminal_no_w13_copy_detail',
    0,
    3,
    'copy_detail',
  ),
];

void main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    _printUsageV1();
    exit(0);
  }

  if (args.length != 2 || !_supportedDevicesV1.contains(args[1])) {
    _printUsageV1();
    exit(64);
  }

  final group = args[0];
  final device = args[1];
  final packetName = group == 'presentation_closure'
      ? 'presentation_closure_v1'
      : group == 'review_return'
      ? 'review_return_v1'
      : device == 'compact'
      ? '${group}_fast'
      : '${group}_${device}_fast';
  final captureSurfaces = _captureGroupsV1[group];
  final routeCaptureSurfaces = group == 'route_w7_w12'
      ? _routeW7W12CaptureSurfacesV1
      : null;
  final activeRouteCaptureSurfaces = group == 'active_route_w7_w12'
      ? _activeRouteW7W12CaptureSurfacesV1
      : null;
  final targetedSurfaces = group == 'presentation_closure'
      ? _presentationClosureSurfacesV1
      : group == 'review_return'
      ? _reviewReturnSurfacesV1
      : null;
  if (captureSurfaces == null &&
      routeCaptureSurfaces == null &&
      activeRouteCaptureSurfaces == null &&
      targetedSurfaces == null) {
    _printUsageV1();
    exit(64);
  }
  final outputDir = Directory('$_outputRootPathV1/$packetName');
  final stagingRoot = Directory('output/screen_review/.staging')
    ..createSync(recursive: true);
  final stagingDir = Directory(
    '${stagingRoot.path}/$packetName.${DateTime.now().toUtc().toIso8601String().replaceAll(':', '').replaceAll('.', '_')}.$pid',
  )..createSync(recursive: true);

  final tempDir = Directory(
    Directory.systemTemp.createTempSync('act0_real_text_surface_capture_').path,
  );
  final testFile = File(
    '${tempDir.path}${Platform.pathSeparator}act0_real_text_surface_capture_test.dart',
  );
  testFile.writeAsStringSync(
    targetedSurfaces != null
        ? _targetedPreHumanQaFlutterTestSource(
            stagingDir.path,
            group,
            device,
            targetedSurfaces,
          )
        : routeCaptureSurfaces == null
        ? activeRouteCaptureSurfaces == null
              ? _flutterTestSource(
                  stagingDir.path,
                  group,
                  device,
                  captureSurfaces!,
                )
              : _activeRouteFlutterTestSource(
                  stagingDir.path,
                  group,
                  device,
                  activeRouteCaptureSurfaces,
                )
        : _routeFlutterTestSource(
            stagingDir.path,
            group,
            device,
            routeCaptureSurfaces,
          ),
  );

  final stopwatch = Stopwatch()..start();
  final result = await Process.start(
    'flutter',
    <String>['test', testFile.path],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  await stdout.addStream(result.stdout);
  await stderr.addStream(result.stderr);
  final exitCode = await result.exitCode.timeout(
    const Duration(minutes: 3),
    onTimeout: () {
      result.kill(ProcessSignal.sigterm);
      stderr.writeln('screen_review_fast_v1: flutter test timed out.');
      return 124;
    },
  );
  stopwatch.stop();

  try {
    tempDir.deleteSync(recursive: true);
  } catch (_) {
    // Best-effort cleanup.
  }

  if (exitCode != 0) {
    stderr.writeln(
      'screen_review_fast_v1: capture failed; previous output preserved at ${outputDir.path}',
    );
    stderr.writeln(
      'screen_review_fast_v1: failed staging output left at ${stagingDir.path}',
    );
    exit(exitCode);
  }

  final surfaces =
      targetedSurfaces ??
      (captureSurfaces != null
          ? captureSurfaces.map((capture) => capture.name).toList()
          : routeCaptureSurfaces != null
          ? routeCaptureSurfaces.map((capture) => capture.name).toList()
          : activeRouteCaptureSurfaces!
                .map((capture) => capture.name)
                .toList());
  final currentGitCommit = _gitOutputV1(<String>['rev-parse', 'HEAD']);
  final currentGitStatus = _evidenceGitStatusV1();
  final currentGitStatusClassification = _evidenceGitStatusClassificationV1();
  final sourceBySurface = targetedSurfaces == null
      ? _sourceBySurfaceV1(
          captureSurfaces: captureSurfaces,
          routeCaptureSurfaces: routeCaptureSurfaces,
          activeRouteCaptureSurfaces: activeRouteCaptureSurfaces,
        )
      : <String, String>{
          for (final surface in targetedSurfaces)
            surface: group == 'presentation_closure'
                ? 'Act0LessonRunnerShellV1.production_state_fixture'
                : surface == 'review_full_shell_authority'
                ? 'Act0ShellPreviewScreenV1.controlled_demo'
                : 'Act0ReviewShellV1.production_callback_fixture',
        };
  final entries = <Map<String, Object?>>[];
  for (final surface in surfaces) {
    final file = File(
      '${stagingDir.path}${Platform.pathSeparator}$device.$surface.png',
    );
    if (!file.existsSync() || file.lengthSync() == 0) {
      stderr.writeln('Missing or empty screenshot artifact `${file.path}`.');
      stderr.writeln(
        'screen_review_fast_v1: previous output preserved at ${outputDir.path}',
      );
      exit(1);
    }
    entries.add(<String, Object?>{
      'lane_type': 'real_text_product_proof',
      'evidence_type': 'product_real_text',
      'render_kind': 'flutter_widget_test_real_text',
      'is_real_text': true,
      'supports_product_copy_review': true,
      'supports_alpha_admission': false,
      'device': device,
      'viewport': device,
      'surface': surface,
      'surface_identity': surface,
      'task_id': targetedSurfaces == null
          ? null
          : group == 'presentation_closure' &&
                (surface == 'normal_four_option_table_read' ||
                    surface == 'accessibility_evidence' ||
                    surface == 'accessibility_answer')
          ? 'what_poker_is_table_read_transfer'
          : 'actions_check_drill',
      'state_identity': targetedSurfaces == null
          ? null
          : '${group}_v1::$surface',
      'presentation_mode': targetedSurfaces == null
          ? null
          : surface.startsWith('accessibility_')
          ? surface.replaceFirst('accessibility_', '')
          : surface,
      'production_source_owner': targetedSurfaces == null
          ? null
          : sourceBySurface[surface],
      'path': 'output/screen_review/current/$packetName/$device.$surface.png',
      'bytes': file.lengthSync(),
      'sha256': sha256.convert(file.readAsBytesSync()).toString(),
      'git_commit': currentGitCommit,
      'git_status': currentGitStatus,
      'git_status_classification': currentGitStatusClassification,
      'matches_current_head': true,
      'allowed_claims': _realTextAllowedClaimsV1,
      'unsupported_claims': _unsupportedViewportClaimsV1(device),
      'semantic_assertions': _semanticAssertionsForSurfaceV1(surface),
      'debug_surface': sourceBySurface[surface],
      'source_route': group == 'active_route_w7_w12'
          ? 'Act0LessonRunnerShellV1.active_runtime_route'
          : group == 'presentation_closure'
          ? 'Act0LessonRunnerShellV1.production_state_fixture'
          : group == 'review_return'
          ? surface == 'review_full_shell_authority'
                ? 'Act0ShellPreviewScreenV1.controlled_demo'
                : 'Act0ReviewShellV1.production_callback_fixture'
          : 'Act0ShellPreviewScreenV1.controlled_demo',
      'capture_source_policy': group == 'active_route_w7_w12'
          ? 'active_act0_runtime_test_only_wrapper'
          : 'active_surface_allowlisted',
    });
  }
  final duplicateHashPolicy = duplicateHashPolicyV1(entries);

  final manifestFile = File(
    '${stagingDir.path}${Platform.pathSeparator}manifest.json',
  );
  final routeVisualAuditValidity = group == 'route_w7_w12'
      ? _routeVisualAuditValidityV1
      : group == 'active_route_w7_w12'
      ? 'active_runtime_visual_evidence'
      : 'active_surface_fast_review';
  final routeAllowedUse = group == 'route_w7_w12'
      ? _routeAllowedUseV1
      : group == 'active_route_w7_w12'
      ? 'final_pre_human_visual_ux_audit'
      : 'final_visual_audit_candidate';
  manifestFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'schema': _schemaV1,
      'group': group,
      'packet': packetName,
      'device': device,
      'lane_version': targetedSurfaces == null ? null : '${group}_v1',
      'lane_type': 'real_text_product_proof',
      'evidence_type': 'product_real_text',
      'render_kind': 'flutter_widget_test_real_text',
      'is_real_text': true,
      'supports_product_copy_review': true,
      'supports_alpha_admission': false,
      'git_commit': currentGitCommit,
      'git_status': currentGitStatus,
      'git_status_classification': currentGitStatusClassification,
      'matches_current_head': true,
      'logical_viewport': device == 'iphone17_class' ? <String, int>{'width': 402, 'height': 874} : null,
      'safe_area_fixture': device == 'iphone17_class' ? <String, int>{'top': 59, 'bottom': 34} : null,
      'text_scaler': group == 'presentation_closure' ? <String, String>{'normal': 'linear(1.0)', 'accessibility': 'linear(1.4)'} : 'linear(1.0)',
      'allowed_claims': _realTextAllowedClaimsV1,
      'unsupported_claims': _unsupportedViewportClaimsV1(device),
      'duplicate_hash_policy': duplicateHashPolicy,
      'scenario_family': group == 'route_w7_w12'
          ? 'late_route_w7_w12_visual_coverage'
          : group == 'active_route_w7_w12'
          ? 'active_runtime_late_route_w7_w12_visual_coverage'
          : 'act0_fast_screen_review',
      'content_reflects_latest_post_idealization_copy': group == 'route_w7_w12' || group == 'active_route_w7_w12',
      'visual_audit_validity': routeVisualAuditValidity,
      'final_visual_audit_eligible': group != 'route_w7_w12',
      'invalid_for_final_visual_ux_judgment': group == 'route_w7_w12' ? true : false,
      'allowed_use': routeAllowedUse,
      'capture_source_policy': group == 'route_w7_w12'
          ? _routeVisualAuditValidityV1
          : group == 'active_route_w7_w12'
          ? 'active_act0_runtime_test_only_wrapper'
          : 'active_surface_allowlisted',
      'legacy_archive_runner_used': group == 'route_w7_w12',
      'active_surface': group == 'active_route_w7_w12'
          ? 'Act0LessonRunnerShellV1'
          : group == 'review_return'
          ? 'mixed: Act0ReviewShellV1 fixture plus Act0ShellPreviewScreenV1 full-shell authority'
          : null,
      'captured_at': DateTime.now().toUtc().toIso8601String(),
      'runtime_seconds': stopwatch.elapsedMilliseconds / 1000.0,
      'surfaces': surfaces,
      'entries': entries,
      'note': 'Generated screenshots are local-only and uncommitted. Real-text claims are valid only for the listed device/viewports and current HEAD.',
    })}\n',
  );

  if (group == 'full_scroll') {
    final metadataFile = File(
      '${stagingDir.path}${Platform.pathSeparator}full_scroll_meta.json',
    );
    if (!metadataFile.existsSync() || metadataFile.lengthSync() == 0) {
      stderr.writeln('Missing full-scroll metadata `${metadataFile.path}`.');
      stderr.writeln(
        'screen_review_fast_v1: previous output preserved at ${outputDir.path}',
      );
      exit(1);
    }
  }

  final previousDir = Directory('${outputDir.path}.previous');
  outputDir.parent.createSync(recursive: true);
  if (previousDir.existsSync()) {
    previousDir.deleteSync(recursive: true);
  }
  if (outputDir.existsSync()) {
    outputDir.renameSync(previousDir.path);
  }
  stagingDir.renameSync(outputDir.path);
  if (previousDir.existsSync()) {
    previousDir.deleteSync(recursive: true);
  }

  stdout.writeln(outputDir.path);
}

const _supportedDevicesV1 = <String>{
  'compact',
  'tall_phone',
  'large_phone',
  'tablet',
  'iphone17_class',
};

String _gitOutputV1(List<String> args) {
  final result = Process.runSync(
    'git',
    args,
    workingDirectory: Directory.current.path,
  );
  if (result.exitCode != 0) {
    throw StateError('git ${args.join(' ')} failed: ${result.stderr}');
  }
  return (result.stdout as String).trim();
}

String _evidenceGitStatusV1() {
  final raw = _gitOutputV1(<String>['status', '--short']);
  final meaningfulLines = raw
      .split('\n')
      .map((line) => line.trimRight())
      .where((line) => line.isNotEmpty)
      .where((line) => !line.startsWith('?? output/screen_review/'))
      .where((line) => line != '?? output/screen_review/')
      .where((line) => !line.startsWith('?? output/design_review/'))
      .where((line) => line != '?? output/design_review/')
      .where(
        (line) =>
            !line.endsWith('macos/Flutter/GeneratedPluginRegistrant.swift'),
      )
      .toList(growable: false);
  if (meaningfulLines.isEmpty) {
    return 'clean_or_output_only';
  }
  return 'dirty';
}

Map<String, Object?> _evidenceGitStatusClassificationV1() {
  final lines = _gitOutputV1(
    <String>['status', '--short', '--ignored'],
  ).split('\n').where((line) => line.trim().isNotEmpty).toList(growable: false);
  final tracked = lines
      .where((line) => !line.startsWith('?? ') && !line.startsWith('!! '))
      .toList(growable: false);
  final untracked = lines
      .where((line) => line.startsWith('?? '))
      .toList(growable: false);
  final ignored = lines
      .where((line) => line.startsWith('!! '))
      .toList(growable: false);
  final untrackedEvidence = untracked
      .where((line) => line.startsWith('?? output/'))
      .toList(growable: false);
  final untrackedNonEvidence = untracked
      .where((line) => !line.startsWith('?? output/'))
      .toList(growable: false);
  return <String, Object?>{
    'tracked_product_dirty': tracked.any((line) => !line.contains('tools/')),
    'tracked_tooling_dirty': tracked.any((line) => line.contains('tools/')),
    'untracked_local_evidence_count': untrackedEvidence.length,
    'untracked_non_evidence_count': untrackedNonEvidence.length,
    'ignored_generated_output_count': ignored
        .where((line) => line.contains('output/'))
        .length,
    'verdict': tracked.isEmpty
        ? untrackedNonEvidence.isEmpty
              ? 'tracked_clean_with_untracked_evidence_only'
              : 'tracked_clean_with_untracked_evidence_and_non_evidence'
        : 'tracked_drift_present',
  };
}

List<String> _unsupportedViewportClaimsV1(String device) {
  return <String>[
    ..._realTextUnsupportedClaimsBaseV1,
    for (final viewport in _supportedDevicesV1)
      if (viewport != device) '${viewport}_real_text_claims',
  ];
}

List<String> _semanticAssertionsForSurfaceV1(String surface) {
  if (surface.contains('terminal') || surface.contains('no_w13')) {
    return <String>['terminal_or_no_w13_copy_visible', 'real_text_rendered'];
  }
  if (surface.contains('decision') ||
      surface.contains('task') ||
      surface.contains('table')) {
    return <String>['decision_or_table_surface_visible', 'real_text_rendered'];
  }
  if (surface.contains('feedback') || surface.contains('repair')) {
    return <String>['feedback_or_repair_copy_visible', 'real_text_rendered'];
  }
  return <String>['surface_copy_visible', 'real_text_rendered'];
}

Map<String, String> _sourceBySurfaceV1({
  required List<_CaptureSurfaceV1>? captureSurfaces,
  required List<_RouteCaptureSurfaceV1>? routeCaptureSurfaces,
  required List<_ActiveRouteCaptureSurfaceV1>? activeRouteCaptureSurfaces,
}) {
  if (captureSurfaces != null) {
    return <String, String>{
      for (final capture in captureSurfaces)
        capture.name:
            'Act0ControlledDemoCaptureSurfaceV1.${capture.debugSurface}',
    };
  }
  if (activeRouteCaptureSurfaces != null) {
    return <String, String>{
      for (final capture in activeRouteCaptureSurfaces)
        capture.name: 'Act0LessonRunnerShellV1.${capture.captureKind}',
    };
  }
  return <String, String>{
    for (final capture
        in routeCaptureSurfaces ?? const <_RouteCaptureSurfaceV1>[])
      capture.name: 'legacy_route_pack.${capture.packId}',
  };
}

Map<String, Object?> duplicateHashPolicyV1(List<Map<String, Object?>> entries) {
  const intentionalSameStateAllowlist = <String, String>{
    'repair_focus|session_repair':
        'Both labels intentionally render the same wrong-outcome repair proof state until a future product-specific session-repair fixture is admitted.',
    'review.scroll_01_top|review.scroll_02_mid|review.scroll_03_bottom':
        'The current Review bench fits inside one viewport, so deterministic top, middle, and bottom scroll requests resolve to the same fixed-height image.',
    'home.scroll_02_mid|home.scroll_03_bottom':
        'The tablet Home surface has one bounded maximum scroll offset, so middle and bottom requests clamp to the same final image.',
    'practice.scroll_01_top|practice.scroll_02_mid|practice.scroll_03_bottom':
        'The current tablet Practice hub fits inside one viewport, so all deterministic scroll requests resolve to the same image.',
    'session_summary.scroll_02_mid|session_summary.scroll_03_bottom':
        'The wider tablet Session Summary reaches one bounded maximum scroll offset, so middle and bottom requests clamp to the same final image.',
  };
  final byViewport = <String, Map<String, List<String>>>{};
  for (final entry in entries) {
    final viewport = entry['viewport'] as String;
    final surface = entry['surface'] as String;
    final hash = entry['sha256'] as String;
    byViewport.putIfAbsent(viewport, () => <String, List<String>>{});
    byViewport[viewport]!.putIfAbsent(hash, () => <String>[]).add(surface);
  }
  final duplicates = <Map<String, Object?>>[];
  for (final viewportEntry in byViewport.entries) {
    for (final hashEntry in viewportEntry.value.entries) {
      if (hashEntry.value.length <= 1) {
        continue;
      }
      final surfaces = [...hashEntry.value]..sort();
      final key = surfaces.join('|');
      final reason = intentionalSameStateAllowlist[key];
      if (reason == null) {
        throw StateError(
          'Unlisted duplicate screenshot hashes in real-text lane: '
          '${viewportEntry.key} $key',
        );
      }
      duplicates.add(<String, Object?>{
        'viewport': viewportEntry.key,
        'sha256': hashEntry.key,
        'surfaces': surfaces,
        'allowlist_key': key,
        'reason': reason,
      });
    }
  }
  return <String, Object?>{
    'policy': 'disallow_unlisted_duplicates',
    'intentional_same_state_allowlist': intentionalSameStateAllowlist,
    'duplicates': duplicates,
  };
}

String _flutterTestSource(
  String outputDirPath,
  String group,
  String device,
  List<_CaptureSurfaceV1> captures,
) {
  final escapedOutputDir = jsonEncode(outputDirPath);
  final captureStatements = captures.indexed.map((entry) {
    final index = entry.$1;
    final capture = entry.$2;
    final screen = capture.name.split('.').first;
    return '''
    await captureSurface(
      tester,
      '$device.${capture.name}.png',
      Act0ControlledDemoCaptureSurfaceV1.${capture.debugSurface},
      screenName: '$screen',
      scrollViewport: '${capture.scrollViewport}',
      captureOrder: ${index + 1},
    );''';
  }).join();
  return '''
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const outputDirPath = $escapedOutputDir;
  const captureGroup = '$group';
  final outputDir = Directory(outputDirPath)..createSync(recursive: true);
  final fullScrollEntries = <Map<String, Object?>>[];
  const viewportSizes = <String, Size>{
    'compact': Size(375, 812),
    'tall_phone': Size(390, 844),
    'large_phone': Size(430, 932),
    'tablet': Size(834, 1194),
  };
  final viewportSize = viewportSizes['$device']!;

  Widget host(Act0ControlledDemoCaptureSurfaceV1 surface) {
    final realTextButtonStyle = ButtonStyle(
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'Roboto'),
      ),
    );
    return MaterialApp(
      locale: const Locale('en'),
      theme: ThemeData(
        fontFamily: 'Roboto',
        filledButtonTheme: FilledButtonThemeData(style: realTextButtonStyle),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: realTextButtonStyle,
        ),
        textButtonTheme: TextButtonThemeData(style: realTextButtonStyle),
      ),
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: RepaintBoundary(
        key: const Key('act0_real_text_capture_boundary'),
        child: Act0ShellPreviewScreenV1(
          key: UniqueKey(),
          showPlacementOnStart: false,
          debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: surface,
          ),
        ),
      ),
    );
  }

  Future<void> loadFontFamily(String family, Uint8List bytes) async {
    final loader = FontLoader(family)
      ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load().timeout(const Duration(seconds: 10));
  }

  Future<void> loadRealTextFont() async {
    const candidates = <String>[
      '/System/Library/Fonts/Supplemental/Arial.ttf',
      '/System/Library/Fonts/SFNS.ttf',
    ];
    for (final path in candidates) {
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      final bytes = await file.readAsBytes();
      await loadFontFamily('Roboto', bytes);
      await loadFontFamily('Ahem', bytes);
      return;
    }
    throw StateError('No local real-text font found for screen capture.');
  }

  Future<void> loadIconFonts() async {
    const iconFonts = <(String, String)>[
      ('MaterialIcons', 'build/unit_test_assets/fonts/MaterialIcons-Regular.otf'),
      ('CupertinoIcons', 'build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('packages/cupertino_icons/CupertinoIcons', 'build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('MaterialIcons', 'build/flutter_assets/fonts/MaterialIcons-Regular.otf'),
      ('CupertinoIcons', 'build/flutter_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('packages/cupertino_icons/CupertinoIcons', 'build/flutter_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
    ];
    final loaded = <String>{};
    for (final (family, path) in iconFonts) {
      if (loaded.contains(family)) {
        continue;
      }
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      final bytes = await file.readAsBytes();
      await loadFontFamily(family, bytes);
      loaded.add(family);
    }
    if (!loaded.contains('MaterialIcons')) {
      throw StateError('No local MaterialIcons font found for screen capture.');
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  setUpAll(() async {
    await loadRealTextFont();
    await loadIconFonts();
  });

  Future<void> pumpCompact(
    WidgetTester tester,
    Act0ControlledDemoCaptureSurfaceV1 surface,
  ) async {
    tester.view.physicalSize = viewportSize;
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(host(surface));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
  }

  Future<void> advanceWelcomeCaptureState(
    WidgetTester tester,
    String fileName,
  ) async {
    if (!fileName.contains('welcome_')) {
      return;
    }
    await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    if (fileName.contains('welcome_decision')) {
      return;
    }
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    if (fileName.contains('welcome_feedback')) {
      return;
    }
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Finder findLessonCardsV1() {
    return find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key != null && key.toString().contains('act0_shell_lesson_');
    });
  }

  Future<void> openLearnDetailIfNeededV1(WidgetTester tester) async {
    if (find.byKey(const Key('act0_shell_selected_lesson_panel')).evaluate().isNotEmpty) {
      return;
    }
    final lessonCards = findLessonCardsV1();
    if (lessonCards.evaluate().isEmpty) {
      throw StateError('Missing visible target for learn lesson card');
    }
    await tester.ensureVisible(lessonCards.first);
    await tester.tap(lessonCards.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    if (find.byKey(const Key('act0_shell_selected_lesson_panel')).evaluate().isEmpty) {
      throw StateError(
        'Learn detail panel did not open after tapping learn lesson card.',
      );
    }
  }

  Future<Map<String, Object?>> movePrimaryScrollableToViewport(
    WidgetTester tester,
    String scrollViewport,
  ) async {
    final candidates = find
        .byType(Scrollable)
        .evaluate()
        .map(
          (element) => element is StatefulElement ? element.state : null,
        )
        .whereType<ScrollableState>()
        .where((state) => state.position.hasPixels)
        .toList()
      ..sort(
        (a, b) => b.position.maxScrollExtent.compareTo(
          a.position.maxScrollExtent,
        ),
      );
    if (candidates.isEmpty) {
      return <String, Object?>{
        'requested_viewport': scrollViewport,
        'scroll_offset': 0.0,
        'max_scroll_extent': 0.0,
        'bottom_reached': true,
        'scrollable_found': false,
      };
    }
    final position = candidates.first.position;
    final maxExtent = position.maxScrollExtent;
    final fraction = switch (scrollViewport) {
      'mid' => 0.5,
      'bottom' => 1.0,
      _ => 0.0,
    };
    final targetOffset = maxExtent * fraction;
    position.jumpTo(targetOffset);
    await tester.pump();
    return <String, Object?>{
      'requested_viewport': scrollViewport,
      'scroll_offset': position.pixels,
      'max_scroll_extent': maxExtent,
      'bottom_reached': position.pixels >= maxExtent,
      'scrollable_found': true,
    };
  }

  String colorToHex(Color color) {
    final alpha = (color.a * 255).round().clamp(0, 255);
    final red = (color.r * 255).round().clamp(0, 255);
    final green = (color.g * 255).round().clamp(0, 255);
    final blue = (color.b * 255).round().clamp(0, 255);
    return '#'
        '\${alpha.toRadixString(16).padLeft(2, '0')}'
        '\${red.toRadixString(16).padLeft(2, '0')}'
        '\${green.toRadixString(16).padLeft(2, '0')}'
        '\${blue.toRadixString(16).padLeft(2, '0')}';
  }

  void writeTextRepairOverlays(WidgetTester tester, String fileName) {
    final overlays = <Map<String, Object?>>[];
    for (final element in find.byType(Text).evaluate()) {
      final widget = element.widget;
      if (widget is! Text) {
        continue;
      }
      final text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
      if (text.trim().isEmpty) {
        continue;
      }
      final defaultStyle = DefaultTextStyle.of(element).style;
      final explicitStyle = widget.style;
      if (defaultStyle.fontFamily != null || explicitStyle?.fontFamily != null) {
        continue;
      }
      final renderObject = element.renderObject;
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        continue;
      }
      final topLeft = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;
      if (size.width <= 0 || size.height <= 0) {
        continue;
      }
      overlays.add(<String, Object?>{
        'text': text,
        'left': topLeft.dx,
        'top': topLeft.dy,
        'width': size.width,
        'height': size.height,
        'fontSize': (explicitStyle?.fontSize ?? defaultStyle.fontSize ?? 14),
        'fontWeight': (explicitStyle?.fontWeight ?? defaultStyle.fontWeight ?? FontWeight.w400).value,
        'color': colorToHex(explicitStyle?.color ?? defaultStyle.color ?? Colors.white),
      });
    }
    final overlayFile = File('\${outputDir.path}/' + fileName + '.text_overlays.json');
    overlayFile.writeAsStringSync(jsonEncode(overlays));
  }

  Future<void> captureSurface(
    WidgetTester tester,
    String fileName,
    Act0ControlledDemoCaptureSurfaceV1 surface,
    {
    required String screenName,
    required String scrollViewport,
    required int captureOrder,
  }
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpCompact(tester, surface);
    await advanceWelcomeCaptureState(tester, fileName);
    if (fileName.contains('learn_detail')) {
      await openLearnDetailIfNeededV1(tester);
    }
    final scrollMetadata = await movePrimaryScrollableToViewport(
      tester,
      scrollViewport,
    );
    writeTextRepairOverlays(tester, fileName);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('act0_real_text_capture_boundary')),
    );
    final byteData = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2.0);
      return image.toByteData(format: ui.ImageByteFormat.png);
    });
    if (byteData == null) {
      throw StateError('Failed to capture screenshot for ' + fileName);
    }
    final file = File('\${outputDir.path}/' + fileName);
    file.writeAsBytesSync(Uint8List.view(byteData.buffer));
    if (captureGroup == 'full_scroll') {
      fullScrollEntries.add(<String, Object?>{
        'screen': screenName,
        'file': fileName,
        'capture_order': captureOrder,
        'source_capture_state': surface.name,
        'capture_mode': 'viewport_sequence',
        ...scrollMetadata,
      });
    }
  }

  testWidgets('capture real-text Act0 $group review surfaces', (tester) async {
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.resetSystemFontFamily();
    });

$captureStatements
    if (captureGroup == 'full_scroll') {
      File('\${outputDir.path}/full_scroll_meta.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(<String, Object?>{
          'schema': 'full_scroll_screen_evidence_v1',
          'device': '$device',
          'capture_mode': 'viewport_sequence',
          'entries': fullScrollEntries,
          'note': 'Generated metadata is local-only and uncommitted.',
        }) + '\\n',
      );
    }
  });
}
''';
}

String _targetedPreHumanQaFlutterTestSource(
  String outputDirPath,
  String group,
  String device,
  List<String> surfaces,
) {
  final escapedOutputDir = jsonEncode(outputDirPath);
  final captureCalls = surfaces
      .map((surface) => "    await capture('$surface');")
      .join('\n');
  return '''
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const outputDirPath = $escapedOutputDir;
  const captureGroup = '$group';
  final outputDir = Directory(outputDirPath)..createSync(recursive: true);
  const viewport = Size(402, 874);
  final bounds = <String, Object?>{};

  Future<void> loadFont() async {
    final file = File('/System/Library/Fonts/Supplemental/Arial.ttf');
    if (!file.existsSync()) throw StateError('No local real-text font found for targeted capture.');
    final bytes = await file.readAsBytes();
    for (final family in <String>['Roboto', 'Ahem']) {
      final loader = FontLoader(family)..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
    final icon = File('build/unit_test_assets/fonts/MaterialIcons-Regular.otf');
    if (icon.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(
          Future<ByteData>.value(ByteData.sublistView(await icon.readAsBytes())),
        );
      await loader.load();
    }
  }

  Act0LessonTaskV1 taskFor(String id) => Act0ShellStateV1.sample
      .worldById('world_1').lessons
      .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise')
      .taskList.firstWhere((task) => task.taskId == id);

  final actionTask = taskFor('actions_check_drill');
  final tableTask = taskFor('actions_call_drill');
  final tableRunner = placementQuickCheckRunnerV1(
    tableTask.runner.copyWith(phase: Act0LessonPhaseV1.drill, teachingSteps: const <Act0TeachingStepV1>[]),
    signalId: 'table_read', checkIndex: 1, checkCount: 3,
  );
  final actionFeedback = actionTask.runner.copyWith(
    phase: Act0LessonPhaseV1.review,
    selectedOptionId: 'check',
    feedbackTitle: 'Correct read',
    feedbackReason: 'No bet faces you, so checking keeps the hand going for free.',
    primaryCtaLabel: 'Next hand',
  );
  var accessibilityStep = Act0AccessibilityPrototypeStepV1.evidence;
  var reviewStage = 'list';
  const activeMistake = Act0MistakeCardV1(
    taskId: 'actions_check_drill', lessonId: 'fold_check_call_raise',
    title: 'No bet yet', weaknessLabel: 'Action read', selectedOptionId: 'fold',
    selectedLabel: 'Fold', betterLabel: 'Check', attempts: 1,
    reason: 'Nobody has bet, so checking keeps the action honest.',
    repairActionLabel: 'Review why the table was telling you to check.',
  );
  const completedMistake = Act0MistakeCardV1(
    taskId: 'actions_check_drill', lessonId: 'fold_check_call_raise',
    title: 'No bet yet', weaknessLabel: 'Action read', selectedOptionId: 'check',
    selectedLabel: 'Check', betterLabel: 'Check', attempts: 2,
    reason: 'You caught the no-bet-yet clue before acting.',
    resolved: true, severityLabel: 'Quick fix',
    qualityLine: 'Focused rep complete.',
  );

  ThemeData captureTheme() {
    final buttonText = ButtonStyle(textStyle: WidgetStateProperty.all(const TextStyle(fontFamily: 'Roboto')));
    return ThemeData(fontFamily: 'Roboto', filledButtonTheme: FilledButtonThemeData(style: buttonText), outlinedButtonTheme: OutlinedButtonThemeData(style: buttonText), textButtonTheme: TextButtonThemeData(style: buttonText));
  }
  Widget runnerHost(Act0RunnerStateV1 runner, {bool accessibility = false}) => MaterialApp(
    theme: captureTheme(),
    home: MediaQuery(
      data: MediaQueryData(size: viewport, viewPadding: const EdgeInsets.only(top: 59, bottom: 34), textScaler: accessibility ? const TextScaler.linear(1.4) : const TextScaler.linear(1.0)),
      child: Scaffold(body: RepaintBoundary(key: const Key('act0_real_text_capture_boundary'), child: StatefulBuilder(builder: (context, setState) => Act0LessonRunnerShellV1(
        runner: runner, selectedTaskFamily: accessibility ? tableTask.resolvedTaskFamily : actionTask.resolvedTaskFamily,
        tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
        accessibilityPrototypeStep: accessibility ? accessibilityStep : null,
        onAccessibilityPrototypeStepChanged: accessibility ? (next) => setState(() => accessibilityStep = next) : null,
        onBack: () {}, onContinueTheory: () {}, onChooseOption: (_) {}, onContinueReview: () {},
      )))),
    ),
  );

  Widget shellBody(Act0ControlledDemoCaptureSurfaceV1 surface) => Act0ShellPreviewScreenV1(
          key: UniqueKey(),
          showPlacementOnStart: false,
          debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: surface,
            worldId: 'world_1',
            lessonId: 'fold_check_call_raise',
            taskId: 'actions_check_drill',
          ),
        );
  Widget shellHost(Act0ControlledDemoCaptureSurfaceV1 surface) => MaterialApp(
    theme: captureTheme(),
    home: MediaQuery(
      data: const MediaQueryData(size: viewport, viewPadding: EdgeInsets.only(top: 59, bottom: 34)),
      child: RepaintBoundary(
        key: const Key('act0_real_text_capture_boundary'),
        child: shellBody(surface),
      ),
    ),
  );

  Widget reviewHost() => MaterialApp(
    theme: captureTheme(),
    home: MediaQuery(
      data: const MediaQueryData(size: viewport, viewPadding: EdgeInsets.only(top: 59, bottom: 34)),
      child: Scaffold(body: RepaintBoundary(key: const Key('act0_real_text_capture_boundary'), child: StatefulBuilder(builder: (context, setState) {
        if (reviewStage == 'focused') return shellBody(Act0ControlledDemoCaptureSurfaceV1.runnerDrill);
        if (reviewStage == 'feedback') return shellBody(Act0ControlledDemoCaptureSurfaceV1.runnerFirstCorrectFeedback);
        return Act0ReviewShellV1(review: Act0ReviewStateV1(title: 'Review', subtitle: reviewStage == 'updated' ? 'That focused rep is complete.' : 'Repair the clue that slipped.', weaknessLabel: 'Action read', reason: '', stats: const <Act0ReviewStatV1>[], chosenLabel: 'Fold', betterLabel: 'Check', mistakes: reviewStage == 'updated' ? const <Act0MistakeCardV1>[] : const <Act0MistakeCardV1>[activeMistake], fixedMistakes: reviewStage == 'updated' ? const <Act0MistakeCardV1>[completedMistake] : const <Act0MistakeCardV1>[]), selected: null, onSelected: (_) {}, onFixMistake: (_) => setState(() => reviewStage = 'focused'), onReplayFixedMistake: (_) {});
      }))),
    ),
  );

  late WidgetTester tester;
  String colorToHex(Color color) {
    final alpha = (color.a * 255).round().clamp(0, 255);
    final red = (color.r * 255).round().clamp(0, 255);
    final green = (color.g * 255).round().clamp(0, 255);
    final blue = (color.b * 255).round().clamp(0, 255);
    return '#'
        '\${alpha.toRadixString(16).padLeft(2, '0')}'
        '\${red.toRadixString(16).padLeft(2, '0')}'
        '\${green.toRadixString(16).padLeft(2, '0')}'
        '\${blue.toRadixString(16).padLeft(2, '0')}';
  }

  void writeTextRepairOverlays(String fileName) {
    final overlays = <Map<String, Object?>>[];
    for (final element in find.byType(Text).evaluate()) {
      final widget = element.widget;
      if (widget is! Text) continue;
      final text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
      if (text.trim().isEmpty) continue;
      final inherited = DefaultTextStyle.of(element).style;
      final explicit = widget.style;
      if (inherited.fontFamily != null || explicit?.fontFamily != null) continue;
      final box = element.renderObject;
      if (box is! RenderBox || !box.hasSize) continue;
      final origin = box.localToGlobal(Offset.zero);
      overlays.add(<String, Object?>{
        'text': text,
        'left': origin.dx,
        'top': origin.dy,
        'width': box.size.width,
        'height': box.size.height,
        'fontSize': explicit?.fontSize ?? inherited.fontSize ?? 14,
        'fontWeight': (explicit?.fontWeight ?? inherited.fontWeight ?? FontWeight.w400).value,
        'color': colorToHex(explicit?.color ?? inherited.color ?? Colors.white),
      });
    }
    File('\${outputDir.path}/$device.' + fileName + '.png.text_overlays.json')
        .writeAsStringSync(jsonEncode(overlays));
  }

  void writeBounds(String name) {
    final values = <String, Object?>{};
    for (final entry in <String, Key>{
      'table': const Key('act0_shell_table'), 'question': const Key('act0_shell_action_question'),
      'feedback_card': const Key('act0_shell_feedback_card'), 'feedback_cta': const Key('act0_shell_feedback_continue_cta'),
      'evidence_card': const Key('act0_shell_accessibility_evidence_surface'), 'answer_cta': const Key('act0_shell_accessibility_answer_cta'),
      'view_table': const Key('act0_shell_accessibility_view_table_cta'),
    }.entries) {
      final finder = find.byKey(entry.value);
      if (finder.evaluate().isNotEmpty) { final r = tester.getRect(finder); values[entry.key] = <String, double>{'left': r.left, 'top': r.top, 'right': r.right, 'bottom': r.bottom, 'width': r.width, 'height': r.height}; }
    }
    final options = find.byKey(const Key('act0_shell_option_fold')).evaluate().isNotEmpty
      ? <String>['fold', 'check', 'call'] : <String>['two_three_six', 'two_five_six', 'two_three_four', 'not_sure_yet'];
    values['options'] = <Object?>[for (final id in options) if (find.byKey(Key('act0_shell_option_\$id')).evaluate().isNotEmpty) (() { final r = tester.getRect(find.byKey(Key('act0_shell_option_\$id'))); return <String, double>{'left': r.left, 'top': r.top, 'right': r.right, 'bottom': r.bottom, 'height': r.height}; })()];
    bounds[name] = values;
  }

  List<Rect> optionRects(List<String> ids) => <Rect>[
    for (final id in ids) tester.getRect(find.byKey(Key('act0_shell_option_\$id'))),
  ];

  void verifyMechanicalState(String surface) {
    if (surface == 'normal_three_option_decision') {
      final rows = optionRects(<String>['fold', 'check', 'call']);
      expect(rows.map((row) => row.height).toSet().length, 1);
      expect(rows.every((row) => row.height >= 44), isTrue);
      final scrollable = find.ancestor(of: find.byKey(const Key('act0_shell_option_call')), matching: find.byType(Scrollable));
      if (scrollable.evaluate().isNotEmpty) expect(tester.state<ScrollableState>(scrollable).position.maxScrollExtent, 0);
    }
    if (surface == 'normal_four_option_table_read') {
      final rows = optionRects(<String>['two_three_six', 'two_five_six', 'two_three_four', 'not_sure_yet']);
      expect(rows.map((row) => row.height).toSet().length, 1);
      expect(rows.every((row) => row.height >= 44), isTrue);
      expect(rows.last.bottom, lessThanOrEqualTo(viewport.height));
      final scrollable = find.ancestor(of: find.byKey(const Key('act0_shell_option_not_sure_yet')), matching: find.byType(Scrollable));
      if (scrollable.evaluate().isNotEmpty) expect(tester.state<ScrollableState>(scrollable).position.maxScrollExtent, 0);
    }
    if (surface == 'correct_feedback') {
      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      final card = tester.getRect(find.byKey(const Key('act0_shell_feedback_card')));
      final cta = tester.getRect(find.byKey(const Key('act0_shell_feedback_continue_cta')));
      expect(card.top - table.bottom, inInclusiveRange(0, 32));
      expect(card.bottom - cta.bottom, inInclusiveRange(0, 24));
    }
    if (surface == 'accessibility_evidence') {
      final card = tester.getRect(find.byKey(const Key('act0_shell_accessibility_evidence_surface')));
      final cta = tester.getRect(find.byKey(const Key('act0_shell_accessibility_answer_cta')));
      expect(card.bottom - cta.bottom, inInclusiveRange(8, 28));
      expect(card.height, lessThan(viewport.height * 0.45));
    }
    if (surface == 'accessibility_answer') {
      final rows = optionRects(<String>['two_three_six', 'two_five_six', 'two_three_four', 'not_sure_yet']);
      final footer = tester.getRect(find.byKey(const Key('act0_shell_accessibility_decision_footer')));
      expect(rows.map((row) => row.height).toSet().length, 1);
      expect(rows.every((row) => row.height >= 44), isTrue);
      expect(footer.bottom, lessThanOrEqualTo(viewport.height));
    }
    if (surface == 'review_list') expect(find.byKey(const Key('act0_shell_review_practice_cta')), findsOneWidget);
    if (surface == 'review_focused_rep') expect(find.text('What action keeps playing for free?'), findsOneWidget);
    if (surface == 'review_feedback') expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    if (surface == 'review_return_updated') {
      expect(find.byKey(const Key('act0_shell_fixed_mistake_actions_check_drill')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_review_practice_cta')), findsNothing);
    }
    if (surface == 'review_full_shell_authority') {
      expect(find.byKey(const Key('act0_shell_bottom_nav')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_review_practice_cta')), findsOneWidget);
    }
  }

  Future<void> capture(String surface) async {
    if (captureGroup == 'presentation_closure') {
      if (surface == 'normal_three_option_decision') await tester.pumpWidget(shellHost(Act0ControlledDemoCaptureSurfaceV1.runnerDrill));
      if (surface == 'correct_feedback') await tester.pumpWidget(shellHost(Act0ControlledDemoCaptureSurfaceV1.runnerFirstCorrectFeedback));
      if (surface == 'normal_four_option_table_read') await tester.pumpWidget(runnerHost(tableRunner));
      if (surface == 'accessibility_evidence') { accessibilityStep = Act0AccessibilityPrototypeStepV1.evidence; await tester.pumpWidget(runnerHost(tableRunner, accessibility: true)); }
      if (surface == 'accessibility_answer') { accessibilityStep = Act0AccessibilityPrototypeStepV1.decision; await tester.pumpWidget(runnerHost(tableRunner, accessibility: true)); }
    } else {
      if (surface == 'review_full_shell_authority') {
        await tester.pumpWidget(
          shellHost(Act0ControlledDemoCaptureSurfaceV1.firstWeekReview),
        );
        await tester.pumpAndSettle();
      } else {
      reviewStage = 'list';
      await tester.pumpWidget(reviewHost());
      await tester.pumpAndSettle();
      if (surface != 'review_list') {
        await tester.tap(find.byKey(const Key('act0_shell_review_practice_cta')));
        await tester.pumpAndSettle();
      }
      if (surface == 'review_feedback') { reviewStage = 'feedback'; await tester.pumpWidget(reviewHost()); }
      if (surface == 'review_return_updated') { reviewStage = 'updated'; await tester.pumpWidget(reviewHost()); }
      }
    }
    await tester.pumpAndSettle();
    verifyMechanicalState(surface);
    writeBounds(surface);
    writeTextRepairOverlays(surface);
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('act0_real_text_capture_boundary')));
    final data = await tester.runAsync(() async => (await boundary.toImage(pixelRatio: 2)).toByteData(format: ui.ImageByteFormat.png));
    File('\${outputDir.path}/$device.\$surface.png').writeAsBytesSync(Uint8List.view(data!.buffer));
  }

  setUpAll(loadFont);
  testWidgets('capture targeted real-text $group lane', (bindingTester) async {
    tester = bindingTester;
    tester.view.physicalSize = viewport; tester.view.devicePixelRatio = 1;
    addTearDown(() { tester.view.resetPhysicalSize(); tester.view.resetDevicePixelRatio(); });
$captureCalls
    File('\${outputDir.path}/bounds.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schema': 'targeted_pre_human_qa_bounds_v1', 'viewport': <String, num>{'width': 402, 'height': 874}, 'safe_area': <String, num>{'top': 59, 'bottom': 34}, 'screens': bounds}) + '\\n');
    File('\${outputDir.path}/visual_ledger.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schema': 'targeted_pre_human_qa_visual_ledger_v1', 'lane': captureGroup, 'claim_boundary': 'mechanical visual review only; not Human QA approval', 'screens': <Object?>[for (final surface in bounds.keys) <String, Object?>{'screen': surface, 'mechanical': 'PASS', 'visual_review_notes': 'Real-text production widget capture.', 'unresolved_risk': 'Human visual review remains required.'}]}) + '\\n');
  });
}
''';
}

String _activeRouteFlutterTestSource(
  String outputDirPath,
  String group,
  String device,
  List<_ActiveRouteCaptureSurfaceV1> captures,
) {
  final escapedOutputDir = jsonEncode(outputDirPath);
  final captureStatements = captures.indexed.map((entry) {
    final index = entry.$1;
    final capture = entry.$2;
    final fileName = '$device.${capture.name}.png';
    return '''
    await captureActiveRouteSurface(
      tester,
      '$fileName',
      world: ${capture.world},
      taskIndex: ${capture.taskIndex},
      captureKind: '${capture.captureKind}',
      captureOrder: ${index + 1},
    );''';
  }).join();
  return '''
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w8_stack_depth_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w9_tournament_pressure_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w11_board_texture_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w12_review_decision_hidden_runtime_session_owner_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const outputDirPath = $escapedOutputDir;
  const captureGroup = '$group';
  final outputDir = Directory(outputDirPath)..createSync(recursive: true);
  final activeRouteEntries = <Map<String, Object?>>[];
  const viewportSizes = <String, Size>{
    'compact': Size(375, 812),
    'tablet': Size(834, 1194),
  };
  final viewportSize = viewportSizes['$device']!;
  final copyDetailSize = viewportSize;

  _TerminalTaskSpecV1 _terminalTaskSpec(int taskIndex) {
    final pack = kCampaignPacksV1['volume_i_terminal_review_v1']!;
    final step = pack[taskIndex];
    final expected = step.expectedSeatIds.isEmpty
        ? 'terminal_review'
        : step.expectedSeatIds.first;
    return _TerminalTaskSpecV1(
      worldId: 'world_12_terminal',
      lessonId: 'volume_i_terminal_review_v1',
      taskId: taskIndex == 0
          ? 'volume_i_terminal_review'
          : 'terminal_no_w13_state',
      conceptFamilyId: 'volume_i_terminal_review',
      boardContext: step.contextText ?? step.hint,
      learningPurpose: step.insightText ?? step.hint,
      expectedChoiceId: expected,
      choiceIds: <String>[
        expected,
        'expect_w13',
        'expect_new_world',
        'skip_review',
      ],
      learnerPrompt: step.prompt,
      choiceLabels: <String, String>{
        expected: taskIndex == 3
            ? 'Volume I complete'
            : expected == 'btn'
            ? 'Start the keep-sharp review.'
            : 'Stay in Volume I review.',
        'expect_w13': 'Expect W13 to open now.',
        'expect_new_world': 'Treat this as a new world.',
        'skip_review': 'Skip the review state.',
      },
      feedbackReason:
          '\${step.contextText ?? ''} \${step.tradeoffText ?? ''} \${step.insightText ?? ''}'.trim(),
    );
  }

  dynamic activeTaskSpecFor({required int world, required int taskIndex}) {
    final specs = switch (world) {
      7 => const Act0W7VisibleAceHiddenRuntimeSessionOwnerV1().taskSpecs,
      8 => const Act0W8StackDepthHiddenRuntimeSessionOwnerV1().taskSpecs,
      9 => const Act0W9TournamentPressureHiddenRuntimeSessionOwnerV1()
          .taskSpecs,
      10 => const Act0W10BetPurposeHiddenRuntimeSessionOwnerV1().taskSpecs,
      11 => const Act0W11BoardTextureHiddenRuntimeSessionOwnerV1().taskSpecs,
      12 => const Act0W12ReviewDecisionHiddenRuntimeSessionOwnerV1().taskSpecs,
      _ => null,
    };
    if (specs == null) {
      return _terminalTaskSpec(taskIndex);
    }
    return specs[taskIndex];
  }

  String humanRepairFocusLabelForConceptFamily(String conceptFamilyId) {
    const knownLabels = <String, String>{
      'w7_combo_density_visible_card_removal': 'Visible cards',
      'w8_stack_depth_risk_control': 'Stack depth risk',
      'w9_tournament_pressure_risk_premium': 'Tournament pressure',
      'w10_bet_purpose_value_bluff': 'Bet purpose',
      'w11_board_texture_danger_awareness': 'Board texture',
      'w12_review_decision_intuition': 'Review clue',
      'volume_i_terminal_review': 'Volume I review',
    };
    final id = conceptFamilyId.trim();
    final known = knownLabels[id];
    if (known != null) {
      return known;
    }
    final withoutWorldPrefix = id.replaceFirst(RegExp(r'^w\d+_'), '');
    final words = withoutWorldPrefix
        .split('_')
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) {
      return 'Route clue';
    }
    return words
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  List<Act0RunnerOptionV1> optionsForTask(dynamic task) {
    final ids = task.choiceIds as List<String>;
    final labels = task.choiceLabels as Map<String, String>;
    return ids.map((id) {
      final correct = id == task.expectedChoiceId;
      return Act0RunnerOptionV1(
        id: id,
        label: labels[id] ?? id,
        isCorrect: correct,
        preferredLabel: labels[task.expectedChoiceId] ?? task.expectedChoiceId,
        quality: correct ? Act0FeedbackQualityV1.correct : Act0FeedbackQualityV1.wrong,
	        feedbackTitle: correct ? 'Good route read.' : 'Use the route clue.',
	        feedbackReason: correct
	            ? task.feedbackReason as String
	            : 'Look for the table clue first: \${task.learningPurpose}.',
        repairFocusLabels: <String>[
          humanRepairFocusLabelForConceptFamily(task.conceptFamilyId as String),
          task.boardContext as String,
        ],
      );
    }).toList(growable: false);
  }

  String worldTitleForTask(dynamic task) {
	    final worldId = task.worldId as String;
	    if (worldId.contains('terminal')) {
	      return 'Volume I review';
	    }
	    final number = worldId.replaceAll('world_', '');
	    return 'World \$number practice';
	  }

  List<Act0CardStateV1> boardCardsForWorld(String worldId, String taskId) {
    if (worldId == 'world_7') {
      return const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 's'),
        Act0CardStateV1(rank: '7', suit: 'd', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '2', suit: 'c'),
      ];
    }
    if (worldId == 'world_8') {
      return const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '8', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '3', suit: 'c'),
      ];
    }
    if (worldId == 'world_9') {
      return const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '9', suit: 'c'),
        Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
      ];
    }
    if (worldId == 'world_10') {
      return const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'Q', suit: 's'),
        Act0CardStateV1(rank: '8', suit: 'd', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '2', suit: 'c'),
      ];
    }
    if (worldId == 'world_11') {
      return const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '9', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '8', suit: 'c'),
      ];
    }
    return const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 's'),
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: 'T', suit: 's'),
    ];
  }

  Act0TableStateV1 tableForTask(dynamic task, {required String captureKind}) {
    final worldId = task.worldId as String;
    final cards = boardCardsForWorld(worldId, task.taskId as String);
    return Act0TableStateV1(
      tableFormat: Act0TableFormatV1.sixMax,
      playerCount: 6,
      seats: const <Act0SeatStateV1>[
        Act0SeatStateV1(seatId: 'utg', seatLabel: 'UTG', displayName: 'UTG'),
        Act0SeatStateV1(seatId: 'hj', seatLabel: 'HJ', displayName: 'Hijack'),
        Act0SeatStateV1(seatId: 'co', seatLabel: 'CO', displayName: 'Cutoff'),
        Act0SeatStateV1(
          seatId: 'btn',
          seatLabel: 'BTN',
          displayName: 'Button',
          isHero: true,
          isDealerButton: true,
          isActive: true,
          cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
          holeCards: <Act0CardStateV1>[
            Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
            Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
          ],
        ),
        Act0SeatStateV1(
          seatId: 'sb',
          seatLabel: 'SB',
          displayName: 'Small blind',
          isSmallBlind: true,
          blindAmountLabel: '0.5 BB',
        ),
        Act0SeatStateV1(
          seatId: 'bb',
          seatLabel: 'BB',
          displayName: 'Big blind',
          isBigBlind: true,
          blindAmountLabel: '1 BB',
        ),
      ],
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
      ],
      boardCards: cards,
      streetLabel: worldId.contains('terminal') ? 'Review' : 'Flop',
      potLabel: worldId == 'world_9' ? 'Pot 18 BB' : 'Pot 12 BB',
      toCallLabel: worldId == 'world_9' ? 'Call 3 BB' : '',
      centerLabel: task.boardContext as String,
      focusCalloutLabel: task.learningPurpose as String,
      activeSeatId: 'btn',
      heroSeatId: 'btn',
      highlightedSeatIds: const <String>['btn'],
      highlightedCardIds: captureKind == 'copy_detail'
          ? const <String>[]
          : const <String>['board_0', 'board_1'],
      actionTrail: <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: task.learningPurpose as String),
      ],
    );
  }

  Act0RunnerStateV1 runnerFromTaskSpec(
    dynamic task, {
    required String captureKind,
  }) {
    final selectedOptionId = captureKind == 'copy_detail'
        ? task.expectedChoiceId as String
        : null;
    final copyDetailQuestion =
        '\${task.learnerPrompt}\\n\\nWhy this route step matters: \${task.learningPurpose}\\n\\nContext: \${task.boardContext}';
    return Act0RunnerStateV1(
      lessonId: task.lessonId as String,
      lessonTitle: worldTitleForTask(task),
      lessonSubtitle: task.learningPurpose as String,
      beatIndex: (task.taskId as String).contains('terminal_no_w13') ? 4 : 1,
      beatCount: 4,
      phase: captureKind == 'copy_detail'
          ? Act0LessonPhaseV1.review
          : Act0LessonPhaseV1.drill,
      caption: task.boardContext as String,
      hint: task.learningPurpose as String,
      question: captureKind == 'copy_detail'
          ? copyDetailQuestion
          : task.learnerPrompt as String,
      options: optionsForTask(task),
      selectedOptionId: selectedOptionId,
      feedbackTitle: captureKind == 'copy_detail'
          ? 'Full route-copy detail'
          : 'Active route task',
      feedbackReason: task.feedbackReason as String,
      primaryCtaLabel: captureKind == 'copy_detail' ? 'Continue review' : 'Choose',
      nextLessonId: null,
      returnTarget: 'learn',
      table: tableForTask(task, captureKind: captureKind),
      hintPolicy: Act0HintPolicyV1.always,
      sharky: const Act0SharkyCueV1(
        preSessionLine: 'Read the active route spot.',
        correctReaction: 'Route clue connected.',
        wrongReaction: 'Use the visible clue before choosing.',
        repairLine: 'Slow down and name the clue.',
        summaryLine: 'The route step stays visible.',
      ),
    );
  }

  Widget host({
    required dynamic task,
    required int world,
    required String captureKind,
  }) {
    final runner = runnerFromTaskSpec(task, captureKind: captureKind);
    final realTextButtonStyle = ButtonStyle(
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'Roboto'),
      ),
    );
    return MaterialApp(
      locale: const Locale('en'),
      theme: ThemeData(
        fontFamily: 'Roboto',
        filledButtonTheme: FilledButtonThemeData(style: realTextButtonStyle),
        outlinedButtonTheme: OutlinedButtonThemeData(style: realTextButtonStyle),
        textButtonTheme: TextButtonThemeData(style: realTextButtonStyle),
      ),
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: RepaintBoundary(
        key: const Key('act0_real_text_capture_boundary'),
        child: Scaffold(
          backgroundColor: const Color(0xFF070B12),
          body: SafeArea(
            child: Act0LessonRunnerShellV1(
              runner: runner,
              worldNumber: world,
              selectedWorldId: task.worldId as String,
              selectedLessonId: task.lessonId as String,
              selectedTaskId: task.taskId as String,
              selectedTaskFamily: captureKind == 'copy_detail'
                  ? Act0TaskFamilyV1.review
                  : Act0TaskFamilyV1.decision,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              relaxTheoryAdvanceLock: true,
              showLearningRailFocusLabels: true,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loadFontFamily(String family, Uint8List bytes) async {
    final loader = FontLoader(family)
      ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load().timeout(const Duration(seconds: 10));
  }

  Future<void> loadRealTextFont() async {
    const candidates = <String>[
      '/System/Library/Fonts/Supplemental/Arial.ttf',
      '/System/Library/Fonts/SFNS.ttf',
    ];
    for (final path in candidates) {
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      final bytes = await file.readAsBytes();
      await loadFontFamily('Roboto', bytes);
      await loadFontFamily('Ahem', bytes);
      return;
    }
    throw StateError('No local real-text font found for active route capture.');
  }

  Future<void> loadIconFonts() async {
    const iconFonts = <(String, String)>[
      ('MaterialIcons', 'build/unit_test_assets/fonts/MaterialIcons-Regular.otf'),
      ('CupertinoIcons', 'build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('packages/cupertino_icons/CupertinoIcons', 'build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('MaterialIcons', 'build/flutter_assets/fonts/MaterialIcons-Regular.otf'),
      ('CupertinoIcons', 'build/flutter_assets/packages/cupertino_icons/assets/cupertino_icons.ttf'),
      ('CupertinoIcons', 'build/flutter_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('packages/cupertino_icons/CupertinoIcons', 'build/flutter_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
    ];
    final loaded = <String>{};
    for (final (family, path) in iconFonts) {
      if (loaded.contains(family)) {
        continue;
      }
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      final bytes = await file.readAsBytes();
      await loadFontFamily(family, bytes);
      loaded.add(family);
    }
    if (!loaded.contains('MaterialIcons')) {
      throw StateError('No local MaterialIcons font found for active route capture.');
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  setUpAll(() async {
    await loadRealTextFont();
    await loadIconFonts();
  });

  String colorToHex(Color color) {
    final alpha = (color.a * 255).round().clamp(0, 255);
    final red = (color.r * 255).round().clamp(0, 255);
    final green = (color.g * 255).round().clamp(0, 255);
    final blue = (color.b * 255).round().clamp(0, 255);
    return '#'
        '\${alpha.toRadixString(16).padLeft(2, '0')}'
        '\${red.toRadixString(16).padLeft(2, '0')}'
        '\${green.toRadixString(16).padLeft(2, '0')}'
        '\${blue.toRadixString(16).padLeft(2, '0')}';
  }

  void writeTextRepairOverlays(WidgetTester tester, String fileName) {
    final overlays = <Map<String, Object?>>[];
    for (final element in find.byType(Text).evaluate()) {
      final widget = element.widget;
      if (widget is! Text) {
        continue;
      }
      final text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
      if (text.trim().isEmpty) {
        continue;
      }
      final defaultStyle = DefaultTextStyle.of(element).style;
      final explicitStyle = widget.style;
      if (defaultStyle.fontFamily != null || explicitStyle?.fontFamily != null) {
        continue;
      }
      final renderObject = element.renderObject;
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        continue;
      }
      final topLeft = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;
      if (size.width <= 0 || size.height <= 0) {
        continue;
      }
      overlays.add(<String, Object?>{
        'text': text,
        'left': topLeft.dx,
        'top': topLeft.dy,
        'width': size.width,
        'height': size.height,
        'fontSize': (explicitStyle?.fontSize ?? defaultStyle.fontSize ?? 14),
        'fontWeight': (explicitStyle?.fontWeight ?? defaultStyle.fontWeight ?? FontWeight.w400).value,
        'color': colorToHex(explicitStyle?.color ?? defaultStyle.color ?? Colors.white),
      });
    }
    final overlayFile = File('\${outputDir.path}/' + fileName + '.text_overlays.json');
    overlayFile.writeAsStringSync(jsonEncode(overlays));
  }

  Future<void> captureActiveRouteSurface(
    WidgetTester tester,
    String fileName, {
    required int world,
    required int taskIndex,
    required String captureKind,
    required int captureOrder,
  }) async {
    final task = activeTaskSpecFor(world: world, taskIndex: taskIndex);
    final size = captureKind == 'copy_detail' ? copyDetailSize : viewportSize;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      host(task: task, world: world, captureKind: captureKind),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    writeTextRepairOverlays(tester, fileName);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('act0_real_text_capture_boundary')),
    );
    final byteData = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2.0);
      return image.toByteData(format: ui.ImageByteFormat.png);
    });
    if (byteData == null) {
      throw StateError('Failed to capture active route screenshot for ' + fileName);
    }
    final file = File('\${outputDir.path}/' + fileName);
    file.writeAsBytesSync(Uint8List.view(byteData.buffer));
    activeRouteEntries.add(<String, Object?>{
      'file': fileName,
      'capture_order': captureOrder,
      'world': world,
      'task_index': taskIndex,
      'task_id': task.taskId as String,
      'lesson_id': task.lessonId as String,
      'capture_kind': captureKind,
      'capture_mode': 'active_act0_runtime_test_only_wrapper',
      'active_surface': 'Act0LessonRunnerShellV1',
      'visual_audit_validity': 'active_runtime_visual_evidence',
      'final_visual_audit_eligible': true,
      'invalid_for_final_visual_ux_judgment': false,
      'allowed_use': 'final_pre_human_visual_ux_audit',
      'legacy_archive_runner_used': false,
    });
  }

  testWidgets('capture active real-text W7-W12 route surfaces', (tester) async {
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.resetSystemFontFamily();
    });

$captureStatements
    File('\${outputDir.path}/active_route_w7_w12_meta.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'schema': 'active_route_w7_w12_screen_evidence_v1',
        'device': '$device',
        'capture_group': captureGroup,
        'scenario_family': 'active_runtime_late_route_w7_w12_visual_coverage',
        'content_reflects_latest_post_idealization_copy': true,
        'visual_audit_validity': 'active_runtime_visual_evidence',
        'final_visual_audit_eligible': true,
        'invalid_for_final_visual_ux_judgment': false,
        'allowed_use': 'final_pre_human_visual_ux_audit',
        'capture_source_policy': 'active_act0_runtime_test_only_wrapper',
        'active_surface': 'Act0LessonRunnerShellV1',
        'legacy_archive_runner_used': false,
        'entries': activeRouteEntries,
        'note': 'Generated metadata is local-only and uncommitted.',
      }) + '\\n',
    );
  });
}

class _TerminalTaskSpecV1 {
  const _TerminalTaskSpecV1({
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.conceptFamilyId,
    required this.boardContext,
    required this.learningPurpose,
    required this.expectedChoiceId,
    required this.choiceIds,
    required this.learnerPrompt,
    required this.choiceLabels,
    required this.feedbackReason,
  });

  final String worldId;
  final String lessonId;
  final String taskId;
  final String conceptFamilyId;
  final String boardContext;
  final String learningPurpose;
  final String expectedChoiceId;
  final List<String> choiceIds;
  final String learnerPrompt;
  final Map<String, String> choiceLabels;
  final String feedbackReason;
}
''';
}

String _routeFlutterTestSource(
  String outputDirPath,
  String group,
  String device,
  List<_RouteCaptureSurfaceV1> captures,
) {
  final escapedOutputDir = jsonEncode(outputDirPath);
  final captureStatements = captures.indexed.map((entry) {
    final index = entry.$1;
    final capture = entry.$2;
    final fileName = '$device.${capture.name}.png';
    return '''
    await captureRouteSurface(
      tester,
      '$fileName',
      packId: '${capture.packId}',
      moduleTitle: ${jsonEncode(capture.moduleTitle)},
      startHandIndex: ${capture.startHandIndex},
      captureOrder: ${index + 1},
    );''';
  }).join();
  return '''
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/archive/legacy_runners/world1_foundations_microtask_runner_surface_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const outputDirPath = $escapedOutputDir;
  const captureGroup = '$group';
  final outputDir = Directory(outputDirPath)..createSync(recursive: true);
  final routeEntries = <Map<String, Object?>>[];
  const compactSize = Size(375, 812);

  Widget host({
    required String packId,
    required String moduleTitle,
    required int startHandIndex,
  }) {
    final realTextButtonStyle = ButtonStyle(
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'Roboto'),
      ),
    );
    return MaterialApp(
      locale: const Locale('en'),
      theme: ThemeData(
        fontFamily: 'Roboto',
        filledButtonTheme: FilledButtonThemeData(style: realTextButtonStyle),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: realTextButtonStyle,
        ),
        textButtonTheme: TextButtonThemeData(style: realTextButtonStyle),
      ),
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: RepaintBoundary(
        key: const Key('act0_real_text_capture_boundary'),
        child: World1FoundationsMicroTaskRunnerScreen(
          key: UniqueKey(),
          moduleId: packId,
          moduleTitle: moduleTitle,
          mode: kWorld1RunnerModeCampaignSpine,
          startHandIndex: startHandIndex,
          hintsEnabledV1: true,
        ),
      ),
    );
  }

  Future<void> loadFontFamily(String family, Uint8List bytes) async {
    final loader = FontLoader(family)
      ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load().timeout(const Duration(seconds: 10));
  }

  Future<void> loadRealTextFont() async {
    const candidates = <String>[
      '/System/Library/Fonts/Supplemental/Arial.ttf',
      '/System/Library/Fonts/SFNS.ttf',
    ];
    for (final path in candidates) {
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      final bytes = await file.readAsBytes();
      await loadFontFamily('Roboto', bytes);
      await loadFontFamily('Ahem', bytes);
      return;
    }
    throw StateError('No local real-text font found for route capture.');
  }

  Future<void> loadIconFonts() async {
    const iconFonts = <(String, String)>[
      ('MaterialIcons', 'build/unit_test_assets/fonts/MaterialIcons-Regular.otf'),
      ('CupertinoIcons', 'build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('packages/cupertino_icons/CupertinoIcons', 'build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('MaterialIcons', 'build/flutter_assets/fonts/MaterialIcons-Regular.otf'),
      ('CupertinoIcons', 'build/flutter_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('packages/cupertino_icons/CupertinoIcons', 'build/flutter_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
    ];
    final loaded = <String>{};
    for (final (family, path) in iconFonts) {
      if (loaded.contains(family)) {
        continue;
      }
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      final bytes = await file.readAsBytes();
      await loadFontFamily(family, bytes);
      loaded.add(family);
    }
    if (!loaded.contains('MaterialIcons')) {
      throw StateError('No local MaterialIcons font found for route capture.');
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  setUpAll(() async {
    await loadRealTextFont();
    await loadIconFonts();
  });

  Future<void> pumpCompact(
    WidgetTester tester, {
    required String packId,
    required String moduleTitle,
    required int startHandIndex,
  }) async {
    tester.view.physicalSize = compactSize;
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      host(
        packId: packId,
        moduleTitle: moduleTitle,
        startHandIndex: startHandIndex,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
  }

  String colorToHex(Color color) {
    final alpha = (color.a * 255).round().clamp(0, 255);
    final red = (color.r * 255).round().clamp(0, 255);
    final green = (color.g * 255).round().clamp(0, 255);
    final blue = (color.b * 255).round().clamp(0, 255);
    return '#'
        '\${alpha.toRadixString(16).padLeft(2, '0')}'
        '\${red.toRadixString(16).padLeft(2, '0')}'
        '\${green.toRadixString(16).padLeft(2, '0')}'
        '\${blue.toRadixString(16).padLeft(2, '0')}';
  }

  void writeTextRepairOverlays(WidgetTester tester, String fileName) {
    final overlays = <Map<String, Object?>>[];
    for (final element in find.byType(Text).evaluate()) {
      final widget = element.widget;
      if (widget is! Text) {
        continue;
      }
      final text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
      if (text.trim().isEmpty) {
        continue;
      }
      final defaultStyle = DefaultTextStyle.of(element).style;
      final explicitStyle = widget.style;
      if (defaultStyle.fontFamily != null || explicitStyle?.fontFamily != null) {
        continue;
      }
      final renderObject = element.renderObject;
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        continue;
      }
      final topLeft = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;
      if (size.width <= 0 || size.height <= 0) {
        continue;
      }
      overlays.add(<String, Object?>{
        'text': text,
        'left': topLeft.dx,
        'top': topLeft.dy,
        'width': size.width,
        'height': size.height,
        'fontSize': (explicitStyle?.fontSize ?? defaultStyle.fontSize ?? 14),
        'fontWeight': (explicitStyle?.fontWeight ?? defaultStyle.fontWeight ?? FontWeight.w400).value,
        'color': colorToHex(explicitStyle?.color ?? defaultStyle.color ?? Colors.white),
      });
    }
    final overlayFile = File('\${outputDir.path}/' + fileName + '.text_overlays.json');
    overlayFile.writeAsStringSync(jsonEncode(overlays));
  }

  Future<void> captureRouteSurface(
    WidgetTester tester,
    String fileName, {
    required String packId,
    required String moduleTitle,
    required int startHandIndex,
    required int captureOrder,
  }) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpCompact(
      tester,
      packId: packId,
      moduleTitle: moduleTitle,
      startHandIndex: startHandIndex,
    );
    final preludeContinue = find.byKey(
      const Key('microtask_prelude_continue_cta_v1'),
    );
    if (preludeContinue.evaluate().isNotEmpty) {
      await tester.tap(preludeContinue, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }
    final detailsIcon = find.byIcon(Icons.info_outline_rounded);
    if (detailsIcon.evaluate().isNotEmpty) {
      await tester.tap(detailsIcon.first, warnIfMissed: false);
      await tester.pumpAndSettle();
    } else {
      final detailsButtons = find.text('Details');
      if (detailsButtons.evaluate().isNotEmpty) {
        await tester.tap(detailsButtons.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    }
    writeTextRepairOverlays(tester, fileName);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('act0_real_text_capture_boundary')),
    );
    final byteData = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2.0);
      return image.toByteData(format: ui.ImageByteFormat.png);
    });
    if (byteData == null) {
      throw StateError('Failed to capture route screenshot for ' + fileName);
    }
    final file = File('\${outputDir.path}/' + fileName);
    file.writeAsBytesSync(Uint8List.view(byteData.buffer));
    routeEntries.add(<String, Object?>{
      'file': fileName,
      'capture_order': captureOrder,
      'pack_id': packId,
      'module_title': moduleTitle,
      'start_hand_index': startHandIndex,
      'capture_mode': 'route_pack_direct_runner_fixture',
    });
  }

  testWidgets('capture real-text route W7-W12 review surfaces', (tester) async {
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.resetSystemFontFamily();
    });

$captureStatements
    File('\${outputDir.path}/route_w7_w12_meta.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'schema': 'route_w7_w12_screen_evidence_v1',
        'device': '$device',
        'capture_group': captureGroup,
        'scenario_family': 'late_route_w7_w12_visual_coverage',
        'content_reflects_latest_post_idealization_copy': true,
        'visual_audit_validity': '$_routeVisualAuditValidityV1',
        'final_visual_audit_eligible': false,
        'invalid_for_final_visual_ux_judgment': true,
        'allowed_use': '$_routeAllowedUseV1',
        'capture_source_policy': 'legacy_reference_not_for_audit',
        'capture_mode': 'route_pack_direct_runner_fixture',
        'entries': routeEntries,
        'note': 'Generated metadata is local-only and uncommitted.',
      }) + '\\n',
    );
  });
}
''';
}

void _printUsageV1() {
  stderr.writeln(
    'Usage: dart run tools/act0_real_text_surface_capture_v1.dart <alpha_journey|core|runner|first_week|day2_return|profile_evidence|full_scroll|route_w7_w12|active_route_w7_w12> <compact|tall_phone|large_phone|tablet>',
  );
}
