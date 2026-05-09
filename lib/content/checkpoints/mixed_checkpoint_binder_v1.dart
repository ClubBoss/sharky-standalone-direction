import 'mixed_checkpoint_loader_v1.dart';

class MixedCheckpointBinderV1 {
  final MixedCheckpointLoaderV1 loader;

  const MixedCheckpointBinderV1(this.loader);

  /// Deterministic placeholder binder.
  Map<String, Object> bind(String checkpointId) {
    return <String, Object>{
      'id': checkpointId,
      'bound': false,
      'status': 'unimplemented',
    };
  }

  /// Deterministic placeholder for listing all bound checkpoints.
  List<Map<String, Object>> listBound() {
    return const <Map<String, Object>>[
      {'id': 'placeholder', 'bound': false, 'status': 'unimplemented'},
    ];
  }
}
