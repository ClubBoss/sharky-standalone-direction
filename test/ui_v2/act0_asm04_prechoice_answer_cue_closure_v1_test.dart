import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_predecision_card_focus_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_prechoice_answer_cue_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// ASM-04 catalog-wide pre-choice closure (2026-11-08).
//
// The detector below is test-only and may read grades; production policy
// never does. It renders the real Learn (Academy) and Runner consumers for
// every assessed task, before any choice, with assistance off, and asks
// whether any visible string (other than the choice buttons themselves)
// names the correct choice without naming a wrong one, or states that the
// correct choice beats/wins. Every remaining hit is an exact, reasoned
// allowance: a table fact the question needs, or the question restating its
// own target. Allowances may shrink, never grow.

final _catalog = [
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons)
      for (final task in lesson.taskList)
        (world: world, lesson: lesson, task: task),
];

final _assessed = [
  for (final row in _catalog)
    if (act0IsPrechoiceAssessmentTaskV1(row.task)) row,
];

const _seatWords = <String>{
  'hero',
  'villain',
  'co',
  'btn',
  'utg',
  'hj',
  'sb',
  'bb',
  'you',
  'your',
  'cutoff',
  'button',
  'seat',
};
const _stopWords = <String>{
  'a',
  'an',
  'the',
  'to',
  'of',
  'and',
  'or',
  'is',
  'it',
  'in',
  'on',
  'at',
  'for',
  'with',
  'this',
  'that',
  'be',
  'by',
  'as',
  'are',
};

String _norm(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

String _core(String label) => _norm(label)
    .split(' ')
    .where((w) => w.isNotEmpty && !_seatWords.contains(w))
    .where((w) => !_stopWords.contains(w))
    .join(' ');

bool _hasPhrase(String text, String phrase) =>
    phrase.isNotEmpty &&
    RegExp('(^| )${RegExp.escape(phrase)}( |\$)').hasMatch(_norm(text));

/// Visible strings that disclose the correct choice before the decision.
List<String> _answerCues(Iterable<String> visible, Act0RunnerStateV1 runner) {
  final labels = {for (final o in runner.options) o.label};
  final correct = [
    for (final o in runner.options)
      if (o.isCorrect) _core(o.label),
  ];
  final wrong = [
    for (final o in runner.options)
      if (!o.isCorrect) _core(o.label),
  ];
  final hits = <String>[];
  for (final text in visible) {
    if (text.trim().isEmpty || labels.contains(text)) continue;
    final namesCorrect = correct.any((c) => _hasPhrase(text, c));
    final namesWrong = wrong.any((w) => _hasPhrase(text, w));
    final verdict = correct.any(
      (c) =>
          c.isNotEmpty &&
          RegExp(
            '(^| )${RegExp.escape(c)}s? (beats?|wins?|ranks? higher|is stronger)',
          ).hasMatch(_norm(text)),
    );
    if ((namesCorrect && !namesWrong) || verdict) hits.add(text);
  }
  return hits;
}

const _priceChip = 'Price chip: the same to-call fact shows for call and fold';

/// Exact remaining detector hits that are table facts the question needs.
const _allowedRunnerHits = <String, List<String>>{
  'your_first_hand_private_cards_recheck': ['K'],
  'actions_call_drill': ['To call 1 BB'],
  'weak_ace_warning_w3_strong_continue': ['To call 2.5 BB'],
  'continue_or_let_go_medium_call_or_fold': ['To call 2.5 BB'],
  'continue_or_let_go_continue_recap': ['To call 2.5 BB'],
  'discipline_checkpoint_checkpoint_borderline_continue': ['To call 2.5 BB'],
  'same_hand_different_seat_w3_same_hand_call': ['To call 2.5 BB'],
  'position_checkpoint_position_checkpoint_btn_call': ['To call 2.5 BB'],
  'w4_good_price_call': ['To call 1 BB'],
  'w4_cheap_price_marginal_call': ['To call 1 BB'],
  'w4_checkpoint_table_price': ['To call 2 BB'],
  'w6_kicker_showdown_compare': ['K'],
  'your_first_hand_recap': ['RIVER'],
};
const _allowedRunnerReasons = <String, String>{
  'your_first_hand_private_cards_recheck':
      'Hero card face the question asks to read',
  'w6_kicker_showdown_compare': 'Rank shared by both shown hands',
  'your_first_hand_recap': 'Table-read step: the shown river is the asked fact',
};

const _allowedLearnHits = <String, List<String>>{
  'w4_good_price_call': [
    'Call price',
    'Start here: Price decision 1. Pot is 8 BB. To call is 1 BB with one pair.',
  ],
  'w4_cheap_price_marginal_call': [
    'Call price',
    'Start here: Price decision 3. Pot is 10 BB. To call is 1 BB with middle pair.',
  ],
  'w4_small_bet': ['Current step · 2 of 5'],
  'w4_half_pot_bet': ['Current step · 3 of 5'],
  'w4_checkpoint_table_price': [
    'Start here: Real-table price read. Real table. Pot is 7 BB. To call is 2 BB. Hero has second pair.',
  ],
  'w7_effective_stack_100bb': ['100 vs 100'],
};
const _allowedLearnReasons = <String, String>{
  'w4_good_price_call':
      'Lesson topic also grades fold answers; pot/price facts',
  'w4_cheap_price_marginal_call':
      'Lesson topic also grades fold answers; pot/price facts',
  'w4_small_bet': 'Step counter digit, not copy',
  'w4_half_pot_bet': 'Step counter digit, not copy',
  'w4_checkpoint_table_price': 'Pot/price facts the question needs',
  'w7_effective_stack_100bb': 'Both stack sizes are the question input',
};

/// Known limitation (honestly not a discrimination proof): the World 4
/// recap answer restates the world's own theme name, which stays as the
/// curriculum identity. Display cannot neutralize it without renaming World 4.
const _openRunnerResiduals = <String, List<String>>{};
const _openLearnResiduals = <String, List<String>>{
  'w4_checkpoint_review': ['Bet Purpose / Price'],
};

Widget _runnerFixture(
  ({dynamic world, dynamic lesson, Act0LessonTaskV1 task}) r,
) {
  final task = r.task;
  return MaterialApp(
    home: Scaffold(
      body: Act0LessonRunnerShellV1(
        runner: task.runner.copyWith(
          phase: task.entryPhase,
          teachingStepIndex: task.runner.teachingSteps.length,
        ),
        worldNumber: (r.world as Act0WorldCardV1).worldNumber,
        selectedWorldId: (r.world as Act0WorldCardV1).worldId,
        selectedLessonId: (r.lesson as Act0LessonCardV1).lessonId,
        selectedTaskId: task.taskId,
        // The production feed (preview screen `_localizedTaskTitleV1`).
        selectedTaskTitle: act0LocalizedTaskTitleAtomByIdV1(
          task.taskId,
          fallback: task.title,
        ),
        selectedTaskFamily: task.resolvedTaskFamily,
        compositionFamily: task.resolvedCompositionFamily,
        tablePresentation: task.tablePresentation,
        onBack: () {},
        onContinueTheory: () {},
        onChooseOption: (_) {},
        onContinueReview: () {},
      ),
    ),
  );
}

Widget _learnFixture(
  Act0WorldCardV1 world,
  Act0LessonCardV1 lesson,
  Act0LessonTaskV1 task,
) {
  final opened = lesson.copyWith(
    state: Act0LessonStateV1.current,
    isSelectable: true,
    isLocked: false,
  );
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: const [Locale('en'), Locale('ru')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: Act0LearnPathShellV1(
        moduleTitle: world.title,
        moduleProgressLabel: '0 earned',
        worlds: [
          world.copyWith(lessons: [opened]),
        ],
        selectedWorldId: world.worldId,
        showWorldMenu: false,
        worldDetailId: null,
        lessons: [opened],
        selectedLessonId: lesson.lessonId,
        selectedTaskId: task.taskId,
        activePopupTaskId: task.taskId,
        completedTaskIds: const {},
        perfectTaskIds: const {},
        skippedTaskIds: const {},
        pathClosedTaskIds: {
          for (final t in lesson.taskList.takeWhile(
            (t) => t.taskId != task.taskId,
          ))
            t.taskId,
        },
        detailLessonId: lesson.lessonId,
        lessonOutcomeLabels: const {},
        onSelectWorld: (_) {},
        onOpenWorldMenu: () {},
        onCloseWorldMenu: () {},
        onDismissWorldDetail: () {},
        onPreviewPremiumWorld: (_) {},
        onSelectLesson: (_) => true,
        onOpenLessonAfterScroll: (_) {},
        onDismissDetail: () {},
        onSelectTask: (_, _) {},
        onDismissTaskPopup: () {},
        onStartTask: (_, _) {},
      ),
    ),
  );
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

List<String> _visibleTexts(WidgetTester tester) => [
  for (final w in tester.widgetList<Text>(find.byType(Text)))
    if (w.data != null) w.data!,
  for (final w in tester.widgetList<RichText>(find.byType(RichText)))
    w.text.toPlainText(),
];

List<String> _tableCues(WidgetTester tester) => [
  for (final w in tester.widgetList(
    find.byWidgetPredicate((w) => w.runtimeType.toString() == '_Act0TableV1'),
  ))
    ((w as dynamic).centerLabelOverride as String?) ?? '',
];

Future<({List<String> texts, List<String> cues})> _pumpRunner(
  WidgetTester tester,
  ({Act0WorldCardV1 world, Act0LessonCardV1 lesson, Act0LessonTaskV1 task})
  row, {
  required bool decided,
}) async {
  final task = row.task;
  final correct = task.runner.options.singleWhere((o) => o.isCorrect);
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0LessonRunnerShellV1(
          runner: task.runner.copyWith(
            phase: decided ? Act0LessonPhaseV1.review : task.entryPhase,
            teachingStepIndex: task.runner.teachingSteps.length,
            selectedOptionId: decided ? correct.id : null,
          ),
          worldNumber: row.world.worldNumber,
          selectedWorldId: row.world.worldId,
          selectedLessonId: row.lesson.lessonId,
          selectedTaskId: task.taskId,
          selectedTaskTitle: act0LocalizedTaskTitleAtomByIdV1(
            task.taskId,
            fallback: task.title,
          ),
          selectedTaskFamily: task.resolvedTaskFamily,
          compositionFamily: task.resolvedCompositionFamily,
          tablePresentation: task.tablePresentation,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  while (tester.takeException() != null) {}
  return (texts: _visibleTexts(tester), cues: _tableCues(tester));
}

({Act0WorldCardV1 world, Act0LessonCardV1 lesson, Act0LessonTaskV1 task}) _row(
  String taskId,
) {
  final r = _catalog.singleWhere((r) => r.task.taskId == taskId);
  return (world: r.world, lesson: r.lesson, task: r.task);
}

void main() {
  test('policy sets name only assessed catalog tasks', () {
    final assessedIds = {for (final r in _assessed) r.task.taskId};
    expect(_assessed, hasLength(275));
    for (final id in [
      ...act0PrechoiceNeutralTitleByTaskIdV1.keys,
      ...act0PrechoiceAnswerBearingSummaryTaskIdsV1,
      ...act0PrechoiceAnswerBearingTableCueTaskIdsV1,
    ]) {
      expect(assessedIds, contains(id));
    }
    // Neutral titles must not themselves name any choice of their task.
    for (final entry in act0PrechoiceNeutralTitleByTaskIdV1.entries) {
      final task = _assessed.singleWhere((r) => r.task.taskId == entry.key);
      expect(
        _answerCues([entry.value], task.task.runner),
        isEmpty,
        reason: entry.key,
      );
    }
  });

  testWidgets('Runner shows no answer cue before choice across the catalog', (
    tester,
  ) async {
    _phone(tester);
    final found = <String, List<String>>{};
    for (final row in _assessed) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _runnerFixture((world: row.world, lesson: row.lesson, task: row.task)),
      );
      await tester.pumpAndSettle();
      while (tester.takeException() != null) {}
      final cues = _tableCues(tester);
      final authoredCue = row.task.runner.table.centerLabel.trim();
      if (act0PrechoiceAnswerBearingTableCueTaskIdsV1.contains(
        row.task.taskId,
      )) {
        // Adjudicated answer-bearing cue: never shown before the choice.
        expect(authoredCue, isNotEmpty, reason: row.task.taskId);
        expect(cues, isNot(contains(authoredCue)), reason: row.task.taskId);
      }
      final hits = _answerCues([
        ..._visibleTexts(tester),
        ...cues,
      ], row.task.runner);
      if (hits.isNotEmpty) found[row.task.taskId] = hits.toSet().toList();
    }
    for (final e in found.entries) {
      // ignore: avoid_print
      print('ASM04_RUNNER_HIT ${e.key}: ${e.value}');
    }
    expect(
      _allowedRunnerReasons.keys.toSet().difference(
        _allowedRunnerHits.keys.toSet(),
      ),
      isEmpty,
    );
    expect(found, {..._allowedRunnerHits, ..._openRunnerResiduals});
    // ignore: avoid_print
    print(
      'ASM04_RUNNER price-chip allowances: ${_allowedRunnerHits.length - _allowedRunnerReasons.length} ($_priceChip)',
    );
  });

  testWidgets('Academy shows no answer cue before choice across the catalog', (
    tester,
  ) async {
    _phone(tester);
    final found = <String, List<String>>{};
    for (final row in _assessed) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(_learnFixture(row.world, row.lesson, row.task));
      await tester.pumpAndSettle();
      while (tester.takeException() != null) {}
      final visible = _visibleTexts(tester);
      final id = row.task.taskId;
      if (act0PrechoiceNeutralTitleByTaskIdV1.containsKey(id)) {
        expect(visible, contains(act0PrechoiceNeutralTitleByTaskIdV1[id]));
        expect(
          visible.where(
            (t) =>
                t == row.task.title ||
                t.contains('Start here: ${row.task.title}.'),
          ),
          isEmpty,
          reason: id,
        );
      }
      if (act0PrechoiceAnswerBearingSummaryTaskIdsV1.contains(id)) {
        expect(
          visible.where((t) => t.contains(row.task.runner.caption)),
          isEmpty,
          reason: id,
        );
      }
      final hits = _answerCues(visible, row.task.runner);
      if (hits.isNotEmpty) found[row.task.taskId] = hits.toSet().toList();
    }
    for (final e in found.entries) {
      // ignore: avoid_print
      print('ASM04_LEARN_HIT ${e.key}: ${e.value}');
    }
    expect(_allowedLearnReasons.keys.toSet(), _allowedLearnHits.keys.toSet());
    expect(found, {..._allowedLearnHits, ..._openLearnResiduals});
  });

  testWidgets('authored cue returns after the decision, source untouched', (
    tester,
  ) async {
    _phone(tester);
    // Centre cue: neutral before choice, authored verdict after it.
    final side = _row('what_poker_is_side_pot_intro');
    expect(side.task.runner.table.centerLabel, 'Hero cannot win side pot');
    final before = await _pumpRunner(tester, side, decided: false);
    expect(before.cues, isNot(contains('Hero cannot win side pot')));
    expect(before.cues.where((c) => c.isNotEmpty), isNotEmpty);
    final after = await _pumpRunner(tester, side, decided: true);
    expect(after.cues, contains('Hero cannot win side pot'));

    // Task rail (seat-target layouts show it): neutral EN atom, never the
    // authored 'BTN vs CO' that names the answer to 'later than CO?'.
    final seat = _row('button_advantage_button_vs_cutoff');
    expect(seat.task.title, 'BTN vs CO');
    final rail = await _pumpRunner(tester, seat, decided: false);
    expect(rail.texts, contains('Seat order question'));
    expect(rail.texts, isNot(contains('BTN vs CO')));
  });

  test('display policy never edits the authored source catalog', () {
    for (final r in _assessed) {
      final t = r.task;
      // The projections take authored copy as input and return either it or
      // a neutral constant; the source objects stay as authored.
      final title = act0PrechoiceDisplayTitleV1(
        taskId: t.taskId,
        authoredTitle: t.title,
        isAssessment: true,
        hasSubmittedCurrentDecision: true,
      );
      expect(title, t.title, reason: t.taskId);
      final summary = act0PrechoiceDisplaySummaryV1(
        taskId: t.taskId,
        authoredSummary: t.runner.caption,
        isAssessment: true,
        hasSubmittedCurrentDecision: true,
      );
      expect(summary, t.runner.caption, reason: t.taskId);
    }
    expect(
      act0PrechoiceDisplaySummaryV1(
        taskId: 'what_poker_is_win_ways',
        authoredSummary: 'x',
        isAssessment: true,
        hasSubmittedCurrentDecision: false,
      ),
      act0PrechoiceNeutralSummaryV1,
    );
  });

  test(
    'single-answer lesson stays a declared limitation, not a choice proof',
    () {
      for (final lessonId in act0PrechoiceSingleAnswerLessonIdsV1) {
        final rows = _assessed.where((r) => r.lesson.lessonId == lessonId);
        expect(rows, isNotEmpty, reason: lessonId);
        final answers = {
          for (final r in rows)
            r.task.runner.options.singleWhere((o) => o.isCorrect).label,
        };
        // Authored Fold answers are kept; the lesson cannot evidence choosing
        // between different actions, so it is only claimed as recall.
        expect(answers, {'Fold'}, reason: lessonId);
        expect(
          act0LocalizedLessonTitleAtomByIdV1(
            lessonId,
            fallback: rows.first.lesson.title,
          ),
          isNot(contains('Fold')),
        );
      }
      // No other lesson repeats one answer across three or more assessments.
      final byLesson = <String, Set<String>>{};
      final counts = <String, int>{};
      for (final r in _assessed) {
        final id = r.lesson.lessonId;
        byLesson
            .putIfAbsent(id, () => {})
            .add(r.task.runner.options.singleWhere((o) => o.isCorrect).label);
        counts[id] = (counts[id] ?? 0) + 1;
      }
      expect({
        for (final e in byLesson.entries)
          if (e.value.length == 1 && counts[e.key]! >= 3) e.key,
      }, act0PrechoiceSingleAnswerLessonIdsV1);
    },
  );

  test('recap keeps the real river and asks an honest table read', () {
    final r = _row('your_first_hand_recap').task;
    expect(r.runner.table.boardCards, hasLength(5));
    expect(r.runner.question, 'Which street comes after the turn?');
    expect(
      act0LocalizedRunnerQuestionAtomByTaskIdV1(
        r.taskId,
        fallback: r.runner.question,
      ),
      'Which street is on the table now?',
    );
    expect(r.runner.options.singleWhere((o) => o.isCorrect).label, 'River');
  });

  group('saved answers and history', () {
    // Fingerprints on main 1a4316d, before this package (no #418 either).
    const mainFingerprints = <String, String>{
      'actions_check_drill':
          'f83ccdabce1c8c216939274080ba10409b49285f7adcece8b42face691e42d6b',
      'actions_raise_drill':
          'c105d1969e7b9a7886def4fed1b93aaee5404f7d0603e771be44ea3a76d06971',
      'actions_legal_context':
          'd889c669abcb49a96b62c12447888f10e8e262e3a2f663b8d2e700010686cad4',
    };
    String fingerprint(String taskId) {
      final r = _row(taskId);
      return act0AuthoredSourceFingerprintV1(
        worldId: r.world.worldId,
        lessonId: r.lesson.lessonId,
        task: r.task,
      )!;
    }

    Act0LearningEvidenceRecordV1 record(String taskId, String fp) {
      final r = _row(taskId);
      final correct = r.task.runner.options.singleWhere((o) => o.isCorrect);
      return Act0LearningEvidenceRecordV1(
        recordId: 'synthetic_asm04_answer_cue|$taskId',
        createdOrder: 1,
        worldId: r.world.worldId,
        lessonId: r.lesson.lessonId,
        taskId: taskId,
        sourceTaskId: taskId,
        choiceId: correct.id,
        expectedChoiceId: correct.id,
        isCorrect: true,
        errorType: 'none',
        conceptFamilyId: r.lesson.lessonId,
        repairFocusId: '',
        skillAtomId:
            act0FirstValueSkillReceiptForRunnerV1(
              runner: r.task.runner,
              option: correct,
              taskFamily: r.task.resolvedTaskFamily,
            )?.skillAtomId ??
            '',
        decisionTimeBucket: '3_to_10s',
        resultKind: 'correct',
        assistanceKind: Act0DecisionAssistanceV1.none,
        authoredSourceFingerprint: fp,
      );
    }

    test('an answer saved under a cue stays history, not current proof', () {
      for (final taskId in ['actions_check_drill', 'actions_raise_drill']) {
        final task = _row(taskId).task;
        // Not covered by the #418 card-focus revision; only this package.
        expect(act0PredecisionCardFocusSourceRevisionV1(task), isNull);
        expect(
          act0PrechoiceAnswerCueSourceRevisionV1(
            task,
            lessonId: _row(taskId).lesson.lessonId,
          ),
          act0PrechoiceAnswerCueRevisionV1,
        );
        final current = fingerprint(taskId);
        expect(current, isNot(mainFingerprints[taskId]));
        final old = record(taskId, mainFingerprints[taskId]!);
        final restored = Act0LearningEvidenceHistoryV1.tryParse(
          jsonDecode(
            Act0LearningEvidenceHistoryV1(records: [old]).toStorageString(),
          ),
        )!;
        expect(restored.records.single.toPayload(), old.toPayload());
        expect(restored.records.single.isCorrect, isTrue);
        expect(
          act0CurrentAuthoredSourceProofV1(restored.records.single),
          isNull,
          reason: taskId,
        );
        expect(
          act0CurrentAuthoredSourceProofV1(
            record(taskId, current),
          )!.isCurrentlyCorrect,
          isTrue,
        );
      }
    });

    test('untouched tasks keep their fingerprint and current proof', () {
      final task = _row('actions_legal_context').task;
      expect(act0PredecisionCardFocusSourceRevisionV1(task), isNull);
      expect(
        act0PrechoiceAnswerCueSourceRevisionV1(task, lessonId: 'x'),
        isNull,
      );
      expect(
        fingerprint('actions_legal_context'),
        mainFingerprints['actions_legal_context'],
      );
      expect(
        act0CurrentAuthoredSourceProofV1(
          record(
            'actions_legal_context',
            mainFingerprints['actions_legal_context']!,
          ),
        )!.isCurrentlyCorrect,
        isTrue,
      );
    });

    test('revision covers exactly the tasks whose pre-choice view changed', () {
      final revised = {
        for (final r in _assessed)
          if (act0PrechoiceAnswerCueSourceRevisionV1(
                r.task,
                lessonId: r.lesson.lessonId,
              ) !=
              null)
            r.task.taskId,
      };
      final changed = {
        ...act0PrechoiceNeutralTitleByTaskIdV1.keys,
        ...act0PrechoiceAnswerBearingSummaryTaskIdsV1,
        ...act0PrechoiceAnswerBearingTableCueTaskIdsV1,
        ...act0PrechoiceNeutralQuestionByTaskIdV1.keys,
        for (final r in _assessed)
          if (r.task.taskId.startsWith('hand_rankings_') ||
              act0PrechoiceNeutralLessonTitleByIdV1.containsKey(
                r.lesson.lessonId,
              ))
            r.task.taskId,
      };
      expect(revised, changed);
      // ignore: avoid_print
      print('ASM04_REVISED ${revised.length} of ${_assessed.length}');
    });
  });
}
