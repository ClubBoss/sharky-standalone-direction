import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFont('Roboto', '/System/Library/Fonts/SFNS.ttf');
    await _loadFont('Ahem', '/System/Library/Fonts/SFNS.ttf');
  });

  final allTasks = Act0ShellStateV1.sample.worlds
      .expand((world) => world.lessons)
      .expand((lesson) => lesson.taskList)
      .toList(growable: false);

  test('exactly two semantic composition families cover every live task', () {
    expect(Act0RunnerCompositionFamilyV1.values, hasLength(2));
    expect(allTasks, hasLength(367));

    final counts = <Act0RunnerCompositionFamilyV1, int>{
      for (final family in Act0RunnerCompositionFamilyV1.values) family: 0,
    };
    for (final task in allTasks) {
      counts[task.resolvedCompositionFamily] =
          counts[task.resolvedCompositionFamily]! + 1;
    }
    expect(counts, <Act0RunnerCompositionFamilyV1, int>{
      Act0RunnerCompositionFamilyV1.f1TableNative: 38,
      Act0RunnerCompositionFamilyV1.f2AnswerList: 329,
    });

    expect(
      act0RunnerCompositionFamilyForTaskIdV1('what_poker_is_find_hero'),
      Act0RunnerCompositionFamilyV1.f1TableNative,
    );
    expect(
      act0RunnerCompositionFamilyForTaskIdV1(
        'visible_king_combo_reduction_intro',
      ),
      Act0RunnerCompositionFamilyV1.f2AnswerList,
    );
  });

  test('profile allocations use one canonical source', () {
    for (final expected in const <_AllocationExpectation>[
      _AllocationExpectation(
        Size(375, 812),
        1,
        Act0RunnerCompositionFamilyV1.f1TableNative,
        463,
        210,
      ),
      _AllocationExpectation(
        Size(375, 812),
        1.4,
        Act0RunnerCompositionFamilyV1.f1TableNative,
        409,
        264,
      ),
      _AllocationExpectation(
        Size(375, 812),
        1,
        Act0RunnerCompositionFamilyV1.f2AnswerList,
        373,
        300,
      ),
      _AllocationExpectation(
        Size(375, 812),
        1.4,
        Act0RunnerCompositionFamilyV1.f2AnswerList,
        293,
        380,
      ),
      _AllocationExpectation(
        Size(402, 874),
        1,
        Act0RunnerCompositionFamilyV1.f1TableNative,
        500,
        223,
      ),
      _AllocationExpectation(
        Size(402, 874),
        1.4,
        Act0RunnerCompositionFamilyV1.f1TableNative,
        469,
        254,
      ),
      _AllocationExpectation(
        Size(402, 874),
        1,
        Act0RunnerCompositionFamilyV1.f2AnswerList,
        403,
        320,
      ),
      _AllocationExpectation(
        Size(402, 874),
        1.4,
        Act0RunnerCompositionFamilyV1.f2AnswerList,
        343,
        380,
      ),
      _AllocationExpectation(
        Size(430, 932),
        1,
        Act0RunnerCompositionFamilyV1.f1TableNative,
        540,
        241,
      ),
      _AllocationExpectation(
        Size(430, 932),
        1.4,
        Act0RunnerCompositionFamilyV1.f1TableNative,
        517,
        264,
      ),
      _AllocationExpectation(
        Size(430, 932),
        1,
        Act0RunnerCompositionFamilyV1.f2AnswerList,
        445,
        336,
      ),
      _AllocationExpectation(
        Size(430, 932),
        1.4,
        Act0RunnerCompositionFamilyV1.f2AnswerList,
        401,
        380,
      ),
    ]) {
      final safeArea = expected.size.width == 375
          ? const EdgeInsets.only(top: 47, bottom: 34)
          : const EdgeInsets.only(top: 59, bottom: 34);
      final actual = resolveAct0RunnerCompositionAllocationV1(
        viewport: expected.size,
        safeArea: safeArea,
        textScale: expected.scale,
        family: expected.family,
      );
      expect(actual.tableHeight, expected.table);
      expect(actual.lowerHeight, expected.lower);
    }
  });

  test(
    'W7 L4 keeps retained identities, order, meaning, and three options',
    () {
      const owner = Act0W7VisibleAceHiddenRuntimeSessionOwnerV1();
      final byId = <String, Act0W7VisibleAceHiddenTaskSpecV1>{
        for (final spec in owner.taskSpecs) spec.taskId: spec,
      };

      expect(byId['visible_king_combo_reduction_intro']!.choiceIds, <String>[
        'king_combos_unchanged',
        'king_combos_reduced',
        'king_combos_impossible',
      ]);
      expect(byId['paired_board_texture_lite_intro']!.choiceIds, <String>[
        'pair_does_not_change_combos',
        'seven_combos_reduced_trips_still_possible',
        'opponent_always_has_trips',
      ]);
      expect(
        byId['visible_card_combo_density_transfer_check']!.choiceIds,
        <String>[
          'only_board_low_cards_matter',
          'visible_cards_show_exact_hand',
          'visible_rank_reduces_matching_rank_combos',
        ],
      );
      expect(
        byId['visible_card_combo_density_transfer_check']!
            .choiceLabels['visible_cards_show_exact_hand'],
        'The visible queens prove the opponent’s exact hand.',
      );
      expect(
        byId['visible_card_combo_density_transfer_check']!.expectedChoiceId,
        'visible_rank_reduces_matching_rank_combos',
      );

      for (final task in allTasks.where(
        (task) => task.phase != Act0LessonPhaseV1.theory,
      )) {
        if (task.runner.options.length <= 3) continue;
        expect(
          act0IsAdmittedCompactFourActionTaskV1(task),
          isTrue,
          reason: task.taskId,
        );
      }
    },
  );

  test('side-pot source remains exact and rejects stale prototype wording', () {
    final task = allTasks.singleWhere(
      (task) => task.taskId == 'what_poker_is_side_pot_intro',
    );
    expect(
      task.runner.hint,
      'Main pot: 20 BB each from Hero, CO, and BB, plus the folded small '
      'blind\'s 0.5 BB. The big blind\'s 1 BB is already inside BB\'s 20 BB. '
      'Side pot: 30 BB each from CO and BB.',
    );
    expect(task.runner.hint, isNot(contains('1.5 BB blinds')));
    expect(task.runner.table.potLabel, 'Main 60.5 BB; side 60 BB');
  });

  testWidgets('F2 compact 1.4 keeps evidence and every answer above the fold', (
    tester,
  ) async {
    final task = allTasks.singleWhere(
      (task) => task.taskId == 'visible_king_combo_reduction_intro',
    );
    final decision = task.runner.copyWith(
      phase: Act0LessonPhaseV1.drill,
      teachingSteps: const <Act0TeachingStepV1>[],
    );
    await tester.binding.setSurfaceSize(const Size(375, 812));
    await tester.pumpWidget(
      _host(
        decision,
        const _Profile(Size(375, 812), 1.4, 47, 34),
        task.resolvedCompositionFamily,
      ),
    );
    await tester.pumpAndSettle();

    final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
    final lower = tester.getRect(
      find.byKey(const Key('act0_shell_runner_action_dock')),
    );
    final boardCard = tester.getRect(
      find.byKey(const Key('act0_shell_card_board_0')),
    );
    final optionRects = <Rect>[
      for (final option in decision.options)
        tester.getRect(find.byKey(Key('act0_shell_option_${option.id}'))),
    ];

    expect(table.height, greaterThanOrEqualTo(270));
    expect(lower.height, greaterThanOrEqualTo(220));
    expect(boardCard.height, greaterThanOrEqualTo(34));
    expect(optionRects.every((rect) => rect.height >= 44), isTrue);
    expect(lower.bottom - optionRects.last.bottom, greaterThanOrEqualTo(12));
    expect(optionRects.last.bottom, lessThanOrEqualTo(778));
    expect(_maxAnswerScrollExtent(tester, decision.options.last.id), 0);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('F1 family remains table-dominant through feedback', (
    tester,
  ) async {
    final task = allTasks.singleWhere(
      (task) => task.taskId == 'what_poker_is_find_hero',
    );
    final decision = normalizeAct0SeatTapRunnerV1(
      task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingSteps: const <Act0TeachingStepV1>[],
      ),
    );
    final correct = decision.options.singleWhere((option) => option.isCorrect);
    final feedback = decision.copyWith(
      phase: Act0LessonPhaseV1.review,
      selectedOptionId: correct.id,
    );
    const profile = _Profile(Size(375, 812), 1.4, 47, 34);
    await tester.binding.setSurfaceSize(profile.size);
    await tester.pumpWidget(
      _host(decision, profile, Act0RunnerCompositionFamilyV1.f1TableNative),
    );
    await tester.pumpAndSettle();
    final decisionTable = tester.getRect(
      find.byKey(const Key('act0_shell_table')),
    );
    final hitRects = <Rect>[
      for (final option in decision.options)
        tester.getRect(find.byKey(Key('act0_shell_seat_tap_${option.seatId}'))),
    ];

    await tester.pumpWidget(
      _host(
        feedback,
        profile,
        // A changed caller value cannot reclassify the active task mid-cycle.
        Act0RunnerCompositionFamilyV1.f2AnswerList,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_runner_composition_f1TableNative')),
      findsOneWidget,
    );
    expect(decisionTable.height, greaterThanOrEqualTo(330));
    final feedbackTable = tester.getRect(
      find.byKey(const Key('act0_shell_table')),
    );
    expect(feedbackTable.height, greaterThanOrEqualTo(330));
    expect(
      (feedbackTable.center - decisionTable.center).distance,
      lessThan(32),
    );
    final continueCta = tester.getRect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
    );
    expect(continueCta.height, greaterThanOrEqualTo(48));
    expect(continueCta.bottom, lessThanOrEqualTo(778));
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_feedback_continue_cta')),
        matching: find.text('Next hand'),
      ),
      findsOneWidget,
    );
    expect(hitRects.every((rect) => rect.width >= 44), isTrue);
    expect(hitRects.every((rect) => rect.height >= 44), isTrue);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
    'compact 1.4 feedback keeps the full preferred answer and CTA above fold',
    (tester) async {
      final task = allTasks.singleWhere(
        (task) => task.taskId == 'visible_king_combo_reduction_intro',
      );
      final wrong = task.runner.options.firstWhere(
        (option) => !option.isCorrect,
      );
      final feedback = task.runner.copyWith(
        phase: Act0LessonPhaseV1.review,
        teachingSteps: const <Act0TeachingStepV1>[],
        selectedOptionId: wrong.id,
      );
      const profile = _Profile(Size(375, 812), 1.4, 47, 34);
      await tester.binding.setSurfaceSize(profile.size);
      await tester.pumpWidget(
        _host(feedback, profile, task.resolvedCompositionFamily),
      );
      await tester.pumpAndSettle();

      final action = tester.widget<Text>(
        find.byKey(const Key('act0_integrated_scene_prompt')),
      );
      expect(
        action.data,
        'The visible king leaves fewer king-containing combinations.',
      );
      expect(action.overflow, TextOverflow.ellipsis);
      expect(
        find.byKey(const Key('act0_shell_feedback_hero_action')),
        findsNothing,
      );
      final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
      final ctaLabel = tester.widget<Text>(
        find.byKey(const Key('act0_shell_feedback_continue_cta_label')),
      );
      expect(ctaLabel.overflow, isNull);
      final ctaRect = tester.getRect(cta);
      final labelPaint = _laidOutTextBounds(
        tester,
        const Key('act0_shell_feedback_continue_cta_label'),
      );
      expect(ctaRect.contains(labelPaint.topLeft), isTrue);
      expect(ctaRect.contains(labelPaint.bottomRight), isTrue);
      expect(tester.getRect(cta).bottom, lessThanOrEqualTo(778));
      expect(tester.takeException(), isNull);

      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets(
    'short successful compact feedback keeps its conclusion and next action together',
    (tester) async {
      final task = allTasks.singleWhere(
        (task) => task.taskId == 'visible_king_combo_reduction_intro',
      );
      final correct = task.runner.options.singleWhere(
        (option) => option.isCorrect,
      );
      final feedback = task.runner.copyWith(
        phase: Act0LessonPhaseV1.review,
        teachingSteps: const <Act0TeachingStepV1>[],
        selectedOptionId: correct.id,
      );
      for (final scale in <double>[1, 1.4]) {
        final profile = _Profile(const Size(375, 812), scale, 47, 34);
        await tester.binding.setSurfaceSize(profile.size);
        await tester.pumpWidget(
          _host(feedback, profile, task.resolvedCompositionFamily),
        );
        await tester.pumpAndSettle();

        final verdict = tester.getRect(
          find.byKey(const Key('act0_integrated_scene_prompt')),
        );
        final reason = tester.getRect(
          find.byKey(const Key('act0_learning_scene_v3_support')),
        );
        final nextAction = tester.getRect(
          find.byKey(const Key('act0_shell_feedback_primary_result_block')),
        );
        final cta = tester.getRect(
          find.byKey(const Key('act0_shell_feedback_continue_cta')),
        );
        final lower = tester.getRect(
          find.byKey(const Key('act0_shell_runner_action_dock')),
        );

        expect(
          find.byKey(const Key('act0_wave_a_learning_context')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('act0_shell_feedback_action_eyebrow')),
          findsNothing,
        );
        expect(verdict.top, lessThan(reason.top));
        expect(reason.bottom, lessThanOrEqualTo(lower.top));
        expect(cta.top - nextAction.bottom, inInclusiveRange(7, 32));
        expect(lower.contains(cta.topLeft), isTrue);
        expect(lower.contains(cta.bottomRight), isTrue);
        expect(tester.takeException(), isNull);
      }

      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets('non-shared F2 feedback keeps its original non-scroll surface', (
    tester,
  ) async {
    final task = allTasks.singleWhere(
      (task) => task.taskId == 'visible_king_combo_reduction_intro',
    );
    final wrong = task.runner.options.firstWhere((option) => !option.isCorrect);
    final feedback = task.runner.copyWith(
      phase: Act0LessonPhaseV1.review,
      teachingSteps: const <Act0TeachingStepV1>[],
      selectedOptionId: wrong.id,
    );
    const profile = _Profile(Size(768, 812), 1.4, 47, 34);
    await tester.binding.setSurfaceSize(profile.size);
    await tester.pumpWidget(
      _host(feedback, profile, Act0RunnerCompositionFamilyV1.f2AnswerList),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_feedback_proof_stack_scroll')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_receipt_scroll')),
      findsNothing,
    );
    final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    expect(cta.hitTestable(), findsOneWidget);
    expect(tester.getRect(cta).bottom, lessThanOrEqualTo(778));
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
    'F1 feedback CTA container and label paint stay inside every safe fold',
    (tester) async {
      final task = allTasks.singleWhere(
        (task) => task.taskId == 'what_poker_is_find_hero',
      );
      final decision = normalizeAct0SeatTapRunnerV1(
        task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
      );
      for (final profile in const <_Profile>[
        _Profile(Size(375, 812), 1, 47, 34),
        _Profile(Size(375, 812), 1.4, 47, 34),
        _Profile(Size(402, 874), 1, 59, 34),
        _Profile(Size(402, 874), 1.4, 59, 34),
        _Profile(Size(430, 932), 1, 59, 34),
        _Profile(Size(430, 932), 1.4, 59, 34),
      ]) {
        for (final option in <Act0RunnerOptionV1>[
          decision.options.singleWhere((option) => option.isCorrect),
          decision.options.firstWhere((option) => !option.isCorrect),
        ]) {
          final feedback = decision.copyWith(
            phase: Act0LessonPhaseV1.review,
            selectedOptionId: option.id,
          );
          await tester.binding.setSurfaceSize(profile.size);
          await tester.pumpWidget(
            _host(
              feedback,
              profile,
              Act0RunnerCompositionFamilyV1.f1TableNative,
            ),
          );
          await tester.pumpAndSettle();
          final ctaFinder = find.byKey(
            const Key('act0_shell_feedback_continue_cta'),
          );
          final cta = tester.getRect(ctaFinder);
          final lower = tester.getRect(
            find.byKey(const Key('act0_shell_runner_action_dock')),
          );
          final table = tester.getRect(
            find.byKey(const Key('act0_shell_table')),
          );
          final labelPaint = _laidOutTextBounds(
            tester,
            const Key('act0_shell_feedback_continue_cta_label'),
          );
          final caseLabel =
              '${profile.size.width}x${profile.size.height} '
              '${profile.textScale} ${option.isCorrect ? 'correct' : 'incorrect'}';

          expect(table.height, greaterThanOrEqualTo(330), reason: caseLabel);
          expect(lower.height, greaterThanOrEqualTo(118), reason: caseLabel);
          expect(cta.height, greaterThanOrEqualTo(48), reason: caseLabel);
          expect(lower.contains(cta.topLeft), isTrue, reason: caseLabel);
          expect(lower.contains(cta.bottomRight), isTrue, reason: caseLabel);
          expect(
            cta.bottom,
            lessThanOrEqualTo(profile.size.height - profile.bottomInset),
            reason: caseLabel,
          );
          expect(
            labelPaint.top - cta.top,
            greaterThanOrEqualTo(4),
            reason: caseLabel,
          );
          expect(
            cta.bottom - labelPaint.bottom,
            greaterThanOrEqualTo(4),
            reason: caseLabel,
          );
          expect(cta.contains(labelPaint.topLeft), isTrue, reason: caseLabel);
          expect(
            cta.contains(labelPaint.bottomRight),
            isTrue,
            reason: caseLabel,
          );
          expect(ctaFinder.hitTestable(), findsOneWidget, reason: caseLabel);
          expect(
            find.byKey(const Key('act0_shell_lower_stage_scroll')),
            findsNothing,
            reason: caseLabel,
          );
          expect(tester.takeException(), isNull, reason: caseLabel);
        }
      }
      await tester.binding.setSurfaceSize(null);
    },
  );
}

Rect _laidOutTextBounds(WidgetTester tester, Key key) {
  final paragraph = tester.renderObject<RenderParagraph>(find.byKey(key));
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(
      baseOffset: 0,
      extentOffset: paragraph.text.toPlainText().length,
    ),
  );
  expect(boxes, isNotEmpty, reason: '$key must paint at least one glyph box');
  final origin = paragraph.localToGlobal(Offset.zero);
  return boxes
      .map((box) => box.toRect().shift(origin))
      .reduce((a, b) => a.expandToInclude(b));
}

double _maxAnswerScrollExtent(WidgetTester tester, String finalOptionId) {
  var result = 0.0;
  final scrollables = find.ancestor(
    of: find.byKey(Key('act0_shell_option_$finalOptionId')),
    matching: find.byType(Scrollable),
  );
  for (final element in scrollables.evaluate()) {
    final state = element is StatefulElement ? element.state : null;
    if (state is ScrollableState && state.position.hasContentDimensions) {
      result = state.position.maxScrollExtent > result
          ? state.position.maxScrollExtent
          : result;
    }
  }
  return result;
}

Widget _host(
  Act0RunnerStateV1 runner,
  _Profile profile,
  Act0RunnerCompositionFamilyV1 family,
) {
  return MaterialApp(
    theme: ThemeData(fontFamily: 'Roboto'),
    home: MediaQuery(
      data: MediaQueryData(
        size: profile.size,
        viewPadding: EdgeInsets.only(
          top: profile.topInset,
          bottom: profile.bottomInset,
        ),
        padding: EdgeInsets.only(
          top: profile.topInset,
          bottom: profile.bottomInset,
        ),
        textScaler: TextScaler.linear(profile.textScale),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Act0LessonRunnerShellV1(
            runner: runner,
            selectedTaskId: runner.lessonId,
            compositionFamily: family,
            tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onChooseSeat: family == Act0RunnerCompositionFamilyV1.f1TableNative
                ? (_) {}
                : null,
            onContinueReview: () {},
          ),
        ),
      ),
    ),
  );
}

Future<void> _loadFont(String family, String path) async {
  final bytes = await File(path).readAsBytes();
  final loader = FontLoader(family)
    ..addFont(
      Future<ByteData>.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
  await loader.load();
}

class _Profile {
  const _Profile(this.size, this.textScale, this.topInset, this.bottomInset);

  final Size size;
  final double textScale;
  final double topInset;
  final double bottomInset;
}

class _AllocationExpectation {
  const _AllocationExpectation(
    this.size,
    this.scale,
    this.family,
    this.table,
    this.lower,
  );

  final Size size;
  final double scale;
  final Act0RunnerCompositionFamilyV1 family;
  final double table;
  final double lower;
}
