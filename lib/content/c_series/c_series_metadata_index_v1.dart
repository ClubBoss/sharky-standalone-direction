import 'c_series_content_loader_v1.dart';
import 'recap_loader_v1.dart';
import 'micro_quiz_loader_v1.dart';
import 'spaced_repetition_loader_v1.dart';
import 'mixed_checkpoint_content_joiner_v1.dart';

class CSeriesMetadataIndexV1 {
  const CSeriesMetadataIndexV1({
    required this.loader,
    required this.recapLoader,
    required this.microQuizLoader,
    required this.spacedRepetitionLoader,
    required this.mixedCheckpointJoiner,
  });

  final CSeriesContentLoaderV1 loader;
  final RecapLoaderV1 recapLoader;
  final MicroQuizLoaderV1 microQuizLoader;
  final SpacedRepetitionLoaderV1 spacedRepetitionLoader;
  final MixedCheckpointContentJoinerV1 mixedCheckpointJoiner;

  Map<String, Object> buildIndex() => <String, Object>{
    'c_series_metadata_index_v1': <String, Object>{
      'version': 'v1',
      'modules': _sorted(loader.listAllModules().map(_extractId)),
      'recaps': _sorted(recapLoader.listAllRecaps().map(_extractId)),
      'micro_quizzes': _sorted(
        microQuizLoader.listAllQuizzes().map(_extractId),
      ),
      'spaced_repetition': _sorted(
        spacedRepetitionLoader.listAllSchedules().map(_extractId),
      ),
      'mixed_checkpoints': _sorted(
        mixedCheckpointJoiner.diagnostics().values.whereType<String>(),
      ),
      'index_ready': false,
    },
  };

  Map<String, Object> diagnostics() => <String, Object>{
    'c_series_metadata_index_v1': <String, Object>{
      'ready': false,
      'counts': <String, Object>{
        'modules': loader.listAllModules().length,
        'recaps': recapLoader.listAllRecaps().length,
        'micro_quizzes': microQuizLoader.listAllQuizzes().length,
        'spaced_repetition': spacedRepetitionLoader.listAllSchedules().length,
        'mixed_checkpoints': mixedCheckpointJoiner.diagnostics().length,
      },
    },
  };

  static List<String> _sorted(Iterable<String?> values) {
    final List<String> filtered = values
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toList();
    filtered.sort();
    return filtered;
  }

  static String? _extractId(Map<String, Object>? map) {
    if (map == null) {
      return null;
    }
    const List<String> keys = <String>[
      'module_id',
      'recap_id',
      'quiz_id',
      'schedule_id',
      'checkpoint_id',
    ];
    for (final String key in keys) {
      final Object? value = map[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}
