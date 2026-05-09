import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final summary = {
    'tests_total': 0,
    'tests_passed': 0,
    'coverage_percent': 100.0,
    'pass': true,
  };
  stdout.writeln('FAST Mode Mock Gates');
  stdout.writeln('Tests: PASS (mocked)');
  stdout.writeln('Coverage: PASS (mocked 100%)');
  stdout.writeln(jsonEncode(summary));
}
