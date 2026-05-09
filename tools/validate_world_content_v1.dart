import 'dart:io';
import 'dart:convert';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/campaign/world1_scenario_truth_pilot_v1.dart';

import 'world_intents_ssot_v1.dart';
import 'why_v1_ssot_v1.dart';

const List<int> _kWorldIds = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
const Set<int> _kRoleCoverageWorldIds = <int>{0, 1, 2, 3, 4};
const Set<int> _kMixedCheckpointWorldIds = <int>{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
const Set<int> _kPacingLintWorldIds = <int>{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
const List<int> _kMixedCheckpointSequences = <int>[3, 6];
const String _kMixedCheckpointMarker = 'mixed checkpoint';
const int _kWorldRoleSessionMinDrills = 1;
const int _kWorldMinTotalDrills = 20;
const int _kMinDrillsPerSession = 3;
const int _kMaxDrillsPerSession = 12;
const int _kLearnRoleMinTotalDrills = 9;
const int _kLearnRoleMaxTotalDrills = 36;
const int _kPracticeRoleMinTotalDrills = 18;
const int _kPracticeRoleMaxTotalDrills = 72;
const int _kCheckpointRoleMinTotalDrills = 3;
const int _kCheckpointRoleMaxTotalDrills = 12;
const Set<String> _kWorld2TailMixedSessionsV1 = <String>{
  'w2.s07',
  'w2.s08',
  'w2.s09',
  'w2.s10',
  'w2.s11',
  'w2.s12',
  'w2.s13',
  'w2.s14',
};
const Set<String> _kWorld3TailPositionSessionsV1 = <String>{
  'w3.s11',
  'w3.s12',
  'w3.s13',
  'w3.s14',
};
const Set<String> _kShowdownWinnerActionsV1 = <String>{
  'hero',
  'villain',
  'board_plays',
};
const Set<String> _kActorChoiceActionsV1 = <String>{'hero', 'villain'};
const Set<String> _kPositionQuestionShapesV1 = <String>{
  'in_position',
  'out_of_position',
  'acts_later',
};
const Set<String> _kInitiativePolicyShapesV1 = <String>{'pressure_owner'};
const Set<String> _kOutsCountActionsV1 = <String>{'4', '8', '9', '15'};
const List<String> _kRequiredRelativePaths = <String>[
  'world.md',
  'atoms.md',
  'sessions/index.md',
];
final RegExp _kSessionIndexLine = RegExp(r'^- ([A-Za-z0-9._-]+):');
final RegExp _kDrillIndexLine = RegExp(r'^- ([a-z0-9_]+):');
const List<String> _kRequiredSessionSubheadings = <String>[
  '## Objective',
  '## Scenario',
  '## Decision',
  '## Explanation',
];

void main(List<String> args) {
  if (args.isNotEmpty) {
    stderr.writeln(
      'validate_world_content_v1: no arguments supported (deterministic scan only)',
    );
    exitCode = 64;
    return;
  }

  final contentRoot = Directory('content');
  if (!contentRoot.existsSync()) {
    stderr.writeln('validate_world_content_v1: content/ not found');
    exitCode = 1;
    return;
  }

  final errors = <String>[];
  final summaries = <String>[];
  var presentRequiredFiles = 0;
  var scannedFiles = 0;
  var totalSessions = 0;
  var totalDrills = 0;

  for (final worldId in _kWorldIds) {
    final worldRoot = Directory('content/worlds/world$worldId/v1');
    final worldLabel = 'world$worldId';
    var worldDrillCount = 0;
    if (!worldRoot.existsSync()) {
      for (final relPath in _kRequiredRelativePaths) {
        errors.add(
          'content/worlds/$worldLabel/v1/$relPath: missing required file',
        );
      }
      summaries.add(
        'validate_world_content_v1: $worldLabel missing dir content/worlds/$worldLabel/v1/',
      );
      continue;
    }

    final files =
        worldRoot
            .listSync(recursive: true)
            .whereType<File>()
            .toList(growable: false)
          ..sort((a, b) => a.path.compareTo(b.path));
    final filesInWorld = files.length;
    scannedFiles += filesInWorld;

    for (final file in files) {
      final rel = _normalizeRelPath(worldRoot.path, file.path);
      if (!_isAscii(rel) || rel.contains(' ')) {
        errors.add(
          '${file.path}: invalid filename (ASCII + no spaces required)',
        );
      }
    }

    var presentForWorld = 0;
    for (final relPath in _kRequiredRelativePaths) {
      final target = File('${worldRoot.path}/$relPath');
      if (!target.existsSync()) {
        errors.add('${target.path}: missing required file');
        continue;
      }
      if (worldId == 0 && relPath == 'world.md') {
        errors.addAll(_validateWorld0WorldCopy(target.path));
      }
      if (worldId == 0 && relPath == 'atoms.md') {
        errors.addAll(_validateWorld0AtomsCopy(target.path));
      }
      presentForWorld++;
      presentRequiredFiles++;
    }

    final sessionIndexFile = File('${worldRoot.path}/sessions/index.md');
    if (sessionIndexFile.existsSync()) {
      if (worldId == 0) {
        errors.addAll(_validateWorld0SessionIndexCopy(sessionIndexFile.path));
      }
      final sessionIds = _parseSessionIds(sessionIndexFile);
      final sessionLineById = _parseSessionLineById(sessionIndexFile);
      final seen = <String>{};
      final dups = <String>{};
      for (final id in sessionIds) {
        if (!seen.add(id)) dups.add(id);
      }
      final sortedDups = dups.toList()..sort();
      for (final dup in sortedDups) {
        errors.add('${sessionIndexFile.path}: duplicate session id $dup');
      }

      if (sessionIds.isEmpty) {
        errors.add('${sessionIndexFile.path}: no session ids found');
      } else {
        final sortedIds = sessionIds.toList()..sort();
        var learnRoleDrills = 0;
        var practiceRoleDrills = 0;
        var checkpointRoleDrills = 0;
        var hasLearn = false;
        var hasPractice = false;
        var hasCheckpoint = false;
        for (final sessionId in sortedIds) {
          if (_kRoleCoverageWorldIds.contains(worldId)) {
            final role = _roleFromSessionIdConvention(
              sessionId: sessionId,
              worldId: worldId,
            );
            if (role == null) {
              errors.add(
                '${sessionIndexFile.path}: world$worldId session "$sessionId" does not map to role convention; expected session ids in w$worldId.s01..w$worldId.s10',
              );
            } else if (role == _SessionRole.learn) {
              hasLearn = true;
            } else if (role == _SessionRole.practice) {
              hasPractice = true;
            } else if (role == _SessionRole.checkpoint) {
              hasCheckpoint = true;
            }
          }
          totalSessions++;
          final sessionDir = Directory('${worldRoot.path}/sessions/$sessionId');
          if (!sessionDir.existsSync()) {
            errors.add('${sessionDir.path}/: missing session folder');
            continue;
          }
          final sessionMd = File('${sessionDir.path}/session.md');
          if (!sessionMd.existsSync()) {
            errors.add('${sessionMd.path}: missing required file');
          } else {
            errors.addAll(_validateSessionStructure(sessionMd.path, sessionId));
            if (worldId == 0) {
              errors.addAll(_validateWorld0SessionCopy(sessionMd.path));
            }
          }
          final drillsIndex = File('${sessionDir.path}/drills/index.md');
          if (!drillsIndex.existsSync()) {
            errors.add('${drillsIndex.path}: missing required file');
          } else {
            if (worldId == 0) {
              errors.addAll(_validateWorld0DrillsIndexCopy(drillsIndex.path));
            }
            final drillIds = _parseDrillIds(drillsIndex);
            final drillSeen = <String>{};
            final drillDups = <String>{};
            for (final drillId in drillIds) {
              if (!drillSeen.add(drillId)) drillDups.add(drillId);
            }
            final sortedDrillDups = drillDups.toList()..sort();
            for (final dup in sortedDrillDups) {
              errors.add('${drillsIndex.path}: duplicate drill id $dup');
            }

            final sortedDrillIds = drillSeen.toList()..sort();
            final sessionDrillCount = sortedDrillIds.length;
            totalDrills += sortedDrillIds.length;
            worldDrillCount += sortedDrillIds.length;
            final roleForSession = _roleFromSessionIdConvention(
              sessionId: sessionId,
              worldId: worldId,
            );
            if (_kRoleCoverageWorldIds.contains(worldId)) {
              if (roleForSession != null &&
                  sortedDrillIds.length < _kWorldRoleSessionMinDrills) {
                errors.add(
                  '${drillsIndex.path}: world$worldId session=$sessionId role=${_sessionRoleLabel(roleForSession)} '
                  'drill_count=${sortedDrillIds.length} required_min=$_kWorldRoleSessionMinDrills',
                );
              }
            }
            if (_kPacingLintWorldIds.contains(worldId)) {
              final roleLabel = roleForSession == null
                  ? 'Unknown'
                  : _sessionRoleLabel(roleForSession);
              final minDrillsPerSession = _minDrillsPerSessionForWorld(
                worldId,
                sessionId,
              );
              final maxDrillsPerSession = _maxDrillsPerSessionForWorld(
                worldId,
                sessionId,
              );
              if (sessionDrillCount < minDrillsPerSession ||
                  sessionDrillCount > maxDrillsPerSession) {
                errors.add(
                  '${drillsIndex.path}: world$worldId session=$sessionId role=$roleLabel '
                  'drill_count=$sessionDrillCount expected_range=$minDrillsPerSession..$maxDrillsPerSession',
                );
              }
              if (roleForSession == _SessionRole.learn) {
                learnRoleDrills += sessionDrillCount;
              } else if (roleForSession == _SessionRole.practice) {
                practiceRoleDrills += sessionDrillCount;
              } else if (roleForSession == _SessionRole.checkpoint) {
                checkpointRoleDrills += sessionDrillCount;
              } else {
                errors.add(
                  '${drillsIndex.path}: world$worldId session=$sessionId role=Unknown '
                  'cannot apply pacing lint role buckets; expected ${_sessionRoleConventionExpectationLabel(worldId)}',
                );
              }
            }
            var hasValidWhyV1InSession = false;
            for (final drillId in sortedDrillIds) {
              final drillFile = File(
                '${sessionDir.path}/drills/d.$drillId.json',
              );
              if (!drillFile.existsSync()) {
                errors.add('${drillFile.path}: missing required file');
                continue;
              }
              if (!_isAsciiBytes(drillFile.readAsBytesSync())) {
                errors.add('${drillFile.path}: non-ASCII bytes not allowed');
              } else {
                hasValidWhyV1InSession =
                    hasValidWhyV1InSession ||
                    _drillJsonHasValidWhyV1(drillFile);
                errors.addAll(
                  _validateDrillJsonFile(drillFile, sessionId, drillId),
                );
              }
            }
            if (kWhyV1StagedSessionsV1.contains(sessionId) &&
                !hasValidWhyV1InSession) {
              errors.add(
                '${sessionDir.path}/drills/: missing_why_v1_for_session',
              );
            }
          }
          final notesMd = File('${sessionDir.path}/notes.md');
          if (!notesMd.existsSync()) {
            errors.add('${notesMd.path}: missing required file');
          } else if (worldId == 0) {
            errors.addAll(_validateWorld0NotesCopy(notesMd.path));
          }
        }
        if (_kRoleCoverageWorldIds.contains(worldId)) {
          final missingRoles = <String>[];
          if (!hasLearn) missingRoles.add('Learn');
          if (!hasPractice) missingRoles.add('Practice');
          if (!hasCheckpoint) missingRoles.add('Checkpoint');
          if (missingRoles.isNotEmpty) {
            errors.add(
              '${sessionIndexFile.path}: world$worldId missing role coverage ${missingRoles.join(', ')} '
              '(expected ranges: ${_roleCoverageExpectationLabel(worldId)})',
            );
          }
          final minWorldDrills = _minWorldDrillsForWorld(worldId);
          if (worldDrillCount < minWorldDrills) {
            errors.add(
              '${worldRoot.path}/sessions/: world$worldId total_drills=$worldDrillCount '
              'required_min=$minWorldDrills',
            );
          }
        }
        if (_kMixedCheckpointWorldIds.contains(worldId)) {
          for (final sequence in _kMixedCheckpointSequences) {
            final sessionId =
                'w$worldId.s${sequence.toString().padLeft(2, '0')}';
            final rawLine = sessionLineById[sessionId];
            if (rawLine == null) {
              errors.add(
                '${sessionIndexFile.path}: world$worldId missing required mixed checkpoint session $sessionId',
              );
              continue;
            }
            if (!rawLine.toLowerCase().contains(_kMixedCheckpointMarker)) {
              errors.add(
                '${sessionIndexFile.path}: world$worldId session=$sessionId missing mixed checkpoint marker '
                '(expected phrase "Mixed checkpoint")',
              );
            }
          }
        }
        if (_kPacingLintWorldIds.contains(worldId)) {
          final learnMin = _minRoleDrillsForWorld(worldId, _SessionRole.learn);
          final learnMax = _maxRoleDrillsForWorld(worldId, _SessionRole.learn);
          if (learnRoleDrills < learnMin || learnRoleDrills > learnMax) {
            errors.add(
              '${worldRoot.path}/sessions/: world$worldId role=Learn total_drills=$learnRoleDrills '
              'expected_range=$learnMin..$learnMax',
            );
          }
          final practiceMin = _minRoleDrillsForWorld(
            worldId,
            _SessionRole.practice,
          );
          final practiceMax = _maxRoleDrillsForWorld(
            worldId,
            _SessionRole.practice,
          );
          if (practiceRoleDrills < practiceMin ||
              practiceRoleDrills > practiceMax) {
            errors.add(
              '${worldRoot.path}/sessions/: world$worldId role=Practice total_drills=$practiceRoleDrills '
              'expected_range=$practiceMin..$practiceMax',
            );
          }
          final checkpointMin = _minRoleDrillsForWorld(
            worldId,
            _SessionRole.checkpoint,
          );
          final checkpointMax = _maxRoleDrillsForWorld(
            worldId,
            _SessionRole.checkpoint,
          );
          if (checkpointRoleDrills < checkpointMin ||
              checkpointRoleDrills > checkpointMax) {
            errors.add(
              '${worldRoot.path}/sessions/: world$worldId role=Checkpoint total_drills=$checkpointRoleDrills '
              'expected_range=$checkpointMin..$checkpointMax',
            );
          }
        }
      }
    }

    summaries.add(
      'validate_world_content_v1: $worldLabel files=$filesInWorld required_present=$presentForWorld/${_kRequiredRelativePaths.length}',
    );
  }

  final pilotSummary = _validateWorld1PilotScenarioTruthV1(errors);
  summaries.add(
    'validate_world_content_v1: world1_pilot_scenario_truth $pilotSummary',
  );

  if (errors.isNotEmpty) {
    for (final line in summaries) {
      stdout.writeln(line);
    }
    for (final error in errors) {
      stderr.writeln('validate_world_content_v1: $error');
    }
    exitCode = 1;
    return;
  }

  for (final line in summaries) {
    stdout.writeln(line);
  }
  stdout.writeln(
    'validate_world_content_v1: OK (worlds=${_kWorldIds.length}, sessions=$totalSessions, drills_total=$totalDrills, required_files=$presentRequiredFiles, scanned_files=$scannedFiles)',
  );
}

String _validateWorld1PilotScenarioTruthV1(List<String> errors) {
  const pilotPackIds = <String>[
    'world1_spine_campaign_v1',
    'world1_spine_followup_v1_b0',
    'world1_spine_followup_v1_b1',
    'world1_spine_followup_v1_b2',
  ];

  var actionableSteps = 0;
  var validatedFamilies = 0;
  for (final packId in pilotPackIds) {
    final pack = kCampaignPacksV1[packId];
    if (pack == null) {
      errors.add('world1_pilot_scenario_truth: missing pack $packId');
      continue;
    }
    final steps = pack12(pack);
    var actionableInPack = 0;
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final normalizedAllowed = (step.allowedActions ?? const <String>[])
          .map((value) => value.trim().toLowerCase())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      if (normalizedAllowed.isEmpty) {
        continue;
      }
      actionableSteps += 1;
      actionableInPack += 1;
      for (final family in World1ScenarioTruthFamilyV1.values) {
        final familyErrors = validateWorld1ScenarioTruthPilotStepV1(
          packId: packId,
          stepIndex: i,
          step: step,
          family: family,
        );
        for (final familyError in familyErrors) {
          errors.add('world1_pilot_scenario_truth: $familyError');
        }
        validatedFamilies += 1;
      }

      final actionTruth = world1ScenarioTruthPilotForStepV1(
        step: step,
        family: World1ScenarioTruthFamilyV1.actionChoiceEarlyDecision,
      );
      final mismatchTruth = world1ScenarioTruthPilotForStepV1(
        step: step,
        family: World1ScenarioTruthFamilyV1.handLoopMismatchFooterFeedback,
      );
      if (actionTruth == null || mismatchTruth == null) {
        errors.add(
          'world1_pilot_scenario_truth: pack=$packId step=$i missing pilot family completeness',
        );
        continue;
      }
      if (actionTruth.expectedActionFamilyV1 !=
          mismatchTruth.expectedActionFamilyV1) {
        errors.add(
          'world1_pilot_scenario_truth: pack=$packId step=$i expected-action mismatch between pilot families',
        );
      }
      if (actionTruth.requiredFocusLabelV1 !=
          mismatchTruth.requiredFocusLabelV1) {
        errors.add(
          'world1_pilot_scenario_truth: pack=$packId step=$i focus-label mismatch between pilot families',
        );
      }
    }
    if (actionableInPack == 0) {
      errors.add(
        'world1_pilot_scenario_truth: pack=$packId has no actionable steps for pilot families',
      );
    }
  }

  return 'packs=${pilotPackIds.length} actionable_steps=$actionableSteps families_validated=$validatedFamilies';
}

List<String> _validateDrillJsonFile(
  File file,
  String sessionId,
  String expectedDrillId,
) {
  final errors = <String>[];
  Object? decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());
  } catch (_) {
    return <String>['${file.path}: invalid JSON'];
  }
  if (decoded is! Map<String, dynamic>) {
    return <String>['${file.path}: drill JSON root must be object'];
  }
  final id = decoded['id'];
  if (id is! String || id != expectedDrillId) {
    errors.add('${file.path}: id must match drill file id "$expectedDrillId"');
  }
  final intentV1 = decoded['intent_v1'];
  if (intentV1 != null && (intentV1 is! String || !isValidIntentV1(intentV1))) {
    errors.add('${file.path}: intent_v1 must match [a-z0-9_]+ when present');
  }
  if (hasPromptAnswerLeakV1(decoded['prompt'])) {
    errors.add(
      '${file.path}: prompt_answer_leak_v1 (prompt contains explicit answer cue such as "expected action" or "answer is")',
    );
  }
  if (_hasWorld0SeatShorthandPromptLeakV1(
    filePath: file.path,
    promptRaw: decoded['prompt'],
  )) {
    errors.add(
      '${file.path}: world0_seat_label_shorthand_prompt_leak_v1 (World 0 learner-facing prompts must spell out seat labels instead of btn/sb/bb shorthand)',
    );
  }
  if (_hasWorld0BoardSlotPromptJargonLeakV1(
    filePath: file.path,
    promptRaw: decoded['prompt'],
  )) {
    errors.add(
      '${file.path}: world0_board_slot_prompt_jargon_leak_v1 (World 0 learner-facing prompts must avoid internal board-slot jargon such as flop_left/card slot phrasing)',
    );
  }
  if (_hasWorld0SeatIdPromptLeakV1(
    filePath: file.path,
    promptRaw: decoded['prompt'],
  )) {
    errors.add(
      '${file.path}: world0_seat_id_prompt_jargon_leak_v1 (World 0 learner-facing prompts must use "seat labeled Sx" phrasing instead of "Tap seat Sx")',
    );
  }
  if (hasActionFocusCueLeakV1(decoded['prompt'])) {
    errors.add(
      '${file.path}: prompt_action_focus_leak_v1 (prompt contains forbidden "Focus: <action>" answer cue)',
    );
  }
  final whyV1 = decoded['why_v1'];
  if (whyV1 != null && !isRuntimeValidWhyV1V1(whyV1)) {
    errors.add('${file.path}: invalid_why_v1');
  }
  if (_hasWorld0CheckpointMixLeakInWhyV1(file.path, whyV1)) {
    errors.add(
      '${file.path}: world0_drill_why_checkpoint_mix_jargon_leak_v1 (World 0 drill why_v1 copy must use "checkpoint set" phrasing instead of "checkpoint mix")',
    );
  }
  if (_hasWorld0HeroAnchorLeakInWhyV1(file.path, whyV1)) {
    errors.add(
      '${file.path}: world0_drill_why_hero_anchor_jargon_leak_v1 (World 0 drill why_v1 copy must use "hole-card anchor" phrasing instead of "hero hole-card anchor")',
    );
  }
  if (hasFeedbackLabelMismatchV1(
    feedbackCorrectV1: decoded['feedback_correct_v1'],
    feedbackIncorrectV1: decoded['feedback_incorrect_v1'],
  )) {
    errors.add(
      '${file.path}: feedback_label_mismatch_v1 (feedback_correct_v1 must not start with "Incorrect"; '
      'feedback_incorrect_v1 must not start with "Correct")',
    );
  }
  if (hasPrimaryCorrectContradictionV1(decoded['feedback_correct_v1'])) {
    errors.add(
      '${file.path}: feedback_primary_correct_contradiction_v1 (feedback_correct_v1 must not contain soft-pass contradiction phrasing such as "legal, but worse than our recommended play")',
    );
  }
  errors.addAll(_validateIntentForSession(file.path, sessionId, intentV1));
  final kind = decoded['kind'];
  if (kind is! String) {
    errors.add('${file.path}: kind must be a string');
    return errors;
  }
  if (_hasWorld0GenericActionWhyLeakInWhyV1(file.path, kind, whyV1)) {
    errors.add(
      '${file.path}: world0_drill_why_generic_action_copy_leak_v1 (World 0 action-choice drill why_v1 copy must not use the generic basic-action template)',
    );
  }
  if (_hasWorld0GenericSeatContextWhyLeakInWhyV1(file.path, kind, whyV1)) {
    errors.add(
      '${file.path}: world0_drill_why_generic_seat_context_copy_leak_v1 (World 0 seat-tap drill why_v1 copy must not use the generic seat-context template)',
    );
  }
  if (_hasWorld0GenericHoleCardFocusWhyLeakInWhyV1(file.path, kind, whyV1)) {
    errors.add(
      '${file.path}: world0_drill_why_generic_hole_card_focus_copy_leak_v1 (World 0 mixed-focus hole-card drill why_v1 copy must not use the generic hole-card focus template)',
    );
  }
  if (sessionId.startsWith('w1.') &&
      kind == 'action_choice' &&
      hasDirectChooseActionPromptLeakV1(decoded['prompt'])) {
    errors.add(
      '${file.path}: prompt_direct_action_leak_world1_v1 (world1 action_choice prompt must not directly reveal fold/call/raise answer)',
    );
  }
  final expected = decoded['expected'];
  final expectedMap =
      (kind == 'board_texture_classifier_v1' ||
          kind == 'range_bucket_classifier_v1' ||
          kind == 'hand_chain_v1')
      ? (expected is Map<String, dynamic> ? expected : <String, dynamic>{})
      : () {
          if (expected is! Map<String, dynamic>) {
            errors.add('${file.path}: expected must be an object');
            return <String, dynamic>{};
          }
          return expected;
        }();
  if (errors.isNotEmpty &&
      kind != 'board_texture_classifier_v1' &&
      kind != 'range_bucket_classifier_v1' &&
      kind != 'hand_chain_v1') {
    return errors;
  }
  switch (kind) {
    case 'seat_tap':
      final seatId = expectedMap['seatId'];
      final role = expectedMap['role'];
      if ((seatId is! String || seatId.isEmpty) &&
          (role is! String || role.isEmpty)) {
        errors.add(
          '${file.path}: seat_tap requires expected.seatId and/or expected.role',
        );
      }
      break;
    case 'action_choice':
      final actionId = expectedMap['actionId'];
      if (actionId is! String || actionId.isEmpty) {
        errors.add('${file.path}: action_choice requires expected.actionId');
      }
      break;
    case 'board_tap':
      final boardSlot = expectedMap['boardSlot'];
      if (boardSlot is! String || boardSlot.isEmpty) {
        errors.add('${file.path}: board_tap requires expected.boardSlot');
      }
      break;
    case 'hole_cards_tap':
      final cardSlot = expectedMap['cardSlot'];
      if (cardSlot is! String || (cardSlot != 'p0' && cardSlot != 'p1')) {
        errors.add(
          '${file.path}: hole_cards_tap requires expected.cardSlot (p0|p1)',
        );
      }
      final cardId = expectedMap['cardId'];
      if (cardId != null &&
          (cardId is! String || !_kCardIdV1Pattern.hasMatch(cardId))) {
        errors.add(
          '${file.path}: hole_cards_tap expected.cardId must match [AKQJT98765432][shdc]',
        );
      }
      break;
    case 'bet_sizing_choice_v1':
      final presetId = expectedMap['presetId'];
      if (presetId is! String || !_kBetSizingPresetIdsV1.contains(presetId)) {
        errors.add(
          '${file.path}: bet_sizing_choice_v1 requires expected.presetId (one_third_pot|half_pot|pot|min_raise)',
        );
      }
      final acceptablePresetIds = decoded['acceptable_preset_ids'];
      if (acceptablePresetIds != null) {
        if (acceptablePresetIds is! List) {
          errors.add('${file.path}: acceptable_preset_ids must be an array');
        } else {
          final normalized = <String>[];
          for (final item in acceptablePresetIds) {
            if (item is! String) {
              errors.add(
                '${file.path}: acceptable_preset_ids entries must be strings',
              );
              continue;
            }
            if (!_kBetSizingPresetIdsV1.contains(item)) {
              errors.add(
                '${file.path}: acceptable_preset_ids entry not allowed: $item',
              );
              continue;
            }
            normalized.add(item);
          }
          final sortedUnique = normalized.toSet().toList()..sort();
          if (normalized.length != sortedUnique.length ||
              !_listEqualsV1(normalized, sortedUnique)) {
            errors.add(
              '${file.path}: acceptable_preset_ids must be deduped and sorted',
            );
          }
        }
      }
      break;
    case 'showdown_winner_choice_v1':
      final street = decoded['street_v1'];
      if (street is! String || !_kHandChainStreetsV1.contains(street)) {
        errors.add(
          '${file.path}: showdown_winner_choice_v1 requires street_v1 (preflop|flop|turn|river)',
        );
      }
      final heroHoleCards = decoded['hero_hole_cards_v1'];
      if (!_hasExactCardListV1(heroHoleCards, 2)) {
        errors.add(
          '${file.path}: showdown_winner_choice_v1 requires hero_hole_cards_v1 length 2',
        );
      }
      final villainHoleCards = decoded['villain_hole_cards_v1'];
      if (!_hasExactCardListV1(villainHoleCards, 2)) {
        errors.add(
          '${file.path}: showdown_winner_choice_v1 requires villain_hole_cards_v1 length 2',
        );
      }
      final boardCards = decoded['board_cards_v1'];
      if (!_hasExactCardListV1(boardCards, 5)) {
        errors.add(
          '${file.path}: showdown_winner_choice_v1 requires board_cards_v1 length 5',
        );
      }
      final availableActions = decoded['available_actions_v1'];
      if (!_matchesExactStringSetV1(
        availableActions,
        _kShowdownWinnerActionsV1,
      )) {
        errors.add(
          '${file.path}: showdown_winner_choice_v1 requires available_actions_v1 [hero, villain, board_plays]',
        );
      }
      final actionId = expectedMap['actionId'];
      if (actionId is! String ||
          !_kShowdownWinnerActionsV1.contains(actionId)) {
        errors.add(
          '${file.path}: showdown_winner_choice_v1 requires expected.actionId (hero|villain|board_plays)',
        );
      }
      break;
    case 'position_thinking_choice_v1':
      final questionShape = decoded['question_shape_v1'];
      if (questionShape != null &&
          (questionShape is! String ||
              !_kPositionQuestionShapesV1.contains(questionShape))) {
        errors.add(
          '${file.path}: position_thinking_choice_v1 question_shape_v1 must be in_position|out_of_position|acts_later',
        );
      }
      final street = decoded['street_v1'];
      if (street is! String || !_kHandChainStreetsV1.contains(street)) {
        errors.add(
          '${file.path}: position_thinking_choice_v1 requires street_v1 (preflop|flop|turn|river)',
        );
      }
      if (decoded['player_count_v1'] is! int) {
        errors.add(
          '${file.path}: position_thinking_choice_v1 requires player_count_v1',
        );
      }
      if (decoded['hero_seat_v1'] is! String ||
          decoded['villain_seat_v1'] is! String) {
        errors.add(
          '${file.path}: position_thinking_choice_v1 requires hero_seat_v1 and villain_seat_v1',
        );
      }
      if (!_isStringListV1(decoded['active_seats_v1'])) {
        errors.add(
          '${file.path}: position_thinking_choice_v1 requires active_seats_v1',
        );
      }
      if (!_matchesExactStringSetV1(
        decoded['available_actions_v1'],
        _kActorChoiceActionsV1,
      )) {
        errors.add(
          '${file.path}: position_thinking_choice_v1 requires available_actions_v1 [hero, villain]',
        );
      }
      final actionId = expectedMap['actionId'];
      if (actionId is! String || !_kActorChoiceActionsV1.contains(actionId)) {
        errors.add(
          '${file.path}: position_thinking_choice_v1 requires expected.actionId (hero|villain)',
        );
      }
      break;
    case 'initiative_aggressor_choice_v1':
      final initiativePolicyShape = decoded['initiative_policy_shape_v1'];
      if (initiativePolicyShape != null &&
          (initiativePolicyShape is! String ||
              !_kInitiativePolicyShapesV1.contains(initiativePolicyShape))) {
        errors.add(
          '${file.path}: initiative_aggressor_choice_v1 initiative_policy_shape_v1 must be pressure_owner',
        );
      }
      final pressureOwner = decoded['pressure_owner_v1'];
      if (pressureOwner != null &&
          (pressureOwner is! String ||
              !_kActorChoiceActionsV1.contains(pressureOwner))) {
        errors.add(
          '${file.path}: initiative_aggressor_choice_v1 pressure_owner_v1 must be hero|villain',
        );
      }
      final street = decoded['street_v1'];
      if (street is! String || !_kHandChainStreetsV1.contains(street)) {
        errors.add(
          '${file.path}: initiative_aggressor_choice_v1 requires street_v1 (preflop|flop|turn|river)',
        );
      }
      if (decoded['player_count_v1'] is! int) {
        errors.add(
          '${file.path}: initiative_aggressor_choice_v1 requires player_count_v1',
        );
      }
      if (decoded['hero_seat_v1'] is! String ||
          decoded['villain_seat_v1'] is! String) {
        errors.add(
          '${file.path}: initiative_aggressor_choice_v1 requires hero_seat_v1 and villain_seat_v1',
        );
      }
      if (!_isStringListV1(decoded['active_seats_v1'])) {
        errors.add(
          '${file.path}: initiative_aggressor_choice_v1 requires active_seats_v1',
        );
      }
      final lastAggressor = decoded['last_aggressor_v1'];
      final initiativeOwner = decoded['initiative_owner_v1'];
      if (lastAggressor is! String ||
          !_kActorChoiceActionsV1.contains(lastAggressor)) {
        errors.add(
          '${file.path}: initiative_aggressor_choice_v1 requires last_aggressor_v1 hero|villain',
        );
      }
      if (initiativeOwner is! String ||
          !_kActorChoiceActionsV1.contains(initiativeOwner)) {
        errors.add(
          '${file.path}: initiative_aggressor_choice_v1 requires initiative_owner_v1 hero|villain',
        );
      }
      if (!_matchesExactStringSetV1(
        decoded['available_actions_v1'],
        _kActorChoiceActionsV1,
      )) {
        errors.add(
          '${file.path}: initiative_aggressor_choice_v1 requires available_actions_v1 [hero, villain]',
        );
      }
      final actionId = expectedMap['actionId'];
      if (actionId is! String || !_kActorChoiceActionsV1.contains(actionId)) {
        errors.add(
          '${file.path}: initiative_aggressor_choice_v1 requires expected.actionId (hero|villain)',
        );
      }
      break;
    case 'outs_count_choice_v1':
      final street = decoded['street_v1'];
      if (street is! String || !_kHandChainStreetsV1.contains(street)) {
        errors.add(
          '${file.path}: outs_count_choice_v1 requires street_v1 (preflop|flop|turn|river)',
        );
      }
      if (!_hasExactCardListV1(decoded['hero_hole_cards_v1'], 2)) {
        errors.add(
          '${file.path}: outs_count_choice_v1 requires hero_hole_cards_v1 length 2',
        );
      }
      final boardCards = decoded['board_cards_v1'];
      if (!_hasBoardCardCountV1(boardCards, const <int>{3, 4})) {
        errors.add(
          '${file.path}: outs_count_choice_v1 requires board_cards_v1 length 3 or 4',
        );
      }
      if (!_matchesExactStringSetV1(
        decoded['available_actions_v1'],
        _kOutsCountActionsV1,
      )) {
        errors.add(
          '${file.path}: outs_count_choice_v1 requires available_actions_v1 [4, 8, 9, 15]',
        );
      }
      final actionId = expectedMap['actionId'];
      if (actionId is! String || !_kOutsCountActionsV1.contains(actionId)) {
        errors.add(
          '${file.path}: outs_count_choice_v1 requires expected.actionId (4|8|9|15)',
        );
      }
      break;
    case 'board_texture_classifier_v1':
      final boardTexture = decoded['board_texture_v1'];
      if (boardTexture is! String ||
          !_kBoardTextureV1Values.contains(boardTexture)) {
        errors.add(
          '${file.path}: board_texture_classifier_v1 requires board_texture_v1 (dry|wet|paired|connected|high_card)',
        );
      }
      final expectedAction = decoded['expected_action'];
      if (expectedAction is! String ||
          !_kBoardTextureActionsV1.contains(expectedAction)) {
        errors.add(
          '${file.path}: board_texture_classifier_v1 requires expected_action (fold|call|raise)',
        );
      }
      final acceptableActions = decoded['acceptable_actions'];
      if (acceptableActions != null) {
        if (acceptableActions is! List) {
          errors.add('${file.path}: acceptable_actions must be an array');
        } else {
          final normalized = <String>[];
          for (final item in acceptableActions) {
            if (item is! String) {
              errors.add(
                '${file.path}: acceptable_actions entries must be strings',
              );
              continue;
            }
            if (!_kBoardTextureActionsV1.contains(item)) {
              errors.add(
                '${file.path}: acceptable_actions entry not allowed: $item',
              );
              continue;
            }
            normalized.add(item);
          }
          final sortedUnique = normalized.toSet().toList()..sort();
          if (normalized.length != sortedUnique.length ||
              !_listEqualsV1(normalized, sortedUnique)) {
            errors.add(
              '${file.path}: acceptable_actions must be deduped and sorted',
            );
          }
        }
      }
      break;
    case 'range_bucket_classifier_v1':
      final rangeBucket = decoded['range_bucket_v1'];
      if (rangeBucket is! String ||
          !_kRangeBucketV1Values.contains(rangeBucket)) {
        errors.add(
          '${file.path}: range_bucket_classifier_v1 requires range_bucket_v1 (strong|medium|weak|draw|missed)',
        );
      }
      final expectedAction = decoded['expected_action'];
      if (expectedAction is! String ||
          !_kRangeBucketActionsV1.contains(expectedAction)) {
        errors.add(
          '${file.path}: range_bucket_classifier_v1 requires expected_action (fold|call|raise)',
        );
      }
      final acceptableActions = decoded['acceptable_actions'];
      if (acceptableActions != null) {
        if (acceptableActions is! List) {
          errors.add('${file.path}: acceptable_actions must be an array');
        } else {
          final normalized = <String>[];
          for (final item in acceptableActions) {
            if (item is! String) {
              errors.add(
                '${file.path}: acceptable_actions entries must be strings',
              );
              continue;
            }
            if (!_kRangeBucketActionsV1.contains(item)) {
              errors.add(
                '${file.path}: acceptable_actions entry not allowed: $item',
              );
              continue;
            }
            normalized.add(item);
          }
          final sortedUnique = normalized.toSet().toList()..sort();
          if (normalized.length != sortedUnique.length ||
              !_listEqualsV1(normalized, sortedUnique)) {
            errors.add(
              '${file.path}: acceptable_actions must be deduped and sorted',
            );
          }
        }
      }
      break;
    case 'hand_chain_v1':
      final chainId = decoded['chain_id'];
      if (chainId is! String || chainId.trim().isEmpty) {
        errors.add('${file.path}: hand_chain_v1 requires chain_id');
      }
      final steps = decoded['steps'];
      if (steps is! List || steps.length < 2 || steps.length > 4) {
        errors.add(
          '${file.path}: hand_chain_v1 steps must be an array length 2..4',
        );
        break;
      }
      for (var i = 0; i < steps.length; i++) {
        final step = steps[i];
        if (step is! Map) {
          errors.add('${file.path}: hand_chain_v1 step[$i] must be an object');
          continue;
        }
        final stepMap = step.cast<String, dynamic>();
        final street = stepMap['street'];
        if (street is! String || !_kHandChainStreetsV1.contains(street)) {
          errors.add(
            '${file.path}: hand_chain_v1 step[$i] street must be preflop|flop|turn|river',
          );
        }
        final prompt = stepMap['prompt'];
        if (prompt is! String || prompt.trim().isEmpty) {
          errors.add('${file.path}: hand_chain_v1 step[$i] prompt is required');
        } else if (hasPromptAnswerLeakV1(prompt)) {
          errors.add(
            '${file.path}: hand_chain_v1 step[$i] prompt_answer_leak_v1 (prompt contains explicit answer cue such as "expected action" or "answer is")',
          );
        } else if (hasActionFocusCueLeakV1(prompt)) {
          errors.add(
            '${file.path}: hand_chain_v1 step[$i] prompt_action_focus_leak_v1 (prompt contains forbidden "Focus: <action>" answer cue)',
          );
        }
        final errorClass = stepMap['error_class'];
        if (errorClass is! String || errorClass.trim().isEmpty) {
          errors.add(
            '${file.path}: hand_chain_v1 step[$i] error_class is required',
          );
        }
        if (hasFeedbackLabelMismatchV1(
          feedbackCorrectV1: stepMap['feedback_correct_v1'],
          feedbackIncorrectV1: stepMap['feedback_incorrect_v1'],
        )) {
          errors.add(
            '${file.path}: hand_chain_v1 step[$i] feedback_label_mismatch_v1 '
            '(feedback_correct_v1 must not start with "Incorrect"; feedback_incorrect_v1 must not start with "Correct")',
          );
        }
        if (hasPrimaryCorrectContradictionV1(stepMap['feedback_correct_v1'])) {
          errors.add(
            '${file.path}: hand_chain_v1 step[$i] feedback_primary_correct_contradiction_v1 '
            '(feedback_correct_v1 must not contain soft-pass contradiction phrasing such as "legal, but worse than our recommended play")',
          );
        }
        final expectedAction = stepMap['expected_action'];
        final expectedPreset = stepMap['expected_preset_id'];
        final rangeBucket = stepMap['range_bucket_v1'];
        final expectedCount = <Object?>[
          expectedAction,
          expectedPreset,
          rangeBucket,
        ].whereType<String>().where((s) => s.isNotEmpty).length;
        if (expectedCount != 1) {
          errors.add(
            '${file.path}: hand_chain_v1 step[$i] must include exactly one of expected_action|expected_preset_id|range_bucket_v1',
          );
        }
        if (expectedAction is String &&
            !_isAllowedHandChainExpectedAction(
              sessionId: sessionId,
              stepIndex: i,
              stepMap: stepMap,
              expectedAction: expectedAction,
            )) {
          errors.add(
            '${file.path}: hand_chain_v1 step[$i] expected_action must be fold|call|raise${_expectedActionAllowanceSuffix(sessionId, i, stepMap)}',
          );
        }
        if (expectedPreset is String &&
            !_kBetSizingPresetIdsV1.contains(expectedPreset)) {
          errors.add(
            '${file.path}: hand_chain_v1 step[$i] expected_preset_id must be one_third_pot|half_pot|pot|min_raise',
          );
        }
        if (rangeBucket is String &&
            !_kRangeBucketV1Values.contains(rangeBucket)) {
          errors.add(
            '${file.path}: hand_chain_v1 step[$i] range_bucket_v1 must be strong|medium|weak|draw|missed',
          );
        }
        final acceptableActions = stepMap['acceptable_actions'];
        if (acceptableActions != null) {
          if (acceptableActions is! List) {
            errors.add(
              '${file.path}: hand_chain_v1 step[$i] acceptable_actions must be an array',
            );
          } else {
            final normalized = <String>[];
            for (final item in acceptableActions) {
              if (item is! String) {
                errors.add(
                  '${file.path}: hand_chain_v1 step[$i] acceptable_actions entries must be strings',
                );
                continue;
              }
              if (!_kRangeBucketActionsV1.contains(item)) {
                errors.add(
                  '${file.path}: hand_chain_v1 step[$i] acceptable_actions entry not allowed: $item',
                );
                continue;
              }
              normalized.add(item);
            }
            final sortedUnique = normalized.toSet().toList()..sort();
            if (normalized.length != sortedUnique.length ||
                !_listEqualsV1(normalized, sortedUnique)) {
              errors.add(
                '${file.path}: hand_chain_v1 step[$i] acceptable_actions must be deduped and sorted',
              );
            }
          }
        }
        final acceptablePresetIds = stepMap['acceptable_preset_ids'];
        if (acceptablePresetIds != null) {
          if (acceptablePresetIds is! List) {
            errors.add(
              '${file.path}: hand_chain_v1 step[$i] acceptable_preset_ids must be an array',
            );
          } else {
            final normalized = <String>[];
            for (final item in acceptablePresetIds) {
              if (item is! String) {
                errors.add(
                  '${file.path}: hand_chain_v1 step[$i] acceptable_preset_ids entries must be strings',
                );
                continue;
              }
              if (!_kBetSizingPresetIdsV1.contains(item)) {
                errors.add(
                  '${file.path}: hand_chain_v1 step[$i] acceptable_preset_ids entry not allowed: $item',
                );
                continue;
              }
              normalized.add(item);
            }
            final sortedUnique = normalized.toSet().toList()..sort();
            if (normalized.length != sortedUnique.length ||
                !_listEqualsV1(normalized, sortedUnique)) {
              errors.add(
                '${file.path}: hand_chain_v1 step[$i] acceptable_preset_ids must be deduped and sorted',
              );
            }
          }
        }
      }
      break;
    default:
      errors.add('${file.path}: unsupported drill kind "$kind"');
      break;
  }
  return errors;
}

List<String> _validateWorld0NotesCopy(String notesMdPath) {
  final errors = <String>[];
  final raw = File(notesMdPath)
      .readAsStringSync()
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  if (_hasWorld0TableReadLeakV1(raw)) {
    errors.add(
      '$notesMdPath: world0_notes_table_read_jargon_leak_v1 (World 0 notes must use "table layout" phrasing instead of "table read")',
    );
  }
  if (_hasWorld0ActorLanguageLeakV1(raw)) {
    errors.add(
      '$notesMdPath: world0_notes_actor_language_leak_v1 (World 0 notes must use "acting seat" phrasing instead of "actor" wording)',
    );
  }
  if (_hasWorld0HeroAnchorLeakV1(raw)) {
    errors.add(
      '$notesMdPath: world0_notes_hero_anchor_jargon_leak_v1 (World 0 notes must use "hole-card anchor" phrasing instead of "hero-card anchor")',
    );
  }
  if (_hasWorld0StreetFlowLeakV1(raw)) {
    errors.add(
      '$notesMdPath: world0_notes_street_flow_jargon_leak_v1 (World 0 notes must use "street order" phrasing instead of "street flow" or "street-order")',
    );
  }
  if (_hasWorld0ActionLabelLeakV1(raw)) {
    errors.add(
      '$notesMdPath: world0_notes_action_label_jargon_leak_v1 (World 0 notes must use "action button" phrasing instead of "action label")',
    );
  }
  if (hasSessionTodoPlaceholderLeakV1(raw)) {
    errors.add(
      '$notesMdPath: world0_notes_todo_placeholder_leak_v1 (notes.md must not contain TODO placeholder tokens)',
    );
  }
  if (_hasWorld0ActionRowLeakV1(raw)) {
    errors.add(
      '$notesMdPath: world0_notes_action_row_jargon_leak_v1 (World 0 notes must use "action buttons" phrasing instead of "action row")',
    );
  }
  if (_hasWorld0TableMapLeakV1(raw)) {
    errors.add(
      '$notesMdPath: world0_notes_table_map_jargon_leak_v1 (World 0 notes must use "table layout" phrasing instead of "table map")',
    );
  }
  if (_hasWorld0SeatMapLeakV1(raw)) {
    errors.add(
      '$notesMdPath: world0_notes_seat_map_jargon_leak_v1 (World 0 notes must use "seat layout" phrasing instead of "seat map")',
    );
  }
  return errors;
}

List<String> _validateWorld0WorldCopy(String worldMdPath) {
  final errors = <String>[];
  final raw = File(worldMdPath)
      .readAsStringSync()
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  if (_hasWorld0ActorLanguageLeakV1(raw)) {
    errors.add(
      '$worldMdPath: world0_world_actor_language_leak_v1 (World 0 world copy must use "acting seat" phrasing instead of "actor" wording)',
    );
  }
  if (_hasWorld0ActionLabelLeakV1(raw)) {
    errors.add(
      '$worldMdPath: world0_world_action_label_jargon_leak_v1 (World 0 world copy must use "action button" phrasing instead of "action label")',
    );
  }
  return errors;
}

List<String> _validateWorld0SessionIndexCopy(String sessionIndexPath) {
  final errors = <String>[];
  final raw = File(sessionIndexPath)
      .readAsStringSync()
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  if (_hasWorld0PositionLanguageLeakV1(raw)) {
    errors.add(
      '$sessionIndexPath: world0_sessions_index_position_language_leak_v1 (World 0 sessions index must use seat-layout wording instead of position phrasing)',
    );
  }
  if (_hasWorld0ActorLanguageLeakV1(raw)) {
    errors.add(
      '$sessionIndexPath: world0_sessions_index_actor_language_leak_v1 (World 0 sessions index must use "acting seat" phrasing instead of "actor" wording)',
    );
  }
  if (_hasWorld0StreetFlowLeakV1(raw)) {
    errors.add(
      '$sessionIndexPath: world0_sessions_index_street_flow_jargon_leak_v1 (World 0 sessions index must use "street order" phrasing instead of "street flow" or "street-order")',
    );
  }
  if (_hasWorld0ActionLabelLeakV1(raw)) {
    errors.add(
      '$sessionIndexPath: world0_sessions_index_action_label_jargon_leak_v1 (World 0 sessions index must use "action button" phrasing instead of "action label")',
    );
  }
  if (_hasWorld0SeatMapLeakV1(raw)) {
    errors.add(
      '$sessionIndexPath: world0_sessions_index_seat_map_jargon_leak_v1 (World 0 sessions index must use "seat layout" phrasing instead of "seat map")',
    );
  }
  return errors;
}

List<String> _validateWorld0AtomsCopy(String atomsMdPath) {
  final errors = <String>[];
  final raw = File(atomsMdPath)
      .readAsStringSync()
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  if (_hasWorld0ActorLanguageLeakV1(raw)) {
    errors.add(
      '$atomsMdPath: world0_atoms_actor_language_leak_v1 (World 0 atoms must use "acting seat" phrasing instead of "actor" wording)',
    );
  }
  if (_hasWorld0ActionLabelLeakV1(raw)) {
    errors.add(
      '$atomsMdPath: world0_atoms_action_label_jargon_leak_v1 (World 0 atoms must use "action button" phrasing instead of "action label")',
    );
  }
  if (hasSessionTodoPlaceholderLeakV1(raw)) {
    errors.add(
      '$atomsMdPath: world0_atoms_todo_placeholder_leak_v1 (atoms.md must not contain TODO placeholder tokens)',
    );
  }
  if (_hasWorld0ActionRowLeakV1(raw)) {
    errors.add(
      '$atomsMdPath: world0_atoms_action_row_jargon_leak_v1 (World 0 atoms must use "action buttons" phrasing instead of "action row")',
    );
  }
  return errors;
}

List<String> _validateWorld0DrillsIndexCopy(String drillsIndexPath) {
  final errors = <String>[];
  final raw = File(drillsIndexPath)
      .readAsStringSync()
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  if (_hasWorld0TableReadLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_table_read_jargon_leak_v1 (World 0 drill indexes must use "table layout" phrasing instead of "table read")',
    );
  }
  if (_hasWorld0ActorLanguageLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_actor_language_leak_v1 (World 0 drill indexes must use "acting seat" phrasing instead of "actor" wording)',
    );
  }
  if (_hasWorld0CheckpointMixLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_checkpoint_mix_jargon_leak_v1 (World 0 drill indexes must use "checkpoint set" phrasing instead of "checkpoint mix")',
    );
  }
  if (_hasWorld0HeroAnchorLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_hero_anchor_jargon_leak_v1 (World 0 drill indexes must use "hole-card anchor" phrasing instead of "hero-card anchor")',
    );
  }
  if (hasSessionTodoPlaceholderLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_todo_placeholder_leak_v1 (drills/index.md must not contain TODO placeholder tokens)',
    );
  }
  if (_hasWorld0SeatIdIndexLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_seat_id_jargon_leak_v1 (drills/index.md must use "seat labeled Sx" phrasing instead of "tap seat Sx")',
    );
  }
  if (_hasWorld0ButtonSeatIndexLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_button_seat_jargon_leak_v1 (drills/index.md must use "dealer button seat" phrasing instead of "button seat")',
    );
  }
  if (_hasWorld0DealerPositionIndexLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_dealer_position_jargon_leak_v1 (drills/index.md must use "dealer button seat" phrasing instead of "dealer position")',
    );
  }
  if (_hasWorld0HoleCardsIndexLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_hole_cards_plural_leak_v1 (drills/index.md must use singular "hole card" phrasing for World 0 learner-facing copy)',
    );
  }
  if (_hasWorld0CurrentActorAreaLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_current_actor_area_jargon_leak_v1 (World 0 drill indexes must use "acting seat" phrasing instead of "current actor area")',
    );
  }
  if (_hasWorld0TableMapLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_table_map_jargon_leak_v1 (World 0 drill indexes must use "table layout" phrasing instead of "table map")',
    );
  }
  if (_hasWorld0ActionRowLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_action_row_jargon_leak_v1 (World 0 drill indexes must use "action buttons" phrasing instead of "action row")',
    );
  }
  if (_hasWorld0SeatMapLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_seat_map_jargon_leak_v1 (World 0 drill indexes must use "seat layout" phrasing instead of "seat map")',
    );
  }
  if (_hasWorld0ActionLabelLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_action_label_jargon_leak_v1 (World 0 drill indexes must use "action button" phrasing instead of "action label")',
    );
  }
  if (_hasWorld0StreetFlowLeakV1(raw)) {
    errors.add(
      '$drillsIndexPath: world0_drills_index_street_flow_jargon_leak_v1 (World 0 drill indexes must use "street order" phrasing instead of "street flow" or "street-order")',
    );
  }
  return errors;
}

List<String> _validateWorld0SessionCopy(String sessionMdPath) {
  final errors = <String>[];
  final raw = File(sessionMdPath)
      .readAsStringSync()
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  if (_hasWorld0PositionLanguageLeakV1(raw)) {
    errors.add(
      '$sessionMdPath: world0_session_position_language_leak_v1 (World 0 session copy must use seat/table wording instead of position phrasing)',
    );
  }
  if (_hasWorld0ActorLanguageLeakV1(raw)) {
    errors.add(
      '$sessionMdPath: world0_session_actor_language_leak_v1 (World 0 session copy must use "acting seat" phrasing instead of "actor" wording)',
    );
  }
  if (_hasWorld0StreetFlowLeakV1(raw)) {
    errors.add(
      '$sessionMdPath: world0_session_street_flow_jargon_leak_v1 (World 0 session copy must use "street order" phrasing instead of "street flow" or "street-order")',
    );
  }
  if (_hasWorld0ActionLabelLeakV1(raw)) {
    errors.add(
      '$sessionMdPath: world0_session_action_label_jargon_leak_v1 (World 0 session copy must use "action button" phrasing instead of "action label")',
    );
  }
  if (_hasWorld0TableMapLeakV1(raw)) {
    errors.add(
      '$sessionMdPath: world0_session_table_map_jargon_leak_v1 (World 0 session copy must use "table layout" phrasing instead of "table map")',
    );
  }
  if (_hasWorld0GenericSessionTemplateLeakV1(raw)) {
    errors.add(
      '$sessionMdPath: world0_session_generic_template_copy_leak_v1 (World 0 session copy must not use the generic template phrasing)',
    );
  }
  return errors;
}

bool _hasWorld0PositionLanguageLeakV1(String raw) {
  final lower = raw.toLowerCase();
  return lower.contains('position cue') ||
      lower.contains('position cues') ||
      lower.contains('position checks') ||
      lower.contains('button position');
}

bool _hasWorld0GenericActionWhyLeakInWhyV1(
  String filePath,
  Object? kindRaw,
  Object? whyV1Raw,
) {
  if (!filePath.contains('content/worlds/world0/v1/')) return false;
  if (kindRaw is! String || kindRaw != 'action_choice') return false;
  if (whyV1Raw is! String) return false;
  return whyV1Raw.trim() ==
      'This drill checks basic action recognition on the table.';
}

bool _hasWorld0GenericSeatContextWhyLeakInWhyV1(
  String filePath,
  Object? kindRaw,
  Object? whyV1Raw,
) {
  if (!filePath.contains('content/worlds/world0/v1/')) return false;
  if (kindRaw is! String || kindRaw != 'seat_tap') return false;
  if (whyV1Raw is! String) return false;
  return whyV1Raw.trim() ==
      'This drill checks seat context before action selection.';
}

bool _hasWorld0GenericHoleCardFocusWhyLeakInWhyV1(
  String filePath,
  Object? kindRaw,
  Object? whyV1Raw,
) {
  if (!filePath.contains('content/worlds/world0/v1/')) return false;
  if (kindRaw is! String || kindRaw != 'hole_cards_tap') return false;
  if (whyV1Raw is! String) return false;
  return whyV1Raw.trim() ==
      'This drill checks whether the learner can keep the hole-card anchor stable inside the mixed focus reps.';
}

bool _hasWorld0GenericSessionTemplateLeakV1(String raw) {
  final lower = raw.toLowerCase();
  return lower.contains(
        'apply the drill sequence to reinforce the target decision pattern.',
      ) ||
      lower.contains(
        'use the provided table state and seat cues for this session.',
      ) ||
      lower.contains('choose the strongest action using the session cues.') ||
      lower.contains('review why the chosen action best fits this spot.');
}

String _normalizeRelPath(String baseDirPath, String filePath) {
  final base = baseDirPath.replaceAll('\\', '/');
  final full = filePath.replaceAll('\\', '/');
  if (full.startsWith('$base/')) {
    return full.substring(base.length + 1);
  }
  return full;
}

bool _isAscii(String value) {
  for (final unit in value.codeUnits) {
    if (unit < 32 || unit > 126) return false;
  }
  return true;
}

bool _isAsciiBytes(List<int> bytes) {
  for (final unit in bytes) {
    if (unit == 9 || unit == 10 || unit == 13) continue;
    if (unit < 32 || unit > 126) return false;
  }
  return true;
}

final RegExp _kCardIdV1Pattern = RegExp(r'^[AKQJT98765432][shdc]$');
const Set<String> _kBetSizingPresetIdsV1 = <String>{
  'one_third_pot',
  'half_pot',
  'pot',
  'min_raise',
};
const Set<String> _kBoardTextureV1Values = <String>{
  'dry',
  'wet',
  'paired',
  'connected',
  'high_card',
};
const Set<String> _kBoardTextureActionsV1 = <String>{'fold', 'call', 'raise'};
const Set<String> _kRangeBucketV1Values = <String>{
  'strong',
  'medium',
  'weak',
  'draw',
  'missed',
};
const Set<String> _kRangeBucketActionsV1 = <String>{'fold', 'call', 'raise'};
const Set<String> _kHandChainStreetsV1 = <String>{
  'preflop',
  'flop',
  'turn',
  'river',
};

bool _listEqualsV1(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

List<String> _validateIntentForSession(
  String filePath,
  String sessionId,
  Object? intentV1,
) {
  final errors = <String>[];
  final world = worldIndexFromSessionId(sessionId);
  if (world == null) return errors;
  if (!requiresIntentV1ForSessionId(sessionId)) return errors;
  if (intentV1 is! String || intentV1.isEmpty) {
    errors.add('$filePath: world$world drills require intent_v1');
    return errors;
  }
  final allowed = allowedIntentsV1ForSessionId(sessionId);
  if (allowed.isNotEmpty && !allowed.contains(intentV1)) {
    errors.add('$filePath: world$world intent_v1 not allowed: $intentV1');
  }
  return errors;
}

bool _drillJsonHasValidWhyV1(File file) {
  Object? decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());
  } catch (_) {
    return false;
  }
  if (decoded is! Map<String, dynamic>) return false;
  return isRuntimeValidWhyV1V1(decoded['why_v1']);
}

List<String> _parseSessionIds(File sessionIndexFile) {
  final ids = <String>[];
  final lines = sessionIndexFile.readAsLinesSync();
  for (final rawLine in lines) {
    final line = rawLine.trim();
    final match = _kSessionIndexLine.firstMatch(line);
    if (match == null) continue;
    ids.add(match.group(1)!);
  }
  return ids;
}

Map<String, String> _parseSessionLineById(File sessionIndexFile) {
  final byId = <String, String>{};
  final lines = sessionIndexFile.readAsLinesSync();
  for (final rawLine in lines) {
    final line = rawLine.trim();
    final match = _kSessionIndexLine.firstMatch(line);
    if (match == null) continue;
    byId[match.group(1)!] = line;
  }
  return byId;
}

List<String> _parseDrillIds(File drillsIndexFile) {
  final ids = <String>[];
  final lines = drillsIndexFile.readAsLinesSync();
  for (final rawLine in lines) {
    final line = rawLine.trim();
    final match = _kDrillIndexLine.firstMatch(line);
    if (match == null) continue;
    ids.add(match.group(1)!);
  }
  return ids;
}

List<String> _validateSessionStructure(String sessionMdPath, String sessionId) {
  final errors = <String>[];
  final file = File(sessionMdPath);
  final raw = file
      .readAsStringSync()
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  if (hasSessionTodoPlaceholderLeakV1(raw)) {
    errors.add(
      '$sessionMdPath: session_todo_placeholder_leak_v1 (session.md must not contain TODO placeholder tokens)',
    );
  }
  final lines = raw.split('\n');
  final expectedTitle = '# Session $sessionId';
  if (lines.isEmpty || lines.first != expectedTitle) {
    errors.add('$sessionMdPath: first line must be "$expectedTitle"');
  }

  final headingLines = <String>[];
  for (final line in lines) {
    if (line.startsWith('#')) headingLines.add(line);
  }

  final requiredHeadings = <String>[
    expectedTitle,
    ..._kRequiredSessionSubheadings,
  ];
  final positions = <String, int>{};
  for (final heading in requiredHeadings) {
    final matchedIndexes = <int>[];
    for (var i = 0; i < headingLines.length; i++) {
      if (headingLines[i] == heading) matchedIndexes.add(i);
    }
    if (matchedIndexes.isEmpty) {
      errors.add('$sessionMdPath: missing required heading $heading');
      continue;
    }
    if (matchedIndexes.length > 1) {
      errors.add('$sessionMdPath: duplicate required heading $heading');
    }
    positions[heading] = matchedIndexes.first;
  }

  var previous = -1;
  for (final heading in requiredHeadings) {
    final pos = positions[heading];
    if (pos == null) continue;
    if (pos <= previous) {
      errors.add(
        '$sessionMdPath: required headings out of order (expected ${requiredHeadings.join(' -> ')})',
      );
      break;
    }
    previous = pos;
  }
  return errors;
}

_SessionRole? _roleFromSessionIdConvention({
  required String sessionId,
  required int worldId,
}) {
  final match = RegExp(r'^w(\d+)\.s(\d{2})$').firstMatch(sessionId);
  if (match == null) return null;
  final parsedWorld = int.tryParse(match.group(1)!);
  final sequence = int.tryParse(match.group(2)!);
  if (parsedWorld != worldId || sequence == null) return null;
  if (worldId == 2) {
    if (sequence >= 1 && sequence <= 3) return _SessionRole.learn;
    if (sequence >= 4 && sequence <= 9) return _SessionRole.practice;
    if (sequence == 10) return _SessionRole.checkpoint;
    if (sequence >= 11 && sequence <= 13) return _SessionRole.practice;
    if (sequence == 14) return _SessionRole.checkpoint;
    return null;
  }
  if (worldId == 3) {
    if (sequence >= 1 && sequence <= 3) return _SessionRole.learn;
    if (sequence >= 4 && sequence <= 9) return _SessionRole.practice;
    if (sequence == 10) return _SessionRole.checkpoint;
    if (sequence >= 11 && sequence <= 13) return _SessionRole.practice;
    if (sequence == 14) return _SessionRole.checkpoint;
    return null;
  }
  if (sequence >= 1 && sequence <= 3) return _SessionRole.learn;
  if (sequence >= 4 && sequence <= 9) return _SessionRole.practice;
  if (sequence == 10) return _SessionRole.checkpoint;
  return null;
}

int _minWorldDrillsForWorld(int worldId) {
  if (worldId == 2) return 14;
  if (worldId == 3) return 14;
  return _kWorldMinTotalDrills;
}

int _minDrillsPerSessionForWorld(int worldId, String sessionId) {
  if (worldId == 2) return 1;
  if (worldId == 3) return 1;
  return _kMinDrillsPerSession;
}

int _maxDrillsPerSessionForWorld(int worldId, String sessionId) {
  if (worldId == 3) return 3;
  return _kMaxDrillsPerSession;
}

int _minRoleDrillsForWorld(int worldId, _SessionRole role) {
  if (worldId == 2) {
    switch (role) {
      case _SessionRole.learn:
        return 3;
      case _SessionRole.practice:
        return 9;
      case _SessionRole.checkpoint:
        return 2;
    }
  }
  if (worldId == 3) {
    switch (role) {
      case _SessionRole.learn:
        return 3;
      case _SessionRole.practice:
        return 9;
      case _SessionRole.checkpoint:
        return 2;
    }
  }
  switch (role) {
    case _SessionRole.learn:
      return _kLearnRoleMinTotalDrills;
    case _SessionRole.practice:
      return _kPracticeRoleMinTotalDrills;
    case _SessionRole.checkpoint:
      return _kCheckpointRoleMinTotalDrills;
  }
}

int _maxRoleDrillsForWorld(int worldId, _SessionRole role) {
  if (worldId == 3) {
    switch (role) {
      case _SessionRole.learn:
        return 9;
      case _SessionRole.practice:
        return 27;
      case _SessionRole.checkpoint:
        return 6;
    }
  }
  switch (role) {
    case _SessionRole.learn:
      return _kLearnRoleMaxTotalDrills;
    case _SessionRole.practice:
      return _kPracticeRoleMaxTotalDrills;
    case _SessionRole.checkpoint:
      return _kCheckpointRoleMaxTotalDrills;
  }
}

String _roleCoverageExpectationLabel(int worldId) {
  if (worldId == 2) {
    return 'Learn=s01..s03, Practice=s04..s09 and s11..s13, Checkpoint=s10 and s14';
  }
  if (worldId == 3) {
    return 'Learn=s01..s03, Practice=s04..s09 and s11..s13, Checkpoint=s10 and s14';
  }
  return 'Learn=s01..s03, Practice=s04..s09, Checkpoint=s10';
}

String _sessionRoleConventionExpectationLabel(int worldId) {
  if (worldId == 2 || worldId == 3) {
    return 'w$worldId.s01..w$worldId.s14';
  }
  return 'w$worldId.s01..w$worldId.s10';
}

bool _isAllowedHandChainExpectedAction({
  required String sessionId,
  required int stepIndex,
  required Map<String, dynamic> stepMap,
  required String expectedAction,
}) {
  if (_kRangeBucketActionsV1.contains(expectedAction)) {
    return true;
  }
  if (_isWorld2TailActorStep(sessionId, stepMap) &&
      (expectedAction == 'hero' || expectedAction == 'villain')) {
    return true;
  }
  if (_isWorld2TailOutsStep(sessionId, stepMap) &&
      _kOutsCountActionsV1.contains(expectedAction)) {
    return true;
  }
  if (_isWorld3TailPositionStep(sessionId, stepIndex, stepMap) &&
      (expectedAction == 'hero' || expectedAction == 'villain')) {
    return true;
  }
  return false;
}

String _expectedActionAllowanceSuffix(
  String sessionId,
  int stepIndex,
  Map<String, dynamic> stepMap,
) {
  if (_isWorld2TailActorStep(sessionId, stepMap)) {
    return ' (World 2 mixed tail actor steps also allow hero|villain)';
  }
  if (_isWorld2TailOutsStep(sessionId, stepMap)) {
    return ' (World 2 mixed tail outs steps also allow 4|8|9|15)';
  }
  if (_isWorld3TailPositionStep(sessionId, stepIndex, stepMap)) {
    return ' (World 3 tail step[0] also allows hero|villain)';
  }
  return '';
}

bool _isWorld2TailActorStep(String sessionId, Map<String, dynamic> stepMap) {
  if (!_kWorld2TailMixedSessionsV1.contains(sessionId)) return false;
  final availableActions = stepMap['available_actions_v1'];
  if (availableActions is! List) return false;
  final normalized = availableActions.whereType<String>().toSet();
  return normalized.length == 2 &&
      normalized.contains('hero') &&
      normalized.contains('villain');
}

bool _isWorld2TailOutsStep(String sessionId, Map<String, dynamic> stepMap) {
  if (!_kWorld2TailMixedSessionsV1.contains(sessionId)) return false;
  final availableActions = stepMap['available_actions_v1'];
  if (availableActions is! List) return false;
  final normalized = availableActions.whereType<String>().toSet();
  return normalized.length == _kOutsCountActionsV1.length &&
      normalized.containsAll(_kOutsCountActionsV1);
}

bool _isWorld3TailPositionStep(
  String sessionId,
  int stepIndex,
  Map<String, dynamic> stepMap,
) {
  if (!_kWorld3TailPositionSessionsV1.contains(sessionId)) return false;
  if (stepIndex != 0) return false;
  final availableActions = stepMap['available_actions_v1'];
  if (availableActions is! List) return false;
  final normalized = availableActions.whereType<String>().toSet();
  return normalized.length == 2 &&
      normalized.contains('hero') &&
      normalized.contains('villain');
}

bool _isStringListV1(Object? raw) {
  return raw is List && raw.every((item) => item is String);
}

bool _matchesExactStringSetV1(Object? raw, Set<String> expected) {
  if (raw is! List) return false;
  final normalized = raw.whereType<String>().toSet();
  return normalized.length == expected.length &&
      normalized.containsAll(expected);
}

bool _hasWorld0SeatShorthandPromptLeakV1({
  required String filePath,
  required Object? promptRaw,
}) {
  if (promptRaw is! String) return false;
  final normalizedPath = filePath.replaceAll('\\', '/');
  if (!normalizedPath.contains('content/worlds/world0/')) {
    return false;
  }
  final lowered = promptRaw.toLowerCase();
  return lowered.contains(' btn seat') ||
      lowered.contains(' sb seat') ||
      lowered.contains(' bb seat');
}

bool _hasWorld0BoardSlotPromptJargonLeakV1({
  required String filePath,
  required Object? promptRaw,
}) {
  if (promptRaw is! String) return false;
  final normalizedPath = filePath.replaceAll('\\', '/');
  if (!normalizedPath.contains('content/worlds/world0/')) {
    return false;
  }
  final lowered = promptRaw.toLowerCase();
  return lowered.contains('flop_left') ||
      lowered.contains('flop_mid') ||
      lowered.contains('left flop card slot') ||
      lowered.contains('middle flop card slot') ||
      lowered.contains('turn card slot') ||
      lowered.contains('river card slot');
}

bool _hasWorld0SeatIdPromptLeakV1({
  required String filePath,
  required Object? promptRaw,
}) {
  if (promptRaw is! String) return false;
  final normalizedPath = filePath.replaceAll('\\', '/');
  if (!normalizedPath.contains('content/worlds/world0/')) {
    return false;
  }
  return RegExp(r'\btap seat s\d\b', caseSensitive: false).hasMatch(promptRaw);
}

bool _hasWorld0SeatIdIndexLeakV1(String raw) {
  return RegExp(r'\btap seat s\d\b', caseSensitive: false).hasMatch(raw);
}

bool _hasWorld0ButtonSeatIndexLeakV1(String raw) {
  return raw.toLowerCase().contains('tap the button seat');
}

bool _hasWorld0DealerPositionIndexLeakV1(String raw) {
  return raw.toLowerCase().contains('dealer position');
}

bool _hasWorld0HoleCardsIndexLeakV1(String raw) {
  final lowered = raw.toLowerCase();
  return lowered.contains('left hole cards') ||
      lowered.contains('right hole cards');
}

bool _hasWorld0CurrentActorAreaLeakV1(String raw) {
  return raw.toLowerCase().contains('current actor area');
}

bool _hasWorld0TableMapLeakV1(String raw) {
  return raw.toLowerCase().contains('table map');
}

bool _hasWorld0SeatMapLeakV1(String raw) {
  return raw.toLowerCase().contains('seat map') ||
      raw.toLowerCase().contains('seat-map');
}

bool _hasWorld0ActionRowLeakV1(String raw) {
  return raw.toLowerCase().contains('action row');
}

bool _hasWorld0ActionLabelLeakV1(String raw) {
  final lowered = raw.toLowerCase();
  return lowered.contains('action label') || lowered.contains('action labels');
}

bool _hasWorld0ActorLanguageLeakV1(String raw) {
  final lowered = raw.toLowerCase();
  return lowered.contains('current actor') ||
      lowered.contains('actor detection') ||
      lowered.contains('highlighted actor') ||
      lowered.contains('confirm the actor') ||
      lowered.contains('checking the actor') ||
      lowered.contains(' actor-and-') ||
      lowered.contains(' actor,') ||
      lowered.contains(' actor and ');
}

bool _hasWorld0TableReadLeakV1(String raw) {
  return raw.toLowerCase().contains('table read');
}

bool _hasWorld0HeroAnchorLeakV1(String raw) {
  final lowered = raw.toLowerCase();
  return lowered.contains('hero-card anchor') ||
      lowered.contains('hero-card anchors') ||
      lowered.contains('hero hole-card anchor') ||
      lowered.contains('hero hole-card anchors');
}

bool _hasWorld0CheckpointMixLeakV1(String raw) {
  return raw.toLowerCase().contains('checkpoint mix');
}

bool _hasWorld0StreetFlowLeakV1(String raw) {
  final lowered = raw.toLowerCase();
  return lowered.contains('street flow') ||
      lowered.contains('street-flow') ||
      lowered.contains('street-order');
}

bool _hasWorld0HeroAnchorLeakInWhyV1(String filePath, Object? whyV1) {
  if (!filePath.replaceAll('\\', '/').contains('content/worlds/world0/')) {
    return false;
  }
  if (whyV1 is! String) return false;
  return _hasWorld0HeroAnchorLeakV1(whyV1);
}

bool _hasWorld0CheckpointMixLeakInWhyV1(String filePath, Object? whyV1) {
  if (!filePath.replaceAll('\\', '/').contains('content/worlds/world0/')) {
    return false;
  }
  if (whyV1 is! String) return false;
  return _hasWorld0CheckpointMixLeakV1(whyV1);
}

bool _hasExactCardListV1(Object? raw, int count) {
  if (raw is! List || raw.length != count) return false;
  return raw.every(
    (item) => item is String && _kCardIdV1Pattern.hasMatch(item),
  );
}

bool _hasBoardCardCountV1(Object? raw, Set<int> allowedCounts) {
  if (raw is! List || !allowedCounts.contains(raw.length)) return false;
  return raw.every(
    (item) => item is String && _kCardIdV1Pattern.hasMatch(item),
  );
}

enum _SessionRole { learn, practice, checkpoint }

String _sessionRoleLabel(_SessionRole role) {
  switch (role) {
    case _SessionRole.learn:
      return 'Learn';
    case _SessionRole.practice:
      return 'Practice';
    case _SessionRole.checkpoint:
      return 'Checkpoint';
  }
}
