import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';

void main() {
  test(
    'W5 s01 board texture family has six manifest-backed same-signal drills',
    () {
      const sessionPath = 'content/worlds/world5/v1/sessions/w5.s01';
      final drillDirectory = Directory('$sessionPath/drills');
      final textureDrills = drillDirectory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .map(
            (file) =>
                jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
          )
          .where((drill) => drill['kind'] == 'board_texture_classifier_v1')
          .toList(growable: false);

      expect(textureDrills, hasLength(6));
      expect(
        textureDrills
            .map((drill) => drill['board_texture_v1'] as String)
            .toSet(),
        containsAll(<String>{'dry', 'wet', 'paired'}),
      );
      expect(
        textureDrills
            .map((drill) => drill['expected_action'] as String)
            .toSet(),
        containsAll(<String>{'raise', 'call', 'fold'}),
      );

      final textureCounts = <String, int>{};
      for (final drill in textureDrills) {
        final texture = drill['board_texture_v1'] as String;
        textureCounts[texture] = (textureCounts[texture] ?? 0) + 1;

        expect(drill['intent_v1'], isNotEmpty);
        expect(drill['why_v1'], isNotEmpty);
        expect(drill['feedback_correct_v1'], isNotEmpty);
        expect(drill['feedback_incorrect_v1'], isNotEmpty);
      }
      expect(textureCounts['dry'], greaterThanOrEqualTo(2));
      expect(textureCounts['wet'], greaterThanOrEqualTo(2));
      expect(textureCounts['paired'], greaterThanOrEqualTo(2));

      final manifest =
          jsonDecode(
                File(
                  'content/_meta/world_drills_manifest_v1.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final worlds = manifest['worlds'] as List<dynamic>;
      final world5 = worlds.cast<Map<String, dynamic>>().firstWhere(
        (world) => world['world'] == 5,
      );
      final session = (world5['sessions'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .firstWhere((entry) => entry['id'] == 'w5.s01');
      final manifestPaths = (session['drills'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((drill) => drill['path'] as String)
          .toSet();

      for (final drill in textureDrills) {
        final id = drill['id'] as String;
        expect(
          manifestPaths,
          contains('$sessionPath/drills/d.$id.json'),
          reason:
              '$id must remain available through the W5 s01 practice manifest.',
        );
      }
    },
  );

  testWidgets('W5 s01 practice runtime loads all six board texture drills', (
    tester,
  ) async {
    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w5.s01'),
    ))!;
    final textureDrills = drills
        .where((drill) => drill.spec.kind == DrillKindV1.boardTextureClassifier)
        .toList(growable: false);

    expect(textureDrills, hasLength(6));
    expect(
      textureDrills.map((drill) => drill.drillId),
      containsAll(<String>[
        'classify_texture_intro_dry_call_control_v1',
        'classify_texture_intro_wet_fold_pressure_v1',
        'classify_texture_intro_paired_call_control_v1',
      ]),
    );
  });
}
