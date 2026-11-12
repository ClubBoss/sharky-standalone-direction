// HLP-only teaching-route checks. Synthetic price vectors below exercise the
// production binding; they are not authored-catalog, native or Human evidence.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hlp02_reference_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hlp02_source_price_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_prechoice_answer_cue_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Reuse the existing independent numeric fixtures, not their main() or a
// second betting/pot implementation.
import 'act0_betting_price_contract_v1_test.dart'
    show
        pkrBlindStartV1,
        pkrButtonOpenV1,
        pkrFlopV1,
        pkrPriceOptionV1,
        pkrPriceTableV1;

Act0LessonTaskV1 _authoredTask(String lessonId, String taskId) =>
    Act0ShellStateV1.sample
        .lessonById(lessonId)
        .taskList
        .singleWhere((task) => task.taskId == taskId);

Act0LessonTaskV1 _sourceWithRunner(
  Act0LessonTaskV1 source,
  Act0RunnerStateV1 runner,
) => Act0LessonTaskV1(
  taskId: source.taskId,
  title: source.title,
  phase: source.phase,
  runner: runner,
  rewardXp: source.rewardXp,
  stepKind: source.stepKind,
  taskFamily: source.taskFamily,
  tablePresentation: source.tablePresentation,
  summary: source.summary,
  lockedSummary: source.lockedSummary,
);

Act0LessonTaskV1 _syntheticPriceSource(
  Act0TableStateV1 table, {
  String callAmount = '1',
  List<Act0RunnerOptionV1>? options,
}) {
  const id = 'hlp02_synthetic_price';
  final template = _authoredTask('call_price', 'w4_price_intro');
  return Act0LessonTaskV1(
    taskId: id,
    title: 'Synthetic source-price binding fixture',
    phase: Act0LessonPhaseV1.theory,
    runner: template.runner.copyWith(
      lessonId: id,
      table: table,
      options: options ?? [pkrPriceOptionV1('Call', callAmount)],
    ),
    rewardXp: 0,
    stepKind: Act0LessonStepKindV1.learn,
  );
}

Widget _reference({
  required String lessonId,
  required String taskId,
  Act0LessonTaskV1? sourceTask,
  bool scored = false,
}) => MaterialApp(
  locale: const Locale('en'),
  home: Scaffold(
    body: SafeArea(
      child: Act0Hlp02ReferenceButtonV1(
        key: const Key('hlp02_tools_route_reference'),
        lessonId: lessonId,
        taskId: taskId,
        isTheory: true,
        isLearnStep: true,
        isSelectable: true,
        isEnglish: true,
        hasActiveScoredChoice: scored,
        sourceTask: sourceTask,
      ),
    ),
  ),
);

void _useReferencePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _openReference(WidgetTester tester) async {
  final open = find.byKey(const Key('act0_hlp02_open_theory_reference'));
  expect(open.hitTestable(), findsOneWidget);
  // Await the panel's actual asset request in the zone which initiated it.
  await tester.runAsync(() async {
    await tester.tap(open);
    await tester.pump();
    final loader = find.descendant(
      of: find.byKey(const Key('act0_hlp02_inline_reference_region')),
      matching: find.byType(FutureBuilder<Act0Hlp02ReferenceCatalogV1>),
    );
    expect(loader, findsOneWidget);
    final future = tester
        .widget<FutureBuilder<Act0Hlp02ReferenceCatalogV1>>(loader)
        .future;
    expect(future, isNotNull);
    final catalog = await future!;
    expect(catalog.contextByLesson, isNotEmpty);
  });
  await tester.pumpAndSettle();
  expect(
    find.byKey(const Key('act0_hlp02_theory_reference_panel')),
    findsOneWidget,
  );
  expect(find.text('Reference unavailable'), findsNothing);
}

Future<Finder> _reveal(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  if (finder.evaluate().isEmpty) {
    // Large text can leave a lazy ListView child unbuilt. Scroll the actual
    // reference viewport; never enlarge it or substitute a direct widget.
    final verticalPanel = find.descendant(
      of: find.byKey(const Key('act0_hlp02_theory_reference_panel')),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
        description: 'vertical HLP reference scrollable',
      ),
    );
    expect(verticalPanel, findsOneWidget);
    await tester.scrollUntilVisible(
      finder,
      160,
      scrollable: verticalPanel,
      maxScrolls: 24,
    );
    await tester.pumpAndSettle();
  }
  expect(finder, findsOneWidget, reason: 'missing $key');
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  expect(finder.hitTestable(), findsOneWidget, reason: 'unreachable $key');
  return finder;
}

Future<void> _expand(WidgetTester tester, String section) async {
  final tile = await _reveal(tester, 'hlp02_tool_$section');
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  final field = await _reveal(tester, key);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester, String key, String label) async {
  final control = await _reveal(tester, key);
  await tester.tap(control);
  await tester.pumpAndSettle();
  final option = find.text(label).hitTestable();
  expect(option, findsOneWidget, reason: 'unreachable dropdown option $label');
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<String> _readResult(WidgetTester tester, String key) async {
  final result = await _reveal(tester, key);
  return tester.widget<Text>(result).data!;
}

void main() {
  test(
    'source binding rejects whitespace loss even with matching wrong pot',
    () {
      final table = pkrPriceTableV1(
        trail: const [
          ' SB blind 0.5 BB',
          'BB blind 1 BB',
          'UTG folds',
          'HJ folds',
          'CO folds',
        ],
      ).copyWith(potLabel: 'Pot 1 BB');
      final source = _syntheticPriceSource(table);
      // One ledger trims the label and counts the SB; the claim of 1 BB then
      // contradicts the replayed 1.5 BB.
      final read = act0TablePriceV1(table);
      expect(read.readiness, Act0TablePriceReadinessV1.contradiction);
      expect(read.reason, 'pot_mismatch');
      expect(
        hlp02VerifiedSourcePriceV1(sourceTask: source, taskId: source.taskId),
        isNull,
      );
    },
  );

  TestWidgetsFlutterBinding.ensureInitialized();

  test('every reference context resolves to its exact unscored source task', () {
    final lessons = Act0ShellStateV1.sample.worlds
        .expand((world) => world.lessons)
        .toList(growable: false);
    for (final context
        in Act0Hlp02ReferencePolicyV1.theoryTaskByLesson.entries) {
      final owners = lessons
          .where((lesson) => lesson.lessonId == context.key)
          .toList(growable: false);
      expect(owners, hasLength(1), reason: 'lesson ${context.key}');
      final tasks = owners.single.taskList
          .where((task) => task.taskId == context.value)
          .toList(growable: false);
      expect(tasks, hasLength(1), reason: '${context.key}/${context.value}');
      final task = tasks.single;
      expect(task.phase, Act0LessonPhaseV1.theory, reason: task.taskId);
      expect(task.stepKind, Act0LessonStepKindV1.learn, reason: task.taskId);
      expect(
        act0IsPrechoiceAssessmentTaskV1(task),
        isFalse,
        reason: task.taskId,
      );
    }

    // This source-only alias is transformed by _retitledTasksV1. Accepting it
    // would make a JSON/policy self-consistency test pass while the app has no
    // matching task and therefore never exposes the outs reference.
    final outs = lessons.singleWhere(
      (lesson) => lesson.lessonId == 'outs_improvement',
    );
    expect(
      outs.taskList.where((task) => task.taskId == 'w5_outs_intro'),
      isEmpty,
    );
    expect(
      Act0Hlp02ReferencePolicyV1.canOpen(
        lessonId: 'outs_improvement',
        taskId: 'w5_outs_intro',
        isTheory: true,
        isLearnStep: true,
        isSelectable: true,
        isEnglish: true,
        hasActiveScoredChoice: false,
      ),
      isFalse,
    );
  });

  testWidgets(
    'reference converts BB and chips and clears invalid or old values',
    (tester) async {
      _useReferencePhone(tester);
      await tester.pumpWidget(
        _reference(lessonId: 'blinds_action_order', taskId: 'blinds_theory'),
      );
      await _openReference(tester);
      await _expand(tester, 'units');
      await _enter(tester, 'hlp02_units_blind', '200');
      await _enter(tester, 'hlp02_units_amount', '2.5');
      expect(await _readResult(tester, 'hlp02_units_result'), '500 chips');

      await _choose(tester, 'hlp02_units_direction', 'Chips to BB');
      expect(
        await _readResult(tester, 'hlp02_units_result'),
        contains('Enter a valid amount'),
      );
      await _enter(tester, 'hlp02_units_amount', '500');
      expect(await _readResult(tester, 'hlp02_units_result'), '2.5 BB');
      await _enter(tester, 'hlp02_units_amount', '0');
      expect(await _readResult(tester, 'hlp02_units_result'), '0 BB');

      await _enter(tester, 'hlp02_units_blind', '0');
      expect(
        await _readResult(tester, 'hlp02_units_result'),
        contains('big blind greater than zero'),
      );
      await _enter(tester, 'hlp02_units_blind', '200');
      for (final invalid in ['-1', 'NaN', '1e3', '500 BB']) {
        await _enter(tester, 'hlp02_units_amount', invalid);
        expect(
          await _readResult(tester, 'hlp02_units_result'),
          contains('Enter a valid amount'),
          reason: invalid,
        );
      }

      // The earlier 2.5 BB -> 500 chips -> 2.5 BB is an exact round trip.
      // A recurring decimal is rounded only for display, to six places.
      await _enter(tester, 'hlp02_units_blind', '3');
      await _enter(tester, 'hlp02_units_amount', '1');
      expect(await _readResult(tester, 'hlp02_units_result'), '0.333333 BB');
      await _enter(tester, 'hlp02_units_blind', '1');
      await _enter(tester, 'hlp02_units_amount', '0.123456');
      expect(await _readResult(tester, 'hlp02_units_result'), '0.123456 BB');
      await _enter(tester, 'hlp02_units_amount', '0.1234567');
      expect(
        await _readResult(tester, 'hlp02_units_result'),
        contains('Enter a valid amount'),
      );

      // Supported individual inputs must not permit an out-of-range output.
      await _enter(tester, 'hlp02_units_blind', '0.000001');
      await _enter(tester, 'hlp02_units_amount', '1000');
      expect(await _readResult(tester, 'hlp02_units_result'), '1000000000 BB');
      await _enter(tester, 'hlp02_units_amount', '1000.000001');
      expect(
        await _readResult(tester, 'hlp02_units_result'),
        contains('Enter a valid amount'),
      );
      await _choose(tester, 'hlp02_units_direction', 'BB to chips');
      await _enter(tester, 'hlp02_units_blind', '1000000000');
      await _enter(tester, 'hlp02_units_amount', '1');
      expect(
        await _readResult(tester, 'hlp02_units_result'),
        '1000000000 chips',
      );
      await _enter(tester, 'hlp02_units_amount', '1.000001');
      expect(
        await _readResult(tester, 'hlp02_units_result'),
        contains('Enter a valid amount'),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Price Bar uses own inputs and never certifies sparse lesson labels',
    (tester) async {
      _useReferencePhone(tester);
      final source = _authoredTask('call_price', 'w4_price_intro');
      await tester.pumpWidget(
        _reference(
          lessonId: 'call_price',
          taskId: source.taskId,
          sourceTask: source,
        ),
      );
      await _openReference(tester);
      await _expand(tester, 'price');
      expect(
        await _readResult(tester, 'hlp02_source_price'),
        startsWith('Lesson price unavailable:'),
      );
      expect(find.byKey(const Key('hlp02_source_result')), findsNothing);

      await _choose(tester, 'hlp02_price_unit', 'Chips');
      await _enter(tester, 'hlp02_price_pot', '150');
      await _enter(tester, 'hlp02_price_call', '50');
      expect(
        await _readResult(tester, 'hlp02_price_result'),
        'Before: 150 chips\nCall: 50 chips\nAfter: 200 chips\n'
        'Break-even threshold: 25.00%',
      );
      final bar = await _reveal(tester, 'hlp02_price_bar_example');
      expect(tester.widget<LinearProgressIndicator>(bar).value, 0.25);

      await _enter(tester, 'hlp02_price_pot', '150 invalid');
      expect(
        await _readResult(tester, 'hlp02_price_result'),
        'Enter valid pot and call amounts.',
      );
      expect(find.byKey(const Key('hlp02_price_bar_example')), findsNothing);
      await _enter(tester, 'hlp02_price_pot', '150');
      await _enter(tester, 'hlp02_price_call', '0');
      expect(
        await _readResult(tester, 'hlp02_price_result'),
        'No additional call cost. No call threshold.',
      );
      expect(find.byKey(const Key('hlp02_price_bar_example')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('outs calculator separates improvement, dirty outs and streets', (
    tester,
  ) async {
    _useReferencePhone(tester);
    await tester.pumpWidget(
      _reference(
        lessonId: 'outs_improvement',
        taskId: 'outs_improvement_w5_outs_intro',
      ),
    );
    await _openReference(tester);
    await _expand(tester, 'outs');
    await _choose(tester, 'hlp02_outs_draws', 'Turn and river');
    await _enter(tester, 'hlp02_outs_count', '9');
    expect(
      await _readResult(tester, 'hlp02_outs_result'),
      contains(
        '9 clean outs among 47 unseen cards\n'
        'Improvement chance: 34.97%',
      ),
    );
    await _enter(tester, 'hlp02_outs_dirty', '2');
    expect(
      await _readResult(tester, 'hlp02_outs_result'),
      contains(
        '7 clean outs among 47 unseen cards\n'
        'Improvement chance: 27.84%',
      ),
    );

    await _enter(tester, 'hlp02_outs_dirty', '10');
    expect(
      await _readResult(tester, 'hlp02_outs_result'),
      startsWith('Enter whole-card counts.'),
    );
    await _enter(tester, 'hlp02_outs_dirty', '2');
    await _choose(tester, 'hlp02_outs_street', 'Turn');
    expect(find.byKey(const Key('hlp02_outs_draws')), findsNothing);
    expect(
      await _readResult(tester, 'hlp02_outs_result'),
      contains(
        '7 clean outs among 46 unseen cards\n'
        'Improvement chance: 15.22%',
      ),
    );
    await _choose(tester, 'hlp02_outs_street', 'River');
    expect(
      await _readResult(tester, 'hlp02_outs_result'),
      'No cards remain after the river. Improvement chance is unavailable.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'range view counts physical combos and removes impossible inputs',
    (tester) async {
      _useReferencePhone(tester);
      await tester.pumpWidget(
        _reference(
          lessonId: 'range_combo_counts',
          taskId: 'w6_combo_counts_intro',
        ),
      );
      await _openReference(tester);
      await _expand(tester, 'range');
      await _enter(tester, 'hlp02_range_classes', 'AA, AKs, AKo, AA');
      expect(
        await _readResult(tester, 'hlp02_range_result'),
        contains(
          '3 selected classes / 22 available selected combos\n'
          '1326 total combos remain after blockers',
        ),
      );
      expect(
        await _readResult(tester, 'hlp02_range_text_alternative'),
        'AA: 6 combos; AKs: 4 combos; AKo: 12 combos',
      );
      final grid = find.byKey(const Key('hlp02_range_grid'));
      expect(grid, findsOneWidget);
      expect(
        find.descendant(of: grid, matching: find.byType(Text)),
        findsNWidgets(169),
      );

      await _enter(tester, 'hlp02_range_blockers', 'As');
      expect(
        await _readResult(tester, 'hlp02_range_result'),
        contains(
          '3 selected classes / 15 available selected combos\n'
          '1275 total combos remain after blockers',
        ),
      );
      expect(
        await _readResult(tester, 'hlp02_range_text_alternative'),
        'AA: 3 combos; AKs: 3 combos; AKo: 9 combos',
      );

      await _enter(tester, 'hlp02_range_blockers', 'As, Zz');
      expect(
        await _readResult(tester, 'hlp02_range_result'),
        startsWith('Range unavailable.'),
      );
      expect(grid, findsNothing);
      expect(
        find.byKey(const Key('hlp02_range_text_alternative')),
        findsNothing,
      );
      await _enter(tester, 'hlp02_range_blockers', 'As');
      await _enter(tester, 'hlp02_range_classes', 'AA, AK');
      expect(
        await _readResult(tester, 'hlp02_range_result'),
        startsWith('Range unavailable.'),
      );
      expect(grid, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'larger text keeps range controls and equivalent semantic counts reachable',
    (tester) async {
      _useReferencePhone(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final semanticsHandle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _reference(
            lessonId: 'range_combo_counts',
            taskId: 'w6_combo_counts_intro',
          ),
        );
        final open = find.byKey(const Key('act0_hlp02_open_theory_reference'));
        expect(MediaQuery.textScalerOf(tester.element(open)).scale(16), 24);
        await _openReference(tester);
        await _expand(tester, 'range');

        await _enter(tester, 'hlp02_range_classes', 'AA, AKs, AKo');
        final classes = await _reveal(tester, 'hlp02_range_classes');
        expect(find.bySemanticsLabel(RegExp('Selected classes')), findsWidgets);
        final classEditor = find.descendant(
          of: classes,
          matching: find.byType(EditableText),
        );
        expect(classEditor, findsOneWidget);
        expect(
          tester.getSemantics(classEditor).getSemanticsData().value,
          'AA, AKs, AKo',
        );

        await _enter(tester, 'hlp02_range_blockers', 'As');
        final blockers = await _reveal(tester, 'hlp02_range_blockers');
        expect(
          find.bySemanticsLabel(RegExp(r'Known cards \(blockers\)')),
          findsWidgets,
        );
        final blockerEditor = find.descendant(
          of: blockers,
          matching: find.byType(EditableText),
        );
        expect(blockerEditor, findsOneWidget);
        expect(
          tester.getSemantics(blockerEditor).getSemanticsData().value,
          'As',
        );

        final result = await _reveal(tester, 'hlp02_range_result');
        final resultLabel = tester
            .getSemantics(result)
            .getSemanticsData()
            .label;
        expect(
          resultLabel,
          contains('3 selected classes / 15 available selected combos'),
        );
        expect(
          resultLabel,
          contains('1275 total combos remain after blockers'),
        );
        expect(resultLabel, contains('Selected share: 1.18%'));
        final alternative = await _reveal(
          tester,
          'hlp02_range_text_alternative',
        );
        expect(
          tester.getSemantics(alternative).getSemanticsData().label,
          contains('AA: 3 combos; AKs: 3 combos; AKo: 9 combos'),
        );
        expect(tester.takeException(), isNull);
      } finally {
        // Release before widget-test end verification, never late teardown.
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets(
    'same task source revision closes tools and discards example input',
    (tester) async {
      _useReferencePhone(tester);
      final source = _authoredTask('call_price', 'w4_price_intro');
      await tester.pumpWidget(
        _reference(
          lessonId: 'call_price',
          taskId: source.taskId,
          sourceTask: source,
        ),
      );
      await _openReference(tester);
      await _expand(tester, 'price');
      await _enter(tester, 'hlp02_price_pot', '150');
      await _enter(tester, 'hlp02_price_call', '50');
      expect(
        await _readResult(tester, 'hlp02_price_result'),
        contains('25.00%'),
      );
      final changed = _sourceWithRunner(
        source,
        source.runner.copyWith(caption: 'Revised source teaching copy'),
      );
      await tester.pumpWidget(
        _reference(
          lessonId: 'call_price',
          taskId: changed.taskId,
          sourceTask: changed,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_hlp02_inline_reference_region')),
        findsNothing,
      );
      expect(find.byKey(const Key('hlp02_price_result')), findsNothing);
      await _openReference(tester);
      await _expand(tester, 'price');
      expect(
        await _readResult(tester, 'hlp02_price_result'),
        'Enter valid pot and call amounts.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('assessment transition removes the open tools and their entry', (
    tester,
  ) async {
    _useReferencePhone(tester);
    await tester.pumpWidget(
      _reference(lessonId: 'call_price', taskId: 'w4_price_intro'),
    );
    await _openReference(tester);
    await _expand(tester, 'price');
    await tester.pumpWidget(
      _reference(
        lessonId: 'call_price',
        taskId: 'w4_price_intro',
        scored: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_hlp02_open_theory_reference')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_hlp02_inline_reference_region')),
      findsNothing,
    );
    expect(find.byKey(const Key('hlp02_tool_price')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  // --- Table-only source binding (act0TablePriceV1). Synthetic vectors use the
  // PKR v7 fixtures, whose default pot label is '' (no displayed claim). ---

  test('SYNTHETIC source price consumes the canonical table-only read', () {
    for (final pot in ['Pot 1.5 BB', '']) {
      final source = _syntheticPriceSource(
        pkrPriceTableV1().copyWith(potLabel: pot),
      );
      final read = hlp02SourcePriceReadV1(
        sourceTask: source,
        taskId: source.taskId,
      );
      expect(read.status, Hlp02SourcePriceStatusV1.verified, reason: pot);
      final price = read.price!;
      // Independent: blinds 0.5 + 1; BTN adds 1; 1 / (1.5 + 1) = 0.4.
      expect(price.potBeforeCallChips, 1.5);
      expect(price.additionalCallChips, 1);
      expect(price.potAfterCallChips, 2.5);
      expect(price.requiredWinRatePercent, closeTo(40, 1e-9));
      expect(
        hlp02VerifiedSourcePriceV1(sourceTask: source, taskId: source.taskId),
        isNotNull,
      );
    }
  });

  test('source price rejects wrong pot, price display and malformed units', () {
    for (final table in [
      pkrPriceTableV1().copyWith(potLabel: 'Pot 8.5 BB'), // Replayed: 1.5.
      pkrPriceTableV1(due: '2').copyWith(potLabel: 'Pot 1.5 BB'),
      pkrPriceTableV1().copyWith(potLabel: 'Pot 1.5 BB extra'),
      pkrPriceTableV1().copyWith(potLabel: 'Pot 150 chips'),
    ]) {
      final source = _syntheticPriceSource(table);
      final read = hlp02SourcePriceReadV1(
        sourceTask: source,
        taskId: source.taskId,
      );
      final why = '${table.potLabel}; ${table.toCallLabel}';
      expect(read.price, isNull, reason: why);
      expect(read.potBeforeCallBb, isNull);
      expect(
        read.status,
        isNot(Hlp02SourcePriceStatusV1.verified),
        reason: read.reason,
      );
    }
  });

  test('SYNTHETIC missing claim not required; unproved stack not promoted', () {
    // No To-call label: the ledger, not the label, is the price authority.
    final noClaim = _syntheticPriceSource(
      pkrPriceTableV1(due: '').copyWith(potLabel: 'Pot 1.5 BB'),
    );
    expect(
      hlp02SourcePriceReadV1(
        sourceTask: noClaim,
        taskId: noClaim.taskId,
      ).price!.additionalCallChips,
      1,
    );
    // Unknown Hero stack: the option API still carries an uncapped number,
    // but no verified price may come from it.
    final table = pkrPriceTableV1(
      heroStack: null,
    ).copyWith(potLabel: 'Pot 1.5 BB');
    final source = _syntheticPriceSource(table);
    final canonical = act0BettingPriceForOptionV1(
      table,
      source.runner.options.single,
    );
    expect(canonical.truth, Act0BettingPriceTruthV1.unproved);
    expect(canonical.amountToMatchBb, 1);
    final read = hlp02SourcePriceReadV1(
      sourceTask: source,
      taskId: source.taskId,
    );
    expect(read.status, Hlp02SourcePriceStatusV1.unavailable);
    expect(read.reason, 'missing_actor_stack');
    expect(read.price, isNull);
  });

  test('one ledger: a posts history cannot certify an undercounted pot', () {
    // The former grammar-intersection guard existed because two parsers
    // disagreed. One ledger now counts the post; a wrong claim contradicts.
    final table = pkrPriceTableV1(
      trail: ['SB blind 0.5 BB', 'BB posts 1 BB', ...pkrButtonOpenV1.skip(2)],
    ).copyWith(potLabel: 'Pot 0.5 BB');
    expect(act0TablePriceV1(table).reason, 'pot_mismatch');
    final source = _syntheticPriceSource(table);
    final read = hlp02SourcePriceReadV1(
      sourceTask: source,
      taskId: source.taskId,
    );
    expect(read.status, Hlp02SourcePriceStatusV1.contradiction);
    expect(read.price, isNull);
  });

  test('SYNTHETIC Preflop prefix: wrong claim fails, right one reads', () {
    final trail = ['Preflop: SB blind 0.5 BB', ...pkrButtonOpenV1.skip(1)];
    final wrong = pkrPriceTableV1(trail: trail).copyWith(potLabel: 'Pot 1 BB');
    final wrongSource = _syntheticPriceSource(wrong);
    expect(act0TablePriceV1(wrong).reason, 'pot_mismatch');
    expect(
      hlp02VerifiedSourcePriceV1(
        sourceTask: wrongSource,
        taskId: wrongSource.taskId,
      ),
      isNull,
    );
    // Composition-dependent: the PKR v7 order proof (in the declared overlap)
    // reads the Preflop prefix; #449's order proof would leave it unproved.
    final right = pkrPriceTableV1(
      trail: trail,
    ).copyWith(potLabel: 'Pot 1.5 BB');
    final rightSource = _syntheticPriceSource(right);
    final price = hlp02VerifiedSourcePriceV1(
      sourceTask: rightSource,
      taskId: rightSource.taskId,
    )!;
    expect(price.potBeforeCallChips, 1.5);
    expect(price.additionalCallChips, 1);
  });

  test('SYNTHETIC stack-capped call or all-in history withholds threshold', () {
    final capped = pkrPriceTableV1(
      heroStack: '0.5 BB',
    ).copyWith(potLabel: 'Pot 1.5 BB');
    final cappedSource = _syntheticPriceSource(capped, callAmount: '0.5');
    final canonical = act0BettingPriceForOptionV1(
      capped,
      cappedSource.runner.options.single,
    );
    expect(canonical.truth, Act0BettingPriceTruthV1.consistent);
    expect(canonical.callCostBb, 0.5);
    expect(canonical.amountToMatchBb, 1);
    final cappedRead = hlp02SourcePriceReadV1(
      sourceTask: cappedSource,
      taskId: cappedSource.taskId,
    );
    expect(cappedRead.status, Hlp02SourcePriceStatusV1.sidePotUnmodelled);
    expect(cappedRead.reason, 'stack_capped_call');
    expect(cappedRead.price, isNull);
    // Existing PKR vector: HJ is all-in for 4; the table read is ready, but
    // side-pot eligibility is not modelled, so no threshold is offered.
    final allIn = pkrPriceTableV1(
      trail: [
        ...pkrBlindStartV1,
        'UTG raises 3 BB',
        'HJ shoves to 4 BB',
        'CO folds',
        'BTN folds',
        'SB folds',
        'BB folds',
      ],
      hero: 'UTG',
      due: '1',
      stacks: {'HJ': '0 BB'},
    );
    expect(act0TablePriceV1(allIn).isReady, isTrue);
    final allInSource = _syntheticPriceSource(allIn);
    final allInRead = hlp02SourcePriceReadV1(
      sourceTask: allInSource,
      taskId: allInSource.taskId,
    );
    expect(allInRead.status, Hlp02SourcePriceStatusV1.sidePotUnmodelled);
    expect(allInRead.reason, 'all_in_history');
    expect(allInRead.price, isNull);
  });

  test('SYNTHETIC zero price is a proven no-call state, not a threshold', () {
    final table = pkrPriceTableV1(
      trail: [...pkrFlopV1, 'Flop: BB checks'],
      street: 'Flop',
      due: '',
    ).copyWith(potLabel: 'Pot 6.5 BB');
    final source = _syntheticPriceSource(table);
    final read = hlp02SourcePriceReadV1(
      sourceTask: source,
      taskId: source.taskId,
    );
    expect(read.status, Hlp02SourcePriceStatusV1.noCallPrice);
    expect(read.potBeforeCallBb, 6.5);
    expect(read.price, isNull);
  });

  test(
    'authored price intro remains unavailable and no option is invented',
    () {
      final source = _authoredTask('call_price', 'w4_price_intro');
      expect(source.runner.options, isEmpty);
      expect(source.runner.table.potLabel, 'Pot 8 BB');
      expect(source.runner.table.toCallLabel, 'To call 2 BB');
      final read = hlp02SourcePriceReadV1(
        sourceTask: source,
        taskId: source.taskId,
      );
      expect(
        read.status,
        Hlp02SourcePriceStatusV1.unavailable,
        reason: read.reason,
      );
      expect(read.price, isNull);
      expect(read.potBeforeCallBb, isNull);
      expect(source.runner.options, isEmpty);
      expect(
        hlp02VerifiedSourcePriceV1(sourceTask: null, taskId: source.taskId),
        isNull,
      );
    },
  );

  test('SYNTHETIC options do not affect table price; identity does', () {
    final table = pkrPriceTableV1().copyWith(potLabel: 'Pot 1.5 BB');
    final source = _syntheticPriceSource(table);
    expect(
      hlp02VerifiedSourcePriceV1(sourceTask: source, taskId: 'another_task'),
      isNull,
    );
    for (final options in <List<Act0RunnerOptionV1>>[
      [],
      [pkrPriceOptionV1('Call', '1'), pkrPriceOptionV1('Call', '1')],
      [pkrPriceOptionV1('Fold', '')],
    ]) {
      final variant = _syntheticPriceSource(table, options: options);
      expect(
        hlp02VerifiedSourcePriceV1(
          sourceTask: variant,
          taskId: variant.taskId,
        )?.requiredWinRatePercent,
        closeTo(40, 1e-9),
        reason: '${options.length} options',
      );
    }
  });

  test('SYNTHETIC projection of W4 proposal w4_new_table_v1 (freeze v3)', () {
    // Projection of the proposal's 13 events (record sha256 f7ad9eb5...) into
    // the existing trail grammar. Not admitted source; a numeric cross-check
    // of the proposal's literal oracle: pot 7, call 2, threshold 2/9.
    final table = pkrPriceTableV1(
      trail: const [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'UTG folds',
        'HJ folds',
        'CO folds',
        'BTN raises 2 BB',
        'SB calls 2 BB',
        'BB folds',
        'Flop: SB checks',
        'Flop: BTN checks',
        'Turn: SB bets 2 BB',
      ],
      street: 'Turn',
      due: '2',
      heroStack: '98 BB',
      stacks: {'SB': '96 BB', 'BB': '99 BB'},
    ).copyWith(potLabel: 'Pot 7 BB');
    final facts = act0TablePriceV1(table).facts!;
    expect(facts.potBeforeActionBb, 7);
    expect(facts.priorStreetsPotBb, 5);
    expect(facts.foldedPlayersContributionBb, 1); // BB's dead blind.
    expect(facts.callCostBb, 2);
    final source = _syntheticPriceSource(table, options: const []);
    final price = hlp02VerifiedSourcePriceV1(
      sourceTask: source,
      taskId: source.taskId,
    )!;
    expect(price.potAfterCallChips, 9);
    expect(price.requiredWinRateFraction, closeTo(2 / 9, 1e-12));
  });

  testWidgets('SYNTHETIC verified lesson price: open, close, reopen and gate', (
    tester,
  ) async {
    _useReferencePhone(tester);
    final authored = _authoredTask('call_price', 'w4_price_intro');
    // Same theory identity, synthetic complete table: simulates a future
    // admitted theory hand. Options stay empty; no Call is invented.
    final source = _sourceWithRunner(
      authored,
      authored.runner.copyWith(
        table: pkrPriceTableV1(
          trail: [...pkrFlopV1, 'Flop: BB bets 2 BB'],
          street: 'Flop',
          due: '2',
        ).copyWith(potLabel: 'Pot 8.5 BB'),
      ),
    );
    expect(source.runner.options, isEmpty);
    Widget build({bool scored = false}) => _reference(
      lessonId: 'call_price',
      taskId: source.taskId,
      sourceTask: source,
      scored: scored,
    );
    // Independent arithmetic: 6.5 preflop + 2 = 8.5; 2 / 10.5 = 19.0476%.
    const sourceText =
        'Current lesson: 8.5 BB before, 2 BB to call, 10.5 BB after.';
    const resultText =
        'Before: 8.5 BB\nCall: 2 BB\nAfter: 10.5 BB\n'
        'Break-even threshold: 19.05%';
    Future<void> expectSource() async {
      expect(await _readResult(tester, 'hlp02_source_price'), sourceText);
      expect(await _readResult(tester, 'hlp02_source_result'), resultText);
      final bar = await _reveal(tester, 'hlp02_price_bar_source');
      expect(
        tester.widget<LinearProgressIndicator>(bar).value,
        closeTo(2 / 10.5, 1e-12),
      );
      expect(
        await _readResult(tester, 'hlp02_source_provenance'),
        contains('in BB'),
      );
    }

    await tester.pumpWidget(build());
    await _openReference(tester);
    await _expand(tester, 'price');
    await expectSource();
    await _enter(tester, 'hlp02_price_pot', '150');
    await _enter(tester, 'hlp02_price_call', '50');
    expect(await _readResult(tester, 'hlp02_price_result'), contains('25.00%'));

    // Close, then reopen: same proven values, example input discarded.
    final toggle = find.byKey(const Key('act0_hlp02_open_theory_reference'));
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_hlp02_inline_reference_region')),
      findsNothing,
    );
    await _openReference(tester);
    await _expand(tester, 'price');
    await expectSource();
    expect(
      await _readResult(tester, 'hlp02_price_result'),
      'Enter valid pot and call amounts.',
    );

    // An assessed choice hides the tool and its entry; returning restores
    // the same source price, never a remembered example.
    await tester.pumpWidget(build(scored: true));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hlp02_tool_price')), findsNothing);
    expect(
      find.byKey(const Key('act0_hlp02_open_theory_reference')),
      findsNothing,
    );
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    await _openReference(tester);
    await _expand(tester, 'price');
    await expectSource();
    expect(source.runner.options, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'SYNTHETIC no-call, side-pot and contradiction lesson texts are honest',
    (tester) async {
      _useReferencePhone(tester);
      final authored = _authoredTask('call_price', 'w4_price_intro');
      // (table, exact source text, provenance line shown)
      final cases = <(Act0TableStateV1, String, bool)>[
        (
          pkrPriceTableV1(
            trail: [...pkrFlopV1, 'Flop: BB checks'],
            street: 'Flop',
            due: '',
          ).copyWith(potLabel: 'Pot 6.5 BB'),
          'Current lesson: 6.5 BB in the pot and nothing to call. '
              'No call threshold.',
          true,
        ),
        (
          pkrPriceTableV1(heroStack: '0.5 BB').copyWith(potLabel: 'Pot 1.5 BB'),
          'Lesson price unavailable: an all-in or a call limited by your '
              'stack may create a side pot or return part of a bet, which '
              'this reference does not model.',
          false,
        ),
        (
          pkrPriceTableV1().copyWith(potLabel: 'Pot 2 BB'),
          'Lesson price unavailable: this lesson\'s table labels disagree '
              'with its recorded actions.',
          false,
        ),
        (
          pkrPriceTableV1(heroStack: null).copyWith(potLabel: 'Pot 1.5 BB'),
          'Lesson price unavailable: this lesson does not provide a '
              'verified call and contestable pot. Displayed table labels '
              'are not enough.',
          false,
        ),
      ];
      for (final (table, text, provenance) in cases) {
        final source = _sourceWithRunner(
          authored,
          authored.runner.copyWith(table: table),
        );
        await tester.pumpWidget(
          _reference(
            lessonId: 'call_price',
            taskId: source.taskId,
            sourceTask: source,
          ),
        );
        await tester.pumpAndSettle();
        await _openReference(tester);
        await _expand(tester, 'price');
        expect(await _readResult(tester, 'hlp02_source_price'), text);
        expect(find.byKey(const Key('hlp02_source_result')), findsNothing);
        expect(find.byKey(const Key('hlp02_price_bar_source')), findsNothing);
        expect(
          find.byKey(const Key('hlp02_source_provenance')),
          provenance ? findsOneWidget : findsNothing,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );
}
