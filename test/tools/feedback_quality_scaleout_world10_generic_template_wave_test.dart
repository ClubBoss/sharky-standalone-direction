import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'world10 generic-template wave stays poker-reasoned in w10.s02-w10.s10',
    () {
      final repoRoot = Directory.current.path;
      final admittedSessions = <String>[
        'w10.s02',
        'w10.s03',
        'w10.s04',
        'w10.s05',
        'w10.s06',
        'w10.s07',
        'w10.s08',
        'w10.s09',
        'w10.s10',
      ];
      final admittedPrefixes = admittedSessions
          .map(
            (sessionId) =>
                'content/worlds/world10/v1/sessions/$sessionId/drills/',
          )
          .toList(growable: false);

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final genericTemplateFindings = report.findings
          .where((item) => item.issueType == 'generic_template_feedback')
          .where(
            (item) => admittedPrefixes.any(
              (prefix) => item.filePath.startsWith(prefix),
            ),
          )
          .toList(growable: false);

      expect(
        genericTemplateFindings,
        isEmpty,
        reason:
            'w10.s02-w10.s10 should no longer emit generic_template_feedback.',
      );

      const bannedFragments = <String>[
        'this spot expects a different action.',
        'this step expects a different anchor.',
        'this step expects a different seat.',
      ];

      for (final sessionId in admittedSessions) {
        final sessionDir = Directory(
          '$repoRoot/content/worlds/world10/v1/sessions/$sessionId/drills',
        );
        final files =
            sessionDir
                .listSync()
                .whereType<File>()
                .where((file) => file.path.endsWith('.json'))
                .toList(growable: false)
              ..sort((a, b) => a.path.compareTo(b.path));

        expect(files, hasLength(8), reason: '$sessionId should keep 8 drills.');

        for (final file in files) {
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
            reason: '${file.path} should explain why the correction is better.',
          );
          expect(
            bannedFragments.any(feedback.contains),
            isFalse,
            reason: '${file.path} should not reuse generic template phrasing.',
          );
          switch (kind) {
            case 'action_choice':
              final actionId =
                  (json['expected'] as Map<String, Object?>)['actionId']
                      as String;
              expect(
                _actionMarkers(actionId).any(feedback.contains),
                isTrue,
                reason: '${file.path} should name the correct action.',
              );
              break;
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
              final cardId =
                  (json['expected'] as Map<String, Object?>)['cardId']
                      as String;
              expect(
                feedback.contains(_cardName(cardId)),
                isTrue,
                reason:
                    '${file.path} should name the correct hole-card anchor.',
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

List<String> _actionMarkers(String actionId) {
  switch (actionId) {
    case 'call':
      return const <String>['call', 'calling'];
    case 'raise':
      return const <String>['raise', 'raising'];
    case 'fold':
      return const <String>['fold', 'folding'];
  }
  return <String>[actionId];
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
