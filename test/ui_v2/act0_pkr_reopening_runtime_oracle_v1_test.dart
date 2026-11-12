// SYNTHETIC fixed numeric oracle, not catalog/native/user-history evidence.
// Ordinary NLHE, blinds0.5/1, no ante/rake. Last full raise increment is2.
// Source: Poker TDA2026 rules45/49, https://www.pokertda.com/view-poker-tda-rules/.
// Expected legality below is fixed independently of production price results.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'act0_betting_price_contract_v1_test.dart'
    show pkrPriceTableV1, pkrPriceOptionV1;

class _Vector {
  const _Vector(
    this.id,
    this.actor,
    this.due,
    this.pot,
    this.trail,
    this.stacks,
    this.probes,
  );
  final String id, actor, due, pot;
  final List<String> trail;
  final Map<String, String?> stacks;
  final List<(String, String, bool)> probes;
}

const _blinds = ['SB blind 0.5 BB', 'BB blind 1 BB'];
const _vectors = <_Vector>[
  _Vector(
    'prior_actor_short',
    'UTG',
    '1',
    '12.5',
    [
      ..._blinds,
      'UTG raises 3 BB',
      'HJ shoves to 4 BB',
      'CO calls 4 BB',
      'BTN folds',
      'SB folds',
      'BB folds',
    ],
    {
      'UTG': '97 BB',
      'HJ': '0 BB',
      'CO': '96 BB',
      'BTN': '100 BB',
      'SB': '99.5 BB',
      'BB': '99 BB',
    },
    [('Raise to', '6', false), ('Call', '1', true)],
  ),
  _Vector(
    'cumulative_full_increment',
    'UTG',
    '2',
    '18.5',
    [
      ..._blinds,
      'UTG raises 3 BB',
      'HJ shoves to 4 BB',
      'CO shoves to 5 BB',
      'BTN calls 5 BB',
      'SB folds',
      'BB folds',
    ],
    {
      'UTG': '97 BB',
      'HJ': '0 BB',
      'CO': '0 BB',
      'BTN': '95 BB',
      'SB': '99.5 BB',
      'BB': '99 BB',
    },
    [('Raise to', '7', true), ('Raise to', '6', false)],
  ),
  _Vector(
    'caller_new_threshold',
    'CO',
    '1',
    '19.5',
    [
      ..._blinds,
      'UTG raises 3 BB',
      'HJ shoves to 4 BB',
      'CO calls 4 BB',
      'BTN shoves to 5 BB',
      'SB folds',
      'BB folds',
      'UTG calls 5 BB',
    ],
    {
      'UTG': '95 BB',
      'HJ': '0 BB',
      'CO': '96 BB',
      'BTN': '0 BB',
      'SB': '99.5 BB',
      'BB': '99 BB',
    },
    [('Raise to', '7', false), ('Call', '1', true)],
  ),
  _Vector(
    'unacted_player',
    'CO',
    '4',
    '8.5',
    [..._blinds, 'UTG raises 3 BB', 'HJ shoves to 4 BB'],
    {
      'UTG': '97 BB',
      'HJ': '0 BB',
      'CO': '100 BB',
      'BTN': '100 BB',
      'SB': '99.5 BB',
      'BB': '99 BB',
    },
    [('Raise to', '6', true), ('Raise to', '5', false)],
  ),
];

void main() {
  for (final vector in _vectors) {
    for (final probe in vector.probes) {
      testWidgets(
        'SYNTHETIC reopening ${vector.id} ${probe.$1} ${probe.$2} legal=${probe.$3}',
        (t) async {
          await t.binding.setSurfaceSize(const Size(430, 932));
          addTearDown(() => t.binding.setSurfaceSize(null));
          final table =
              pkrPriceTableV1(
                trail: vector.trail,
                hero: vector.actor,
                due: vector.due,
                stacks: vector.stacks,
              ).copyWith(
                potLabel: 'Pot ${vector.pot} BB',
                heroCards: const [
                  Act0CardStateV1(rank: 'A', suit: 's'),
                  Act0CardStateV1(rank: 'K', suit: 'd'),
                ],
              );
          // Separate fixture-readiness sentinel using the known full call cost.
          // This does not compute the tested raise's expected legality.
          final ready = act0BettingPriceForOptionV1(
            table,
            pkrPriceOptionV1('Call', vector.due),
          );
          expect(
            ready.sourceReady,
            true,
            reason: 'SOURCE_READINESS ${vector.id}: ${ready.reason}',
          );
          expect(
            ready.potBeforeActionBb,
            double.parse(vector.pot),
            reason: 'SOURCE_POT ${vector.id}',
          );
          expect(
            ready.callCostBb,
            double.parse(vector.due),
            reason: 'SOURCE_CALL ${vector.id}',
          );
          final option = pkrPriceOptionV1(probe.$1, probe.$2);
          final id = 'synthetic_reopening_${vector.id}_${probe.$1}_${probe.$2}';
          final runner = Act0RunnerStateV1(
            lessonId: id,
            lessonTitle: 'Synthetic reopening probe',
            lessonSubtitle: 'Fixed independent arithmetic',
            beatIndex: 0,
            beatCount: 1,
            phase: Act0LessonPhaseV1.drill,
            caption: 'Synthetic complete betting history',
            hint: '',
            question: 'Choose the legal wager.',
            options: [option],
            feedbackTitle: '',
            feedbackReason: '',
            primaryCtaLabel: 'Continue',
            nextLessonId: null,
            returnTarget: 'learn',
            table: table,
          );
          final sink = Act0InMemoryTelemetrySinkV1();
          final choices = <Act0RunnerOptionV1>[];
          final decisions = <Act0CompletedDecisionV1>[];
          var backCalls = 0;
          await t.pumpWidget(
            MaterialApp(
              locale: const Locale('en'),
              home: Scaffold(
                body: Act0LessonRunnerShellV1(
                  key: ValueKey(id),
                  runner: runner,
                  selectedWorldId: 'synthetic_pkr_oracle',
                  selectedLessonId: id,
                  selectedTaskId: id,
                  selectedTaskFamily: Act0TaskFamilyV1.decision,
                  telemetrySink: sink,
                  evidenceRunId: 'synthetic_reopening',
                  tableChoreographyMode: Act0TableChoreographyModeV1.settled,
                  onBack: () {
                    backCalls++;
                  },
                  onContinueTheory: () {},
                  onChooseOption: choices.add,
                  onCompletedDecision: decisions.add,
                  onContinueReview: () {},
                ),
              ),
            ),
          );
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          final button = find.byKey(Key('act0_shell_option_${option.id}'));
          expect(
            button,
            findsOneWidget,
            reason: 'Choice must actually be offered',
          );
          expect(
            find.descendant(of: button, matching: find.text('${probe.$2} BB')),
            findsOneWidget,
          );
          await t.ensureVisible(button);
          await t.tap(button);
          await t.pumpAndSettle();
          final events = sink.events
              .where(
                (e) => const [
                  'user_choice',
                  'decision_made',
                  'task_result',
                ].contains(e.name),
              )
              .toList();
          final correct = events
              .where((e) => e.fields['correct'] == true)
              .length;
          debugPrint(
            'PKR_REOPENING ${jsonEncode({'id': vector.id, 'action': probe.$1, 'amount': probe.$2, 'expectedLegal': probe.$3, 'choices': choices.length, 'decisions': decisions.length, 'events': events.map((e) => e.name).toList(), 'correctEvents': correct})}',
          );
          if (probe.$3) {
            expect(choices, hasLength(1));
            expect(decisions, hasLength(1));
            expect(decisions.single.isCorrect, true);
            for (final name in [
              'user_choice',
              'decision_made',
              'task_result',
            ]) {
              expect(events.where((e) => e.name == name), hasLength(1));
            }
            expect(correct, 3);
            expect(
              find.byKey(const Key('act0_betting_price_unavailable')),
              findsNothing,
            );
          } else {
            expect(choices, isEmpty);
            expect(decisions, isEmpty);
            expect(events, isEmpty);
            expect(correct, 0);
            expect(
              find.byKey(const Key('act0_betting_price_unavailable')),
              findsOneWidget,
            );
            await t.tap(find.byKey(const Key('act0_shell_runner_back')));
            await t.pumpAndSettle();
            expect(backCalls, 1);
          }
          expect(t.takeException(), isNull);
        },
      );
    }
  }
}
