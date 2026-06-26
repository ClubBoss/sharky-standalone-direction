import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';

class Act0AchievementSeedConsumerV1 {
  const Act0AchievementSeedConsumerV1({
    this.moments = const <Act0AchievementMomentViewModelV1>[],
  });

  final List<Act0AchievementMomentViewModelV1> moments;

  bool get hasMoments => moments.isNotEmpty;

  static Act0AchievementSeedConsumerV1 fromProjection(
    Act0AchievementSeedProjectionV1 projection,
  ) {
    final earned = projection.seeds
        .where((seed) => seed.earned)
        .where((seed) => seed.state == act0AchievementSeedStateEarnedV1)
        .where((seed) => _labelForSeedIdV1(seed.id) != null)
        .toList(growable: false);
    final ordered = <Act0AchievementSeedV1>[...earned]..sort(_compareSeedsV1);
    return Act0AchievementSeedConsumerV1(
      moments: List<Act0AchievementMomentViewModelV1>.unmodifiable(
        ordered
            .take(3)
            .map(
              (seed) => Act0AchievementMomentViewModelV1(
                seedId: seed.id,
                label: _labelForSeedIdV1(seed.id)!,
              ),
            ),
      ),
    );
  }
}

class Act0AchievementMomentViewModelV1 {
  const Act0AchievementMomentViewModelV1({
    required this.seedId,
    required this.label,
  });

  final String seedId;
  final String label;
}

int _compareSeedsV1(Act0AchievementSeedV1 a, Act0AchievementSeedV1 b) {
  final aSequence = a.earnedSequence;
  final bSequence = b.earnedSequence;
  if (aSequence != null && bSequence != null && aSequence != bSequence) {
    return aSequence.compareTo(bSequence);
  }
  if (aSequence != null && bSequence == null) {
    return -1;
  }
  if (aSequence == null && bSequence != null) {
    return 1;
  }
  return _contractOrderV1(a.id).compareTo(_contractOrderV1(b.id));
}

String? _labelForSeedIdV1(String seedId) {
  switch (seedId) {
    case act0AchievementSeedFirstCorrectReadV1:
      return 'First correct read';
    case act0AchievementSeedFirstRepairNoteV1:
      return 'Back to the spot';
    case act0AchievementSeedFirstReviewHistoryItemV1:
      return 'One miss to fix';
    case act0AchievementSeedFirstEvidenceSignalV1:
      return 'First evidence signal';
    case act0AchievementSeedFirstSessionCompleteV1:
      return 'First session complete';
    case act0AchievementSeedThreeDayStreakV1:
      return 'Three-day rhythm';
  }
  return null;
}

int _contractOrderV1(String seedId) {
  final index = _contractOrder.indexOf(seedId);
  return index == -1 ? _contractOrder.length : index;
}

const List<String> _contractOrder = <String>[
  act0AchievementSeedFirstCorrectReadV1,
  act0AchievementSeedFirstRepairNoteV1,
  act0AchievementSeedFirstReviewHistoryItemV1,
  act0AchievementSeedFirstEvidenceSignalV1,
  act0AchievementSeedFirstSessionCompleteV1,
  act0AchievementSeedThreeDayStreakV1,
];
