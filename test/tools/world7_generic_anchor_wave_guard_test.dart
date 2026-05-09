import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'world7 generic-anchor family stays learner-facing in w7.s03 and w7.s05-w7.s08',
    () {
      final repoRoot = Directory.current.path;
      final admittedSessions = <String>[
        'w7.s03',
        'w7.s05',
        'w7.s06',
        'w7.s07',
        'w7.s08',
      ];
      final admittedPrefixes = admittedSessions
          .map(
            (sessionId) =>
                'content/worlds/world7/v1/sessions/$sessionId/drills/',
          )
          .toList(growable: false);

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final findings = report.findings
          .where((item) => item.issueType == 'generic_anchor_feedback')
          .where(
            (item) => admittedPrefixes.any(
              (prefix) => item.filePath.startsWith(prefix),
            ),
          )
          .toList(growable: false);

      expect(
        findings,
        isEmpty,
        reason:
            'w7.s03 and w7.s05-w7.s08 should no longer emit generic_anchor_feedback.',
      );

      for (final sessionId in admittedSessions) {
        final sessionDir = Directory(
          '$repoRoot/content/worlds/world7/v1/sessions/$sessionId/drills',
        );
        for (final entity in sessionDir.listSync().whereType<File>()) {
          final fileName = entity.uri.pathSegments.last;
          if (!fileName.startsWith('d.') || !fileName.endsWith('.json')) {
            continue;
          }

          final json =
              jsonDecode(entity.readAsStringSync()) as Map<String, Object?>;
          final kind = json['kind'] as String;
          if (kind != 'seat_tap' &&
              kind != 'board_tap' &&
              kind != 'hole_cards_tap') {
            continue;
          }

          final feedback = (json['feedback_incorrect_v1'] as String)
              .toLowerCase();
          expect(feedback.startsWith('incorrect.'), isTrue);
          expect(feedback.contains('because'), isTrue);
          expect(feedback.contains('is the right anchor here'), isTrue);

          expect(feedback.contains('find the '), isFalse);
          expect(feedback.contains('tap the '), isFalse);
          expect(feedback.contains('tap the ace of spades first'), isFalse);
          expect(feedback.contains('tap the river first'), isFalse);
          expect(feedback.contains('tap the turn first'), isFalse);
          expect(feedback.contains('find the big blind first'), isFalse);
          expect(feedback.contains('find the button first'), isFalse);

          switch (kind) {
            case 'seat_tap':
              final expected = json['expected'] as Map<String, Object?>;
              final role = expected['role'] as String?;
              final seatId = expected['seatId'] as String?;
              final expectedLabel = role == null
                  ? seatId!.toLowerCase()
                  : _roleName(role);
              expect(feedback.contains(expectedLabel), isTrue);
              break;
            case 'board_tap':
              final boardSlot =
                  (json['expected'] as Map<String, Object?>)['boardSlot']
                      as String;
              expect(feedback.contains(_boardSlotName(boardSlot)), isTrue);
              break;
            case 'hole_cards_tap':
              final expected = json['expected'] as Map<String, Object?>;
              final cardId = expected['cardId'] as String?;
              final cardSlot = expected['cardSlot'] as String?;
              final expectedLabel = cardId == null
                  ? _cardSlotName(cardSlot!)
                  : _cardIdName(cardId);
              expect(feedback.contains(expectedLabel), isTrue);
              break;
          }
        }
      }
    },
  );
}

String _roleName(String code) {
  switch (code) {
    case 'bb':
      return 'big blind';
    case 'sb':
      return 'small blind';
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
    case 'flop_mid':
      return 'middle flop card';
    case 'flop_right':
      return 'right flop card';
    case 'turn':
      return 'turn';
    case 'river':
      return 'river';
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

String _cardIdName(String cardId) {
  switch (cardId) {
    case 'As':
      return 'ace of spades';
  }
  return cardId.toLowerCase();
}
