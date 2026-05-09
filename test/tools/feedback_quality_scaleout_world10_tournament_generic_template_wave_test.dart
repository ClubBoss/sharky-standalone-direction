import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'world10 tournament generic-template wave stays poker-reasoned in tournament.s01-tournament.s06',
    () {
      final repoRoot = Directory.current.path;
      final admittedSessions = <String>[
        'tournament.s01',
        'tournament.s02',
        'tournament.s03',
        'tournament.s04',
        'tournament.s05',
        'tournament.s06',
        'tournament.s07',
        'tournament.s08',
        'tournament.s09',
        'tournament.s10',
      ];
      final admittedPrefixes = admittedSessions
          .map(
            (sessionId) =>
                'content/worlds/world10/v1/tracks/tournament/sessions/$sessionId/drills/',
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
            'tournament.s01-tournament.s06 should no longer emit generic_template_feedback.',
      );

      const admittedFiles = <String>{
        'd.call.json',
        'd.raise.json',
        'd.bet.json',
        'd.check.json',
        'd.fold.json',
        'd.find_role_anchor.json',
        'd.find_seat_anchor.json',
        'd.tap_flop_left_anchor.json',
        'd.tap_turn_anchor.json',
        'd.tap_river_anchor.json',
        'd.tap_hole_left_anchor.json',
      };
      const bannedFragments = <String>[
        'this spot expects a different action.',
        'this spot expects a different anchor.',
        'this spot expects a different seat.',
        'this step expects the target seat anchor.',
        'this step expects the target board card.',
        'this step expects the target hole card.',
      ];

      for (final sessionId in admittedSessions) {
        final sessionDir = Directory(
          '$repoRoot/content/worlds/world10/v1/tracks/tournament/sessions/$sessionId/drills',
        );
        final files =
            sessionDir
                .listSync()
                .whereType<File>()
                .where((file) => admittedFiles.contains(_basename(file.path)))
                .toList(growable: false)
              ..sort((a, b) => a.path.compareTo(b.path));

        expect(
          files,
          isNotEmpty,
          reason: '$sessionId should retain the admitted drill family.',
        );

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

String _basename(String path) => path.split(Platform.pathSeparator).last;

String _roleName(String code) {
  switch (code) {
    case 'btn':
      return 'button';
    case 'co':
      return 'cutoff';
    case 'hj':
      return 'hijack';
    case 'utg':
      return 'under the gun';
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
    case 'bet':
      return const <String>['bet', 'betting'];
    case 'check':
      return const <String>['check', 'checking'];
    case 'fold':
      return const <String>['fold', 'folding'];
  }
  return <String>[actionId];
}

String _cardSlotName(String cardSlot) {
  switch (cardSlot) {
    case 'hole_left':
      return 'left hole card';
    case 'hole_right':
      return 'right hole card';
  }
  return cardSlot;
}
