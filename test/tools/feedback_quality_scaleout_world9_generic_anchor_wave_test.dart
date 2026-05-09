import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test('world9 generic-anchor wave stays poker-reasoned in w9.s07', () {
    final repoRoot = Directory.current.path;
    const admittedPrefix = 'content/worlds/world9/v1/sessions/w9.s07/drills/';

    final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
    final genericAnchorFindings = report.findings
        .where((item) => item.issueType == 'generic_anchor_feedback')
        .where((item) => item.filePath.startsWith(admittedPrefix))
        .toList(growable: false);

    expect(
      genericAnchorFindings,
      isEmpty,
      reason: 'w9.s07 should no longer emit generic_anchor_feedback.',
    );

    const admittedFiles = <String>[
      'd.find_btn_exploit_blocker.json',
      'd.find_seat_s5_exploit_blocker.json',
      'd.tap_flop_exploit_blocker.json',
      'd.tap_hole_left_exploit_blocker.json',
      'd.tap_river_exploit_blocker.json',
      'd.tap_turn_exploit_blocker.json',
    ];

    const bannedFragments = <String>[
      'find the button first',
      'find seat s5 first',
      'tap the middle flop card first',
      'tap the ace of spades first',
      'tap the river card first',
      'tap the turn card first',
    ];

    for (final fileName in admittedFiles) {
      final file = File('$repoRoot/$admittedPrefix$fileName');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final kind = json['kind'] as String;
      final feedback = (json['feedback_incorrect_v1'] as String).toLowerCase();

      expect(
        feedback.startsWith('incorrect.'),
        isTrue,
        reason: '${file.path} should keep the incorrect-feedback prefix.',
      );
      expect(
        feedback.contains('because'),
        isTrue,
        reason: '${file.path} should explain why the anchor matters.',
      );
      expect(
        bannedFragments.any(feedback.contains),
        isFalse,
        reason: '${file.path} should not reuse generic anchor phrasing.',
      );

      switch (kind) {
        case 'seat_tap':
          final expected = json['expected'] as Map<String, Object?>;
          final role = expected['role'] as String?;
          final seatId = expected['seatId'] as String?;
          final expectedSeatLabel = role == null
              ? seatId!.toLowerCase()
              : _roleName(role);
          expect(
            feedback.contains(expectedSeatLabel),
            isTrue,
            reason: '${file.path} should name the correct seat or role anchor.',
          );
          break;
        case 'board_tap':
          final boardSlot =
              (json['expected'] as Map<String, Object?>)['boardSlot'] as String;
          expect(
            feedback.contains(_boardSlotName(boardSlot)),
            isTrue,
            reason: '${file.path} should name the correct board anchor.',
          );
          break;
        case 'hole_cards_tap':
          final expected = json['expected'] as Map<String, Object?>;
          final cardId = expected['cardId'] as String?;
          final cardSlot = expected['cardSlot'] as String;
          final expectedMarker = cardId == null
              ? _cardSlotName(cardSlot)
              : _cardName(cardId);
          expect(
            feedback.contains(expectedMarker),
            isTrue,
            reason: '${file.path} should name the correct hole-card anchor.',
          );
          break;
        default:
          fail('Unhandled drill kind $kind for ${file.path}');
      }
    }
  });
}

String _roleName(String code) {
  switch (code) {
    case 'btn':
      return 'button';
  }
  return code;
}

String _boardSlotName(String boardSlot) {
  switch (boardSlot) {
    case 'flop_mid':
      return 'middle flop card';
    case 'turn':
      return 'turn card';
    case 'river':
      return 'river card';
  }
  return boardSlot;
}

String _cardSlotName(String cardSlot) {
  switch (cardSlot) {
    case 'p0':
      return 'left hole card';
    case 'p1':
      return 'right hole card';
  }
  return cardSlot;
}

String _cardName(String cardId) {
  final rank = switch (cardId[0]) {
    'A' => 'ace',
    'K' => 'king',
    'Q' => 'queen',
    'J' => 'jack',
    'T' => 'ten',
    '9' => 'nine',
    '8' => 'eight',
    '7' => 'seven',
    '6' => 'six',
    '5' => 'five',
    '4' => 'four',
    '3' => 'three',
    '2' => 'two',
    _ => cardId[0],
  };
  final suit = switch (cardId[1]) {
    's' => 'spades',
    'h' => 'hearts',
    'd' => 'diamonds',
    'c' => 'clubs',
    _ => cardId[1],
  };
  return '$rank of $suit';
}
