import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/core/training/library/training_pack_library_v2.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart';
import 'package:poker_analyzer/screens/training_session_screen.dart';
import 'package:poker_analyzer/screens/v2/training_pack_play_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/module_launcher_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(TrainingPackLibraryV2.instance.clear);

  testWidgets(
    'cash and mtt branch entries stay on branch-specific launcher surface',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ModuleLauncherScreen(branch: ModuleLauncherBranch.cash),
        ),
      );
      expect(find.byType(ModuleLauncherScreen), findsOneWidget);
      expect(find.byKey(const Key('cash_branch_entry_tile')), findsOneWidget);
      expect(find.text('Cash Progression'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: ModuleLauncherScreen(branch: ModuleLauncherBranch.mtt),
        ),
      );
      expect(find.byType(ModuleLauncherScreen), findsOneWidget);
      expect(find.byKey(const Key('mtt_branch_entry_tile')), findsOneWidget);
      expect(find.text('MTT Progression'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'branch progression tile reaches pack-play host, not legacy training session',
    (tester) async {
      TrainingPackLibraryV2.instance.addPack(
        TrainingPackTemplateV2(
          id: 'cash:l3:v1',
          name: 'Cash L3 Core',
          trainingType: TrainingType.pushFold,
          spots: <TrainingPackSpot>[TrainingPackSpot(id: 'cash_branch_spot')],
          tags: const <String>['branch_test'],
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ModuleLauncherScreen(branch: ModuleLauncherBranch.cash),
        ),
      );
      expect(find.byType(ModuleLauncherScreen), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('cash_branch_entry_tile')).first,
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TrainingPackPlayScreen), findsOneWidget);
      expect(find.byType(TrainingSessionScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
