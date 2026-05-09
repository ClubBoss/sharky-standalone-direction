import '../core/training/engine/training_type_engine.dart';

enum PackAvailabilityV1 { available, comingSoon, locked }

class TrainingPackMeta {
  final String id;
  final String title;
  final String skillLevel; // e.g. beginner, intermediate, advanced
  final List<String> tags;
  final TrainingType trainingType;
  final int difficultyTier;
  final PackAvailabilityV1 availability;
  final String? titleKey;
  final String? subtitleKey;

  const TrainingPackMeta({
    required this.id,
    required this.title,
    required this.skillLevel,
    required this.tags,
    required this.trainingType,
    this.difficultyTier = 1,
    this.availability = PackAvailabilityV1.available,
    this.titleKey,
    this.subtitleKey,
  });
}
