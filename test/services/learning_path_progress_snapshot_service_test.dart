import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/models/learning_path_progress_snapshot.dart';
import 'package:poker_analyzer/services/learning_path_progress_snapshot_service.dart';
import 'package:poker_analyzer/ui/telemetry_test_harness.dart';

void main() {
  group('LearningPathProgressSnapshotService', () {
    late Directory tempDir;
    late TelemetryTestHarness harness;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('lp_snapshot_test_');
      harness = TelemetryTestHarness();
      Telemetry.overrideLogHandler(harness.logEvent);
    });

    tearDown(() {
      Telemetry.overrideLogHandler(null);
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('recovers corrupted snapshot from backup and logs once', () async {
      final storage = FileProgressSnapshotStorage(rootDir: tempDir);
      final service = LearningPathProgressSnapshotService(storage: storage);
      const pathId = 'path-1';
      const snap1 = LearningPathProgressSnapshot(
        pathId: pathId,
        stageId: 'stage-a',
        handsPlayed: 3,
        accuracy: 0.4,
      );
      const snap2 = LearningPathProgressSnapshot(
        pathId: pathId,
        stageId: 'stage-b',
        handsPlayed: 7,
        accuracy: 0.9,
      );

      await service.save(pathId, snap1);
      await service.save(pathId, snap2);

      final key = 'lp_snapshot_$pathId';
      final safeKey = key.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final file = File('${tempDir.path}/$safeKey.json');
      file.writeAsStringSync('{bad json');

      final loaded = await service.load(pathId);

      expect(loaded, isNotNull);
      expect(loaded!.stageId, equals('stage-a'));
      final events = harness.eventsByName('learning_path_snapshot_corrupt_v1');
      expect(events, hasLength(1));
      expect(events.single.payload['recovered'], isTrue);
      expect(events.single.payload['storage'], equals('file'));
      expect(events.single.payload['pathId'], equals(pathId));
    });
  });
}
