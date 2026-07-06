import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';

void main() {
  test(
    'W6 s01 range bucket family has six manifest-backed same-signal drills',
    () {
      const sessionPath = 'content/worlds/world6/v1/sessions/w6.s01';
      final drillDirectory = Directory('$sessionPath/drills');
      final rangeBucketDrills = drillDirectory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .map(
            (file) =>
                jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
          )
          .where(
            (drill) => drill['kind'] == 'range_bucket_board_fit_classifier_v1',
          )
          .toList(growable: false);

      expect(rangeBucketDrills, hasLength(6));
      expect(
        rangeBucketDrills
            .map((drill) => drill['range_bucket_v1'] as String)
            .toSet(),
        containsAll(<String>{'strong', 'medium', 'weak', 'missed'}),
      );
      expect(
        rangeBucketDrills
            .map((drill) => drill['expected_action'] as String)
            .toSet(),
        containsAll(<String>{'strong', 'medium', 'weak', 'missed'}),
      );
      for (final drill in rangeBucketDrills) {
        expect(drill['intent_v1'], isNotEmpty);
        expect(drill['why_v1'], isNotEmpty);
        expect(drill['feedback_correct_v1'], isNotEmpty);
        expect(drill['feedback_incorrect_v1'], isNotEmpty);
      }

      final manifest =
          jsonDecode(
                File(
                  'content/_meta/world_drills_manifest_v1.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final worlds = manifest['worlds'] as List<dynamic>;
      final world6 = worlds.cast<Map<String, dynamic>>().firstWhere(
        (world) => world['world'] == 6,
      );
      final session = (world6['sessions'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .firstWhere((entry) => entry['id'] == 'w6.s01');
      final manifestById = <String, String>{
        for (final drill
            in (session['drills'] as List<dynamic>)
                .cast<Map<String, dynamic>>())
          drill['id'] as String: drill['path'] as String,
      };

      for (final drill in rangeBucketDrills) {
        final id = drill['id'] as String;
        expect(manifestById, contains(id));
        expect(File(manifestById[id]!).existsSync(), isTrue);
      }
    },
  );

  testWidgets('W6 s01 practice runtime loads all six range bucket drills', (
    tester,
  ) async {
    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w6.s01'),
    ))!;
    const ids = <String>{
      'classify_strong_clean_fit',
      'classify_strong_overpair_fit',
      'classify_medium_second_pair_fit',
      'classify_weak_bottom_pair_fit',
      'classify_missed_overcards_no_draw',
      'classify_missed_low_cards_no_draw',
    };
    final rangeBucketDrills = drills
        .where((drill) => ids.contains(drill.drillId))
        .toList(growable: false);

    expect(rangeBucketDrills, hasLength(6));
    expect(
      rangeBucketDrills.map((drill) => drill.spec.kind).toSet(),
      equals(<DrillKindV1>{DrillKindV1.actionChoice}),
    );
    expect(
      rangeBucketDrills.map((drill) => drill.drillId),
      equals(rangeBucketDrills.map((drill) => drill.spec.id)),
    );
  });
}
