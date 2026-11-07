import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_leaf_style_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_onboarding_leaf_v1.dart';

const _primaryKey = Key('source_primary');
const _secondaryKey = Key('source_secondary');
const _backKey = Key('source_back');

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pump();
}

Act0AcademyOnboardingLeafV1 _page({
  Widget content = const SizedBox.shrink(),
  VoidCallback? onPrimary,
  VoidCallback? onSecondary,
  VoidCallback? onBack,
  Widget? actions,
  bool hero = false,
  ImageProvider? backdrop,
}) => Act0AcademyOnboardingLeafV1(
  eyebrow: 'Your starting point',
  title: 'Find your first hand',
  subtitle: 'A few questions help choose where to begin.',
  stage: '1 of 3',
  content: content,
  primaryLabel: 'Continue',
  primaryKey: _primaryKey,
  onPrimary: onPrimary,
  secondaryLabel: 'Start from zero',
  secondaryKey: _secondaryKey,
  onSecondary: onSecondary,
  onBack: onBack,
  backKey: _backKey,
  backLabel: 'Close welcome',
  actions: actions,
  hero: hero,
  backdrop: backdrop,
);

void main() {
  Future<void> tap(WidgetTester tester, String key) async {
    final target = find.byKey(Key(key));
    expect(target, findsOneWidget, reason: key);
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> fresh(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await _pump(
      tester,
      const Act0ShellPreviewScreenV1(showPlacementOnStart: true),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'connected green placement preserves edits, diagnostic and recommended destination',
    (tester) async {
      await fresh(tester);
      expect(find.byType(Act0AcademyOnboardingLeafV1), findsOneWidget);
      await tap(tester, 'act0_shell_placement_intro_cta');
      expect(find.text('Starting point'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('act0_shell_placement_next_cta')),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const Key('act0_shell_placement_back_arrow')),
            )
            .onPressed,
        isNull,
      );
      expect(find.text('Best for zero'), findsOneWidget);
      expect(find.text('Faster start'), findsOneWidget);
      await tap(tester, 'act0_shell_placement_option_friends');
      await tap(tester, 'act0_shell_placement_next_cta');
      await tap(tester, 'act0_shell_placement_back_arrow');
      expect(
        tester
            .widget<Act0AcademyOnboardingChoiceV1>(
              find.byKey(const Key('act0_shell_placement_option_friends')),
            )
            .selected,
        isTrue,
      );
      await tap(tester, 'act0_shell_placement_option_online');
      expect(
        tester
            .widget<Act0AcademyOnboardingChoiceV1>(
              find.byKey(const Key('act0_shell_placement_option_friends')),
            )
            .selected,
        isFalse,
      );
      await tap(tester, 'act0_shell_placement_next_cta');
      await tap(tester, 'act0_shell_placement_option_cards');
      await tap(tester, 'act0_shell_placement_next_cta');
      expect(
        find.byKey(const Key('act0_shell_placement_diagnostic_ready')),
        findsOneWidget,
      );
      await tap(tester, 'act0_shell_placement_back_arrow');
      expect(
        tester
            .widget<Act0AcademyOnboardingChoiceV1>(
              find.byKey(const Key('act0_shell_placement_option_cards')),
            )
            .selected,
        isTrue,
      );
      await tap(tester, 'act0_shell_placement_next_cta');
      await tap(tester, 'act0_shell_placement_start_diagnostic');
      final diagnosticIds = <String>[];
      final diagnosticQuestions = <String>{};
      for (var i = 0; i < 3; i++) {
        final runner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        diagnosticIds.add(runner.selectedTaskId!);
        diagnosticQuestions.add(runner.runner.question);
        expect(runner.runner.beatIndex, i + 1);
        expect(runner.runner.beatCount, 3);
        expect(find.byType(Act0AcademyOnboardingLeafV1), findsNothing);
        final option = runner.runner.options.firstWhere((o) => o.isCorrect);
        await tap(
          tester,
          option.seatId == null
              ? 'act0_shell_option_${option.id}'
              : 'act0_shell_seat_tap_${option.seatId}',
        );
        await tap(tester, 'act0_shell_feedback_continue_cta');
      }
      expect(
        diagnosticIds,
        List.filled(3, 'what_poker_is_table_read_transfer'),
      );
      expect(diagnosticQuestions, hasLength(3));
      final result = tester
          .widget<Act0PlacementShellV1>(find.byType(Act0PlacementShellV1))
          .result!;
      expect(result.diagnosticTotal, 3);
      expect(result.diagnosticCorrect, 3);
      expect(find.text(result.levelLabel), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_placement_hero')),
        findsOneWidget,
      );
      expect(find.text(result.recommendedReason), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_placement_destination_trust_line')),
        findsOneWidget,
      );
      await tap(tester, 'act0_shell_placement_start_recommended');
      expect(find.byType(Act0AcademyOnboardingLeafV1), findsOneWidget);
      await tap(tester, 'act0_shell_welcome_primary_cta');
      final demo = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(demo.onCompletedDecision, isNull);
      final wrong = demo.runner.options.firstWhere((o) => !o.isCorrect);
      await tap(tester, 'act0_shell_option_${wrong.id}');
      expect(find.byType(Act0FeedbackShellV1), findsNothing);
      expect(find.textContaining('This preview was ungraded.'), findsOneWidget);
      expect(find.text('Start recommended lesson'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_welcome_presenter_tile')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_welcome_cta_bridge')),
        findsOneWidget,
      );
      await tap(tester, 'act0_shell_welcome_primary_cta');
      final real = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(real.selectedTaskId, result.recommendedTaskId);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'connected beginner shortcut still bypasses diagnostic without a graded demo',
    (tester) async {
      await fresh(tester);
      await tap(tester, 'act0_shell_placement_intro_cta');
      await tap(tester, 'act0_shell_placement_option_new');
      expect(find.text('Start from zero'), findsOneWidget);
      await tap(tester, 'act0_shell_placement_next_cta');
      expect(find.byType(Act0WelcomeShellV1), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_placement_start_diagnostic')),
        findsNothing,
      );
      await tap(tester, 'act0_shell_welcome_primary_cta');
      final demo = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(demo.onCompletedDecision, isNull);
      await tap(tester, 'act0_shell_option_${demo.runner.options.first.id}');
      expect(find.byType(Act0FeedbackShellV1), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_welcome_next_step_line')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'green multiselect retains caller ownership, minimum and disabled action',
    (tester) async {
      const question = Act0PlacementQuestionV1(
        questionId: 'existing_multi',
        title: 'Existing multi',
        subtitle: 'Choose what fits.',
        allowsMultiple: true,
        minSelections: 2,
        maxSelections: 2,
        options: [
          Act0PlacementOptionV1(
            optionId: 'a',
            label: 'Source A',
            score: 0,
            profileTag: 'A',
          ),
          Act0PlacementOptionV1(
            optionId: 'b',
            label: 'Source B',
            score: 1,
            profileTag: 'B',
          ),
        ],
      );
      var selected = <String>{};
      var next = 0;
      var back = 0;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, update) => Act0PlacementShellV1(
            questions: const [question],
            showIntro: false,
            currentQuestionIndex: 0,
            selectedOptionIds: {'existing_multi': selected},
            result: null,
            onSelectOption: (q, id) {
              expect(q, same(question));
              expect(q.maxSelections, 2);
              update(() {
                selected = {...selected};
                if (!selected.remove(id)) selected.add(id);
              });
            },
            onStartPlacement: () {},
            onBack: () => back++,
            onNext: () => next++,
            onStartDiagnostic: () {},
            onStartRecommended: () {},
            onStartFromZero: () {},
          ),
        ),
      );
      final nextFinder = find.byKey(const Key('act0_shell_placement_next_cta'));
      expect(tester.widget<FilledButton>(nextFinder).onPressed, isNull);
      await tap(tester, 'act0_shell_placement_option_a');
      expect(selected, {'a'});
      expect(tester.widget<FilledButton>(nextFinder).onPressed, isNull);
      await tap(tester, 'act0_shell_placement_option_b');
      expect(selected, {'a', 'b'});
      expect(find.text('2 selected'), findsOneWidget);
      await tap(tester, 'act0_shell_placement_next_cta');
      expect(next, 1);
      await tap(tester, 'act0_shell_placement_option_a');
      expect(selected, {'b'});
      expect(tester.widget<FilledButton>(nextFinder).onPressed, isNull);
      expect(back, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'green replay preserves Close and Back to profile without grading',
    (tester) async {
      var close = 0;
      var completed = 0;
      await _pump(
        tester,
        Act0WelcomeShellV1(
          replayMode: true,
          onClose: () => close++,
          onCompleted: () => completed++,
        ),
      );
      await tap(tester, 'act0_shell_welcome_close');
      expect(close, 1);
      expect(completed, 0);
      await tap(tester, 'act0_shell_welcome_primary_cta');
      final demo = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(demo.onCompletedDecision, isNull);
      await tap(tester, 'act0_shell_option_${demo.runner.options.first.id}');
      expect(find.text('Back to profile'), findsOneWidget);
      expect(find.text('Start recommended lesson'), findsNothing);
      expect(find.byType(Act0FeedbackShellV1), findsNothing);
      await tap(tester, 'act0_shell_welcome_close');
      expect(close, 2);
      await tap(tester, 'act0_shell_welcome_primary_cta');
      expect(completed, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('source labels, keys and callbacks are preserved', (
    tester,
  ) async {
    var primary = 0;
    var secondary = 0;
    var back = 0;
    await _pump(
      tester,
      _page(
        onPrimary: () => primary++,
        onSecondary: () => secondary++,
        onBack: () => back++,
      ),
    );
    expect(find.text('Find your first hand'), findsOneWidget);
    expect(find.text('Your starting point'), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);
    expect(find.byTooltip('Close welcome'), findsOneWidget);
    await tester.tap(find.byKey(_primaryKey));
    await tester.tap(find.byKey(_secondaryKey));
    await tester.tap(find.byKey(_backKey));
    expect([primary, secondary, back], [1, 1, 1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('null primary callback remains disabled', (tester) async {
    await _pump(tester, _page());
    final button = tester.widget<FilledButton>(find.byKey(_primaryKey));
    expect(button.onPressed, isNull);
    expect(find.byKey(_secondaryKey), findsNothing);
    expect(find.byKey(_backKey), findsNothing);
  });

  testWidgets('long source content scrolls while actions remain reachable', (
    tester,
  ) async {
    var presses = 0;
    await _pump(
      tester,
      _page(
        onPrimary: () => presses++,
        content: Column(
          children: [
            for (var index = 0; index < 30; index++)
              Text(
                'Source instruction $index: read the table before choosing.',
              ),
            const Text('Last source instruction'),
          ],
        ),
      ),
    );
    expect(find.byKey(_primaryKey).hitTestable(), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('act0_academy_onboarding_scroll')),
      const Offset(0, -1600),
    );
    await tester.pumpAndSettle();
    expect(find.text('Last source instruction').hitTestable(), findsOneWidget);
    await tester.tap(find.byKey(_primaryKey));
    expect(presses, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('caller-owned action bar replaces default controls', (
    tester,
  ) async {
    await _pump(tester, _page(actions: const Text('Existing flow actions')));
    expect(find.text('Existing flow actions'), findsOneWidget);
    expect(find.byKey(_primaryKey), findsNothing);
    expect(find.text('Continue'), findsNothing);
  });

  testWidgets('selected choice reports state without changing its owner', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    const choiceKey = Key('source_choice');
    await _pump(
      tester,
      _page(
        content: Act0AcademyOnboardingChoiceV1(
          key: choiceKey,
          label: 'I am new to poker',
          subtitle: 'Start with the table basics.',
          selected: true,
          onTap: () => taps++,
        ),
      ),
    );
    expect(
      tester.getSemantics(
        find.bySemanticsLabel(
          'I am new to poker\nStart with the table basics.',
        ),
      ),
      matchesSemantics(
        label: 'I am new to poker\nStart with the table basics.',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await tester.tap(find.byKey(choiceKey));
    expect(taps, 1);
    expect(
      tester
          .widget<Act0AcademyOnboardingChoiceV1>(find.byKey(choiceKey))
          .selected,
      isTrue,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('disabled choice cannot invoke an action', (tester) async {
    await _pump(
      tester,
      _page(
        content: const Act0AcademyOnboardingChoiceV1(
          label: 'Existing disabled choice',
          subtitle: null,
          selected: false,
          onTap: null,
        ),
      ),
    );
    final ink = tester.widget<InkWell>(find.byType(InkWell).first);
    expect(ink.onTap, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty action labels never produce blank controls', (
    tester,
  ) async {
    await _pump(
      tester,
      Act0AcademyOnboardingActionsV1(
        primaryLabel: ' ',
        primaryKey: _primaryKey,
        onPrimary: () {},
        secondaryLabel: null,
        onSecondary: () {},
      ),
    );
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('panel preserves source title body and child', (tester) async {
    await _pump(
      tester,
      _page(
        content: const Act0AcademyOnboardingPanelV1(
          title: 'Source recommendation',
          body: 'Source reason, not an invented result.',
          child: Text('Source detail'),
        ),
      ),
    );
    for (final label in [
      'Source recommendation',
      'Source reason, not an invented result.',
      'Source detail',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    final background = tester.widget<ColoredBox>(find.byType(ColoredBox).first);
    expect(background.color, Act0AcademyLeafPaletteV1.ink);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing decorative backdrop leaves usable controls', (
    tester,
  ) async {
    var presses = 0;
    await _pump(
      tester,
      _page(
        hero: true,
        backdrop: const AssetImage('missing-decorative-backdrop.png'),
        onPrimary: () => presses++,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_primaryKey));
    expect(presses, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unmount does not invoke or retain source callbacks', (
    tester,
  ) async {
    var presses = 0;
    await _pump(tester, _page(onPrimary: () => presses++));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(presses, 0);
    expect(tester.takeException(), isNull);
  });
}
