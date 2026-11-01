// Child process for the LDR-01 process-boundary driver. Run only through
// `dart run tools/ldr01_process_boundary/driver_v1.dart`; one invocation = one
// fresh Dart VM whose only shared state is the JSON file named by LDR01_FILE.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _FileDisk extends SharedPreferencesStorePlatform {
  _FileDisk(this.file) {
    values = file.existsSync()
        ? Map<String, Object>.from(
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
          )
        : <String, Object>{};
  }
  final File file;
  late Map<String, Object> values;
  Set<String> failSet = {}, failRemove = {}, landFalse = {};
  Map<String, int> failFrom = {};
  final counts = <String, int>{};

  void _persist() {
    final next = File('${file.path}.next');
    next.writeAsStringSync(jsonEncode(values), flush: true);
    next.renameSync(file.path);
  }

  @override
  Future<Map<String, Object>> getAll() async => Map.of(values);
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    final n = counts[key] = (counts[key] ?? 0) + 1;
    if (failSet.contains(key) ||
        ((failFrom[key] ?? 0) > 0 && n >= failFrom[key]!)) {
      return false;
    }
    values[key] = value;
    _persist();
    return !landFalse.contains(key);
  }

  @override
  Future<bool> remove(String key) async {
    if (failRemove.contains(key)) return false;
    values.remove(key);
    _persist();
    return true;
  }

  @override
  Future<bool> clear() async {
    values.clear();
    _persist();
    return true;
  }
}

void main() {
  test('ldr01 child', () async {
    final file = File(Platform.environment['LDR01_FILE']!);
    final step = jsonDecode(Platform.environment['LDR01_STEP']!) as Map;
    final disk = _FileDisk(file);
    Set<String> keys(String f) => {
      for (final k in (step[f] as List? ?? const [])) 'flutter.$k',
    };
    disk.failSet = keys('failSet');
    disk.failRemove = keys('failRemove');
    disk.landFalse = keys('landFalse');
    disk.failFrom = {
      for (final e in ((step['failFrom'] as Map?) ?? const {}).entries)
        'flutter.${e.key}': e.value as int,
    };
    SharedPreferencesStorePlatform.instance = disk;
    final store = Act0ProgressStoreV1(
      key: 'p',
      isValidPayload: (v) => v != 'bad',
    );
    Object? result;
    switch (step['op']) {
      case 'save':
        result = await store.save(step['payload'] as String);
      case 'clear':
        result = await store.clear();
      case 'load':
        try {
          result = {'payload': await store.load()};
        } on FormatException {
          result = 'FormatException';
        }
      case 'corrupt':
        disk.values['flutter.p_${step['key']}'] = '{corrupt';
        disk._persist();
        result = 'ok';
      case 'seedLegacy':
        disk.values['flutter.p'] = step['payload'] as String;
        disk._persist();
        result = 'ok';
      case 'writeCopies':
        for (final c in ['recovery', 'backup']) {
          final v = step[c] as List?;
          if (v != null) {
            disk.values['flutter.p_$c'] = Act0ProgressStoreV1.debugEnvelopeV1(
              v[0] as int,
              v[1] as String?,
            );
          }
        }
        disk._persist();
        result = 'ok';
    }
    String one(String n) {
      final raw = disk.values['flutter.p_$n'];
      if (raw == null) return '-';
      try {
        final m = jsonDecode(raw as String) as Map;
        return 'r${m['revision']}:${m['payload']}';
      } catch (_) {
        return 'BAD';
      }
    }

    stdout.writeln(
      'RESULT ${jsonEncode({'pid': pid, 'result': result, 'recovery': one('recovery'), 'backup': one('backup')})}',
    );
  });
}
