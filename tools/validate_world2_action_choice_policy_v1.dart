import 'dart:io';

import 'package:poker_analyzer/services/world2_action_choice_policy_validator_v1.dart';

Future<void> main() async {
  final report = validateWorld2ActionChoicePolicyDirectoryV1(
    'content/worlds/world2/v1',
  );
  if (report.issues.isNotEmpty) {
    for (final issue in report.issues) {
      stderr.writeln('validate_world2_action_choice_policy_v1: $issue');
    }
    for (final source in report.excludedSources) {
      stderr.writeln(
        'validate_world2_action_choice_policy_v1: excluded $source: ${report.excludedReasons[source]}',
      );
    }
    stderr.writeln(
      'validate_world2_action_choice_policy_v1: FAIL checked=${report.checkedCount} excluded=${report.excludedCount} issues=${report.issues.length}',
    );
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'validate_world2_action_choice_policy_v1: OK checked=${report.checkedCount} excluded=${report.excludedCount}',
  );
}
