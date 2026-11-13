import 'act0_dat07_transfer_v1.dart';
import 'act0_progress_store_v1.dart';

/// The store must use the active shell's canonical payload validator.
/// The supported schema is injected by that shell, never inferred from a file.
/// No read/save emulation, preference keys, or alternative persistence engine.
class Act0Dat07CanonicalStorePortV1 implements Act0Dat07ProgressPortV1 {
  const Act0Dat07CanonicalStorePortV1({
    required this.store,
    required this.supportedProgressSchema,
  });

  final Act0ProgressStoreV1 store;
  final int supportedProgressSchema;

  @override
  Future<Act0Dat07DurableStateV1> readDurableSnapshot() =>
      store.readDurableSnapshot();

  @override
  Future<Act0Dat07WriteResultV1> restoreIfUnchanged({
    required Act0Dat07DurableStateV1 expected,
    required String incomingPayload,
  }) async => switch (await store.restoreIfUnchanged(
    expected: expected,
    incomingPayload: incomingPayload,
    supportedProgressSchema: supportedProgressSchema,
  )) {
    Act0ProgressRestoreResultV1.committed => Act0Dat07WriteResultV1.committed,
    Act0ProgressRestoreResultV1.changed => Act0Dat07WriteResultV1.changed,
    Act0ProgressRestoreResultV1.unverified => Act0Dat07WriteResultV1.unverified,
  };
}
