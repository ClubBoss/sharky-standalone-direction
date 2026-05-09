import 'c_series_content_loader_v1.dart';
import 'recap_loader_v1.dart';
import 'micro_quiz_loader_v1.dart';
import 'spaced_repetition_loader_v1.dart';
import 'mixed_checkpoint_content_joiner_v1.dart';

class CSeriesSurfaceUnifierV1 {
  const CSeriesSurfaceUnifierV1({
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

  Map<String, Object> buildSurface(String id) => <String, Object>{
    'c_series_surface_v1': <String, Object>{
      'version': 'v1',
      'joined': <String, Object>{
        'content': loader.loadModuleById(id),
        'recaps': recapLoader.loadRecapById(id),
        'micro_quizzes': microQuizLoader.loadQuizById(id),
        'spaced_repetition': spacedRepetitionLoader.loadScheduleById(id),
        'mixed_checkpoints': mixedCheckpointJoiner.joinById(id),
      },
      'surface_ready': false,
    },
  };

  Map<String, Object> diagnostics() => const <String, Object>{
    'c_series_surface_unifier_v1': <String, Object>{
      'ready': false,
      'components': <String>[
        'content',
        'recaps',
        'micro_quizzes',
        'spaced_repetition',
        'mixed_checkpoints',
      ],
    },
  };
}
