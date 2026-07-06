import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';

void main() {
  const adapter = DrillRuntimeAdapterV1();

  testWidgets('W5 s11 is manifest-backed and runtime-loadable', (tester) async {
    final drills = (await tester.runAsync(
      () => adapter.loadSessionDrills('w5.s11'),
    ))!;

    expect(drills, hasLength(3));
    expect(
      drills.map((drill) => drill.drillId),
      equals(drills.map((drill) => drill.spec.id)),
    );
    expect(
      drills.map((drill) => drill.spec.kind).toSet(),
      equals(<DrillKindV1>{DrillKindV1.outsCountChoice}),
    );
    expect(drills.every((drill) => drill.spec.whyV1 != null), isTrue);
  });

  testWidgets('W6 normalized classifier sessions are runtime-loadable', (
    tester,
  ) async {
    final s01 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w6.s01'),
    ))!;
    final s02 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w6.s02'),
    ))!;

    final normalizedIds = <String>{
      'classify_strong_clean_fit',
      'classify_strong_overpair_fit',
      'classify_medium_second_pair_fit',
      'classify_weak_bottom_pair_fit',
      'classify_missed_overcards_no_draw',
      'classify_missed_low_cards_no_draw',
      'classify_button_range_wider',
      'classify_big_blind_continue_narrower',
      'classify_continue_range_narrower',
      'classify_button_open_less_constrained',
      'classify_utg_range_stronger_average',
      'classify_late_position_more_hands',
    };
    final normalized = <SessionDrillItemV1>[
      ...s01,
      ...s02,
    ].where((drill) => normalizedIds.contains(drill.drillId)).toList();

    expect(normalized, hasLength(12));
    expect(
      normalized.map((drill) => drill.drillId),
      equals(normalized.map((drill) => drill.spec.id)),
    );
    expect(
      normalized.map((drill) => drill.spec.kind).toSet(),
      equals(<DrillKindV1>{DrillKindV1.actionChoice}),
    );
  });

  test(
    'accepted source IDs match manifest IDs while paths stay resolvable',
    () {
      final raw = File(
        'content/_meta/world_drills_manifest_v1.json',
      ).readAsStringSync();
      for (final sessionId in <String>['w5.s11', 'w6.s01', 'w6.s02']) {
        final ids = parseDrillIdsForSessionFromManifestV1(raw, sessionId);
        expect(ids, isNotEmpty, reason: sessionId);
        for (final id in ids) {
          final path = parseDrillAssetPathForSessionFromManifestV1(
            raw,
            sessionId,
            id,
          );
          expect(path, isNotNull, reason: '$sessionId/$id');
          final file = File(path!);
          expect(file.existsSync(), isTrue, reason: path);
          final json =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          expect(json['id'], id, reason: path);
        }
      }
    },
  );

  test('unknown runtime kind and missing manifest ID remain rejected', () {
    expect(
      () => DrillSpecV1.fromJsonString(
        '{"id":"bad","kind":"unknown_classifier_v1","prompt":"Classify this.","expected":{"actionId":"x"},"error_class":"bad"}',
      ),
      throwsFormatException,
    );

    const manifest =
        '{"worlds":[{"world":6,"sessions":[{"id":"w6.s01","drills":[{"id":"known","path":"known.json"}]}]}]}';
    expect(
      parseDrillAssetPathForSessionFromManifestV1(
        manifest,
        'w6.s01',
        'missing',
      ),
      isNull,
    );
  });

  test('broad scanner reports no W5 or W6 contract errors', () async {
    final result = await Process.run('dart', <String>[
      'run',
      'tools/validate_world_content_v1.dart',
    ]);
    final output = '${result.stdout}\n${result.stderr}';
    expect(
      output
          .split('\n')
          .where(
            (line) =>
                line.contains('content/worlds/world5/') ||
                line.contains('content/worlds/world6/'),
          ),
      isEmpty,
    );
    expect(result.exitCode, 0, reason: output);
  });
}
