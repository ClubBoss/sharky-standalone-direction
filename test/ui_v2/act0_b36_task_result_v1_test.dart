import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/skin/act0_skin_components_v1.dart';

void main() {
  for (final scale in [1.0, 1.3]) {
    testWidgets('TaskHeader fits 393 pt at $scale×', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final mode = ValueNotifier(false);
      addTearDown(mode.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Scaffold(
            body: ValueListenableBuilder(
              valueListenable: mode,
              builder: (_, extra, __) => Act0SkinTaskHeaderV1(
                step: 11,
                total: 12,
                onClose: () {},
                modeLabel: extra ? 'Extra practice' : null,
                onHelp: extra ? () {} : null,
              ),
            ),
          ),
        ),
      );
      final header = find.byType(Act0SkinTaskHeaderV1);
      final before = tester.getRect(header);
      mode.value = true;
      await tester.pump();
      expect(tester.getRect(header), before);
      for (final label in ['11 of 12', 'Extra practice']) {
        final text = find.text(label);
        expect(
          tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
          isFalse,
        );
        final bounds = tester.getRect(text);
        expect(before.contains(bounds.topLeft), isTrue);
        expect(bounds.right, lessThan(before.right));
        expect(bounds.bottom, lessThanOrEqualTo(before.bottom));
      }
      final help = tester.getRect(find.byTooltip('Glossary'));
      expect(help.right, before.right);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Result has one primary, one review action and header close', (
    tester,
  ) async {
    var next = 0;
    var reviews = 0;
    var closed = 0;
    final reminders = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0BlockCompletionShellV1(
            summary: const Act0BlockCompletionSummaryV1(
              lessonTitle: 'Action words',
              nextLessonTitle: 'Position',
              curriculumCompleted: true,
              xpEarned: 0,
              errorCount: 1,
              taskCount: 1,
              correctCount: 0,
              independentCount: 0,
              repairedCount: 1,
              startLevel: 1,
              endLevel: 1,
              startXp: 0,
              endXp: 0,
              xpTarget: 200,
            ),
            onContinue: () => next++,
            onOpenReview: () => reviews++,
            onBackToMap: () {},
            onBackToHome: () => closed++,
            onFirstLessonReminder: reminders.add,
            canShareResult: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final primary = find.byType(Act0SkinPrimaryButtonV1);
    final secondary = find.byType(Act0SkinSecondaryButtonV1);
    expect(primary, findsOneWidget);
    expect(secondary, findsOneWidget);
    expect(find.byType(Act0SkinBannerV1), findsOneWidget);
    expect(find.text('Back to Home'), findsNothing);
    expect(find.text('Back to map'), findsNothing);
    expect(find.text('Share result'), findsOneWidget);
    for (final action in [
      primary,
      secondary,
      find.text('Yes'),
      find.text('No'),
      find.byTooltip('Close result'),
    ]) {
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pumpAndSettle();
    }
    expect(next, 1);
    expect(reviews, 1);
    expect(closed, 1);
    expect(reminders, [true, false]);
  });
}
