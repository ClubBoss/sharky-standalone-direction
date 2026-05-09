import 'mixed_checkpoint_content_binder_v1.dart';
import 'c_series_content_loader_v1.dart';

class MixedCheckpointContentJoinerV1 {
  const MixedCheckpointContentJoinerV1({
    required this.loader,
    required this.binder,
  });

  final CSeriesContentLoaderV1 loader;
  final MixedCheckpointContentBinderV1 binder;

  Map<String, Object> joinById(String id) => <String, Object>{
    'checkpoint_id': id,
    'kind': 'mixed_checkpoint_joined',
    'version': 'v1',
    'content_ready': false,
    'source': <String, Object>{
      'loader': loader.loadModuleById(id),
      'binder': binder.bindContentById(id),
    },
  };

  Map<String, Object> diagnostics() => const <String, Object>{
    'mixed_checkpoint_joiner_v1': <String, Object>{
      'ready': false,
      'supported_ids': <Object>[],
    },
  };
}
