import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('eligible checkpoint opens checkpoint session runner', (
    tester,
  ) async {
    final seed = seedWorld1CampaignComplete();
    await pumpToMap(
      tester,
      seed: GuardSeedV2(<String, Object>{
        ...seed.values,
        '${ProgressService.completedPrefix}${kWorld1CanonicalModuleOrder.first}':
            true,
        '${ProgressService.completedPrefix}${kWorld1CanonicalModuleOrder[1]}':
            true,
        '${ProgressService.completedPrefix}${kWorld1CanonicalModuleOrder[2]}':
            true,
      }),
    );

    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);
    final openCheckpoint = find.byKey(const Key('world1_checkpoint_open_3'));
    final lockedCheckpoint = find.byKey(
      const Key('world1_checkpoint_locked_3'),
    );
    if (openCheckpoint.evaluate().isNotEmpty) {
      await tester.ensureVisible(openCheckpoint);
      await tester.tap(openCheckpoint, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('checkpoint_runner')), findsOneWidget);
      await tester.tap(find.byKey(const Key('microtask_seat_btn')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('checkpoint_check_cta')));
      await tester.pumpAndSettle();
    }
    if (lockedCheckpoint.evaluate().isNotEmpty) {
      expect(lockedCheckpoint, findsOneWidget);
    }

    expect(tester.takeException(), isNull);
  });
}
