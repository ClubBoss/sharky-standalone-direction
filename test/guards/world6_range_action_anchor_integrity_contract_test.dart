import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _admittedWorld6RangeFiles = <String>[
  'content/worlds/world6/v1/sessions/w6.s06/drills/d.choose_call_ip_range.json',
  'content/worlds/world6/v1/sessions/w6.s06/drills/d.choose_raise_ip_range.json',
  'content/worlds/world6/v1/sessions/w6.s06/drills/d.find_btn_ip_range.json',
  'content/worlds/world6/v1/sessions/w6.s06/drills/d.find_co_ip_range.json',
  'content/worlds/world6/v1/sessions/w6.s06/drills/d.tap_flop_ip_range.json',
  'content/worlds/world6/v1/sessions/w6.s06/drills/d.tap_hole_left_ip_range.json',
  'content/worlds/world6/v1/sessions/w6.s06/drills/d.tap_river_ip_range.json',
  'content/worlds/world6/v1/sessions/w6.s06/drills/d.tap_turn_ip_range.json',
  'content/worlds/world6/v1/sessions/w6.s07/drills/d.choose_call_oop_range.json',
  'content/worlds/world6/v1/sessions/w6.s07/drills/d.choose_fold_oop_range.json',
  'content/worlds/world6/v1/sessions/w6.s07/drills/d.find_bb_oop_range.json',
  'content/worlds/world6/v1/sessions/w6.s07/drills/d.find_sb_oop_range.json',
  'content/worlds/world6/v1/sessions/w6.s07/drills/d.tap_flop_oop_range.json',
  'content/worlds/world6/v1/sessions/w6.s07/drills/d.tap_hole_right_oop_range.json',
  'content/worlds/world6/v1/sessions/w6.s07/drills/d.tap_river_oop_range.json',
  'content/worlds/world6/v1/sessions/w6.s07/drills/d.tap_turn_oop_range.json',
];

const _genericIncorrectTemplates = <String>{
  'Incorrect. This spot expects a different action.',
  'Incorrect. This step expects the target board card.',
  'Incorrect. This step expects the target seat anchor.',
  'Incorrect. This step expects the target hole card.',
};

Map<String, dynamic> _loadJson(String relativePath) {
  final file = File(relativePath);
  expect(
    file.existsSync(),
    isTrue,
    reason: 'Missing admitted file: $relativePath',
  );
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

String _normalized(String value) => value.trim().toLowerCase();

String _expectedAction(Map<String, dynamic> data) {
  final topLevel = data['expected_action'];
  if (topLevel is String && topLevel.trim().isNotEmpty) {
    return _normalized(topLevel);
  }
  final nested = data['expected'];
  if (nested is Map<String, dynamic>) {
    final actionId = nested['actionId'];
    if (actionId is String && actionId.trim().isNotEmpty) {
      return _normalized(actionId);
    }
  }
  return '';
}

List<String> _availableActions(Map<String, dynamic> data) {
  final raw = data['available_actions_v1'];
  if (raw is! List) return const <String>[];
  return raw.map((entry) => _normalized(entry.toString())).toList();
}

String _expectedRolePhrase(Map<String, dynamic> data) {
  final expected = data['expected'];
  if (expected is! Map<String, dynamic>) return '';
  switch (_normalized((expected['role'] ?? '').toString())) {
    case 'btn':
      return 'button';
    case 'co':
      return 'cutoff';
    case 'bb':
      return 'big blind';
    case 'sb':
      return 'small blind';
    default:
      return '';
  }
}

List<String> _expectedBoardKeywords(Map<String, dynamic> data) {
  final expected = data['expected'];
  if (expected is! Map<String, dynamic>) return const <String>[];
  switch (_normalized((expected['boardSlot'] ?? '').toString())) {
    case 'flop_left':
      return const <String>['flop', 'left'];
    case 'flop_right':
      return const <String>['flop', 'right'];
    case 'turn':
      return const <String>['turn'];
    case 'river':
      return const <String>['river'];
    default:
      return const <String>[];
  }
}

List<String> _expectedHoleKeywords(Map<String, dynamic> data) {
  final expected = data['expected'];
  if (expected is! Map<String, dynamic>) return const <String>[];
  switch (_normalized((expected['cardSlot'] ?? '').toString())) {
    case 'p0':
      return const <String>['left', 'hole card'];
    case 'p1':
      return const <String>['right', 'hole card'];
    default:
      return const <String>[];
  }
}

void main() {
  test('world6 ip-oop range action-anchor content stays learner-truthful', () {
    for (final path in _admittedWorld6RangeFiles) {
      final data = _loadJson(path);
      final prompt = (data['prompt'] ?? '').toString().trim();
      final errorClass = (data['error_class'] ?? '').toString().trim();
      final why = (data['why_v1'] ?? '').toString().trim();
      final correct = (data['feedback_correct_v1'] ?? '').toString().trim();
      final incorrect = (data['feedback_incorrect_v1'] ?? '').toString().trim();
      final promptLower = _normalized(prompt);
      final correctLower = _normalized(correct);
      final incorrectLower = _normalized(incorrect);

      expect(prompt, isNotEmpty, reason: '$path is missing prompt');
      expect(errorClass, isNotEmpty, reason: '$path is missing error_class');
      expect(why, isNotEmpty, reason: '$path is missing why_v1');
      expect(
        correct,
        isNotEmpty,
        reason: '$path is missing feedback_correct_v1',
      );
      expect(
        incorrect,
        isNotEmpty,
        reason: '$path is missing feedback_incorrect_v1',
      );
      expect(
        _genericIncorrectTemplates.contains(incorrect),
        isFalse,
        reason: '$path still uses a generic incorrect-feedback template',
      );

      if (errorClass == 'expected_action_mismatch') {
        final expectedAction = _expectedAction(data);
        final availableActions = _availableActions(data);
        expect(
          expectedAction,
          isNotEmpty,
          reason: '$path is missing expected action',
        );
        expect(
          availableActions,
          contains(expectedAction),
          reason:
              '$path must declare available_actions_v1 containing $expectedAction',
        );
        expect(
          RegExp('\\bchoose\\s+$expectedAction\\b').hasMatch(promptLower),
          isFalse,
          reason: '$path leaks the answer in prompt',
        );
        expect(
          incorrectLower,
          contains(expectedAction),
          reason: '$path incorrect feedback must name the expected action',
        );
        expect(
          correctLower,
          contains(expectedAction),
          reason: '$path correct feedback must name the confirmed action',
        );
        continue;
      }

      if (errorClass == 'anchor_order_mismatch') {
        final expectedRole = _expectedRolePhrase(data);
        expect(
          promptLower,
          contains('tap'),
          reason: '$path seat-anchor prompt should remain a tap instruction',
        );
        expect(
          expectedRole,
          isNotEmpty,
          reason: '$path is missing expected role',
        );
        expect(
          incorrectLower,
          contains(expectedRole),
          reason: '$path incorrect feedback must name the expected seat anchor',
        );
        expect(
          correctLower,
          contains(expectedRole),
          reason: '$path correct feedback must name the confirmed seat anchor',
        );
        continue;
      }

      if (errorClass == 'focus_anchor_mismatch') {
        final kind = (data['kind'] ?? '').toString().trim();
        if (kind == 'board_tap') {
          final keywords = _expectedBoardKeywords(data);
          expect(
            keywords,
            isNotEmpty,
            reason: '$path is missing expected board slot keywords',
          );
          for (final keyword in keywords) {
            expect(
              incorrectLower,
              contains(keyword),
              reason:
                  '$path incorrect feedback must name the expected board anchor',
            );
            expect(
              correctLower,
              contains(keyword),
              reason:
                  '$path correct feedback must name the confirmed board anchor',
            );
          }
        } else if (kind == 'hole_cards_tap') {
          final keywords = _expectedHoleKeywords(data);
          expect(
            keywords,
            isNotEmpty,
            reason: '$path is missing expected hole-card keywords',
          );
          for (final keyword in keywords) {
            expect(
              incorrectLower,
              contains(keyword),
              reason:
                  '$path incorrect feedback must name the expected hole-card anchor',
            );
            expect(
              correctLower,
              contains(keyword),
              reason:
                  '$path correct feedback must name the confirmed hole-card anchor',
            );
          }
        } else {
          fail('$path has unsupported focus_anchor_mismatch kind: $kind');
        }
      }
    }
  });
}
