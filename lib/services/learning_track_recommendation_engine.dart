import '../models/v3/lesson_track.dart';
import 'learning_track_engine.dart';
import 'track_mastery_service.dart';
import 'yaml_lesson_track_loader.dart';
import 'lesson_track_meta_service.dart';

class World10TrackRecommendationV1 {
  const World10TrackRecommendationV1({
    required this.choiceId,
    required this.label,
    required this.reason,
  });

  final String choiceId;
  final String label;
  final String reason;
}

/// Recommends lesson tracks based on mastery levels.
class LearningTrackRecommendationEngine {
  final TrackMasteryService masteryService;
  final LessonTrackMetaService metaService;
  final LearningTrackEngine trackEngine;
  final YamlLessonTrackLoader yamlLoader;

  LearningTrackRecommendationEngine({
    required this.masteryService,
    LessonTrackMetaService? metaService,
    LearningTrackEngine? trackEngine,
    YamlLessonTrackLoader? yamlLoader,
  }) : metaService = metaService ?? LessonTrackMetaService.instance,
       trackEngine = trackEngine ?? LearningTrackEngine(),
       yamlLoader = yamlLoader ?? YamlLessonTrackLoader.instance;

  /// Returns up to [limit] recommended tracks sorted by lowest mastery.
  Future<List<LessonTrack>> getRecommendedTracks({int limit = 3}) async {
    final builtIn = trackEngine.getTracks();
    final yaml = await yamlLoader.loadTracksFromAssets();
    final tracks = <LessonTrack>[...builtIn, ...yaml];

    final mastery = await masteryService.computeTrackMastery();
    final entries = <MapEntry<LessonTrack, double>>[];
    for (final t in tracks) {
      entries.add(MapEntry(t, mastery[t.id] ?? 0.0));
    }
    entries.sort((a, b) => a.value.compareTo(b.value));

    final result = <LessonTrack>[];
    for (final e in entries) {
      final meta = await metaService.load(e.key.id);
      if (meta?.completedAt != null) continue;
      result.add(e.key);
      if (result.length >= limit) break;
    }
    return result;
  }

  /// Returns textual explanation for a recommendation.
  Future<String> getRecommendationReason(LessonTrack track) async {
    final mastery = await masteryService.computeTrackMastery();
    final value = mastery[track.id] ?? 0.0;
    final pct = (value * 100).round();
    return 'Mastery $pct%';
  }

  /// Returns a narrow world10 chooser recommendation by adapting the existing
  /// track-mastery signal into the cash / tournament / mixed split.
  Future<World10TrackRecommendationV1> getWorld10TrackRecommendationV1() async {
    final mastery = await masteryService.computeTrackMastery();

    final candidates = <({
      String choiceId,
      String label,
      String sourceTrackId,
      String fallbackReason,
      int tieBreak,
    })>[
      (
        choiceId: 'tournament',
        label: 'Tournament',
        sourceTrackId: 'mtt_pro',
        fallbackReason:
            'Tournament pressure and survival tradeoffs look like the weakest current fit signal.',
        tieBreak: 0,
      ),
      (
        choiceId: 'cash',
        label: 'Cash',
        sourceTrackId: 'live_exploit',
        fallbackReason:
            'Cash depth and steadier value tradeoffs look like the weakest current fit signal.',
        tieBreak: 1,
      ),
      (
        choiceId: 'mixed',
        label: 'Mixed',
        sourceTrackId: 'leak_fixer',
        fallbackReason:
            'A balanced mixed path is the safest fit when your broad leak-fixing signal is lowest.',
        tieBreak: 2,
      ),
    ];

    candidates.sort((a, b) {
      final aValue = mastery[a.sourceTrackId] ?? 0.0;
      final bValue = mastery[b.sourceTrackId] ?? 0.0;
      final byMastery = aValue.compareTo(bValue);
      if (byMastery != 0) return byMastery;
      return a.tieBreak.compareTo(b.tieBreak);
    });

    final winner = candidates.first;
    final sourceTrack = trackEngine.getTracks().firstWhere(
      (track) => track.id == winner.sourceTrackId,
      orElse: () => LessonTrack(
        id: winner.sourceTrackId,
        title: winner.label,
        description: winner.fallbackReason,
        stepIds: const <String>[],
      ),
    );
    final masteryReason = await getRecommendationReason(sourceTrack);
    return World10TrackRecommendationV1(
      choiceId: winner.choiceId,
      label: winner.label,
      reason: '${winner.fallbackReason} $masteryReason.',
    );
  }
}
