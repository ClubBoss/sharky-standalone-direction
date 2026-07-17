import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'act0_hnp_trace_file_store_v1.dart';

Act0HnpTraceFileStoreV1 createAct0HnpTraceFileStoreV1() =>
    _Act0HnpTraceFileStoreV1();

class _Act0HnpTraceFileStoreV1 implements Act0HnpTraceFileStoreV1 {
  late final Future<File> _file = _resolveFile();

  @override
  Future<String> getPath() async => (await _file).path;

  @override
  Future<void> replace(String jsonl) async {
    final file = await _file;
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonl, flush: true);
  }

  Future<File> _resolveFile() async {
    final directory = await getApplicationSupportDirectory();
    return File(
      '${directory.path}${Platform.pathSeparator}act0_hnp_trace_v1.jsonl',
    );
  }
}
