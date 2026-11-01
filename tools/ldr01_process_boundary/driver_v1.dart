// LDR-01 process-boundary driver. Every step is a NEW OS process
// (`flutter test` child) sharing only persisted bytes in a JSON file.
// Usage: dart run tools/ldr01_process_boundary/driver_v1.dart
import 'dart:convert';
import 'dart:io';

var failures = 0;

Future<Map<String, dynamic>> step(File f, Map<String, Object?> s) async {
  final r = await Process.run(
    'flutter',
    ['test', 'tools/ldr01_process_boundary/store_child_v1.dart'],
    environment: {'LDR01_FILE': f.path, 'LDR01_STEP': jsonEncode(s)},
  );
  final line = '${r.stdout}'
      .split('\n')
      .firstWhere((l) => l.contains('RESULT '), orElse: () => '');
  if (line.isEmpty) {
    stdout.writeln('CHILD FAILED ${jsonEncode(s)}\n${r.stdout}${r.stderr}');
    exit(2);
  }
  final out =
      jsonDecode(line.substring(line.indexOf('RESULT ') + 7))
          as Map<String, dynamic>;
  stdout.writeln(
    '  pid=${out['pid']} ${jsonEncode(s)} -> result=${jsonEncode(out['result'])} disk=[recovery=${out['recovery']} backup=${out['backup']}]',
  );
  return out;
}

void expectEq(String name, Object? actual, Object? want) {
  final ok = jsonEncode(actual) == jsonEncode(want);
  if (!ok) failures++;
  stdout.writeln(
    '  ${ok ? 'PASS' : 'FAIL'} $name: got ${jsonEncode(actual)} want ${jsonEncode(want)}',
  );
}

Future<void> scenario(String name, Future<void> Function(File) body) async {
  stdout.writeln('SCENARIO $name');
  final dir = Directory.systemTemp.createTempSync('ldr01_pb_');
  await body(File('${dir.path}/disk.json'));
  dir.deleteSync(recursive: true);
}

Map<String, Object?> pl(String x) => {'payload': x};

Future<void> main() async {
  await scenario(
    'R1 failed reset + failed rollback, restart, corrupt recovery',
    (f) async {
      await step(f, {'op': 'save', 'payload': '{"xp":50}'});
      final c = await step(f, {
        'op': 'clear',
        'failSet': ['p_backup'],
        'failRemove': ['p_backup'],
      });
      expectEq('clear ack', c['result'], false);
      final blocked = await step(f, {
        'op': 'load',
        'failSet': ['p_backup'],
      });
      expectEq(
        'heal blocked fails closed',
        blocked['result'],
        'FormatException',
      );
      final healed = await step(f, {'op': 'load'});
      expectEq('fresh process heals tombstone', healed['result'], {
        'payload': null,
      });
      await step(f, {'op': 'corrupt', 'key': 'recovery'});
      final after = await step(f, {'op': 'load'});
      expectEq('no resurrection after corruption', after['result'], {
        'payload': null,
      });
    },
  );
  await scenario('R1 original evidence: recovery rollback also fails', (
    f,
  ) async {
    await step(f, {'op': 'save', 'payload': '{"xp":50}'});
    final c = await step(f, {
      'op': 'clear',
      'failSet': ['p_backup'],
      'failRemove': ['p_backup'],
      'failFrom': {'p_recovery': 2},
    });
    expectEq('clear ack', c['result'], false);
    expectEq(
      'fresh process (writable)',
      (await step(f, {'op': 'load'}))['result'],
      {'payload': null},
    );
    await step(f, {'op': 'corrupt', 'key': 'recovery'});
    expectEq(
      'no resurrection after corruption',
      (await step(f, {'op': 'load'}))['result'],
      {'payload': null},
    );
  });
  await scenario('failed save then fresh process', (f) async {
    await step(f, {'op': 'save', 'payload': '{"xp":50}'});
    final s = await step(f, {
      'op': 'save',
      'payload': '{"xp":99}',
      'failSet': ['p_backup'],
    });
    expectEq('save ack', s['result'], false);
    final l = await step(f, {'op': 'load'});
    expectEq('healed forward', l['result'], {'payload': '{"xp":99}'});
  });
  await scenario('setValue false but landed', (f) async {
    await step(f, {'op': 'save', 'payload': '{"xp":50}'});
    final s = await step(f, {
      'op': 'save',
      'payload': '{"xp":70}',
      'landFalse': ['p_recovery', 'p_backup'],
    });
    expectEq('ack after verified landing', s['result'], true);
    expectEq('fresh load', (await step(f, {'op': 'load'}))['result'], {
      'payload': '{"xp":70}',
    });
  });
  await scenario('remove failure of legacy mirror', (f) async {
    await step(f, {'op': 'seedLegacy', 'payload': '{"xp":50}'});
    await step(f, {'op': 'save', 'payload': '{"xp":60}'});
    final c = await step(f, {
      'op': 'clear',
      'failRemove': ['p'],
    });
    expectEq('clear ack', c['result'], true);
    expectEq(
      'legacy mirror ignored',
      (await step(f, {'op': 'load'}))['result'],
      {'payload': null},
    );
  });
  await scenario('backup newer than recovery', (f) async {
    await step(f, {
      'op': 'writeCopies',
      'recovery': [1, 'a'],
      'backup': [2, 'b'],
    });
    expectEq('higher wins', (await step(f, {'op': 'load'}))['result'], {
      'payload': 'b',
    });
  });
  await scenario('recovery newer than backup', (f) async {
    await step(f, {
      'op': 'writeCopies',
      'recovery': [3, 'c'],
      'backup': [2, 'b'],
    });
    expectEq('higher wins', (await step(f, {'op': 'load'}))['result'], {
      'payload': 'c',
    });
  });
  await scenario('equal revision conflicting payload', (f) async {
    await step(f, {
      'op': 'writeCopies',
      'recovery': [2, 'a'],
      'backup': [2, 'b'],
    });
    expectEq(
      'fails closed',
      (await step(f, {'op': 'load'}))['result'],
      'FormatException',
    );
    expectEq(
      'save refused',
      (await step(f, {'op': 'save', 'payload': 'x'}))['result'],
      false,
    );
  });
  await scenario('interrupted between copies', (f) async {
    await step(f, {'op': 'save', 'payload': '{"xp":50}'});
    await step(f, {
      'op': 'save',
      'payload': '{"xp":70}',
      'failSet': ['p_backup'],
    });
    expectEq('fresh heals to new', (await step(f, {'op': 'load'}))['result'], {
      'payload': '{"xp":70}',
    });
  });
  await scenario('failed mandatory healing', (f) async {
    await step(f, {
      'op': 'writeCopies',
      'recovery': [2, 'new'],
      'backup': [1, 'old'],
    });
    final l = await step(f, {
      'op': 'load',
      'failSet': ['p_backup'],
    });
    expectEq('fail closed', l['result'], 'FormatException');
    expectEq(
      'save refused',
      (await step(f, {
        'op': 'save',
        'payload': 'x',
        'failSet': ['p_backup'],
      }))['result'],
      false,
    );
  });
  await scenario('recovery corruption before healing (R2) vs after', (f) async {
    await step(f, {
      'op': 'writeCopies',
      'recovery': [2, 'new'],
      'backup': [1, 'old'],
    });
    await step(f, {'op': 'corrupt', 'key': 'recovery'});
    expectEq(
      'R2: only acked copy survives',
      (await step(f, {'op': 'load'}))['result'],
      {'payload': 'old'},
    );
  });
  await scenario('committed save + reset, single-copy and double corruption', (
    f,
  ) async {
    expectEq(
      'save ack',
      (await step(f, {'op': 'save', 'payload': 'v1'}))['result'],
      true,
    );
    await step(f, {'op': 'corrupt', 'key': 'backup'});
    expectEq(
      'single copy recovers',
      (await step(f, {'op': 'load'}))['result'],
      {'payload': 'v1'},
    );
    expectEq('reset ack', (await step(f, {'op': 'clear'}))['result'], true);
    expectEq(
      'tombstone in fresh process',
      (await step(f, {'op': 'load'}))['result'],
      {'payload': null},
    );
    await step(f, {'op': 'corrupt', 'key': 'recovery'});
    await step(f, {'op': 'corrupt', 'key': 'backup'});
    expectEq(
      'both corrupt fail closed',
      (await step(f, {'op': 'load'}))['result'],
      'FormatException',
    );
  });
  await scenario('legacy migration', (f) async {
    await step(f, {'op': 'seedLegacy', 'payload': '{"xp":5}'});
    expectEq('legacy read', (await step(f, {'op': 'load'}))['result'], {
      'payload': '{"xp":5}',
    });
    expectEq(
      'first save',
      (await step(f, {'op': 'save', 'payload': '{"xp":9}'}))['result'],
      true,
    );
    expectEq('protected wins', (await step(f, {'op': 'load'}))['result'], {
      'payload': '{"xp":9}',
    });
  });
  stdout.writeln(
    failures == 0
        ? 'PROCESS_BOUNDARY_ALL_PASS'
        : 'PROCESS_BOUNDARY_FAILURES=$failures',
  );
  exit(failures == 0 ? 0 : 1);
}
