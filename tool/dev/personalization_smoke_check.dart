import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/personalization/personalization_next_action_router_v1.dart';

int _fail(String message) {
  stderr.writeln(message);
  exitCode = 2;
  return 2;
}

Future<int> main(List<String> args) async {
  if (args.length != 2 || args[0] != '--json') {
    return _fail(
      'ERROR: Usage: dart tool/dev/personalization_smoke_check.dart --json <json>',
    );
  }
  final payload = args[1];
  Map<String, dynamic>? decoded;
  try {
    decoded = jsonDecode(payload) as Map<String, dynamic>?;
  } catch (_) {
    return _fail('ERROR: invalid JSON payload');
  }
  if (decoded == null ||
      decoded['schema'] != 'personalization_next_action_v1') {
    return _fail('ERROR: missing personalization_next_action_v1 schema');
  }
  final action = decoded['next_action'];
  if (action is! String || action.isEmpty) {
    return _fail(
      'ERROR: next_action must be a non-empty string (${action.runtimeType})',
    );
  }
  if (action == 'idle') {
    stdout.writeln('NOTE: idle action requires no routing');
    return 0;
  }
  if (!isRoutableNextAction(action)) {
    return _fail('ERROR: next_action=$action is not routable');
  }
  stdout.writeln('OK: next_action=$action is routable');
  return 0;
}
