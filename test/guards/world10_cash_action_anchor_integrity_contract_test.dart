import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _admittedWorld10CashFiles = <String>[
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s06/drills/d.call.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s06/drills/d.find_role_anchor.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s06/drills/d.find_seat_anchor.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s06/drills/d.fold.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s06/drills/d.tap_flop_left_anchor.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s06/drills/d.tap_hole_left_anchor.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s06/drills/d.tap_river_anchor.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s06/drills/d.tap_turn_anchor.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s07/drills/d.call.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s07/drills/d.find_role_anchor.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s07/drills/d.find_seat_anchor.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s07/drills/d.raise.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s07/drills/d.tap_flop_left_anchor.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s07/drills/d.tap_hole_left_anchor.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s07/drills/d.tap_river_anchor.json',
  'content/worlds/world10/v1/tracks/cash/sessions/cash.s07/drills/d.tap_turn_anchor.json',
];

const _genericIncorrectTemplates = <String>{
  'Incorrect. This spot expects a different action.',
  'Incorrect. This spot expects a different seat.',
  'Incorrect. This spot expects a different anchor.',
};

const _genericCorrectTemplates = <String>{
  'Correct. Expected action is confirmed.',
  'Correct. Expected seat is confirmed.',
  'Correct. Expected anchor is confirmed.',
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
    case 'hj':
      return 'hijack';
    case 'co':
      return 'cutoff';
    default:
      return '';
  }
}

String _expectedSeatPhrase(Map<String, dynamic> data) {
  final expected = data['expected'];
  if (expected is! Map<String, dynamic>) return '';
  final seatId = (expected['seatId'] ?? '').toString().trim();
  return seatId.toLowerCase();
}

List<String> _expectedBoardKeywords(Map<String, dynamic> data) {
  final expected = data['expected'];
  if (expected is! Map<String, dynamic>) return const <String>[];
  switch (_normalized((expected['boardSlot'] ?? '').toString())) {
    case 'flop_left':
      return const <String>['left', 'flop'];
    case 'turn':
      return const <String>['turn'];
    case 'river':
      return const <String>['river'];
    default:
      return const <String>[];
  }
}

List<String> _expectedCardKeywords(Map<String, dynamic> data) {
  final expected = data['expected'];
  if (expected is! Map<String, dynamic>) return const <String>[];
  switch (_normalized((expected['cardSlot'] ?? '').toString())) {
    case 'hole_left':
      return const <String>['left', 'hole'];
    default:
      return const <String>[];
  }
}

void main() {
  test('world10 cash action-anchor content stays learner-truthful', () {
    for (final path in _admittedWorld10CashFiles) {
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
      expect(
        _genericCorrectTemplates.contains(correct),
        isFalse,
        reason: '$path still uses a generic correct-feedback template',
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
          RegExp('\\b$expectedAction\\b').hasMatch(promptLower),
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
        expect(
          promptLower,
          contains('tap'),
          reason: '$path anchor prompt should remain a tap instruction',
        );
        final expectedRole = _expectedRolePhrase(data);
        if (expectedRole.isNotEmpty) {
          expect(
            incorrectLower,
            contains(expectedRole),
            reason:
                '$path incorrect feedback must name the expected seat anchor',
          );
          expect(
            correctLower,
            contains(expectedRole),
            reason:
                '$path correct feedback must name the confirmed seat anchor',
          );
          continue;
        }
        final expectedSeat = _expectedSeatPhrase(data);
        expect(
          expectedSeat,
          isNotEmpty,
          reason: '$path is missing expected seat id',
        );
        expect(
          incorrectLower,
          contains(expectedSeat),
          reason: '$path incorrect feedback must name the expected seat id',
        );
        expect(
          correctLower,
          contains(expectedSeat),
          reason: '$path correct feedback must name the confirmed seat id',
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
          continue;
        }
        if (kind == 'card_tap') {
          final keywords = _expectedCardKeywords(data);
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
                  '$path incorrect feedback must name the expected card anchor',
            );
            expect(
              correctLower,
              contains(keyword),
              reason:
                  '$path correct feedback must name the confirmed card anchor',
            );
          }
          continue;
        }
      }

      fail('$path has unsupported integrity shape for this bounded validator');
    }
  });
}
