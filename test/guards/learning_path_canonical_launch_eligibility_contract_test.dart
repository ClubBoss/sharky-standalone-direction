import 'dart:io';

import 'package:poker_analyzer/canonical/learning_path_canonical_launch_eligibility_v1.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:test/test.dart';

void main() {
  test(
    'learning-path canonical launch eligibility stays explicit and zero-ambiguity',
    () {
      final learningPathSources = <String>[
        File(
          'lib/services/learning_path_level_one_builder_service.dart',
        ).readAsStringSync(),
        File('lib/services/learning_path_stage_seeder.dart').readAsStringSync(),
        File(
          'lib/services/learning_path_config_loader.dart',
        ).readAsStringSync(),
      ].join('\n');

      final exactCanonicalMatches = <String>{
        for (final moduleId in kWorld1CanonicalModuleOrder)
          if (learningPathSources.contains("'$moduleId'")) moduleId,
      };

      expect(
        exactCanonicalMatches,
        isEmpty,
        reason:
            'Learning-path practice ids should not silently drift into canonical runner eligibility without an explicit helper update.',
      );

      for (final entry
          in kLearningPathPracticeCanonicalRunnerModuleIdByPackIdV1.entries) {
        expect(
          entry.key,
          isNot(entry.value),
          reason:
              'Exact canonical matches should rely on the helper fallback, not duplicate map entries.',
        );
        expect(
          kWorld1CanonicalModuleOrder.contains(entry.value),
          isTrue,
          reason:
              'Mapped learning-path practice ids must resolve only to canonical World 1 module ids.',
        );
        expect(
          canonicalRunnerModuleIdForLearningPathPracticePackIdV1(entry.key),
          entry.value,
          reason:
              'Explicit learning-path mapping should resolve deterministically.',
        );
      }

      for (final moduleId in kWorld1CanonicalModuleOrder) {
        expect(
          canonicalRunnerModuleIdForLearningPathPracticePackIdV1(moduleId),
          moduleId,
          reason:
              'Exact canonical module ids should be eligible without extra mapping.',
        );
      }

      expect(
        canonicalRunnerModuleIdForLearningPathPracticePackIdV1(
          'pack_intro_push_fold_mtt',
        ),
        isNull,
        reason:
            'Generic learning-path practice ids must remain ineligible until explicitly mapped.',
      );
    },
  );
}
