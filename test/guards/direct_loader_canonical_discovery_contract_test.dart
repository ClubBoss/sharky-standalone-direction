import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart';
import 'package:poker_analyzer/ui_v2/home/direct_loader.dart';

void main() {
  test('direct loader world1 manifests stay anchored to canonical truth', () {
    final manifestBackedModuleIds = canonicalManifestBackedModuleIdsForWorldV1(
      1,
    );

    expect(manifestBackedModuleIds, const <String>[
      'world1_act0_table_literacy',
      'world1_act0_action_literacy',
      'world1_act0_street_flow',
    ]);
    expect(
      DirectLoader.availableManifestPathsV1(),
      manifestBackedModuleIds
          .map((moduleId) => 'content/$moduleId/v1/manifest.json')
          .toList(growable: false),
    );
  });
}
