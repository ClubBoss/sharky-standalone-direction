// Linux MACHINE harness, not the iOS preferences implementation.
// Run only through driver_v1.py. All reads reopen the on-disk file; the writer
// can be killed while its save Future is still pending, including a torn temp.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _FilePrefs extends SharedPreferencesStorePlatform {
  _FilePrefs(this.file, this.cut, this.marker);
  final File file;
  final String? cut;
  final File marker;

  Map<String, Object> read() => file.existsSync()
      ? Map<String, Object>.from(jsonDecode(file.readAsStringSync()) as Map)
      : {};

  Future<void> boundary(String stage) async {
    if (stage != cut) return;
    final nextMarker = File('${marker.path}.next');
    nextMarker.writeAsStringSync(
      jsonEncode({'pid': pid, 'stage': stage}),
      flush: true,
    );
    nextMarker.renameSync(marker.path);
    // The parent sends SIGKILL to this exact test-VM PID. No exception, finally,
    // rollback, successful result or orderly test teardown can run after it.
    await Completer<void>().future;
  }

  @override
  Future<Map<String, Object>> getAll() async => read();

  Future<bool> mutate(String key, Object? value, {bool remove = false}) async {
    final stageKey = key.replaceFirst('flutter.', '');
    await boundary('before_set:$stageKey');
    final values = read();
    if (remove) {
      values.remove(key);
    } else {
      values[key] = value!;
    }
    final bytes = jsonEncode(values);
    final next = File('${file.path}.next');
    if (cut == 'torn_set:$stageKey') {
      next.writeAsStringSync(
        bytes.substring(0, bytes.length ~/ 2),
        flush: true,
      );
      await boundary('torn_set:$stageKey');
    }
    next.writeAsStringSync(bytes, flush: true);
    next.renameSync(file.path);
    await boundary('after_set:$stageKey');
    return true;
  }

  @override
  Future<bool> setValue(String type, String key, Object value) =>
      mutate(key, value);

  @override
  Future<bool> remove(String key) => mutate(key, null, remove: true);

  @override
  Future<bool> clear() =>
      throw UnsupportedError('No global clear in this proof');
}

void main() {
  test('DAT04 process store', () async {
    final step = jsonDecode(Platform.environment['DAT04_STEP']!) as Map;
    final disk = _FilePrefs(
      File(step['file'] as String),
      step['cut'] as String?,
      File(step['marker'] as String),
    );
    SharedPreferencesStorePlatform.instance = disk;
    final store = Act0ProgressStoreV1(key: 'p', isValidPayload: (_) => true);
    Object? result;
    await disk.boundary('before_save');
    switch (step['op']) {
      case 'save':
        result = await store.save(step['payload'] as String);
      case 'clear':
        result = await store.clear();
      case 'load':
        try {
          result = {'payload': await store.load()};
        } on FormatException {
          result = 'HOLD';
        }
    }
    // File receipt avoids the Flutter reporter's carriage-return formatting.
    File(step['result'] as String).writeAsStringSync(
      jsonEncode({'pid': pid, 'result': result}),
      flush: true,
    );
  });
}
