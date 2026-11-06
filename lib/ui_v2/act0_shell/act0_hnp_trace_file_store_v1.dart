import 'act0_hnp_trace_file_store_stub_v1.dart'
    if (dart.library.io) 'act0_hnp_trace_file_store_io_v1.dart'
    as platform;

abstract class Act0HnpTraceFileStoreV1 {
  Future<String?> getPath();

  Future<void> replace(String jsonl);
}

/// Optional capability: a store that can return the trace written by the
/// previous app process, so a restart does not erase incident history.
abstract class Act0HnpTraceHistoryReaderV1 {
  Future<String?> readPrevious();
}

Act0HnpTraceFileStoreV1? createAct0HnpTraceFileStoreV1() =>
    platform.createAct0HnpTraceFileStoreV1();
