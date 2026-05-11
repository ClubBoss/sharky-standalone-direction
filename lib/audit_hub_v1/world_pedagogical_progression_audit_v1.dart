import 'dart:convert';
import 'dart:io';

const worldPedagogicalProgressionAuditToolPathV1 =
    'tools/world_pedagogical_progression_audit_v1.dart';
const progressionPrerequisiteMatrixPathV1 =
    'docs/plan/PROGRESSION_PREREQUISITE_MATRIX_v1.md';
const worldPedagogicalProgressionAuditSourcePathV1 =
    'lib/audit_hub_v1/world_pedagogical_progression_audit_v1.dart';

enum PedagogicalProgressionTruthStatusV1 {
  clear('clear'),
  surfacedGap('surfaced_gap'),
  groundedDataLimited('grounded_data_limited');

  const PedagogicalProgressionTruthStatusV1(this.wireValue);

  final String wireValue;
}

class PedagogicalProgressionFindingV1 {
  const PedagogicalProgressionFindingV1({
    required this.gapId,
    required this.worldScope,
    required this.category,
    required this.currentStatus,
    required this.admissibility,
    required this.likelySeam,
    required this.ownerFiles,
    required this.measurableProofPath,
    required this.blockers,
    required this.evPriorityOrder,
    required this.reason,
  });

  final String gapId;
  final List<String> worldScope;
  final String category;
  final String currentStatus;
  final String admissibility;
  final String likelySeam;
  final List<String> ownerFiles;
  final List<String> measurableProofPath;
  final List<String> blockers;
  final int evPriorityOrder;
  final String reason;

  Map<String, Object?> toJson() => <String, Object?>{
    'gap_id': gapId,
    'world_scope': worldScope,
    'category': category,
    'current_status': currentStatus,
    'admissibility': admissibility,
    'likely_seam': likelySeam,
    'owner_files': ownerFiles,
    'measurable_proof_path': measurableProofPath,
    'blockers': blockers,
    'ev_priority_order': evPriorityOrder,
    'reason': reason,
  };
}

class WorldPedagogicalProgressionReportV1 {
  const WorldPedagogicalProgressionReportV1({
    required this.worldId,
    required this.status,
    required this.progressionCorrectnessStatus,
    required this.wrongAnswerFeedbackQualityStatus,
    required this.introFramingOnboardingQualityStatus,
    required this.sessionDrillSemanticFitStatus,
    required this.worldPedagogicalFinishStatus,
    required this.summary,
    required this.findings,
    required this.ownerFiles,
    required this.measurableProofPath,
    required this.blockingGaps,
  });

  final String worldId;
  final PedagogicalProgressionTruthStatusV1 status;
  final PedagogicalProgressionTruthStatusV1 progressionCorrectnessStatus;
  final PedagogicalProgressionTruthStatusV1 wrongAnswerFeedbackQualityStatus;
  final PedagogicalProgressionTruthStatusV1 introFramingOnboardingQualityStatus;
  final PedagogicalProgressionTruthStatusV1 sessionDrillSemanticFitStatus;
  final PedagogicalProgressionTruthStatusV1 worldPedagogicalFinishStatus;
  final String summary;
  final List<PedagogicalProgressionFindingV1> findings;
  final List<String> ownerFiles;
  final List<String> measurableProofPath;
  final List<String> blockingGaps;

  Map<String, Object?> toJson() => <String, Object?>{
    'world_id': worldId,
    'status': status.wireValue,
    'progression_correctness_status': progressionCorrectnessStatus.wireValue,
    'wrong_answer_feedback_quality_status':
        wrongAnswerFeedbackQualityStatus.wireValue,
    'intro_framing_onboarding_quality_status':
        introFramingOnboardingQualityStatus.wireValue,
    'session_drill_semantic_fit_status':
        sessionDrillSemanticFitStatus.wireValue,
    'world_pedagogical_finish_status': worldPedagogicalFinishStatus.wireValue,
    'summary': summary,
    'findings': findings.map((finding) => finding.toJson()).toList(),
    'owner_files': ownerFiles,
    'measurable_proof_path': measurableProofPath,
    'blocking_gaps': blockingGaps,
  };
}

const Map<String, int> _kEarliestWorldAnchorByKindV1 = <String, int>{
  'action_choice': 2,
  'bet_sizing_choice_v1': 3,
  'board_texture_classifier_v1': 3,
  'range_bucket_classifier_v1': 3,
  'initiative_aggressor_choice_v1': 3,
  'position_thinking_choice_v1': 3,
  'outs_count_choice_v1': 4,
  'hand_chain_v1': 5,
};

const Map<String, List<String>> _kSessionSemanticKeywordsByKindV1 =
    <String, List<String>>{
      'seat_tap': <String>[
        'seat',
        'blind',
        'button',
        'dealer',
        'acting seat',
        'layout',
        'position',
      ],
      'action_choice': <String>[
        'action',
        'fold',
        'call',
        'raise',
        'check',
        'bet',
        'button',
      ],
      'board_tap': <String>['board', 'flop', 'turn', 'river', 'street'],
      'hole_cards_tap': <String>['hole card', 'card', 'hand'],
      'card_tap': <String>['card', 'hand'],
      'bet_sizing_choice_v1': <String>['size', 'bet', 'pot', 'raise'],
      'board_texture_classifier_v1': <String>[
        'texture',
        'board',
        'draw',
        'wet',
        'dry',
        'paired',
        'connected',
      ],
      'range_bucket_classifier_v1': <String>['range', 'hand', 'bucket'],
      'initiative_aggressor_choice_v1': <String>[
        'aggressor',
        'initiative',
        'pressure',
      ],
      'position_thinking_choice_v1': <String>[
        'position',
        'order',
        'later',
        'act',
      ],
      'outs_count_choice_v1': <String>['outs', 'draw', 'cards', 'improve'],
      'showdown_winner_choice_v1': <String>[
        'winner',
        'showdown',
        'best hand',
        'hand',
      ],
      'hand_chain_v1': <String>['sequence', 'order', 'street', 'then', 'chain'],
    };

List<WorldPedagogicalProgressionReportV1>
buildWorldPedagogicalProgressionReportsV1({
  String rootPath = '.',
  required List<Map<String, Object?>> worlds,
}) {
  final selectedWorlds = worlds.toList(growable: false)
    ..sort(
      (left, right) =>
          _parseWorldNumberFromWorldIdV1(
            left['world_id'] as String? ?? '',
          ).compareTo(
            _parseWorldNumberFromWorldIdV1(right['world_id'] as String? ?? ''),
          ),
    );
  return selectedWorlds
      .map(
        (world) => buildWorldPedagogicalProgressionReportV1(
          rootPath: rootPath,
          worldSnapshot: world,
        ),
      )
      .toList(growable: false);
}

WorldPedagogicalProgressionReportV1 buildWorldPedagogicalProgressionReportV1({
  String rootPath = '.',
  required Map<String, Object?> worldSnapshot,
}) {
  final worldId = worldSnapshot['world_id'] as String? ?? 'unknown';
  final worldNumber = _parseWorldNumberFromWorldIdV1(worldId);
  final worldLabel = 'world$worldNumber';
  final sessionsRoot = Directory(
    '$rootPath/content/worlds/$worldLabel/v1/sessions',
  );
  final worldMarkdownPath = 'content/worlds/$worldLabel/v1/world.md';
  final sessionsIndexPath = 'content/worlds/$worldLabel/v1/sessions/index.md';
  final ownerFiles = <String>[
    worldMarkdownPath,
    sessionsIndexPath,
    progressionPrerequisiteMatrixPathV1,
    worldPedagogicalProgressionAuditSourcePathV1,
  ];
  final measurableProofPath = <String>[
    'dart run $worldPedagogicalProgressionAuditToolPathV1 --world=$worldNumber --json',
    'dart run tools/audit_hub_refresh_v1.dart --timestamp <UTC_ISO>',
  ];

  final drillFiles = <File>[
    if (sessionsRoot.existsSync())
      ...sessionsRoot
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .where(
            (file) => file.path.contains(
              '${Platform.pathSeparator}drills${Platform.pathSeparator}',
            ),
          ),
  ];
  final drillMaps = <Map<String, Object?>>[];
  final drillKindCounts = <String, int>{};
  var strategicActionChoiceCount = 0;
  var missingFeedbackCount = 0;
  for (final file in drillFiles) {
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map<String, Object?>) {
        continue;
      }
      drillMaps.add(decoded);
      final kind = decoded['kind'];
      if (kind is String && kind.isNotEmpty) {
        drillKindCounts[kind] = (drillKindCounts[kind] ?? 0) + 1;
        if (kind == 'action_choice' &&
            !_isFoundationalActionButtonLiteracyDrillV1(decoded)) {
          strategicActionChoiceCount += 1;
        }
      }
      if (decoded['feedback_incorrect_v1'] is! String ||
          decoded['feedback_correct_v1'] is! String) {
        missingFeedbackCount += 1;
      }
    } catch (_) {}
  }

  final findings = <PedagogicalProgressionFindingV1>[];
  final blockingGaps = <String>[];

  final progressionViolations = <String>[];
  for (final entry in _kEarliestWorldAnchorByKindV1.entries) {
    final count = entry.key == 'action_choice'
        ? strategicActionChoiceCount
        : (drillKindCounts[entry.key] ?? 0);
    if (count == 0) continue;
    if (worldNumber < entry.value) {
      progressionViolations.add(
        '${entry.key} appears in $count drill(s) before the earliest safe world anchor W${entry.value}.',
      );
    }
  }
  if (progressionViolations.isNotEmpty) {
    findings.add(
      PedagogicalProgressionFindingV1(
        gapId: 'pedagogy_${worldId.toLowerCase()}_progression_correctness_v1',
        worldScope: <String>[worldId],
        category: 'progression_correctness',
        currentStatus: 'truth_surfaced',
        admissibility: 'truth_layer_first',
        likelySeam: 'task family appears earlier than progression canon allows',
        ownerFiles: <String>[
          progressionPrerequisiteMatrixPathV1,
          sessionsIndexPath,
          worldMarkdownPath,
        ],
        measurableProofPath: <String>[
          'dart run $worldPedagogicalProgressionAuditToolPathV1 --world=$worldNumber --json',
        ],
        blockers: progressionViolations,
        evPriorityOrder: 101 + worldNumber,
        reason:
            '$worldId currently introduces one or more drill families earlier than the progression prerequisite matrix says is safely scaffolded.',
      ),
    );
    blockingGaps.addAll(progressionViolations);
  }

  final totalDrills = drillMaps.length;
  if (totalDrills > 0 && missingFeedbackCount > 0) {
    findings.add(
      PedagogicalProgressionFindingV1(
        gapId:
            'pedagogy_${worldId.toLowerCase()}_wrong_answer_feedback_quality_v1',
        worldScope: <String>[worldId],
        category: 'wrong_answer_feedback_quality',
        currentStatus: 'truth_surfaced',
        admissibility: 'truth_layer_first',
        likelySeam: 'drill feedback coverage is incomplete',
        ownerFiles: <String>[sessionsIndexPath],
        measurableProofPath: <String>[
          'dart run $worldPedagogicalProgressionAuditToolPathV1 --world=$worldNumber --json',
          'dart run tools/validate_world_content_v1.dart',
        ],
        blockers: <String>[
          '$worldId has $missingFeedbackCount / $totalDrills drill JSON files without explicit feedback_correct_v1 + feedback_incorrect_v1 coverage.',
        ],
        evPriorityOrder: 140 + worldNumber,
        reason:
            '$worldId still leaves too much wrong-answer teaching quality implicit instead of repo-owned and inspectable.',
      ),
    );
    blockingGaps.add(
      '$worldId feedback coverage is incomplete: $missingFeedbackCount / $totalDrills drill files are missing explicit wrong-answer or right-answer feedback.',
    );
  }

  final introFinding = _buildIntroFramingFindingV1(
    rootPath: rootPath,
    worldSnapshot: worldSnapshot,
    worldNumber: worldNumber,
    worldId: worldId,
    worldMarkdownPath: worldMarkdownPath,
    sessionsIndexPath: sessionsIndexPath,
  );
  if (introFinding != null) {
    findings.add(introFinding);
    blockingGaps.addAll(introFinding.blockers);
  }

  final semanticMismatchSessions = _findSemanticMismatchSessionsV1(
    sessionsRoot: sessionsRoot,
  );
  if (semanticMismatchSessions.isNotEmpty) {
    findings.add(
      PedagogicalProgressionFindingV1(
        gapId: 'pedagogy_${worldId.toLowerCase()}_session_drill_fit_v1',
        worldScope: <String>[worldId],
        category: 'session_drill_semantic_fit',
        currentStatus: 'truth_surfaced',
        admissibility: 'truth_layer_first',
        likelySeam:
            'session framing does not clearly cover all live drill families',
        ownerFiles: <String>[
          sessionsIndexPath,
          ...semanticMismatchSessions
              .map(
                (item) =>
                    'content/worlds/$worldLabel/v1/sessions/${item.sessionId}/session.md',
              )
              .take(4),
        ],
        measurableProofPath: <String>[
          'dart run $worldPedagogicalProgressionAuditToolPathV1 --world=$worldNumber --json',
        ],
        blockers: semanticMismatchSessions
            .map(
              (item) =>
                  '${item.sessionId}: missing framing for ${item.missingKinds.join(', ')}.',
            )
            .toList(growable: false),
        evPriorityOrder: 160 + worldNumber,
        reason:
            '$worldId has session surfaces where the authored session framing does not clearly teach the drill families that runtime actually asks the learner to perform.',
      ),
    );
    blockingGaps.add(
      '$worldId has ${semanticMismatchSessions.length} session(s) with session/drill teaching-fit mismatches.',
    );
  }

  final finishFinding = _buildPedagogicalFinishFindingV1(
    rootPath: rootPath,
    worldSnapshot: worldSnapshot,
    worldId: worldId,
    worldMarkdownPath: worldMarkdownPath,
    sessionsIndexPath: sessionsIndexPath,
    worldNumber: worldNumber,
    missingFeedbackCount: missingFeedbackCount,
    strategicActionChoiceCount: strategicActionChoiceCount,
    semanticMismatchSessions: semanticMismatchSessions,
  );
  if (finishFinding != null) {
    findings.add(finishFinding);
    blockingGaps.addAll(finishFinding.blockers);
  }

  final progressionStatus = progressionViolations.isNotEmpty
      ? PedagogicalProgressionTruthStatusV1.surfacedGap
      : PedagogicalProgressionTruthStatusV1.clear;
  final feedbackStatus = totalDrills == 0
      ? PedagogicalProgressionTruthStatusV1.groundedDataLimited
      : missingFeedbackCount > 0
      ? PedagogicalProgressionTruthStatusV1.surfacedGap
      : PedagogicalProgressionTruthStatusV1.clear;
  final introStatus = introFinding == null
      ? worldNumber <= 1
            ? PedagogicalProgressionTruthStatusV1.clear
            : PedagogicalProgressionTruthStatusV1.groundedDataLimited
      : PedagogicalProgressionTruthStatusV1.surfacedGap;
  final semanticStatus = !sessionsRoot.existsSync()
      ? PedagogicalProgressionTruthStatusV1.groundedDataLimited
      : semanticMismatchSessions.isNotEmpty
      ? PedagogicalProgressionTruthStatusV1.surfacedGap
      : PedagogicalProgressionTruthStatusV1.clear;
  final finishStatus = finishFinding == null
      ? PedagogicalProgressionTruthStatusV1.clear
      : PedagogicalProgressionTruthStatusV1.surfacedGap;
  final overallStatus = findings.isNotEmpty
      ? PedagogicalProgressionTruthStatusV1.surfacedGap
      : (worldNumber <= 1 || totalDrills > 0)
      ? PedagogicalProgressionTruthStatusV1.clear
      : PedagogicalProgressionTruthStatusV1.groundedDataLimited;

  final summary = findings.isEmpty
      ? '$worldId has no surfaced pedagogical/progression findings under the current bounded audit rules.'
      : '$worldId surfaces ${findings.length} pedagogical/progression finding(s) across progression, feedback, framing, semantic-fit, or pedagogical-finish truth.';

  return WorldPedagogicalProgressionReportV1(
    worldId: worldId,
    status: overallStatus,
    progressionCorrectnessStatus: progressionStatus,
    wrongAnswerFeedbackQualityStatus: feedbackStatus,
    introFramingOnboardingQualityStatus: introStatus,
    sessionDrillSemanticFitStatus: semanticStatus,
    worldPedagogicalFinishStatus: finishStatus,
    summary: summary,
    findings: findings,
    ownerFiles: ownerFiles,
    measurableProofPath: measurableProofPath,
    blockingGaps: blockingGaps,
  );
}

Map<String, Object?> buildPedagogicalProgressionTruthSummaryJsonV1({
  required List<WorldPedagogicalProgressionReportV1> reports,
}) {
  final affectedWorlds = <String>[
    for (final report in reports)
      if (report.findings.isNotEmpty) report.worldId,
  ];
  final categoryCounts = <String, int>{};
  final limitedCategories = <String>{};
  for (final report in reports) {
    for (final finding in report.findings) {
      categoryCounts[finding.category] =
          (categoryCounts[finding.category] ?? 0) + 1;
    }
    if (report.introFramingOnboardingQualityStatus ==
        PedagogicalProgressionTruthStatusV1.groundedDataLimited) {
      limitedCategories.add('intro_framing_onboarding_quality');
    }
  }
  final sortedCategories = categoryCounts.keys.toList()
    ..sort(
      (left, right) =>
          (categoryCounts[right] ?? 0).compareTo(categoryCounts[left] ?? 0),
    );
  final openFindingCount = categoryCounts.values.fold<int>(
    0,
    (sum, value) => sum + value,
  );
  final status = openFindingCount == 0
      ? PedagogicalProgressionTruthStatusV1.clear
      : PedagogicalProgressionTruthStatusV1.surfacedGap;
  final summary = openFindingCount == 0
      ? 'No pedagogical/progression findings are surfaced by the current bounded audit rules.'
      : 'Pedagogical/progression truth surfaces $openFindingCount finding(s) across ${affectedWorlds.length} world(s); top categories: ${sortedCategories.take(3).join(' | ')}.';

  return <String, Object?>{
    'status': status.wireValue,
    'source_truth_owners': <String>[
      progressionPrerequisiteMatrixPathV1,
      worldPedagogicalProgressionAuditSourcePathV1,
    ],
    'open_finding_count': openFindingCount,
    'affected_worlds': affectedWorlds,
    'category_counts': categoryCounts,
    'top_categories': sortedCategories,
    'coverage_notes': limitedCategories.isEmpty
        ? const <String>[]
        : <String>[
            'Intro / framing / onboarding quality is only explicitly audited for first-user worlds; later-world intro quality remains grounded_data_limited until stronger repo-owned heuristics or proof surfaces are added.',
          ],
    'summary': summary,
  };
}

String encodeWorldPedagogicalProgressionReportJsonV1(
  WorldPedagogicalProgressionReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

String renderWorldPedagogicalProgressionReportV1(
  WorldPedagogicalProgressionReportV1 report,
) {
  final buffer = StringBuffer()
    ..writeln('WORLD_PEDAGOGICAL_PROGRESSION_AUDIT_V1')
    ..writeln('WORLD\t${report.worldId}')
    ..writeln('STATUS\t${report.status.wireValue}')
    ..writeln(
      'PROGRESSION_CORRECTNESS\t${report.progressionCorrectnessStatus.wireValue}',
    )
    ..writeln(
      'WRONG_ANSWER_FEEDBACK_QUALITY\t${report.wrongAnswerFeedbackQualityStatus.wireValue}',
    )
    ..writeln(
      'INTRO_FRAMING_ONBOARDING_QUALITY\t${report.introFramingOnboardingQualityStatus.wireValue}',
    )
    ..writeln(
      'SESSION_DRILL_SEMANTIC_FIT\t${report.sessionDrillSemanticFitStatus.wireValue}',
    )
    ..writeln(
      'WORLD_PEDAGOGICAL_FINISH\t${report.worldPedagogicalFinishStatus.wireValue}',
    )
    ..writeln('SUMMARY\t${report.summary}');
  if (report.findings.isNotEmpty) {
    buffer.writeln('FINDINGS');
    for (final finding in report.findings) {
      buffer.writeln(
        '- ${finding.gapId}\t${finding.category}\t${finding.admissibility}\t${finding.reason}',
      );
    }
  }
  if (report.blockingGaps.isNotEmpty) {
    buffer.writeln('BLOCKERS');
    for (final gap in report.blockingGaps) {
      buffer.writeln('- $gap');
    }
  }
  return buffer.toString();
}

PedagogicalProgressionFindingV1? _buildIntroFramingFindingV1({
  required String rootPath,
  required Map<String, Object?> worldSnapshot,
  required int worldNumber,
  required String worldId,
  required String worldMarkdownPath,
  required String sessionsIndexPath,
}) {
  if (worldNumber > 1) return null;
  if (_hasExecutableWorld0OpenerFramingProofV1(
    rootPath: rootPath,
    worldNumber: worldNumber,
    worldMarkdownPath: worldMarkdownPath,
    sessionsIndexPath: sessionsIndexPath,
  )) {
    return null;
  }
  final topOpenGaps =
      (worldSnapshot['top_open_gaps'] as List<Object?>? ?? const <Object?>[])
          .whereType<String>()
          .toList();
  final releaseGradeBlockerNote =
      worldSnapshot['release_grade_blocker_note'] as String? ?? '';
  final lensStatuses = Map<String, Object?>.from(
    worldSnapshot['lens_statuses'] as Map? ?? const <String, Object?>{},
  );
  final naturalness = lensStatuses['learner_language_naturalness'] as String?;
  final shouldSurface =
      naturalness != null && naturalness != 'done' ||
      topOpenGaps.join(' | ').toLowerCase().contains('first-world polish') ||
      topOpenGaps.join(' | ').toLowerCase().contains('learner-language') ||
      releaseGradeBlockerNote.toLowerCase().contains('release-grade opener');
  if (!shouldSurface) return null;
  return PedagogicalProgressionFindingV1(
    gapId: 'pedagogy_${worldId.toLowerCase()}_intro_framing_quality_v1',
    worldScope: <String>[worldId],
    category: 'intro_framing_onboarding_quality',
    currentStatus: 'truth_surfaced',
    admissibility: 'truth_layer_first',
    likelySeam:
        'first-user framing / onboarding quality remains under release-grade finish',
    ownerFiles: <String>[worldMarkdownPath, sessionsIndexPath],
    measurableProofPath: <String>[
      'dart run $worldPedagogicalProgressionAuditToolPathV1 --world=$worldNumber --json',
    ],
    blockers: <String>[
      if (topOpenGaps.isNotEmpty) ...topOpenGaps,
      if (releaseGradeBlockerNote.isNotEmpty) releaseGradeBlockerNote,
    ],
    evPriorityOrder: 180 + worldNumber,
    reason:
        '$worldId is on the first-user path, but current world truth still marks its framing/language finish as not fully release-grade.',
  );
}

PedagogicalProgressionFindingV1? _buildPedagogicalFinishFindingV1({
  required String rootPath,
  required Map<String, Object?> worldSnapshot,
  required String worldId,
  required String worldMarkdownPath,
  required String sessionsIndexPath,
  required int worldNumber,
  required int missingFeedbackCount,
  required int strategicActionChoiceCount,
  required List<_SemanticMismatchSessionV1> semanticMismatchSessions,
}) {
  if (_hasExecutablePedagogicalFinishProofV1(
    rootPath: rootPath,
    worldNumber: worldNumber,
    worldMarkdownPath: worldMarkdownPath,
    sessionsIndexPath: sessionsIndexPath,
    missingFeedbackCount: missingFeedbackCount,
    strategicActionChoiceCount: strategicActionChoiceCount,
    semanticMismatchSessions: semanticMismatchSessions,
  )) {
    return null;
  }
  final pedagogyHealth = worldSnapshot['pedagogy_health'] as String?;
  final lensStatuses = Map<String, Object?>.from(
    worldSnapshot['lens_statuses'] as Map? ?? const <String, Object?>{},
  );
  final openLensNames = <String>[
    for (final entry in lensStatuses.entries)
      if (entry.value is String && entry.value != 'done')
        '${entry.key}=${entry.value}',
  ];
  if ((pedagogyHealth == null || pedagogyHealth == 'done') &&
      openLensNames.isEmpty) {
    return null;
  }
  return PedagogicalProgressionFindingV1(
    gapId: 'pedagogy_${worldId.toLowerCase()}_world_finish_v1',
    worldScope: <String>[worldId],
    category: 'world_pedagogical_finish_completeness',
    currentStatus: 'truth_surfaced',
    admissibility: 'truth_layer_first',
    likelySeam: 'world pedagogical finish is not yet release-grade complete',
    ownerFiles: <String>[worldMarkdownPath, sessionsIndexPath],
    measurableProofPath: <String>[
      'dart run $worldPedagogicalProgressionAuditToolPathV1 --world=$worldNumber --json',
    ],
    blockers: <String>[
      if (pedagogyHealth != null && pedagogyHealth != 'done')
        'pedagogy_health=$pedagogyHealth',
      ...openLensNames.take(4),
      if ((worldSnapshot['release_grade_blocker_note'] as String?)
              ?.isNotEmpty ??
          false)
        worldSnapshot['release_grade_blocker_note'] as String,
    ],
    evPriorityOrder: 200 + worldNumber,
    reason:
        '$worldId still has non-done pedagogy/feedback/language finish signals in current world truth.',
  );
}

bool _hasExecutablePedagogicalFinishProofV1({
  required String rootPath,
  required int worldNumber,
  required String worldMarkdownPath,
  required String sessionsIndexPath,
  required int missingFeedbackCount,
  required int strategicActionChoiceCount,
  required List<_SemanticMismatchSessionV1> semanticMismatchSessions,
}) {
  if (worldNumber == 0) {
    return _hasExecutableWorld0PedagogicalFinishProofV1(
      rootPath: rootPath,
      worldNumber: worldNumber,
      worldMarkdownPath: worldMarkdownPath,
      sessionsIndexPath: sessionsIndexPath,
      missingFeedbackCount: missingFeedbackCount,
      strategicActionChoiceCount: strategicActionChoiceCount,
      semanticMismatchSessions: semanticMismatchSessions,
    );
  }
  if (worldNumber == 10) {
    return _hasExecutableWorld10PedagogicalFinishProofV1(
      rootPath: rootPath,
      worldMarkdownPath: worldMarkdownPath,
      sessionsIndexPath: sessionsIndexPath,
      missingFeedbackCount: missingFeedbackCount,
      strategicActionChoiceCount: strategicActionChoiceCount,
      semanticMismatchSessions: semanticMismatchSessions,
    );
  }
  return false;
}

List<_SemanticMismatchSessionV1> _findSemanticMismatchSessionsV1({
  required Directory sessionsRoot,
}) {
  if (!sessionsRoot.existsSync()) {
    return const <_SemanticMismatchSessionV1>[];
  }
  final mismatches = <_SemanticMismatchSessionV1>[];
  for (final sessionDir in sessionsRoot.listSync().whereType<Directory>()) {
    final sessionId = sessionDir.path.split(Platform.pathSeparator).last;
    if (!sessionId.startsWith('w')) continue;
    final sessionMd = File('${sessionDir.path}/session.md');
    if (!sessionMd.existsSync()) continue;
    final text = sessionMd.readAsStringSync().toLowerCase();
    final missingKinds = <String>[];
    final kinds = <String>{};
    final drillsDir = Directory('${sessionDir.path}/drills');
    if (!drillsDir.existsSync()) continue;
    for (final file in drillsDir.listSync().whereType<File>()) {
      if (!file.path.endsWith('.json')) continue;
      try {
        final decoded = jsonDecode(file.readAsStringSync());
        if (decoded is! Map<String, Object?>) continue;
        final kind = decoded['kind'];
        if (kind is String && kind.isNotEmpty) {
          kinds.add(kind);
        }
      } catch (_) {}
    }
    for (final kind in kinds) {
      final keywords = _kSessionSemanticKeywordsByKindV1[kind];
      if (keywords == null) continue;
      if (!keywords.any(text.contains)) {
        missingKinds.add(kind);
      }
    }
    if (missingKinds.isNotEmpty) {
      mismatches.add(
        _SemanticMismatchSessionV1(
          sessionId: sessionId,
          missingKinds: missingKinds..sort(),
        ),
      );
    }
  }
  return mismatches;
}

int _parseWorldNumberFromWorldIdV1(String worldId) {
  if (!worldId.startsWith('W')) return 0;
  return int.tryParse(worldId.substring(1)) ?? 0;
}

class _SemanticMismatchSessionV1 {
  const _SemanticMismatchSessionV1({
    required this.sessionId,
    required this.missingKinds,
  });

  final String sessionId;
  final List<String> missingKinds;
}

bool _hasExecutableWorld0OpenerFramingProofV1({
  required String rootPath,
  required int worldNumber,
  required String worldMarkdownPath,
  required String sessionsIndexPath,
}) {
  if (worldNumber != 0) {
    return false;
  }
  final worldFile = File('$rootPath/$worldMarkdownPath');
  final sessionsIndexFile = File('$rootPath/$sessionsIndexPath');
  final sessionsRoot = Directory('$rootPath/content/worlds/world0/v1/sessions');
  if (!worldFile.existsSync() ||
      !sessionsIndexFile.existsSync() ||
      !sessionsRoot.existsSync()) {
    return false;
  }

  final worldText = worldFile.readAsStringSync();
  final worldLower = worldText.toLowerCase();
  final sessionsIndexText = sessionsIndexFile.readAsStringSync();
  final sessionsIndexLower = sessionsIndexText.toLowerCase();
  final sessionFiles = sessionsRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('session.md'))
      .toList(growable: false);
  final sessionIndexCount = RegExp(
    r'^- w0\.s\d{2}:',
    multiLine: true,
  ).allMatches(sessionsIndexText).length;
  final allSessionsHaveFramingSections =
      sessionFiles.isNotEmpty &&
      sessionFiles.every((file) {
        final text = file.readAsStringSync().toLowerCase();
        return text.contains('## objective') &&
            text.contains('## scenario') &&
            text.contains('## decision') &&
            text.contains('## explanation');
      });

  return worldLower.contains('## overview') &&
      worldLower.contains('## goals') &&
      worldLower.contains('## completion criteria') &&
      worldLower.contains('cognitive shift:') &&
      worldLower.contains('you move from') &&
      worldLower.contains('not yet part of this world') &&
      worldLower.contains('common mistake we fix:') &&
      sessionIndexCount == 10 &&
      sessionsIndexLower.contains('the ladder starts with blind anchors') &&
      sessionsIndexLower.contains('the world still stops before strategy') &&
      allSessionsHaveFramingSections;
}

bool _hasExecutableWorld0PedagogicalFinishProofV1({
  required String rootPath,
  required int worldNumber,
  required String worldMarkdownPath,
  required String sessionsIndexPath,
  required int missingFeedbackCount,
  required int strategicActionChoiceCount,
  required List<_SemanticMismatchSessionV1> semanticMismatchSessions,
}) {
  if (worldNumber != 0) {
    return false;
  }
  if (!_hasExecutableWorld0OpenerFramingProofV1(
    rootPath: rootPath,
    worldNumber: worldNumber,
    worldMarkdownPath: worldMarkdownPath,
    sessionsIndexPath: sessionsIndexPath,
  )) {
    return false;
  }
  if (missingFeedbackCount != 0 ||
      strategicActionChoiceCount != 0 ||
      semanticMismatchSessions.isNotEmpty) {
    return false;
  }

  final worldFile = File('$rootPath/$worldMarkdownPath');
  final sessionsIndexFile = File('$rootPath/$sessionsIndexPath');
  if (!worldFile.existsSync() || !sessionsIndexFile.existsSync()) {
    return false;
  }

  final worldLower = worldFile.readAsStringSync().toLowerCase();
  final sessionsIndexLower = sessionsIndexFile.readAsStringSync().toLowerCase();
  return worldLower.contains('## release-grade finish proof') &&
      worldLower.contains(
        'the learner can name blind anchors, the acting seat, street order, and basic action buttons without guessing.',
      ) &&
      worldLower.contains('## handoff to world 1') &&
      worldLower.contains(
        'the next world can add stronger live learner decisions because world 0 now closes the table-reading foundation cleanly.',
      ) &&
      sessionsIndexLower.contains('completion shape:') &&
      sessionsIndexLower.contains('handoff to w1:') &&
      sessionsIndexLower.contains('without reteaching table orientation');
}

bool _hasExecutableWorld10PedagogicalFinishProofV1({
  required String rootPath,
  required String worldMarkdownPath,
  required String sessionsIndexPath,
  required int missingFeedbackCount,
  required int strategicActionChoiceCount,
  required List<_SemanticMismatchSessionV1> semanticMismatchSessions,
}) {
  if (missingFeedbackCount != 0 || semanticMismatchSessions.isNotEmpty) {
    return false;
  }

  final worldFile = File('$rootPath/$worldMarkdownPath');
  final sessionsIndexFile = File('$rootPath/$sessionsIndexPath');
  final sessionsRoot = Directory(
    '$rootPath/content/worlds/world10/v1/sessions',
  );
  if (!worldFile.existsSync() ||
      !sessionsIndexFile.existsSync() ||
      !sessionsRoot.existsSync()) {
    return false;
  }

  final worldText = worldFile.readAsStringSync();
  final worldLower = worldText.toLowerCase();
  final sessionsIndexText = sessionsIndexFile.readAsStringSync();
  final sessionsIndexLower = sessionsIndexText.toLowerCase();
  if (worldLower.contains('todo') || sessionsIndexLower.contains('todo')) {
    return false;
  }

  final sessionFiles = sessionsRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('session.md'))
      .toList(growable: false);
  final noteFiles = sessionsRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('notes.md'))
      .toList(growable: false);
  final sessionIndexCount = RegExp(
    r'^- w10\.s\d{2}:',
    multiLine: true,
  ).allMatches(sessionsIndexText).length;
  final allSessionsHaveFramingSections =
      sessionFiles.length == 10 &&
      sessionFiles.every((file) {
        final text = file.readAsStringSync().toLowerCase();
        return text.contains('## objective') &&
            text.contains('## scenario') &&
            text.contains('## decision') &&
            text.contains('## explanation');
      });
  final allSessionNotesAuthored =
      noteFiles.length == 10 &&
      noteFiles.every((file) {
        final text = file.readAsStringSync().toLowerCase();
        return text.contains('# notes') &&
            !text.contains('todo') &&
            RegExp(r'^- ', multiLine: true).allMatches(text).length >= 2;
      });

  return worldLower.contains('## overview') &&
      worldLower.contains('## goals') &&
      worldLower.contains('## completion criteria') &&
      worldLower.contains('## release-grade finish proof') &&
      worldLower.contains('## handoff to track play') &&
      worldLower.contains('one coherent track read') &&
      worldLower.contains('seat, board, hole cards, and action') &&
      worldLower.contains('track roots should deepen the selected plan') &&
      sessionIndexCount == 10 &&
      sessionsIndexLower.contains('completion shape:') &&
      sessionsIndexLower.contains('handoff to tracks:') &&
      sessionsIndexLower.contains('w10.s10') &&
      sessionsIndexLower.contains('integrated synthesis check') &&
      sessionsIndexLower.contains(
        'use the selected root session to deepen the same cue story',
      ) &&
      allSessionsHaveFramingSections &&
      allSessionNotesAuthored;
}

bool _isFoundationalActionButtonLiteracyDrillV1(Map<String, Object?> drill) {
  if (drill['kind'] != 'action_choice') {
    return false;
  }
  final prompt = (drill['prompt'] as String? ?? '').trim().toLowerCase();
  final why = (drill['why_v1'] as String? ?? '').trim().toLowerCase();
  final expected = Map<String, Object?>.from(
    drill['expected'] as Map? ?? const <String, Object?>{},
  );
  final actionId = (expected['actionId'] as String? ?? '').trim().toLowerCase();
  if (!const <String>{
    'fold',
    'call',
    'raise',
    'check',
    'bet',
  }.contains(actionId)) {
    return false;
  }

  final hasStrategicContext =
      drill.containsKey('street_v1') ||
      drill.containsKey('player_count_v1') ||
      drill.containsKey('board_cards_v1') ||
      drill.containsKey('hero_hole_cards_v1') ||
      drill.containsKey('available_actions_v1');
  if (hasStrategicContext) {
    return false;
  }

  final simplePrompt = prompt == 'choose $actionId.';
  final literacyWhy =
      why.isEmpty ||
      why.contains('action button') ||
      why.contains('button in the row') ||
      why.contains('first action button') ||
      why.contains('middle action button') ||
      why.contains('third action button');
  return simplePrompt && literacyWhy;
}
