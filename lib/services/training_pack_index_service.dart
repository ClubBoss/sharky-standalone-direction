import '../generated/pack_library.g.dart';
import '../models/training_pack_meta.dart';
import '../core/training/engine/training_type_engine.dart';

class TrainingPackIndexService {
  TrainingPackIndexService._();
  static final instance = TrainingPackIndexService._();

  static final Map<String, TrainingPackMeta> _index = {
    'starter_pushfold_10bb': const TrainingPackMeta(
      id: 'starter_pushfold_10bb',
      title: 'Starter Push/Fold 10bb',
      skillLevel: 'beginner',
      tags: ['starter', 'pushfold'],
      trainingType: TrainingType.pushFold,
      difficultyTier: 1,
      availability: PackAvailabilityV1.available,
      titleKey: 'pack_title_starter_pushfold_10bb',
      subtitleKey: 'pack_subtitle_starter_pushfold_10bb',
    ),
    'starter_postflop_basics': const TrainingPackMeta(
      id: 'starter_postflop_basics',
      title: 'Starter Postflop Basics',
      skillLevel: 'beginner',
      tags: ['starter', 'postflop'],
      trainingType: TrainingType.postflop,
      difficultyTier: 1,
      availability: PackAvailabilityV1.comingSoon,
      titleKey: 'pack_title_starter_postflop_basics',
      subtitleKey: 'pack_subtitle_starter_postflop_basics',
    ),
    'advanced_pushfold_15bb': const TrainingPackMeta(
      id: 'advanced_pushfold_15bb',
      title: 'Advanced Push/Fold 15bb',
      skillLevel: 'advanced',
      tags: ['advanced', 'pushfold'],
      trainingType: TrainingType.pushFold,
      difficultyTier: 3,
      availability: PackAvailabilityV1.locked,
      titleKey: 'pack_title_advanced_pushfold_15bb',
      subtitleKey: 'pack_subtitle_advanced_pushfold_15bb',
    ),
  };

  TrainingPackMeta? getMeta(String id) {
    if (!packLibrary.containsKey(id)) return null;
    return _index[id];
  }

  List<TrainingPackMeta> getAll() {
    final result = <TrainingPackMeta>[];
    for (final id in packLibrary.keys) {
      final meta = _index[id];
      if (meta != null) result.add(meta);
    }
    return result;
  }
}
