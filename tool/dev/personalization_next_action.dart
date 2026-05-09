import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/personalization/personalization_adapter_v1.dart';

Future<int> main(List<String> args) async {
  if (args.length != 2 || args[0] != '--input') {
    stderr.writeln(
      'Usage: dart tool/dev/personalization_next_action.dart --input <path>',
    );
    return 2;
  }
  final inputPath = args[1];
  final file = File(inputPath);
  if (!await file.exists()) {
    stderr.writeln('ERROR: input file not found: $inputPath');
    return 2;
  }
  Map<String, Object?>? lastReport;
  await for (final line
      in file
          .openRead()
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    try {
      final payload = jsonDecode(trimmed);
      if (payload is Map && payload['schema'] == 'phase_autopilot_report_v1') {
        lastReport = Map<String, Object?>.from(payload.cast<String, Object?>());
      }
    } catch (_) {
      continue;
    }
  }
  if (lastReport == null) {
    stderr.writeln('ERROR: phase_autopilot_report_v1 not found in $inputPath');
    exitCode = 2;
    return 2;
  }
  final decoded = lastReport;
  final recommendation = recommendFromReports(
    phase1ReportJson: decoded['phase1'] as Map<String, Object?>?,
    phase2ReportJson: decoded['phase2'] as Map<String, Object?>?,
    phase3ReportJson: decoded['phase3'] as Map<String, Object?>?,
  );
  final output = {
    'schema': 'personalization_next_action_v1',
    'next_action': recommendation.action.name,
    'reason': recommendation.reason,
  };
  stdout.writeln(jsonEncode(output));
  return 0;
}
