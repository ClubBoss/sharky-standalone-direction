import 'dart:convert';

import 'package:test/test.dart';

import '../../tools/canonical_trust_inspector_v1.dart';

void main() {
  test('canonical trust inspector v1 is deterministic on current repo', () {
    final first = buildCanonicalTrustInspectorReportV1();
    final second = buildCanonicalTrustInspectorReportV1();

    expect(
      encodeCanonicalTrustInspectorReportJsonV1(first),
      encodeCanonicalTrustInspectorReportJsonV1(second),
    );
    expect(
      renderCanonicalTrustInspectorReportV1(first),
      renderCanonicalTrustInspectorReportV1(second),
    );
  });

  test(
    'canonical trust inspector v1 stays clean on accepted learner trust seams',
    () {
      final report = buildCanonicalTrustInspectorReportV1();

      expect(report.summary.inspectedEntityCount, greaterThan(0));
      expect(
        report.inspectedEntities,
        contains('next_target:learning_path_summary_cache_v2'),
      );
      expect(
        report.inspectedEntities,
        contains('action_surface:session_result_screen_v1'),
      );
      expect(
        report.inspectedEntities,
        contains('handoff_surface:drill_runner_to_session_result_v1'),
      );
      expect(report.issues, isEmpty);
      expect(report.summary.totalIssues, 0);
      expect(report.summary.reasonCounts, isEmpty);
    },
  );

  test(
    'canonical trust inspector v1 json payload exposes bounded issue families',
    () {
      final decoded =
          jsonDecode(
                encodeCanonicalTrustInspectorReportJsonV1(
                  buildCanonicalTrustInspectorReportV1(),
                ),
              )
              as Map<String, dynamic>;

      expect(decoded['version'], 'v1');
      expect(decoded['summary'], isA<Map<String, dynamic>>());
      expect(decoded['inspected_entities'], isA<List<dynamic>>());
      expect(decoded['issues'], isA<List<dynamic>>());
    },
  );
}
