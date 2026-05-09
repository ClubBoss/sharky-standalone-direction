import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'alpha feedback report surfaces flow/scenario/steps for unclear items',
    () async {
      final tmp = File(
        '${Directory.systemTemp.path}/alpha_feedback_report_test.jsonl',
      );
      final lines = [
        // Clear entry with context (should not show in unclear group).
        '{"classification":"clear","flow_id":"flowA","scenario_id":"scenario1","scenario_title":"Onboarding","step_index":1,"step_total":3}',
        // Unclear entries for same scenario with different steps.
        '{"classification":"unclear","flow_id":"flowA","scenario_id":"scenario1","scenario_title":"Onboarding","step_index":1,"step_total":3}',
        '{"classification":"UNCLEAR","flow_id":"flowA","scenario_id":"scenario1","scenario_title":"Onboarding","step_index":2,"step_total":3}',
        // Unclear entry with only scenario_id.
        '{"classification":"unclear","flow_id":"flowB","scenario_id":"s2","step_index":4}',
        // Legacy entry without context should not crash.
        '{"classification":"unclear"}',
      ];
      await tmp.writeAsString(lines.join('\n'));

      final result = await Process.run('dart', [
        'run',
        'tools/alpha_feedback_report.dart',
        '--file',
        tmp.path,
      ]);

      expect(result.exitCode, 0);
      final output = result.stdout.toString();

      expect(output, contains('flow=flowA scenario=Onboarding'));
      expect(output, contains('count=2'));
      expect(output, contains('steps=[1/3, 2/3]'));

      expect(output, contains('flow=flowB scenario=s2 count=1'));
      expect(output, contains('steps=[4]'));

      // Legacy entry aggregates under unknowns but does not break output.
      expect(output, contains('flow=unknown scenario=unknown'));
    },
  );
}
