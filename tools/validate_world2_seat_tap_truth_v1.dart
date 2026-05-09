import 'dart:io';

import 'package:poker_analyzer/services/world2_seat_tap_truth_validator_v1.dart';

Future<void> main() async {
  final report = validateWorld2SeatTapTruthDirectoryV1(
    'content/worlds/world2/v1/sessions',
  );
  if (report.issues.isNotEmpty) {
    for (final issue in report.issues) {
      stderr.writeln('validate_world2_seat_tap_truth_v1: $issue');
    }
    stderr.writeln(
      'validate_world2_seat_tap_truth_v1: FAIL checked=${report.checkedCount} skipped=${report.skippedCount}',
    );
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'validate_world2_seat_tap_truth_v1: OK checked=${report.checkedCount} skipped=${report.skippedCount}',
  );
}
