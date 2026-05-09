import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:poker_analyzer/content/release_content_plan.dart';

void main() {
  test('release plan modules align with available manifests', () {
    final planIds = ReleaseContentPlanV1.modules.map((m) => m.id).toSet();

    final contentDir = Directory('content');
    final manifestMap = <String, Map<String, dynamic>>{};

    for (final entity in contentDir.listSync()) {
      if (entity is Directory) {
        final manifestFile = File('${entity.path}/v1/manifest.json');
        if (!manifestFile.existsSync()) continue;
        final data =
            jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
        final id = data['id'] as String?;
        if (id == null || id.isEmpty) {
          fail('Manifest ${manifestFile.path} missing id');
        }
        manifestMap[id] = data;
      }
    }

    for (final module in ReleaseContentPlanV1.modules) {
      final manifest = manifestMap[module.id];
      expect(
        manifest,
        isNotNull,
        reason: 'Release module ${module.id} lacks a manifest file',
      );
      final availability = manifest!['availability'] as String? ?? 'available';
      expect(
        availability,
        'available',
        reason:
            'Release manifest ${module.id} must declare availability=available',
      );
      final tier = manifest['difficulty_tier'];
      expect(
        tier,
        module.difficultyTier,
        reason:
            'Release manifest ${module.id} difficulty ($tier) must match plan (${module.difficultyTier})',
      );
    }
  });
}
