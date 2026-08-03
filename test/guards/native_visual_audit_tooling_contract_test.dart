import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

void main() {
  test('native audit payload resolves only known capture surfaces', () {
    expect(parseAct0NativeVisualAuditEntryV1('act0_capture=home'), isNotNull);
    final wave2Mappings = <String, Act0ControlledDemoCaptureSurfaceV1>{
      'wave2_home_fresh': Act0ControlledDemoCaptureSurfaceV1.wave2HomeFresh,
      'wave2_home_progressed':
          Act0ControlledDemoCaptureSurfaceV1.wave2HomeProgressed,
      'wave2_home_repair_return':
          Act0ControlledDemoCaptureSurfaceV1.wave2HomeRepairReturn,
      'wave2_learn_fresh': Act0ControlledDemoCaptureSurfaceV1.wave2LearnFresh,
      'wave2_learn_progressed':
          Act0ControlledDemoCaptureSurfaceV1.wave2LearnProgressed,
      'wave2_practice_no_repair':
          Act0ControlledDemoCaptureSurfaceV1.wave2PracticeNoRepair,
      'wave2_practice_active_repair_hub':
          Act0ControlledDemoCaptureSurfaceV1.wave2PracticeActiveRepairHub,
      'wave2_review_empty': Act0ControlledDemoCaptureSurfaceV1.reviewEmpty,
      'wave2_review_miss': Act0ControlledDemoCaptureSurfaceV1.wave2ReviewMiss,
      'wave2_profile_fresh':
          Act0ControlledDemoCaptureSurfaceV1.wave2ProfileFresh,
      'wave2_profile_progressed':
          Act0ControlledDemoCaptureSurfaceV1.wave2ProfileProgressed,
    };
    for (final mapping in wave2Mappings.entries) {
      final entry = parseAct0NativeVisualAuditEntryV1(
        'act0_capture=${mapping.key}',
      );
      expect(entry, isNotNull, reason: mapping.key);
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
      parseAct0NativeVisualAuditEntryV1('act0_capture=wave2_home_fresh.png'),
      isNull,
    );
  });

  test('native audit entry remains compile-time gated and fails closed', () {
    final source = File('lib/ui_v2/app_root.dart').readAsStringSync();
    expect(
      source,
      contains('const bool _sharkyVisualAuditEnabled = bool.fromEnvironment('),
    );
    expect(
      source,
      contains('if (!_sharkyVisualAuditEnabled || kReleaseMode) return null;'),
    );
  });

  test('active-repair Wave 2 identity stays on the Practice hub', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
    ).readAsStringSync();
    final start = source.indexOf(
      'void _applyDebugWave2PracticeActiveRepairHubSurface(',
    );
    final end = source.indexOf(
      'void _applyDebugWave2ProfileFreshSurface()',
      start,
    );
    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));
    final handler = source.substring(start, end);
    expect(handler, contains('_seedDebugDay2OpenRepairStateV1(state)'));
    expect(handler, contains('_tab = Act0ShellTabV1.play'));
    expect(handler, contains('_showPlayHub = true'));
    expect(handler, isNot(contains('_startMistakeRepair')));
  });

  test(
    'native audit manifest has the exact admitted row-level distribution',
    () {
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
          .map(
            (row) =>
                '${row['state']}/${row['device_profile']}/${row['modifier']}',
          )
          .toSet();
      expect(tuples, hasLength(54));
      expect(
        rows.where((row) => row['state'] == 'lesson.completion'),
        isNotEmpty,
      );
      expect(
        rows.where((row) => row['state'] == 'completion.world'),
        isNotEmpty,
      );
      expect(
        rows.where(
          (row) =>
              row['device_profile'] == 'large' &&
              row['modifier'] == 'reduced_motion',
        ),
        isEmpty,
      );
    },
  );

  test('native audit transport exposes all required coverage dimensions', () {
    final source = File(
      'tools/sharky_native_visual_audit_v1.py',
    ).readAsStringSync();
    expect(source, contains('validate(rows)'));
    expect(source, contains('total rows must be 54'));
    expect(source, contains('selected_simulator(profile)'));
    expect(
      source,
      contains('a capture shard must contain exactly one device profile'),
    );
    expect(source, contains('"iPhone 16e"'));
    expect(source, contains('"candidate_sha": candidate'));
    expect(source, contains('--frame-settle-seconds'));
    expect(
      source,
      contains(
        'args.frame_settle_seconds if attempt == 1 else args.frame_settle_seconds + 1.5',
      ),
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
    expect(
      source,
      contains('replacement shard must contain exactly one successful row'),
    );
  });

  test(
    'native audit tooling emits shards and rejects invalid delta selection',
    () {
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
        final shard =
            jsonDecode(
                  File(
                    '${temp.path}/shards/${entry.key}.json',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>;
        expect((shard['row_ids'] as List<dynamic>), hasLength(entry.value));
      }
      final subset = Process.runSync('python3', [
        'tools/sharky_native_visual_audit_v1.py',
        '--row-id',
        'home.canonical.normal',
        '--validate-selection',
      ]);
      expect(subset.exitCode, 0, reason: '${subset.stderr}');
      final unknown = Process.runSync('python3', [
        'tools/sharky_native_visual_audit_v1.py',
        '--row-id',
        'unknown.row',
        '--validate-selection',
      ]);
      expect(unknown.exitCode, isNot(0));
      final selfTest = Process.runSync('python3', [
        'tools/sharky_native_visual_audit_v1.py',
        '--self-test',
      ]);
      expect(selfTest.exitCode, 0, reason: '${selfTest.stderr}');
      final incompleteAggregate = Process.runSync('python3', [
        'tools/sharky_native_visual_audit_v1.py',
        '--aggregate-shards',
        temp.path,
        '--candidate-sha',
        '0000000000000000000000000000000000000000',
        '--out',
        '${temp.path}/unified',
      ]);
      expect(incompleteAggregate.exitCode, isNot(0));
    },
  );

  test(
    'Wave 2 closure manifest exposes exactly eleven truthful identities',
    () {
      final manifest = File(
        'tools/sharky_wave2_visual_closure_manifest_v1.json',
      );
      final payload =
          jsonDecode(manifest.readAsStringSync()) as Map<String, dynamic>;
      final rows = (payload['rows'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      expect(rows, hasLength(11));
      expect(
        rows.map((row) => row['state']).toSet(),
        equals(<String>{
          'home_fresh',
          'home_progressed',
          'home_repair_return',
          'learn_fresh',
          'learn_progressed',
          'practice_no_repair',
          'practice_active_repair_hub',
          'review_empty',
          'review_miss',
          'profile_fresh',
          'profile_progressed',
        }),
      );
      final preflight = Process.runSync('python3', <String>[
        'tools/sharky_native_visual_audit_v1.py',
        '--manifest',
        manifest.path,
        '--preflight',
      ]);
      expect(preflight.exitCode, 0, reason: '${preflight.stderr}');
    },
  );
}
