import 'mixed_checkpoint_binder_v1.dart';

class MixedCheckpointRouterV1 {
  final MixedCheckpointBinderV1 binder;

  const MixedCheckpointRouterV1(this.binder);

  /// Deterministic placeholder router.
  Map<String, Object> route(String checkpointId) {
    return <String, Object>{
      'id': checkpointId,
      'routed': false,
      'status': 'unimplemented',
    };
  }

  /// Deterministic placeholder for router diagnostics.
  Map<String, Object> diagnostics() {
    return <String, Object>{
      'router': 'v1',
      'status': 'unimplemented',
      'count': 0,
    };
  }
}
