import 'act0_hnp_trace_file_store_stub_v1.dart'
    if (dart.library.io) 'act0_hnp_trace_file_store_io_v1.dart'
    as platform;

abstract class Act0HnpTraceFileStoreV1 {
  Future<String?> getPath();

  Future<void> replace(String jsonl);
}

Act0HnpTraceFileStoreV1? createAct0HnpTraceFileStoreV1() =>
    platform.createAct0HnpTraceFileStoreV1();
