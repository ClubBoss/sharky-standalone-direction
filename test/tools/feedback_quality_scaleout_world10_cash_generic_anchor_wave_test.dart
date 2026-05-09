import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'world10 cash generic-anchor wave stays poker-reasoned in cash.s01, cash.s02, cash.s03, cash.s04, cash.s05, cash.s06, cash.s07, cash.s08, and cash.s09',
    () {
      final repoRoot = Directory.current.path;
      final admittedSessions = <String>[
        'cash.s01',
        'cash.s02',
        'cash.s03',
        'cash.s04',
        'cash.s05',
        'cash.s06',
        'cash.s07',
        'cash.s08',
        'cash.s09',
      ];
      final admittedPrefixes = admittedSessions
          .map(
            (sessionId) =>
                'content/worlds/world10/v1/tracks/cash/sessions/$sessionId/drills/',
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
        reason:
            'cash.s01, cash.s02, cash.s03, cash.s04, cash.s05, cash.s06, cash.s07, cash.s08, and cash.s09 should no longer emit generic_anchor_feedback.',
      );

      const admittedFiles = <String>[
        'd.find_role_anchor.json',
        'd.find_seat_anchor.json',
        'd.tap_flop_left_anchor.json',
        'd.tap_hole_left_anchor.json',
        'd.tap_river_anchor.json',
        'd.tap_turn_anchor.json',
      ];

      const bannedFragments = <String>[
        'tap the button first',
        'tap the button because',
        'tap the hijack first',
        'tap the hijack because',
        'tap seat s2 first',
        'tap seat s2 because',
        'tap the left flop card first',
        'tap the left flop card because',
        'tap the left hole card first',
        'tap the left hole card because',
        'tap the turn card first',
        'tap the turn card because',
        'tap the river card first',
        'tap the river card because',
      ];

      for (final sessionId in admittedSessions) {
        for (final fileName in admittedFiles) {
          final file = File(
            '$repoRoot/content/worlds/world10/v1/tracks/cash/sessions/$sessionId/drills/$fileName',
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
            case 'card_tap':
              final cardSlot =
                  (json['expected'] as Map<String, Object?>)['cardSlot']
                      as String;
              expect(
                feedback.contains(_cardSlotName(cardSlot)),
                isTrue,
                reason: '${file.path} should name the correct card anchor.',
              );
              break;
            default:
              fail('Unhandled drill kind $kind for ${file.path}');
          }
        }
      }
    },
  );
}

String _roleName(String code) {
  switch (code) {
    case 'btn':
      return 'button';
    case 'co':
      return 'cutoff';
    case 'hj':
      return 'hijack';
  }
  return code;
}

String _boardSlotName(String boardSlot) {
  switch (boardSlot) {
    case 'flop_left':
      return 'left flop card';
    case 'turn':
      return 'turn card';
    case 'river':
      return 'river card';
  }
  return boardSlot;
}

String _cardSlotName(String cardSlot) {
  switch (cardSlot) {
    case 'hole_left':
      return 'left hole card';
  }
  return cardSlot;
}
