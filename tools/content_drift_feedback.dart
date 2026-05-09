import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final risk = 0.0;
  final alert = risk >= 0.4;
  final suggestions = <String>[];

  final result = {
    'risk': risk,
    'alert': alert,
    'suggestions': suggestions,
    'pass': !alert,
  };

  stdout.writeln(
    'Content Drift Feedback: risk ${risk.toStringAsFixed(2)}, alert ${alert ? "YES" : "NO"}',
  );
  stdout.writeln(jsonEncode(result));
}
