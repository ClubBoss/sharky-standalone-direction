import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _w11ManifestPath =
    'content/worlds/world11/v1/source_proof_manifest_v1.json';
const _w12ManifestPath =
    'content/worlds/world12/v1/source_proof_manifest_v1.json';
const _validatorPath = 'tools/validate_w11_w12_source_proof_v1.dart';

void main() {
  test('W11 and W12 source-proof manifests resolve all accepted IDs', () async {
    final result = await _runValidator(_w11ManifestPath, _w12ManifestPath);

    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(
      result.stdout,
      contains('world_11 lessons=4 tasks=21 reps=6 packs=4'),
    );
    expect(
      result.stdout,
      contains('world_12 lessons=4 tasks=20 reps=6 packs=4'),
    );
    expect(result.stdout, contains('validate_w11_w12_source_proof_v1: OK'));
  });

  test('unknown Act0 task ID fails deterministically', () async {
    final manifests = await _temporaryManifests((w11, _) {
      final lessons = (w11['lessons']! as List).cast<Map<String, Object?>>();
      final firstTasks = (lessons.first['task_ids']! as List).cast<String>();
      firstTasks[0] = 'w11_missing_task_reference';
    });
    addTearDown(manifests.dispose);

    final result = await _runValidator(manifests.w11Path, manifests.w12Path);

    expect(result.exitCode, 2);
    expect(result.stderr, contains('unresolved Act0 task ID'));
    expect(result.stderr, contains('w11_missing_task_reference'));
  });

  test('unknown packet rep ID fails deterministically', () async {
    final manifests = await _temporaryManifests((_, w12) {
      final repIds = (w12['packet_rep_ids']! as List).cast<String>();
      repIds[0] = 'w12.s01.r99';
    });
    addTearDown(manifests.dispose);

    final result = await _runValidator(manifests.w11Path, manifests.w12Path);

    expect(result.exitCode, 2);
    expect(result.stderr, contains('unresolved packet rep ID'));
    expect(result.stderr, contains('w12.s01.r99'));
  });

  test('unknown campaign pack ID fails deterministically', () async {
    final manifests = await _temporaryManifests((w11, _) {
      final packIds = (w11['campaign_pack_ids']! as List).cast<String>();
      packIds[0] = 'world11_missing_pack_v1';
    });
    addTearDown(manifests.dispose);

    final result = await _runValidator(manifests.w11Path, manifests.w12Path);

    expect(result.exitCode, 2);
    expect(result.stderr, contains('unresolved campaign pack ID'));
    expect(result.stderr, contains('world11_missing_pack_v1'));
  });

  test('learner-facing copy fields are rejected from metadata', () async {
    final manifests = await _temporaryManifests((_, w12) {
      w12['learner_prompt'] = 'copied learner text';
    });
    addTearDown(manifests.dispose);

    final result = await _runValidator(manifests.w11Path, manifests.w12Path);

    expect(result.exitCode, 2);
    expect(result.stderr, contains('forbidden learner-facing metadata key'));
    expect(result.stderr, contains('learner_prompt'));
  });
}

Future<ProcessResult> _runValidator(String w11Path, String w12Path) {
  return Process.run('dart', <String>['run', _validatorPath, w11Path, w12Path]);
}

Future<_TemporaryManifests> _temporaryManifests(
  void Function(Map<String, Object?> w11, Map<String, Object?> w12) mutate,
) async {
  final tempDir = await Directory.systemTemp.createTemp(
    'w11_w12_source_proof_validator_v1_',
  );
  final w11 = _readManifest(_w11ManifestPath);
  final w12 = _readManifest(_w12ManifestPath);
  mutate(w11, w12);

  final w11File = File('${tempDir.path}/w11.json');
  final w12File = File('${tempDir.path}/w12.json');
  await w11File.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(w11)}\n',
  );
  await w12File.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(w12)}\n',
  );
  return _TemporaryManifests(tempDir, w11File.path, w12File.path);
}

Map<String, Object?> _readManifest(String path) {
  return (jsonDecode(File(path).readAsStringSync()) as Map)
      .cast<String, Object?>();
}

class _TemporaryManifests {
  const _TemporaryManifests(this.directory, this.w11Path, this.w12Path);

  final Directory directory;
  final String w11Path;
  final String w12Path;

  Future<void> dispose() => directory.delete(recursive: true);
}
