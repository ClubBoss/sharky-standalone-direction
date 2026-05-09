import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingPackTemplate,
        TrainingPackTemplateV2,
        HandData; // fix: hide shim
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: v2 alias
import 'package:poker_analyzer/models/v2/hand_data.dart'
    as v2models; // fix: v2 hand
import 'package:poker_analyzer/screens/packs_library_screen.dart';
import 'package:poker_analyzer/screens/v2/training_session_screen.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

class _FakeBundle extends CachingAssetBundle {
  final Map<String, String> data;
  _FakeBundle(this.data);
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      data[key]!;
}

void main() {
  testWidgets('resume button opens session', (tester) async {
    final spots = <TrainingPackSpot>[
      TrainingPackSpot(id: 's1', hand: v2models.HandData()),
    ]; // fix: v2 ctor/collections/types
    final tpl = v2.TrainingPackTemplateV2(
      id: 'p1',
      name: 'Pack',
      trainingType: TrainingType.quiz,
      spots: spots,
      spotCount: spots.length,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    final bundle = _FakeBundle({
      'AssetManifest.json': jsonEncode({
        'assets/packs/test.json': ['assets/packs/test.json'],
      }),
      'assets/packs/test.json': jsonEncode(tpl.toJson()),
    });
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: bundle,
        child: MaterialApp(home: PacksLibraryScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_circle_fill));
    await tester.pumpAndSettle();
    expect(find.byType(TrainingSessionScreen), findsOneWidget);
  });
}
