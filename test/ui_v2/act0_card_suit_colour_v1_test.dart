import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A card's ink follows its suit: hearts and diamonds read red even when the
// task author left the default dark tone.
void main() {
  test('suit decides red ink, tone only for unknown suits', () {
    expect(const Act0CardStateV1(rank: 'A', suit: 'h').isRedSuit, isTrue);
    expect(const Act0CardStateV1(rank: 'Q', suit: 'd').isRedSuit, isTrue);
    expect(
      const Act0CardStateV1(
        rank: 'K',
        suit: 's',
        tone: Act0CardToneV1.red,
      ).isRedSuit,
      isFalse,
    );
    expect(const Act0CardStateV1(rank: '7', suit: 'c').isRedSuit, isFalse);
    expect(const Act0CardStateV1(rank: '?', suit: '').isRedSuit, isFalse);
  });

  testWidgets('a heart left with the default tone is drawn in red', (t) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    // Hero holds As Ah here; Ah carries no explicit red tone in the catalog.
    await t.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        home: Act0ShellPreviewScreenV1(
          initialPhase: Act0LessonPhaseV1.drill,
          showPlacementOnStart: false,
          debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
            worldId: 'world_2',
            lessonId: 'hand_discipline_buckets',
            taskId: 'hand_discipline_buckets_premium',
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final hearts = t
        .widgetList<Text>(find.text('\u2665'))
        .map((w) => w.style?.color)
        .toList();
    final spades = t
        .widgetList<Text>(find.text('\u2660'))
        .map((w) => w.style?.color)
        .toList();
    expect(hearts, isNotEmpty);
    expect(spades, isNotEmpty);
    expect(hearts.toSet(), {Act0ShellTokensV1.runnerAnswerDanger});
    expect(spades.toSet(), {Act0ShellTokensV1.runnerAnswerText});
  });
}
