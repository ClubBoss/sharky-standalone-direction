import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

void main() {
  test('native audit payload resolves only known capture surfaces', () {
    expect(parseAct0NativeVisualAuditEntryV1('act0_capture=home'), isNotNull);
    final identityMappings = <String, Act0ControlledDemoCaptureSurfaceV1>{
      'first_week_home': Act0ControlledDemoCaptureSurfaceV1.firstWeekHome,
      'day2_return_home': Act0ControlledDemoCaptureSurfaceV1.day2ReturnHome,
      'day2_practice_repair_target': Act0ControlledDemoCaptureSurfaceV1.day2PracticeRepairTarget,
      'review_empty': Act0ControlledDemoCaptureSurfaceV1.reviewEmpty,
    };
    for (final mapping in identityMappings.entries) {
      final entry = parseAct0NativeVisualAuditEntryV1('act0_capture=${mapping.key}');
      expect(entry, isNotNull);
      expect(entry!.mode, Act0ControlledDemoCaptureModeV1.directState);
      expect(entry.surface, mapping.value);
    }
    expect(
      parseAct0NativeVisualAuditEntryV1(
        'act0_capture=runner_feedback&world=world_1&lesson=positions&task=positions_early_late',
      ),
      isNotNull,
    );
    expect(parseAct0NativeVisualAuditEntryV1('act0_capture=unknown'), isNull);
    expect(
      parseAct0NativeVisualAuditEntryV1('act0_capture=day2_return_home.png'),
      isNull,
    );
  });

  test('native audit bridge retains the compile-time and release boot guard', () {
    final source = File('lib/ui_v2/app_root.dart').readAsStringSync();
    expect(source, contains('if (!_sharkyVisualAuditEnabled || kReleaseMode) return null;'));
    expect(source, contains('const bool _sharkyVisualAuditEnabled = bool.fromEnvironment('));
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
    expect(source, contains('a capture shard must contain exactly one device profile'));
    expect(source, contains('"iPhone 16e"'));
    expect(source, contains('"candidate_sha": candidate'));
    expect(source, contains('--frame-settle-seconds'));
    expect(
      source,
      contains('args.frame_settle_seconds if attempt == 1 else args.frame_settle_seconds + 1.5'),
    );
    expect(source, contains('--row-ids-file'));
    expect(source, contains('--full-checkpoint'));
    expect(source, contains('log", "stream"'));
    expect(source, contains('listener.poll() is not None'));
    expect(source, contains('"log", "show", "--last", "30s"'));
    expect(source, contains('png_frame_metrics(path)'));
    expect(source, contains('near_black_ratio'));
    expect(source, contains('near_white_ratio'));
    expect(source, contains('practically_uniform'));
    expect(source, contains('near_black_blank'));
    expect(source, contains('assert_valid_frame(png)'));
    expect(source, contains('--resume-from'));
    expect(source, contains('"resumed_rows"'));
    expect(source, contains('for attempt in (1, 2)'));
    expect(source, contains('shard_capture_manifest.json'));
    expect(source, contains('aggregate requires four shard manifests'));
    expect(source, contains('--replace-shard-row'));
    expect(source, contains('replacement shard must contain exactly one successful row'));
  });

  test('native audit tooling emits shards and rejects invalid delta selection', () {
    final temp = Directory.systemTemp.createTempSync('native-audit-tooling-');
    addTearDown(() => temp.deleteSync(recursive: true));
    final preflight = Process.runSync('python3', [
      'tools/sharky_native_visual_audit_v1.py',
      '--preflight',
      '--emit-shards',
      '${temp.path}/shards',
    ]);
    expect(preflight.exitCode, 0, reason: '${preflight.stderr}');
    final expected = <String, int>{
      'canonical-normal': 20,
      'canonical-modifiers': 16,
      'compact-normal': 14,
      'large-normal': 4,
    };
    for (final entry in expected.entries) {
      final shard = jsonDecode(File('${temp.path}/shards/${entry.key}.json').readAsStringSync()) as Map<String, dynamic>;
      expect((shard['row_ids'] as List<dynamic>), hasLength(entry.value));
    }
    final subset = Process.runSync('python3', [
      'tools/sharky_native_visual_audit_v1.py', '--row-id', 'home.canonical.normal', '--validate-selection',
    ]);
    expect(subset.exitCode, 0, reason: '${subset.stderr}');
    final unknown = Process.runSync('python3', [
      'tools/sharky_native_visual_audit_v1.py', '--row-id', 'unknown.row', '--validate-selection',
    ]);
    expect(unknown.exitCode, isNot(0));
    final selfTest = Process.runSync('python3', ['tools/sharky_native_visual_audit_v1.py', '--self-test']);
    expect(selfTest.exitCode, 0, reason: '${selfTest.stderr}');
    final incompleteAggregate = Process.runSync('python3', [
      'tools/sharky_native_visual_audit_v1.py',
      '--aggregate-shards', temp.path,
      '--candidate-sha', '0000000000000000000000000000000000000000',
      '--out', '${temp.path}/unified',
    ]);
    expect(incompleteAggregate.exitCode, isNot(0));
  });
}
