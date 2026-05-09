import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'w1.s02-w1.s03 surface the next World 1 expansion cluster on the action-choice seam',
    (tester) async {
      final adapter = const DrillRuntimeAdapterV1();
      final sessionIds = <String>['w1.s02', 'w1.s03'];

      for (final sessionId in sessionIds) {
        final drills = (await tester.runAsync(
          () => adapter.loadSessionDrills(sessionId),
        ))!;

        await tester.pumpWidget(
          MaterialApp(
            home: SessionDrillPlayerV1Screen(
              sessionId: sessionId,
              debugDrillsOverrideV1: drills,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('session_drill_player_texture_fold_v1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('session_drill_player_texture_call_v1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('session_drill_player_texture_raise_v1')),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets(
    'w1.s04-w1.s06 continue the World 1 repetition cluster on the action-choice seam',
    (tester) async {
      final adapter = const DrillRuntimeAdapterV1();
      final sessionIds = <String>['w1.s04', 'w1.s05', 'w1.s06'];

      for (final sessionId in sessionIds) {
        final drills = (await tester.runAsync(
          () => adapter.loadSessionDrills(sessionId),
        ))!;

        await tester.pumpWidget(
          MaterialApp(
            home: SessionDrillPlayerV1Screen(
              sessionId: sessionId,
              debugDrillsOverrideV1: drills,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('session_drill_player_texture_fold_v1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('session_drill_player_texture_call_v1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('session_drill_player_texture_raise_v1')),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets('w1.s07-w1.s10 keep the World 1 tail on the action-choice seam', (
    tester,
  ) async {
    final adapter = const DrillRuntimeAdapterV1();
    final sessionIds = <String>['w1.s07', 'w1.s08', 'w1.s09', 'w1.s10'];

    for (final sessionId in sessionIds) {
      final drills = (await tester.runAsync(
        () => adapter.loadSessionDrills(sessionId),
      ))!;

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: sessionId,
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_call_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
        findsOneWidget,
      );
    }
  });

  testWidgets(
    'w1.s03 mixed checkpoint expansion cluster completes deterministically',
    (tester) async {
      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w1.s03'),
      ))!;

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w1.s03',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('small blind with AQs'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
      );
      await tester.pump();

      expect(find.textContaining('button with KQs'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_call_v1')),
      );
      await tester.pump();

      expect(find.textContaining('big blind with T7o'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'w1.s06 mixed checkpoint continuation cluster completes deterministically',
    (tester) async {
      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w1.s06'),
      ))!;

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w1.s06',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('cutoff with AJs'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
      );
      await tester.pump();

      expect(find.textContaining('button with KJs'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_call_v1')),
      );
      await tester.pump();

      expect(find.textContaining('big blind with J4o'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
    },
  );

  testWidgets('w1.s09 focused tail cluster completes deterministically', (
    tester,
  ) async {
    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w1.s09'),
    ))!;

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w1.s09',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('small blind with ATs'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_raise_v1')),
    );
    await tester.pump();

    expect(find.textContaining('button with KTs'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_call_v1')),
    );
    await tester.pump();

    expect(find.textContaining('big blind with T5o'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_fold_v1')),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('session_drill_player_complete')),
      findsOneWidget,
    );
  });

  testWidgets('w1.s10 final checkpoint completes deterministically', (
    tester,
  ) async {
    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w1.s10'),
    ))!;

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w1.s10',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('button with AQs'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_raise_v1')),
    );
    await tester.pump();

    expect(find.textContaining('button with KQs'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_call_v1')),
    );
    await tester.pump();

    expect(find.textContaining('big blind with T6o'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_fold_v1')),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('session_drill_player_complete')),
      findsOneWidget,
    );
  });
}
