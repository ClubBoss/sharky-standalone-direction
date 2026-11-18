import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> eraseAct0LocalDiagnosticFileV1() async {
  final directory = await getApplicationSupportDirectory();
  final file = File('${directory.path}/act0_hnp_trace_v1.jsonl');
  if (await file.exists()) await file.delete();
  if (await file.exists()) throw StateError('Local trace deletion failed');
}
