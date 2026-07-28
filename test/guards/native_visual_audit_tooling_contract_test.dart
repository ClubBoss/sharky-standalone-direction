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

  test('native audit manifest has the exact admitted row-level distribution', () {
    final manifest =
        jsonDecode(
              File(
                'tools/sharky_native_visual_audit_manifest_v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final rows = (manifest['rows'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(rows, hasLength(54));
    final counts = <String, int>{};
    for (final row in rows) {
      final key = '${row['device_profile']}/${row['modifier']}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    expect(
      counts,
      equals(<String, int>{
        'canonical/none': 20,
        'compact/none': 14,
        'canonical/text_scale_1_4': 10,
        'canonical/reduced_motion': 6,
        'large/none': 4,
      }),
    );
    final tuples = rows
        .map((row) => '${row['state']}/${row['device_profile']}/${row['modifier']}')
        .toSet();
    expect(tuples, hasLength(54));
    expect(rows.where((row) => row['state'] == 'lesson.completion'), isNotEmpty);
    expect(rows.where((row) => row['state'] == 'completion.world'), isNotEmpty);
    expect(
      rows.where(
        (row) =>
            row['device_profile'] == 'large' &&
            row['modifier'] == 'reduced_motion',
      ),
      isEmpty,
    );
  });

  test('native audit transport exposes all required coverage dimensions', () {
    final source = File('tools/sharky_native_visual_audit_v1.py').readAsStringSync();
    expect(source, contains('validate(rows)'));
    expect(source, contains('total rows must be 54'));
    expect(source, contains('selected_simulator(profile)'));
    expect(source, contains('simulators[row["device_profile"]]'));
  });
}
