import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';

void main() {
  test('native audit payload resolves only known capture surfaces', () {
    expect(parseAct0NativeVisualAuditEntryV1('act0_capture=home'), isNotNull);
    expect(
      parseAct0NativeVisualAuditEntryV1(
        'act0_capture=runner_feedback&world=world_1&lesson=positions&task=positions_early_late',
      ),
      isNotNull,
    );
    expect(parseAct0NativeVisualAuditEntryV1('act0_capture=unknown'), isNull);
  });

  test('native audit state manifest has the required six fidelity rows', () {
    final manifest =
        jsonDecode(
              File(
                'tools/sharky_native_visual_audit_manifest_v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final states = (manifest['states'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final fidelity = states.where((state) => state['fidelity_gate'] == true);
    expect(fidelity, hasLength(6));
    expect(
      fidelity.map((state) => state['visual_state_id']),
      containsAll(<String>[
        'placement.normal',
        'home.normal',
        'learn.normal',
        'vrt02.normal',
        'vrt02.incorrect',
        'vrt02.text_scale_1_4',
      ]),
    );
  });

  test('native audit transport exposes all required coverage dimensions', () {
    final source = File('tools/sharky_native_visual_audit_v1.py').readAsStringSync();
    expect(source, contains('--device-profile'));
    expect(source, contains('--modifier'));
    expect(source, contains('text_scale_1_4'));
    expect(source, contains('reduced_motion'));
  });
}
