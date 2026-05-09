import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test('world10 mixed seat-anchor family stays learner-facing in mixed.s01-s10', () {
    final repoRoot = Directory.current.path;
    final admittedSessions = <String>[
      'mixed.s01',
      'mixed.s02',
      'mixed.s03',
      'mixed.s04',
      'mixed.s05',
      'mixed.s06',
      'mixed.s07',
      'mixed.s08',
      'mixed.s09',
      'mixed.s10',
    ];
    final admittedPrefixes = admittedSessions
        .map(
          (sessionId) =>
              'content/worlds/world10/v1/tracks/mixed/sessions/$sessionId/drills/d.find_seat_anchor.json',
        )
        .toList(growable: false);

    final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
    final findings = report.findings
        .where((item) => item.issueType == 'generic_anchor_feedback')
        .where(
          (item) => admittedPrefixes.any((prefix) => item.filePath == prefix),
        )
        .toList(growable: false);

    expect(
      findings,
      isEmpty,
      reason:
          'mixed.s01-s10 d.find_seat_anchor should no longer emit generic_anchor_feedback.',
    );

    for (final sessionId in admittedSessions) {
      final file = File(
        '$repoRoot/content/worlds/world10/v1/tracks/mixed/sessions/$sessionId/drills/d.find_seat_anchor.json',
      );
      final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final feedback = (json['feedback_incorrect_v1'] as String).toLowerCase();

      expect(feedback.startsWith('incorrect.'), isTrue);
      expect(feedback.contains('seat s2'), isTrue);
      expect(feedback.contains('mixed decision'), isTrue);
      expect(feedback.contains('acting player'), isTrue);
      expect(feedback.contains('because'), isTrue);

      expect(feedback.contains('tap seat s2 first'), isFalse);
      expect(feedback.contains('stays attached'), isFalse);
      expect(feedback.contains('drifting to another seat'), isFalse);
    }
  });
}
