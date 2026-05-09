import 'dart:io';

import 'package:test/test.dart';

import '../../tools/public_release_preparer.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync(
      'public_release_personalization',
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Directory reportsDir() => Directory('${tempDir.path}/release/_reports');

  test('missing personalization artifact fails gate', () {
    final reports = reportsDir();
    reports.createSync(recursive: true);

    final result = checkPersonalizationArtifact(reports);

    expect(result.success, isFalse);
    expect(result.message, contains('personalization_next_action.jsonl'));
    expect(result.message, contains(reports.path));
  });

  test('present personalization artifact passes gate', () async {
    final reports = reportsDir();
    reports.createSync(recursive: true);
    final artifact = File('${reports.path}/personalization_next_action.jsonl');
    await artifact.writeAsString('{"schema":"personalization_next_action_v1"}');

    final result = checkPersonalizationArtifact(reports);

    expect(result.success, isTrue);
    expect(result.message, contains('present'));
  });
}
