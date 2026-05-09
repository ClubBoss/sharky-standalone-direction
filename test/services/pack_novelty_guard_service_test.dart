import 'package:poker_analyzer/testing/test_shims.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/pack_novelty_guard_service.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: type adjust use v2
import 'package:poker_analyzer/models/game_type.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/core/training/library/training_pack_library_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TrainingPackLibraryV2.instance.clear();
    final cacheDir = Directory('autogen_cache');
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  });

  v2.TrainingPackTemplateV2 buildPack(String id, List<String> boards) {
    final spots = <TrainingPackSpot>[];
    for (var i = 0; i < boards.length; i++) {
      spots.add(
        TrainingPackSpot(id: '${id}_$i', tags: ['t'], board: [boards[i]]),
      );
    }
    return v2.TrainingPackTemplateV2(
      id: id,
      name: id,
      trainingType: TrainingType.custom, // fix: type adjust use v2
      spots: spots,
      spotCount: spots.length,
      tags: const <String>['t'], // fix: type adjust generics
      gameType: GameType.cash,
    );
  }

  test('flags duplicates above threshold', () async {
    final existing = buildPack('a', ['As']);
    TrainingPackLibraryV2.instance.addPack(existing);
    final guard = PackNoveltyGuardService();
    final candidate = buildPack('b', ['As']);
    final result = await guard.evaluate[candidate];
    expect(result.isDuplicate, isTrue);
    expect(result.bestMatchId, 'a');
  });

  test('accepts novel packs', () async {
    final existing = buildPack('a', ['As']);
    TrainingPackLibraryV2.instance.addPack(existing);
    final guard = PackNoveltyGuardService();
    final candidate = buildPack('b', ['Kd']);
    final result = await guard.evaluate[candidate];
    expect(result.isDuplicate, isFalse);
  });
}
