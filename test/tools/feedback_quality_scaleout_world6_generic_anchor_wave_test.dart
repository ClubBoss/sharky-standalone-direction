import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test('world6 generic-anchor wave stays poker-reasoned in w6.s06-w6.s07', () {
    final repoRoot = Directory.current.path;
    final admittedSessions = <String>['w6.s06', 'w6.s07'];
    final admittedPrefixes = admittedSessions
        .map(
          (sessionId) => 'content/worlds/world6/v1/sessions/$sessionId/drills/',
        )
        .toList(growable: false);

    final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
    final genericAnchorFindings = report.findings
        .where((item) => item.issueType == 'generic_anchor_feedback')
        .where(
          (item) => admittedPrefixes.any(
            (prefix) => item.filePath.startsWith(prefix),
          ),
        )
        .toList(growable: false);

    expect(
      genericAnchorFindings,
      isEmpty,
      reason: 'w6.s06-w6.s07 should no longer emit generic_anchor_feedback.',
    );

    const admittedFiles = <String, List<String>>{
      'w6.s06': <String>[
        'd.find_btn_ip_range.json',
        'd.find_co_ip_range.json',
        'd.tap_flop_ip_range.json',
        'd.tap_hole_left_ip_range.json',
        'd.tap_river_ip_range.json',
        'd.tap_turn_ip_range.json',
      ],
      'w6.s07': <String>[
        'd.find_bb_oop_range.json',
        'd.find_sb_oop_range.json',
        'd.tap_flop_oop_range.json',
        'd.tap_hole_right_oop_range.json',
        'd.tap_river_oop_range.json',
        'd.tap_turn_oop_range.json',
      ],
    };

    const bannedFragments = <String>[
      'tap the button first',
      'tap the cutoff',
      'tap the big blind first',
      'tap the small blind first',
      'tap the left flop card first',
      'tap the right flop card first',
      'tap the turn card first',
      'tap the river card first',
      'tap the left hole card first',
      'tap the right hole card first',
    ];

    for (final sessionEntry in admittedFiles.entries) {
      for (final fileName in sessionEntry.value) {
        final file = File(
          '$repoRoot/content/worlds/world6/v1/sessions/${sessionEntry.key}/drills/$fileName',
        );
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
        final kind = json['kind'] as String;
        final feedback = (json['feedback_incorrect_v1'] as String)
            .toLowerCase();

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
              reason:
                  '${file.path} should name the correct seat or role anchor.',
            );
            break;
          case 'board_tap':
            final boardSlot =
                (json['expected'] as Map<String, Object?>)['boardSlot']
                    as String;
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
    }
  });
}

String _roleName(String code) {
  switch (code) {
    case 'btn':
      return 'button';
    case 'co':
      return 'cutoff';
    case 'sb':
      return 'small blind';
    case 'bb':
      return 'big blind';
  }
  return code;
}

String _boardSlotName(String boardSlot) {
  switch (boardSlot) {
    case 'flop_left':
      return 'left flop card';
    case 'flop_mid':
      return 'middle flop card';
    case 'flop_right':
      return 'right flop card';
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
