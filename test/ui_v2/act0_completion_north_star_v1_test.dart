import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_north_star_preview_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

/// The North Star lesson payoff is paint only: same projection, copy, keys,
/// CTA order and callbacks as the light reading payoff.
void main() {
  const summaries = <String, Act0BlockCompletionSummaryV1>{
    'assisted miss': Act0BlockCompletionSummaryV1(
      lessonTitle: 'Your first hand, dealt',
      xpEarned: 20,
      errorCount: 1,
      assistedCount: 1,
      taskCount: 7,
      correctCount: 6,
      startLevel: 1,
      endLevel: 1,
      startXp: 80,
      endXp: 100,
      xpTarget: 200,
      nextLessonTitle: 'Fold, check, call, raise',
    ),
    'clean clear': Act0BlockCompletionSummaryV1(
      lessonTitle: 'Action words',
      xpEarned: 20,
      errorCount: 0,
      taskCount: 2,
      correctCount: 2,
      startLevel: 1,
      endLevel: 1,
      startXp: 80,
      endXp: 100,
      xpTarget: 200,
      nextLessonTitle: 'Blinds and action order',
    ),
  };
  const evidence = Act0SessionSummaryEvidenceViewModelV1(
    hasEvidence: true,
    title: 'This run',
    runId: 'run_v1|world_1|your_first_hand|lesson|1',
    runKind: 'lesson',
    spotsLine: 'You played 7 spots.',
    resultLine: '6 correct / 1 to review.',
    repairFocusLine: 'You missed the table read clue.',
    currentSessionOnly: true,
  );

  Future<List<String>> pump(
    WidgetTester t,
    Act0BlockCompletionSummaryV1 summary, {
    required bool northStar,
    List<String>? calls,
  }) async {
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0BlockCompletionShellV1(
            northStar: northStar,
            summary: summary,
            evidenceSummary: evidence,
            onContinue: () => calls?.add('continue'),
            onReplay: () => calls?.add('replay'),
            onOpenReview: () => calls?.add('review'),
            onBackToMap: () => calls?.add('map'),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    return [
      for (final e in find.byType(Text).evaluate())
        '${e.widget.key}|${(e.widget as Text).data}',
    ];
  }

  for (final MapEntry(key: name, value: summary) in summaries.entries) {
    testWidgets('$name: identical copy and keys in both palettes', (t) async {
      final light = await pump(t, summary, northStar: false);
      final dark = await pump(t, summary, northStar: true);
      expect(dark, light);
      expect(
        find.byKey(const Key('act0_shell_block_summary_north_star_page')),
        findsOneWidget,
      );
      final page = t.widget<ColoredBox>(
        find.byKey(const Key('act0_shell_block_summary_north_star_page')),
      );
      expect(page.color, Act0HomeNorthStarPaletteV1.ink);
    });

    testWidgets('$name: primary CTA keeps its callback in North Star', (
      t,
    ) async {
      final lightCalls = <String>[];
      await pump(t, summary, northStar: false, calls: lightCalls);
      await t.tap(
        find.byKey(const Key('act0_shell_block_summary_continue_cta')),
      );
      final darkCalls = <String>[];
      await pump(t, summary, northStar: true, calls: darkCalls);
      await t.tap(
        find.byKey(const Key('act0_shell_block_summary_continue_cta')),
      );
      expect(darkCalls, lightCalls);
      expect(darkCalls, hasLength(1));
      final cta = t.getSize(
        find.byKey(const Key('act0_shell_block_summary_continue_cta')),
      );
      expect(cta.height, greaterThanOrEqualTo(48));
    });
  }

  testWidgets('assisted work is still labelled as help, not mastery', (
    t,
  ) async {
    final texts = await pump(t, summaries['assisted miss']!, northStar: true);
    expect(texts.any((t) => t.contains('with help')), isTrue);
    expect(texts.any((t) => t.toLowerCase().contains('mastered')), isFalse);
  });

  test('North Star text keeps readable contrast on its ink ground', () {
    double lum(Color c) => c.computeLuminance();
    double ratio(Color a, Color b) {
      final x = lum(a), y = lum(b);
      return (_max(x, y) + .05) / (_min(x, y) + .05);
    }

    const p = Act0CompletionPaletteV1.northStar;
    for (final c in [p.text, p.textMuted, p.info]) {
      expect(ratio(c, p.page!), greaterThanOrEqualTo(4.5));
      expect(ratio(c, p.surface2), greaterThanOrEqualTo(4.5));
    }
  });
}

double _max(double a, double b) => a > b ? a : b;
double _min(double a, double b) => a < b ? a : b;
