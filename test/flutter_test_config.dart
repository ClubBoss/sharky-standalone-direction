import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'stubs/file_picker_stub.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await Directory('build/unit_test_assets/shaders').create(recursive: true);
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    FilePicker.platform = StubFilePicker();
  }
  await testMain();
}
