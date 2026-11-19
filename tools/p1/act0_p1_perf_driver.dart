import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  timeout: const Duration(minutes: 60),
  responseDataCallback: (data) async {
    final out = File('build/p1_perf_report.json');
    await out.create(recursive: true);
    await out.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  },
);
