import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// Catalog-level learning truth for the live Act0 W1-W12 route.
///
/// Guards the failure classes found by the W1-W12 progression audit:
/// a recap that rewrites `question` while inheriting another task's options,
/// teaching copy naming a hand Hero does not hold, and authored tables whose
/// seats contradict the action they describe.
void main() {
  final tasks = <({String worldId, String lessonId, Act0LessonTaskV1 task})>[
    for (final w in Act0ShellStateV1.sample.worlds)
      for (final l in w.lessons)
        for (final t in l.taskList)
          (worldId: w.worldId, lessonId: l.lessonId, task: t),
  ];
  bool graded(Act0LessonTaskV1 t) =>
      t.phase != Act0LessonPhaseV1.theory && t.runner.options.isNotEmpty;
  Iterable<Act0TableStateV1> tablesOf(Act0LessonTaskV1 t) => [
    t.runner.table,
    for (final s in t.runner.teachingSteps)
      if (s.table != null) s.table!,
  ];

  test('the live catalog is the audited 367-task W1-W12 route', () {
    expect(Act0ShellStateV1.sample.worlds.length, 12);
    expect(tasks.length, 367);
  });

  group('graded questions are answered by their own options', () {
    // Each of these once sat on a graded recap whose inherited options did
    // not answer it (for example "avoid" keyed to Fold).
    const retiredNonAnswerQuestions = <String>[
      'What should weak familiar hands avoid?',
      'What did the opener create?',
      'What do board cards mean?',
      'What prevents one-hand-one-answer thinking?',
      'What should you check after the bucket?',
      'Which seat usually sees more first?',
      'What carries this read into World 8?',
    ];

    test('no graded task carries a retired non-answer question', () {
      final offenders = [
        for (final e in tasks)
          if (graded(e.task) &&
              retiredNonAnswerQuestions.contains(e.task.runner.question))
            e.task.taskId,
      ];
      expect(offenders, isEmpty);
    });

    test('a "why" question is never keyed to a bare seat or action', () {
      const bare = <String>{
        'UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB', 'BTN (your seat)', //
        'Fold', 'Check', 'Call', 'Raise', 'Bet',
      };
      final offenders = [
        for (final e in tasks)
          if (graded(e.task) &&
              e.task.runner.question.trim().startsWith('Why') &&
              e.task.runner.options.any(
                (o) => o.isCorrect && bare.contains(o.label.trim()),
              ))
            e.task.taskId,
      ];
      expect(offenders, isEmpty);
    });

    test('repaired recaps keep their answers and ask matching questions', () {
      const expected = <String, (String, String)>{
        'fold_discipline_fold_recap': ('fold', 'What protects your stack?'),
        'weak_ace_warning_w3_dominated_recap': (
          'fold',
          'What protects your stack?',
        ),
        'apply_recap': ('fold', 'What protects your stack?'),
        'continue_or_let_go_continue_recap': ('call', 'response to that price'),
        'cards_ranks_suits_recap': ('five', 'make your final hand'),
        'same_hand_different_seat_w3_same_hand_recap': (
          'btn',
          'more comfortable to play',
        ),
        'position_apply_recap': ('raise', 'cleaner action'),
        'position_checkpoint_position_checkpoint_review': (
          'raise',
          'cleaner action',
        ),
        'button_advantage_button_recap': ('bottom', 'acts last after the flop'),
        'early_vs_late_w2_position_recap': (
          'bottom',
          'acts last after the flop',
        ),
        'range_checkpoint_review': (
          'range_plus_stack_depth',
          'Later in Volume I',
        ),
      };
      for (final MapEntry(key: id, value: (correctId, phrase))
          in expected.entries) {
        final task = tasks.firstWhere((e) => e.task.taskId == id).task;
        expect(graded(task), isTrue, reason: id);
        expect(task.runner.question, contains(phrase), reason: id);
        expect(
          task.runner.options.where((o) => o.isCorrect).map((o) => o.id),
          [correctId],
          reason: '$id must keep its stored grading semantics',
        );
      }
    });

    test('postflop seat questions explain postflop order', () {
      for (final id in const [
        'positions_review',
        'button_advantage_button_recap',
        'early_vs_late_w2_position_recap',
      ]) {
        final task = tasks.firstWhere((e) => e.task.taskId == id).task;
        final bb = task.runner.options.firstWhere((o) => o.label == 'BB');
        expect(bb.isCorrect, isFalse, reason: id);
        expect(bb.feedbackReason, contains('after the flop'), reason: id);
        expect(bb.feedbackReason, isNot(contains('not next here')));
      }
    });

    testWidgets('theory-phase options are not presented as answers', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final e = tasks.firstWhere(
        (e) => e.task.taskId == 'cards_ranks_suits_theory',
      );
      expect(e.task.phase, Act0LessonPhaseV1.theory);
      await tester.pumpWidget(
        MaterialApp(
          home: Act0LessonRunnerShellV1(
            runner: e.task.runner,
            selectedWorldId: e.worldId,
            selectedLessonId: e.lessonId,
            selectedTaskId: e.task.taskId,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onChooseSeat: (_) {},
            onContinueReview: () {},
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      for (final o in e.task.runner.options) {
        expect(find.byKey(Key('act0_shell_option_${o.id}')), findsNothing);
      }
      expect(find.text(e.task.runner.question), findsNothing);
    });
  });

  group('teaching names the hand Hero holds', () {
    const order = '23456789TJQKA';
    final handCode = RegExp(r'\b([AKQJT2-9]{2}[so]|AA|KK|QQ|JJ|TT)\b');
    String? codeOf(List<Act0CardStateV1> cards) {
      if (cards.length != 2) return null;
      final a = cards[0], b = cards[1];
      if (!order.contains(a.rank) || !order.contains(b.rank)) return null;
      if (a.rank.length != 1 || b.rank.length != 1) return null;
      final hi = order.indexOf(a.rank) >= order.indexOf(b.rank) ? a : b;
      final lo = identical(hi, a) ? b : a;
      if (hi.rank == lo.rank) return '${hi.rank}${lo.rank}';
      return '${hi.rank}${lo.rank}${a.suit == b.suit ? 's' : 'o'}';
    }

    test('stated hand codes match Hero cards in caption and teaching', () {
      final offenders = <String>[];
      for (final e in tasks) {
        final runner = e.task.runner;
        final hero = codeOf(runner.table.heroCards);
        if (hero == null) continue;
        final stated = handCode
            .allMatches('${runner.caption} ${runner.question}')
            .map((m) => m.group(1)!)
            .toSet();
        if (stated.isEmpty) continue;
        if (!stated.contains(hero)) {
          offenders.add('${e.task.taskId}: states $stated, holds $hero');
        }
        final taught = {
          for (final s in runner.teachingSteps)
            ...handCode.allMatches(s.body).map((m) => m.group(1)!),
        };
        if (taught.length == 1 && !taught.contains(hero)) {
          offenders.add('${e.task.taskId}: teaches $taught, holds $hero');
        }
      }
      expect(offenders, isEmpty);
    });
  });

  group('authored tables match the action they describe', () {
    const preflopOrder = ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'];
    final actorStep = RegExp(r'^(UTG|HJ|CO|BTN|SB|BB) folds$');
    final observedActor = RegExp(r'^(UTG|HJ|CO|BTN|SB|BB) acts$');
    final voluntary = RegExp(
      r'^(UTG|HJ|CO|BTN|SB|BB) (folds|opens|calls|raises|bets|checks|acts)',
    );

    test('every seat is occupied: Volume I scenes are fully seated', () {
      final offenders = [
        for (final e in tasks)
          for (final t in tablesOf(e.task))
            for (final s in t.seats)
              if (!s.isOccupied) '${e.task.taskId}:${s.seatId}',
      ];
      expect(offenders, isEmpty);
    });

    test('folded players are out, Hero is in, trail folds agree', () {
      final offenders = <String>[];
      for (final e in tasks) {
        for (final t in tablesOf(e.task)) {
          final byLabel = {for (final s in t.seats) s.seatLabel: s};
          for (final s in t.seats) {
            if (s.isFolded && s.isInHand) {
              offenders.add('${e.task.taskId}: ${s.seatLabel} folded in hand');
            }
            if (s.isHero && (s.isFolded || !s.isInHand)) {
              offenders.add('${e.task.taskId}: Hero is out of the hand');
            }
          }
          for (final item in t.actionTrail) {
            final m = actorStep.firstMatch(item.label);
            if (m == null) continue;
            final seat = byLabel[m.group(1)]!;
            if (seat.isInHand) {
              offenders.add('${e.task.taskId}: "${item.label}" yet in hand');
            }
          }
        }
      }
      expect(offenders, isEmpty);
    });

    test('W1 table-read recheck: four live players make its 4 BB pot', () {
      final task = tasks
          .firstWhere(
            (e) => e.task.taskId == 'what_poker_is_table_read_recheck',
          )
          .task;
      final t = task.runner.table;
      expect(t.potLabel, 'Pot 4 BB');
      expect(t.seats.where((s) => s.isInHand).length, 4);
      expect(t.heroSeat.isInHand, isTrue);
    });

    test('preflop action never skips a seat that is still in the hand', () {
      // Seat-map frames (blind posts only, or an explicit seat comparison)
      // highlight a seat to tap; nobody has acted, so they are exempt.
      final offenders = <String>[];
      for (final e in tasks) {
        for (final t in tablesOf(e.task)) {
          if (t.boardCards.isNotEmpty) continue;
          if (!t.actionTrail.any((i) => voluntary.hasMatch(i.label))) continue;
          // Observation frames: the trail ends on another player's turn while
          // the learner answers from Hero's seat (Table Truth D1 keeps the
          // decision actor on Hero). The order is about that other player.
          final last = observedActor.firstMatch(t.actionTrail.last.label);
          if (last != null && last.group(1) != t.heroSeat.seatLabel) continue;
          final active = t.seats
              .where((s) => s.seatId == t.activeSeatId)
              .firstOrNull;
          if (active == null) continue;
          final before = preflopOrder.take(
            preflopOrder.indexOf(active.seatLabel),
          );
          for (final label in before) {
            final s = t.seats.firstWhere((x) => x.seatLabel == label);
            if (s.isInHand && !s.hasActed) {
              offenders.add('${e.task.taskId}: $label skipped');
            }
          }
        }
      }
      expect(offenders, isEmpty);
    });
  });
}
