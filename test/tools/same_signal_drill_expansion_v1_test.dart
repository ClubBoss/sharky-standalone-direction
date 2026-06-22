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
          .where((drill) => drill['kind'] == 'range_bucket_classifier_v1')
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
        containsAll(<String>{'raise', 'call', 'fold'}),
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
      final manifestPaths = (session['drills'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((drill) => drill['path'] as String)
          .toSet();

      for (final drill in rangeBucketDrills) {
        final id = drill['id'] as String;
        expect(
          manifestPaths,
          contains('$sessionPath/drills/d.$id.json'),
          reason:
              '$id must remain available through the W6 s01 practice manifest.',
        );
      }
    },
  );

  testWidgets('W6 s01 practice runtime loads all six range bucket drills', (
    tester,
  ) async {
    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w6.s01'),
    ))!;
    final rangeBucketDrills = drills
        .where((drill) => drill.spec.kind == DrillKindV1.rangeBucketClassifier)
        .toList(growable: false);

    expect(rangeBucketDrills, hasLength(6));
    expect(
      rangeBucketDrills.map((drill) => drill.drillId),
      containsAll(<String>[
        'classify_medium_call_control',
        'classify_weak_fold_pressure',
        'classify_strong_call_control',
        'classify_missed_fold_recheck',
      ]),
    );
  });
}
