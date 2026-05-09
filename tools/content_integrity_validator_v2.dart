import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:poker_analyzer/services/drill_contract_v1.dart';

import 'content_integrity_validator_v1.dart';

class ContentIntegrityReportV2 {
  const ContentIntegrityReportV2({
    required this.filesChecked,
    required this.issues,
  });

  final int filesChecked;
  final List<ContentIntegrityIssueV1> issues;

  bool get isSuccess => issues.isEmpty;

  Map<String, Object> toJson() => <String, Object>{
    'version': 'v2',
    'filesChecked': filesChecked,
    'issueCount': issues.length,
    'issues': issues.map((item) => item.toJson()).toList(growable: false),
  };
}

const Set<int> _kDefaultIncludedWorldsV2 = <int>{
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
};

const Map<String, String> _kBoardTexturePolicyExpectedActionsV2 =
    <String, String>{'calmer': 'call', 'pressure_building': 'raise'};
const Set<String> _kCanonicalActionChoiceActionIdsV2 = <String>{
  'fold',
  'call',
  'raise',
  'check',
  'bet',
};
const Set<String> _kCanonicalBetSizingPresetIdsV2 = <String>{
  'one_third_pot',
  'half_pot',
  'pot',
  'min_raise',
};
const Set<String> _kCanonicalBoardTextureLabelsV2 = <String>{
  'dry',
  'wet',
  'paired',
  'connected',
  'high_card',
};
const Set<String> _kCanonicalRangeBucketLabelsV2 = <String>{
  'strong',
  'medium',
  'weak',
  'draw',
  'missed',
};
final RegExp _kActionChoicePromptActionPatternV2 = RegExp(
  r'\bchoose\s+(fold|call|raise|check|bet)\b',
  caseSensitive: false,
);
final RegExp _kBetSizingMinRaisePatternV2 = RegExp(
  r'smallest legal (raise|reopen)|min raise',
  caseSensitive: false,
);
final RegExp _kBetSizingOneThirdPatternV2 = RegExp(
  r'one third pot',
  caseSensitive: false,
);
final RegExp _kBetSizingHalfPotPatternV2 = RegExp(
  r'half pot',
  caseSensitive: false,
);
const Set<String> _kCanonicalShowdownWinnerIdsV2 = <String>{
  'hero',
  'villain',
  'board_plays',
};
const Map<String, int> _kChainPromptStepCountsV2 = <String, int>{
  'two': 2,
  'three': 3,
  'four': 4,
};
const Map<String, String> _kChainStreetPromptPrefixesV2 = <String, String>{
  'preflop': 'preflop',
  'flop': 'flop',
  'turn': 'turn',
  'river': 'river',
};
final RegExp _kChainPromptStepCountPatternV2 = RegExp(
  r'\b(two|three|four)-step\b',
  caseSensitive: false,
);
final RegExp _kChainStepNumberPatternV2 = RegExp(
  r'^\s*step\s+(\d+)\s*:',
  caseSensitive: false,
);

class _DrillFileRefV2 {
  const _DrillFileRefV2({
    required this.world,
    required this.sessionId,
    required this.drillId,
    required this.path,
  });

  final int world;
  final String sessionId;
  final String drillId;
  final String path;
}

ContentIntegrityReportV2 buildContentIntegrityReportV2({
  String rootPath = '.',
  Set<int>? includedWorlds,
}) {
  final worlds = includedWorlds ?? _kDefaultIncludedWorldsV2;
  final baseReport = buildContentIntegrityReportV1(
    rootPath: rootPath,
    includedWorlds: worlds,
  );
  final issues = <ContentIntegrityIssueV1>[...baseReport.issues];
  final refs = _collectDrillRefsV2(rootPath, worlds)..sort(_compareRefsV2);

  for (final ref in refs) {
    final file = File('$rootPath/${ref.path}');
    if (!file.existsSync()) {
      continue;
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync());
    } on FormatException {
      continue;
    }
    if (decoded is! Map<String, Object?>) {
      continue;
    }

    final DrillSpecV1 spec;
    try {
      spec = DrillSpecV1.fromJson(decoded);
    } on FormatException {
      continue;
    } on StateError {
      continue;
    }

    issues.addAll(
      _collectModeSpecificIssuesV2(ref: ref, json: decoded, spec: spec),
    );
  }

  issues.sort(_compareIssuesV2);
  return ContentIntegrityReportV2(
    filesChecked: refs.length,
    issues: List<ContentIntegrityIssueV1>.unmodifiable(issues),
  );
}

String renderContentIntegrityReportV2(ContentIntegrityReportV2 report) {
  final out = StringBuffer()
    ..writeln('FILES_CHECKED\t${report.filesChecked}')
    ..writeln('ISSUE_COUNT\t${report.issues.length}')
    ..writeln();
  if (report.issues.isEmpty) {
    out.writeln('STATUS\tOK');
    return out.toString().trimRight();
  }
  out.writeln('WORLD\tSESSION\tDRILL\tREASON\tPATH\tDETAILS');
  for (final issue in report.issues) {
    out.writeln(
      '${issue.world}\t${issue.sessionId}\t${issue.drillId}\t${issue.reason}\t${issue.path}\t${issue.details ?? ''}',
    );
  }
  return out.toString().trimRight();
}

String encodeContentIntegrityReportJsonV2(ContentIntegrityReportV2 report) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

void main(List<String> args) {
  var emitJson = false;
  final includedWorlds = <int>{};

  for (final arg in args) {
    if (arg == '--json') {
      emitJson = true;
      continue;
    }
    if (arg.startsWith('--world=')) {
      final value = int.tryParse(arg.substring('--world='.length));
      if (value == null) {
        stderr.writeln('invalid --world value: $arg');
        exitCode = 64;
        return;
      }
      includedWorlds.add(value);
      continue;
    }
    stderr.writeln('unknown argument: $arg');
    exitCode = 64;
    return;
  }

  final report = buildContentIntegrityReportV2(
    includedWorlds: includedWorlds.isEmpty ? null : includedWorlds,
  );
  stdout.writeln(
    emitJson
        ? encodeContentIntegrityReportJsonV2(report)
        : renderContentIntegrityReportV2(report),
  );
  exitCode = report.isSuccess ? 0 : 1;
}

List<_DrillFileRefV2> _collectDrillRefsV2(String rootPath, Set<int> worlds) {
  return <_DrillFileRefV2>[
    ..._loadManifestRefsV2(rootPath, worlds),
    ..._scanWorld10TrackRefsV2(rootPath, worlds),
  ];
}

List<_DrillFileRefV2> _loadManifestRefsV2(String rootPath, Set<int> worlds) {
  final file = File('$rootPath/content/_meta/world_drills_manifest_v1.json');
  if (!file.existsSync()) {
    return const <_DrillFileRefV2>[];
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, Object?>) {
    return const <_DrillFileRefV2>[];
  }
  final worldEntries = decoded['worlds'];
  if (worldEntries is! List<Object?>) {
    return const <_DrillFileRefV2>[];
  }

  final refs = <_DrillFileRefV2>[];
  for (final worldEntry in worldEntries) {
    if (worldEntry is! Map<String, Object?>) {
      continue;
    }
    final world = worldEntry['world'];
    if (world is! int || !worlds.contains(world)) {
      continue;
    }
    final sessions = worldEntry['sessions'];
    if (sessions is! List<Object?>) {
      continue;
    }
    for (final session in sessions) {
      if (session is! Map<String, Object?>) {
        continue;
      }
      final sessionId = (session['id'] ?? '').toString().trim();
      final drills = session['drills'];
      if (sessionId.isEmpty || drills is! List<Object?>) {
        continue;
      }
      for (final drill in drills) {
        if (drill is! Map<String, Object?>) {
          continue;
        }
        final drillId = (drill['id'] ?? '').toString().trim();
        final drillPath = (drill['path'] ?? '').toString().trim();
        if (drillId.isEmpty || drillPath.isEmpty) {
          continue;
        }
        refs.add(
          _DrillFileRefV2(
            world: world,
            sessionId: sessionId,
            drillId: drillId,
            path: drillPath,
          ),
        );
      }
    }
  }
  return refs;
}

List<_DrillFileRefV2> _scanWorld10TrackRefsV2(
  String rootPath,
  Set<int> worlds,
) {
  if (!worlds.contains(10)) {
    return const <_DrillFileRefV2>[];
  }

  final refs = <_DrillFileRefV2>[];
  for (final track in const <String>['cash', 'mixed', 'tournament']) {
    final sessionsDir = Directory(
      '$rootPath/content/worlds/world10/v1/tracks/$track/sessions',
    );
    if (!sessionsDir.existsSync()) {
      continue;
    }
    final sessionDirs = sessionsDir.listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final sessionDir in sessionDirs) {
      final sessionId = sessionDir.uri.pathSegments.lastWhere(
        (segment) => segment.isNotEmpty,
      );
      final drillsDir = Directory('${sessionDir.path}/drills');
      if (!drillsDir.existsSync()) {
        continue;
      }
      final drillFiles = drillsDir.listSync().whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      for (final drillFile in drillFiles) {
        if (!drillFile.path.endsWith('.json')) {
          continue;
        }
        refs.add(
          _DrillFileRefV2(
            world: 10,
            sessionId: sessionId,
            drillId: _inferDrillIdFromPathV2(drillFile.path),
            path: path.relative(drillFile.path, from: Directory(rootPath).path),
          ),
        );
      }
    }
  }
  return refs;
}

List<ContentIntegrityIssueV1> _collectModeSpecificIssuesV2({
  required _DrillFileRefV2 ref,
  required Map<String, Object?> json,
  required DrillSpecV1 spec,
}) {
  switch (spec.kind) {
    case DrillKindV1.seatTap:
      return _collectSeatTapIssuesV2(ref, spec);
    case DrillKindV1.actionChoice:
      return _collectActionChoiceIssuesV2(ref, spec);
    case DrillKindV1.betSizingChoice:
      return _collectBetSizingIssuesV2(ref, spec);
    case DrillKindV1.showdownWinnerChoice:
      return _collectShowdownWinnerIssuesV2(ref, spec);
    case DrillKindV1.holeCardsTap:
      return _collectHoleCardTapIssuesV2(ref, spec);
    case DrillKindV1.boardTextureClassifier:
      return _collectBoardTextureIssuesV2(ref, json, spec);
    case DrillKindV1.rangeBucketClassifier:
      return _collectRangeBucketIssuesV2(ref, spec);
    case DrillKindV1.handChain:
      return _collectHandChainIssuesV2(ref, spec);
    default:
      return const <ContentIntegrityIssueV1>[];
  }
}

List<ContentIntegrityIssueV1> _collectHandChainIssuesV2(
  _DrillFileRefV2 ref,
  DrillSpecV1 spec,
) {
  final issues = <ContentIntegrityIssueV1>[];
  final steps = spec.chainStepsV1;
  if (steps == null || steps.isEmpty) {
    return issues;
  }

  final impliedCount = _expectedChainStepCountFromPromptV2(spec.prompt);
  if (impliedCount != null && steps.length != impliedCount) {
    issues.add(
      _issueV2(
        ref,
        'hand_chain_prompt_step_count_mismatch_v2',
        details:
            'prompt implies $impliedCount steps but steps length is ${steps.length}',
      ),
    );
  }

  for (var index = 0; index < steps.length; index++) {
    final step = steps[index];
    final promptStepNumber = _expectedChainStepNumberFromPromptV2(step.prompt);
    if (promptStepNumber != null && promptStepNumber != index + 1) {
      issues.add(
        _issueV2(
          ref,
          'hand_chain_step_number_mismatch_v2',
          details:
              'step ${index + 1} prompt labels itself as step $promptStepNumber',
        ),
      );
    }

    final promptStreet = _expectedChainStreetFromPromptPrefixV2(step.prompt);
    final actualStreet = step.street.trim().toLowerCase();
    if (promptStreet != null && promptStreet != actualStreet) {
      issues.add(
        _issueV2(
          ref,
          'hand_chain_step_street_prefix_mismatch_v2',
          details:
              'step ${index + 1} prompt implies $promptStreet but street is $actualStreet',
        ),
      );
    }
  }

  return issues;
}

List<ContentIntegrityIssueV1> _collectActionChoiceIssuesV2(
  _DrillFileRefV2 ref,
  DrillSpecV1 spec,
) {
  final issues = <ContentIntegrityIssueV1>[];
  final expectedActionId = spec.expected.actionId?.trim().toLowerCase();
  if (expectedActionId == null ||
      !_kCanonicalActionChoiceActionIdsV2.contains(expectedActionId)) {
    issues.add(
      _issueV2(
        ref,
        'action_choice_expected_action_invalid_v2',
        details:
            'expected.actionId must be one of ${_kCanonicalActionChoiceActionIdsV2.join('|')}',
      ),
    );
    return issues;
  }

  final availableActions = spec.availableActionsV1;
  if (availableActions != null) {
    final normalizedAvailableActions = availableActions
        .map((action) => action.trim().toLowerCase())
        .toList(growable: false);
    final invalidAvailableActions =
        normalizedAvailableActions
            .where(
              (action) => !_kCanonicalActionChoiceActionIdsV2.contains(action),
            )
            .toSet()
            .toList()
          ..sort();
    if (invalidAvailableActions.isNotEmpty) {
      issues.add(
        _issueV2(
          ref,
          'action_choice_available_actions_invalid_v2',
          details:
              'available_actions_v1 contains non-canonical action ids: ${invalidAvailableActions.join('|')}',
        ),
      );
    }
    if (!normalizedAvailableActions.contains(expectedActionId)) {
      issues.add(
        _issueV2(
          ref,
          'action_choice_available_actions_missing_expected_v2',
          details:
              'expected.actionId $expectedActionId must be present in available_actions_v1',
        ),
      );
    }
  }

  final promptActionId = _expectedActionChoicePromptActionV2(spec.prompt);
  if (promptActionId != null && promptActionId != expectedActionId) {
    issues.add(
      _issueV2(
        ref,
        'action_choice_prompt_action_mismatch_v2',
        details:
            'prompt implies $promptActionId but expected.actionId is $expectedActionId',
      ),
    );
  }

  return issues;
}

List<ContentIntegrityIssueV1> _collectBetSizingIssuesV2(
  _DrillFileRefV2 ref,
  DrillSpecV1 spec,
) {
  final issues = <ContentIntegrityIssueV1>[];
  final expectedPresetId = spec.expected.presetId?.trim().toLowerCase();
  if (expectedPresetId == null ||
      !_kCanonicalBetSizingPresetIdsV2.contains(expectedPresetId)) {
    issues.add(
      _issueV2(
        ref,
        'bet_sizing_expected_preset_invalid_v2',
        details:
            'expected.presetId must be one of ${_kCanonicalBetSizingPresetIdsV2.join('|')}',
      ),
    );
    return issues;
  }

  final acceptablePresetIds = spec.acceptablePresetIds;
  if (acceptablePresetIds != null) {
    final normalizedAcceptablePresetIds = acceptablePresetIds
        .map((preset) => preset.trim().toLowerCase())
        .toSet();
    final invalidAcceptablePresetIds =
        normalizedAcceptablePresetIds
            .where(
              (preset) => !_kCanonicalBetSizingPresetIdsV2.contains(preset),
            )
            .toList()
          ..sort();
    if (invalidAcceptablePresetIds.isNotEmpty) {
      issues.add(
        _issueV2(
          ref,
          'bet_sizing_acceptable_presets_invalid_v2',
          details:
              'acceptable_preset_ids contains non-canonical preset ids: ${invalidAcceptablePresetIds.join('|')}',
        ),
      );
    }
    if (normalizedAcceptablePresetIds.contains(expectedPresetId)) {
      issues.add(
        _issueV2(
          ref,
          'bet_sizing_acceptable_presets_include_expected_v2',
          details:
              'acceptable_preset_ids should not include expected.presetId $expectedPresetId',
        ),
      );
    }
  }

  final impliedPresetId = _expectedBetSizingPresetFromCopyV2(spec);
  if (impliedPresetId != null && impliedPresetId != expectedPresetId) {
    issues.add(
      _issueV2(
        ref,
        'bet_sizing_prompt_preset_mismatch_v2',
        details:
            'copy implies $impliedPresetId but expected.presetId is $expectedPresetId',
      ),
    );
  }

  return issues;
}

List<ContentIntegrityIssueV1> _collectShowdownWinnerIssuesV2(
  _DrillFileRefV2 ref,
  DrillSpecV1 spec,
) {
  final issues = <ContentIntegrityIssueV1>[];
  final expectedWinnerId = spec.expected.actionId?.trim().toLowerCase();
  if (expectedWinnerId == null ||
      !_kCanonicalShowdownWinnerIdsV2.contains(expectedWinnerId)) {
    issues.add(
      _issueV2(
        ref,
        'showdown_expected_winner_invalid_v2',
        details:
            'expected.actionId must be one of ${_kCanonicalShowdownWinnerIdsV2.join('|')}',
      ),
    );
    return issues;
  }

  if (spec.scenarioShowdownContextV1 == null) {
    issues.add(
      _issueV2(
        ref,
        'showdown_visible_payload_missing_v2',
        details:
            'showdown_winner_choice_v1 requires street_v1, hero_hole_cards_v1, villain_hole_cards_v1, and exactly 5 board_cards_v1',
      ),
    );
    return issues;
  }

  final impliedWinnerId = _expectedShowdownWinnerFromCopyV2(spec);
  if (impliedWinnerId != null && impliedWinnerId != expectedWinnerId) {
    issues.add(
      _issueV2(
        ref,
        'showdown_copy_winner_mismatch_v2',
        details:
            'copy implies $impliedWinnerId but expected.actionId is $expectedWinnerId',
      ),
    );
  }

  return issues;
}

List<ContentIntegrityIssueV1> _collectSeatTapIssuesV2(
  _DrillFileRefV2 ref,
  DrillSpecV1 spec,
) {
  final issues = <ContentIntegrityIssueV1>[];
  final prompt = spec.prompt.toLowerCase();
  final expectedRole = _expectedSeatRoleFromPromptV2(prompt);
  final expectedSeatId = _expectedSeatIdFromPromptV2(prompt);

  if (expectedRole != null && spec.expected.role != expectedRole) {
    issues.add(
      _issueV2(
        ref,
        'seat_tap_prompt_role_mismatch_v2',
        details:
            'prompt implies $expectedRole but expected.role is ${spec.expected.role}',
      ),
    );
  }
  if (expectedSeatId != null && spec.expected.seatId != expectedSeatId) {
    issues.add(
      _issueV2(
        ref,
        'seat_tap_prompt_seat_id_mismatch_v2',
        details:
            'prompt implies $expectedSeatId but expected.seatId is ${spec.expected.seatId}',
      ),
    );
  }

  return issues;
}

List<ContentIntegrityIssueV1> _collectHoleCardTapIssuesV2(
  _DrillFileRefV2 ref,
  DrillSpecV1 spec,
) {
  final issues = <ContentIntegrityIssueV1>[];
  final prompt = spec.prompt.toLowerCase();
  final expectedSlot = _expectedHoleCardSlotFromPromptV2(prompt);
  final expectedCardId = _expectedCardIdFromPromptV2(prompt);

  if (expectedSlot != null && spec.expected.cardSlot != expectedSlot) {
    issues.add(
      _issueV2(
        ref,
        'hole_cards_tap_prompt_slot_mismatch_v2',
        details:
            'prompt implies $expectedSlot but expected.cardSlot is ${spec.expected.cardSlot}',
      ),
    );
  }
  if (expectedCardId != null && spec.expected.cardId != expectedCardId) {
    issues.add(
      _issueV2(
        ref,
        'hole_cards_tap_prompt_card_id_mismatch_v2',
        details:
            'prompt implies $expectedCardId but expected.cardId is ${spec.expected.cardId}',
      ),
    );
  }

  return issues;
}

List<ContentIntegrityIssueV1> _collectBoardTextureIssuesV2(
  _DrillFileRefV2 ref,
  Map<String, Object?> json,
  DrillSpecV1 spec,
) {
  final issues = <ContentIntegrityIssueV1>[];
  final boardTexture = spec.boardTextureV1?.trim().toLowerCase();
  if (boardTexture == null ||
      !_kCanonicalBoardTextureLabelsV2.contains(boardTexture)) {
    issues.add(
      _issueV2(
        ref,
        'board_texture_classifier_label_invalid_v2',
        details:
            'board_texture_v1 must be one of ${_kCanonicalBoardTextureLabelsV2.join('|')}',
      ),
    );
    return issues;
  }

  final impliedTexture = _expectedBoardTextureLabelFromCopyV2(spec);
  if (impliedTexture != null && impliedTexture != boardTexture) {
    issues.add(
      _issueV2(
        ref,
        'board_texture_classifier_prompt_label_mismatch_v2',
        details:
            'copy implies $impliedTexture but board_texture_v1 is $boardTexture',
      ),
    );
  }

  final policyShape = _readNonEmptyStringV2(
    json['board_texture_policy_shape_v1'],
  );
  final policyTarget = _readNonEmptyStringV2(
    json['board_texture_policy_target_v1'],
  );
  if (policyShape != 'pressure_level' || policyTarget == null) {
    return issues;
  }

  final expectedAction = _kBoardTexturePolicyExpectedActionsV2[policyTarget];
  if (expectedAction == null) {
    return issues;
  }
  if (spec.expectedActionV1 != expectedAction) {
    issues.add(
      _issueV2(
        ref,
        'board_texture_policy_expected_action_mismatch_v2',
        details:
            'policy target $policyTarget expects $expectedAction but expected_action is ${spec.expectedActionV1}',
      ),
    );
  }
  return issues;
}

List<ContentIntegrityIssueV1> _collectRangeBucketIssuesV2(
  _DrillFileRefV2 ref,
  DrillSpecV1 spec,
) {
  final issues = <ContentIntegrityIssueV1>[];
  final rangeBucket = spec.rangeBucketV1?.trim().toLowerCase();
  if (rangeBucket == null ||
      !_kCanonicalRangeBucketLabelsV2.contains(rangeBucket)) {
    issues.add(
      _issueV2(
        ref,
        'range_bucket_classifier_label_invalid_v2',
        details:
            'range_bucket_v1 must be one of ${_kCanonicalRangeBucketLabelsV2.join('|')}',
      ),
    );
    return issues;
  }

  final impliedBucket = _expectedRangeBucketLabelFromCopyV2(spec);
  if (impliedBucket != null && impliedBucket != rangeBucket) {
    issues.add(
      _issueV2(
        ref,
        'range_bucket_classifier_prompt_label_mismatch_v2',
        details:
            'copy implies $impliedBucket but range_bucket_v1 is $rangeBucket',
      ),
    );
  }

  return issues;
}

String? _expectedSeatRoleFromPromptV2(String prompt) {
  if (RegExp(r'\bbtn\b').hasMatch(prompt) || prompt.contains('button seat')) {
    return 'btn';
  }
  if (RegExp(r'\bsb\b').hasMatch(prompt) || prompt.contains('small blind')) {
    return 'sb';
  }
  if (RegExp(r'\bbb\b').hasMatch(prompt) || prompt.contains('big blind')) {
    return 'bb';
  }
  return null;
}

int? _expectedChainStepCountFromPromptV2(String prompt) {
  final match = _kChainPromptStepCountPatternV2.firstMatch(prompt);
  if (match == null) {
    return null;
  }
  return _kChainPromptStepCountsV2[match.group(1)!.toLowerCase()];
}

int? _expectedChainStepNumberFromPromptV2(String prompt) {
  final match = _kChainStepNumberPatternV2.firstMatch(prompt);
  return match == null ? null : int.tryParse(match.group(1)!);
}

String? _expectedChainStreetFromPromptPrefixV2(String prompt) {
  final trimmed = prompt.trimLeft().toLowerCase();
  for (final entry in _kChainStreetPromptPrefixesV2.entries) {
    if (trimmed.startsWith('${entry.value}:')) {
      return entry.key;
    }
  }
  return null;
}

String? _expectedShowdownWinnerFromCopyV2(DrillSpecV1 spec) {
  final text = <String>[
    spec.prompt,
    if (spec.whyV1 != null) spec.whyV1!,
    if (spec.feedbackCorrectV1 != null) spec.feedbackCorrectV1!,
    if (spec.feedbackIncorrectV1 != null) spec.feedbackIncorrectV1!,
  ].join(' ').toLowerCase();

  final winners = <String>{};
  if (text.contains('board plays') ||
      text.contains('both players tie') ||
      text.contains('best hand for everyone')) {
    winners.add('board_plays');
  }
  if (text.contains('hero wins')) {
    winners.add('hero');
  }
  if (text.contains('villain wins')) {
    winners.add('villain');
  }
  if (winners.length != 1) {
    return null;
  }
  return winners.single;
}

String? _expectedSeatIdFromPromptV2(String prompt) {
  final match = RegExp(r'\bseat\s+(s\d+)\b').firstMatch(prompt);
  return match?.group(1)?.toUpperCase();
}

String? _expectedActionChoicePromptActionV2(String prompt) {
  final match = _kActionChoicePromptActionPatternV2.firstMatch(prompt);
  return match?.group(1)?.trim().toLowerCase();
}

String? _expectedBetSizingPresetFromCopyV2(DrillSpecV1 spec) {
  final text = <String>[
    spec.prompt,
    if (spec.whyV1 != null) spec.whyV1!,
    if (spec.feedbackCorrectV1 != null) spec.feedbackCorrectV1!,
    if (spec.feedbackIncorrectV1 != null) spec.feedbackIncorrectV1!,
  ].join(' ');

  final matches = <String>{};
  if (_kBetSizingMinRaisePatternV2.hasMatch(text)) {
    matches.add('min_raise');
  }
  if (_kBetSizingOneThirdPatternV2.hasMatch(text)) {
    matches.add('one_third_pot');
  }
  if (_kBetSizingHalfPotPatternV2.hasMatch(text)) {
    matches.add('half_pot');
  }
  if (matches.length != 1) {
    return null;
  }
  return matches.single;
}

String? _expectedBoardTextureLabelFromCopyV2(DrillSpecV1 spec) {
  final text = <String>[
    spec.prompt,
    if (spec.whyV1 != null) spec.whyV1!,
    if (spec.feedbackCorrectV1 != null) spec.feedbackCorrectV1!,
    if (spec.feedbackIncorrectV1 != null) spec.feedbackIncorrectV1!,
  ].join(' ').toLowerCase();

  final matches = <String>{};
  if (RegExp(r'\bdry\b').hasMatch(text)) {
    matches.add('dry');
  }
  if (RegExp(r'\bwet\b').hasMatch(text)) {
    matches.add('wet');
  }
  if (RegExp(r'\bpaired\b').hasMatch(text)) {
    matches.add('paired');
  }
  if (RegExp(r'\bconnected\b').hasMatch(text)) {
    matches.add('connected');
  }
  if (text.contains('high card')) {
    matches.add('high_card');
  }
  if (matches.length != 1) {
    return null;
  }
  return matches.single;
}

String? _expectedRangeBucketLabelFromCopyV2(DrillSpecV1 spec) {
  final text = <String>[
    spec.prompt,
    if (spec.whyV1 != null) spec.whyV1!,
    if (spec.feedbackCorrectV1 != null) spec.feedbackCorrectV1!,
    if (spec.feedbackIncorrectV1 != null) spec.feedbackIncorrectV1!,
  ].join(' ').toLowerCase();

  final matches = <String>{};
  if (RegExp(r'\bstrong\b').hasMatch(text)) {
    matches.add('strong');
  }
  if (RegExp(r'\bmedium\b').hasMatch(text)) {
    matches.add('medium');
  }
  if (RegExp(r'\bweak\b').hasMatch(text)) {
    matches.add('weak');
  }
  if (RegExp(r'\bdraw\b').hasMatch(text)) {
    matches.add('draw');
  }
  if (RegExp(r'\bmissed\b').hasMatch(text)) {
    matches.add('missed');
  }
  if (matches.length != 1) {
    return null;
  }
  return matches.single;
}

String? _expectedHoleCardSlotFromPromptV2(String prompt) {
  if (prompt.contains('hole_left') || prompt.contains('left hole card')) {
    return 'p0';
  }
  if (prompt.contains('hole_right') || prompt.contains('right hole card')) {
    return 'p1';
  }
  return null;
}

String? _expectedCardIdFromPromptV2(String prompt) {
  final shorthand = RegExp(r'\btap\s+([akqjt2-9][shdc])\b').firstMatch(prompt);
  if (shorthand != null) {
    return shorthand.group(1)!.substring(0, 1).toUpperCase() +
        shorthand.group(1)!.substring(1).toLowerCase();
  }

  final words = RegExp(
    r'\b(the\s+)?(ace|king|queen|jack|ten|nine|eight|seven|six|five|four|three|two)\s+of\s+(spades|hearts|diamonds|clubs)\b',
  ).firstMatch(prompt);
  if (words == null) {
    return null;
  }

  final rank = <String, String>{
    'ace': 'A',
    'king': 'K',
    'queen': 'Q',
    'jack': 'J',
    'ten': 'T',
    'nine': '9',
    'eight': '8',
    'seven': '7',
    'six': '6',
    'five': '5',
    'four': '4',
    'three': '3',
    'two': '2',
  }[words.group(2)!];
  final suit = <String, String>{
    'spades': 's',
    'hearts': 'h',
    'diamonds': 'd',
    'clubs': 'c',
  }[words.group(3)!];
  if (rank == null || suit == null) {
    return null;
  }
  return '$rank$suit';
}

String? _readNonEmptyStringV2(Object? raw) {
  if (raw is! String) {
    return null;
  }
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return trimmed.toLowerCase();
}

ContentIntegrityIssueV1 _issueV2(
  _DrillFileRefV2 ref,
  String reason, {
  String? details,
}) {
  return ContentIntegrityIssueV1(
    world: ref.world,
    sessionId: ref.sessionId,
    drillId: ref.drillId,
    reason: reason,
    path: ref.path,
    details: details,
  );
}

String _inferDrillIdFromPathV2(String filePath) {
  final name = filePath.split(Platform.pathSeparator).last;
  if (name.startsWith('d.') && name.endsWith('.json')) {
    return name.substring(2, name.length - 5);
  }
  if (name.endsWith('.json')) {
    return name.substring(0, name.length - 5);
  }
  return name;
}

int _compareRefsV2(_DrillFileRefV2 a, _DrillFileRefV2 b) {
  final byWorld = a.world.compareTo(b.world);
  if (byWorld != 0) return byWorld;
  final bySession = a.sessionId.compareTo(b.sessionId);
  if (bySession != 0) return bySession;
  return a.path.compareTo(b.path);
}

int _compareIssuesV2(ContentIntegrityIssueV1 a, ContentIntegrityIssueV1 b) {
  final byWorld = a.world.compareTo(b.world);
  if (byWorld != 0) return byWorld;
  final bySession = a.sessionId.compareTo(b.sessionId);
  if (bySession != 0) return bySession;
  final byDrill = a.drillId.compareTo(b.drillId);
  if (byDrill != 0) return byDrill;
  final byReason = a.reason.compareTo(b.reason);
  if (byReason != 0) return byReason;
  return a.path.compareTo(b.path);
}
