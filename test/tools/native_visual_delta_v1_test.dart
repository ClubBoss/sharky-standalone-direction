import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';

void main() {
  test(
    'delta transport requires a truthful explicit World-3 seat-order spec',
    () {
      final source = File('tools/native_visual_delta_v1.py').readAsStringSync();
      expect(
        source,
        contains('delta specification requires a non-empty rows list'),
      );
      expect(
        source,
        contains('delta state/device_profile/modifier tuples must be unique'),
      );
      expect(
        source,
        contains('captured delta rows do not exactly match requested rows'),
      );

      final state = File(
        'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
      ).readAsStringSync();
      expect(state, contains("taskId: 'button_vs_cutoff'"));
      expect(state, contains('_w3LateSeatContrastRunner'));
      expect(state, contains("question: 'Which seat is later than CO?'"));
      expect(
        parseAct0NativeVisualAuditEntryV1(
          'act0_capture=runner_drill&world=world_3&lesson=button_advantage&task=button_advantage_button_vs_cutoff',
        ),
        isNotNull,
      );
    },
  );

  test('delta preflight rejects absent rows instead of falling back to 54', () {
    final temp = Directory.systemTemp.createTempSync('native-delta-');
    addTearDown(() => temp.deleteSync(recursive: true));
    final spec = File('${temp.path}/spec.json')
      ..writeAsStringSync(jsonEncode(<String, Object>{'rows': <Object>[]}));
    final result = Process.runSync('python3', <String>[
      'tools/native_visual_delta_v1.py',
      '--spec',
      spec.path,
      '--emit-shards',
      '${temp.path}/shards',
    ]);
    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('non-empty rows list'));
  });
}
