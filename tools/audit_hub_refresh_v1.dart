import 'dart:convert';
import 'dart:io';

import 'audit_hub_service_v1.dart';

void main(List<String> args) {
  final timestampFlagIndex = args.indexOf('--timestamp');
  final timestamp = timestampFlagIndex != -1 &&
          timestampFlagIndex + 1 < args.length
      ? args[timestampFlagIndex + 1]
      : DateTime.now().toUtc().toIso8601String();

  final result = refreshAuditHubReadinessCalibrationSupportV1(
    timestampUtc: timestamp,
  );
  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert(result.toJson()),
  );
}
