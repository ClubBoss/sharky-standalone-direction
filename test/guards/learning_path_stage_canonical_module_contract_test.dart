import 'package:poker_analyzer/models/learning_path_stage_model.dart';
import 'package:test/test.dart';

void main() {
  test(
    'learning path stage model supports optional canonicalModuleId without breaking older content',
    () {
      final legacyStage = LearningPathStageModel.fromJson(<String, dynamic>{
        'id': 'legacy_stage',
        'title': 'Legacy Stage',
        'description': 'No canonical module binding yet.',
        'packId': 'open_fold_early_mtt',
        'requiredAccuracy': 80,
        'minHands': 10,
      });

      expect(legacyStage.canonicalModuleId, isNull);
      expect(legacyStage.toJson().containsKey('canonicalModuleId'), isFalse);

      final canonicalStage = LearningPathStageModel.fromJson(<String, dynamic>{
        'id': 'mapped_stage',
        'title': 'Mapped Stage',
        'description': 'Explicit canonical binding.',
        'packId': 'custom_learning_path_pack',
        'canonicalModuleId': 'world1_act0_table_literacy',
        'requiredAccuracy': 80,
        'minHands': 10,
      });

      expect(canonicalStage.canonicalModuleId, 'world1_act0_table_literacy');
      expect(
        canonicalStage.toJson()['canonicalModuleId'],
        'world1_act0_table_literacy',
      );
    },
  );
}
