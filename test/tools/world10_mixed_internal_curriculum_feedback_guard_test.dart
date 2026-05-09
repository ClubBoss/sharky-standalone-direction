import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'world10 mixed internal-curriculum subset stays learner-facing in mixed.s01-s10',
    () {
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
                'content/worlds/world10/v1/tracks/mixed/sessions/$sessionId/drills/d.tap_hole_left_anchor.json',
          )
          .toList(growable: false);

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final findings = report.findings
          .where(
            (item) => item.issueType == 'internal_curriculum_label_feedback',
          )
          .where(
            (item) => admittedPrefixes.any((prefix) => item.filePath == prefix),
          )
          .toList(growable: false);

      expect(
        findings,
        isEmpty,
        reason:
            'mixed.s01-s10 tap_hole_left anchors should no longer emit internal_curriculum_label_feedback.',
      );

      for (final sessionId in admittedSessions) {
        final file = File(
          '$repoRoot/content/worlds/world10/v1/tracks/mixed/sessions/$sessionId/drills/d.tap_hole_left_anchor.json',
        );
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
        final feedback = (json['feedback_incorrect_v1'] as String)
            .toLowerCase();

        expect(feedback.startsWith('incorrect.'), isTrue);
        expect(feedback.contains('left hole card'), isTrue);
        expect(feedback.contains('first private-card cue'), isTrue);
        expect(feedback.contains('mixed'), isTrue);

        expect(feedback.contains('tap hole_left first'), isFalse);
        expect(feedback.contains('hand cue'), isFalse);
        expect(feedback.contains('spot is asking you to track'), isFalse);
        expect(feedback.contains('curriculum'), isFalse);
        expect(feedback.contains('lesson'), isFalse);
      }
    },
  );
}
