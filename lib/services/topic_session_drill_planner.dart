import 'session_log_service.dart';
import 'topic_progress_service.dart';
import 'content_module_loader_service.dart';

class TopicSessionDrillPlanner {
  final SessionLogService sessionLogService;
  final TopicProgressService topicProgressService;
  final ContentModuleLoaderService contentModuleLoaderService;

  TopicSessionDrillPlanner({
    required this.sessionLogService,
    required this.topicProgressService,
    required this.contentModuleLoaderService,
  });

  List<SpotEntry> generateDrill(String topicId) {
    final mistakes = sessionLogService
        .getMistakesByTopic(topicId)
        .map(
          (entry) =>
              SpotEntry(id: entry.spot.id, description: entry.spot.description),
        )
        .toList();
    final lowAccuracySpots = topicProgressService
        .getAccuracy(topicId)
        .entries
        .where((entry) => entry.value <= 60)
        .map((entry) => entry.key)
        .toList();
    final allSpots = [
      for (final spot in contentModuleLoaderService.getSpots(topicId))
        SpotEntry(id: spot.id, description: spot.description),
    ];

    final seenSpots = mistakes.map((e) => e.id).toSet()
      ..addAll(lowAccuracySpots);
    final neverSeenSpots = allSpots.where(
      (spot) => !seenSpots.contains(spot.id),
    );

    final List<SpotEntry> prioritizedSpots = [
      ...mistakes,
      ...lowAccuracySpots.map(
        (id) => allSpots.firstWhere(
          (spot) => spot.id == id,
          orElse: () => SpotEntry(id: id, description: id),
        ),
      ),
      ...neverSeenSpots,
    ];

    final randomFiller = allSpots.where(
      (spot) => !prioritizedSpots.contains(spot),
    );

    final List<SpotEntry> drill = [
      ...prioritizedSpots,
      ...randomFiller,
    ].take(30).toList();

    return drill;
  }
}

class SpotEntry {
  final String id;
  final String description;

  SpotEntry({required this.id, required this.description});
}
