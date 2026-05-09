import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/product_surface_audit_v1.dart';

void main() {
  test(
    'current repo report is deterministic and exposes first-user spine summary',
    () {
      final first = buildProductSurfaceAuditReportV1();
      final second = buildProductSurfaceAuditReportV1();

      expect(
        encodeProductSurfaceAuditReportJsonV1(first),
        encodeProductSurfaceAuditReportJsonV1(second),
      );
      expect(
        renderProductSurfaceAuditReportV1(first),
        renderProductSurfaceAuditReportV1(second),
      );
      expect(first.summary.totalIssues, greaterThanOrEqualTo(0));
      expect(
        first.summary.familyCounts.keys,
        containsAll(<String>[
          'today_plan_intake',
          'first_user_intro_trust_primer',
          'runner_prompt_table_surface',
          'result_next_step_surface',
          'premium_trial_access_state_surface',
        ]),
      );
      expect(first.summary.firstUserSpineFamilyCounts, isNotEmpty);
      expect(
        renderProductSurfaceAuditReportV1(first),
        contains('PRODUCT_SURFACE_AUDIT_V1'),
      );
      expect(
        renderProductSurfaceAuditReportV1(first),
        contains('FIRST_USER_SPINE_TOTAL'),
      );
    },
  );

  test('synthetic repo surfaces missing seams and internal token leakage', () {
    final tempRoot = Directory.systemTemp.createTempSync(
      'product_surface_audit_v1_',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    _writeFile(
      tempRoot,
      'docs/plan/PRODUCT_SURFACE_READINESS_v1.md',
      '# synthetic truth\n',
    );
    _writeFile(
      tempRoot,
      'lib/ui_v2/screens/universal_intake_plan_screen.dart',
      '''
class SyntheticTodayPlanScreen {
  final String title = "Tap seat anchor now.";
}
''',
    );

    final report = buildProductSurfaceAuditReportV1(
      rootPath: tempRoot.path,
      familyFilter: 'today',
    );

    expect(report.inspectedFamilies, <String>['today_plan_intake']);
    expect(
      report.findings.any(
        (finding) => finding.reasonCode == 'missing_required_test_seam',
      ),
      isTrue,
    );
    expect(
      report.findings.any(
        (finding) => finding.reasonCode == 'internal_token_leakage_candidate',
      ),
      isTrue,
    );
    expect(
      report.findings.any(
        (finding) => finding.reasonCode == 'missing_rendered_text_safety_seam',
      ),
      isTrue,
    );
    expect(
      report.findings.any(
        (finding) => finding.reasonCode == 'degraded_state_coverage_gap',
      ),
      isTrue,
    );
    expect(
      report.summary.failureClassCounts['copy_language_problem'],
      greaterThanOrEqualTo(1),
    );
    expect(
      report.summary.fixStrategyCounts.keys,
      containsAll(<String>['copy fix', 'layout fix']),
    );
  });

  test(
    'synthetic runner repo surfaces early-world feedback leakage and rendered seam gaps',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'product_surface_audit_v1_runner_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeFile(
        tempRoot,
        'docs/plan/PRODUCT_SURFACE_READINESS_v1.md',
        '# synthetic truth\n',
      );
      _writeFile(
        tempRoot,
        'lib/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart',
        'class RunnerHostPromptRevealPresentationV1 {}\n',
      );
      _writeFile(
        tempRoot,
        'lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart',
        '''
class World1FoundationsMicroTaskRunnerSurfaceV1 {
  final String feedbackSlice = 'slice: World1SeatQuizFeedbackSliceV1.generic';
  final String checkpointTone = 'Checkpoint: review your top mistakes.';
  final List<String> outcomeLines = <String>['Correct.', 'Incorrect.'];
  final String genericFollowUp = 'Improve \$categoryLabel decisions next.';
  final String genericCategory = 'Category: \$categoryLabel';
}
''',
      );
      _writeFile(
        tempRoot,
        'lib/campaign/world1_scenario_truth_pilot_v1.dart',
        '''
class World1ScenarioTruthPilotV1 {
  final String feedbackIncorrectV1 =
      'Legal, but worse than our recommended play.';
}
''',
      );
      _writeFile(
        tempRoot,
        'lib/ui_v2/runner/world1_hand_loop_feedback_copy_v1.dart',
        '''
String buildFixLine() {
  return 'Fix: Choose the expected action before you continue.';
}
''',
      );
      _writeFile(
        tempRoot,
        'lib/ui_v2/runner/world1_seat_quiz_feedback_copy_v1.dart',
        '''
enum World1SeatQuizFeedbackSliceV1 { generic }

String resolveWorld1SeatQuizMismatchFixLineV1() {
  switch (World1SeatQuizFeedbackSliceV1.generic) {
    case World1SeatQuizFeedbackSliceV1.generic:
      return 'Fix: Start from the seat anchor, then follow seat order.';
  }
}
''',
      );

      final report = buildProductSurfaceAuditReportV1(
        rootPath: tempRoot.path,
        familyFilter: 'runner',
      );

      expect(report.inspectedFamilies, <String>['runner_prompt_table_surface']);
      expect(
        report.findings.any(
          (finding) => finding.reasonCode == 'wrong_feedback_family_mapping',
        ),
        isTrue,
      );
      expect(
        report.findings.any(
          (finding) => finding.reasonCode == 'legacy_feedback_leak',
        ),
        isTrue,
      );
      expect(
        report.findings.any(
          (finding) => finding.reasonCode == 'ungated_generic_outcome_copy',
        ),
        isTrue,
      );
      expect(
        report.findings.any(
          (finding) =>
              finding.reasonCode == 'ungated_legal_suboptimal_outcome_copy',
        ),
        isTrue,
      );
      expect(
        report.findings.any(
          (finding) => finding.reasonCode == 'early_world_tone_mismatch',
        ),
        isTrue,
      );
      expect(
        report.findings.any(
          (finding) => finding.reasonCode == 'generic_category_followup_copy',
        ),
        isTrue,
      );
      expect(
        report.findings.any(
          (finding) =>
              finding.reasonCode == 'missing_rendered_text_safety_seam',
        ),
        isTrue,
      );
      expect(
        report.summary.failureClassCounts.keys,
        containsAll(<String>[
          'stage_inappropriate_feedback',
          'legacy_feedback_leak',
          'ungated_generic_outcome_copy',
          'early_world_tone_mismatch',
          'missing_rendered_text_safety_seam',
        ]),
      );
    },
  );

  test('json output exposes grouped counts and top-level shape', () {
    final report = buildProductSurfaceAuditReportV1();
    final decoded =
        jsonDecode(encodeProductSurfaceAuditReportJsonV1(report))
            as Map<String, Object?>;
    final summary = decoded['summary'] as Map<String, Object?>;

    expect(decoded['version'], 'PRODUCT_SURFACE_AUDIT_V1');
    expect(decoded['inspected_families'], isA<List<Object?>>());
    expect(decoded['findings'], isA<List<Object?>>());
    expect(summary['total_issues'], isA<int>());
    expect(summary['family_counts'], isA<Map<String, Object?>>());
    expect(summary['severity_counts'], isA<Map<String, Object?>>());
    expect(summary['failure_class_counts'], isA<Map<String, Object?>>());
    expect(summary['fix_strategy_counts'], isA<Map<String, Object?>>());
    expect(summary['first_user_spine_total'], isA<int>());
    expect(summary['top_clusters'], isA<List<Object?>>());
  });
}

void _writeFile(Directory root, String relativePath, String contents) {
  final file = File('${root.path}/$relativePath');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}
