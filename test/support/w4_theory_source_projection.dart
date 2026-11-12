// Private projection of a NEW authored theory record. Not a migration or ledger.
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const theoryRecordHash =
    '2aced940af987770de0a4693b5828fed720a647234674d835c6aacf33095a474';
Map<String, dynamic> readTheoryRecord() {
  final bytes = File('test/fixtures/w4_theory/source.json').readAsBytesSync();
  if (sha256.convert(bytes).toString() != theoryRecordHash) {
    throw StateError('Unreviewed theory source bytes');
  }
  return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
}

Act0CardStateV1 _card(String c) => Act0CardStateV1(
  rank: c.substring(0, c.length - 1),
  suit: c.substring(c.length - 1),
  tone: 'hd'.contains(c.substring(c.length - 1))
      ? Act0CardToneV1.red
      : Act0CardToneV1.dark,
);
Act0LessonTaskV1 projectTheorySource() {
  final r = readTheoryRecord();
  final literal = r['canonical_projection_literals'] as Map<String, dynamic>;
  final cards = r['cards'] as Map<String, dynamic>;
  final theory = r['theory'] as Map<String, dynamic>;
  final old = Act0ShellStateV1.sample.worlds
      .singleWhere((w) => w.worldId == 'world_4')
      .lessons
      .singleWhere((l) => l.lessonId == 'call_price')
      .taskList
      .singleWhere((t) => t.taskId == 'w4_price_intro');
  final hero = (cards['hero_hole'] as List).cast<String>().map(_card).toList();
  final table = Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    streetLabel: literal['streetLabel'],
    potLabel: literal['potLabel'],
    toCallLabel: literal['toCallLabel'],
    centerLabel: 'New authored price demonstration',
    heroSeatId: literal['heroSeatId'],
    activeSeatId: literal['activeSeatId'],
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
    heroCards: hero,
    boardCards: [
      ...(cards['flop'] as List).cast<String>(),
      cards['turn'] as String,
    ].map(_card).toList(),
    actionTrail: (literal['actionTrail'] as List)
        .cast<String>()
        .map((s) => Act0ActionTrailItemV1(label: s))
        .toList(),
    seats: (r['participants'] as List).map((v) {
      final s = v as Map<String, dynamic>;
      final id = s['seat_id'] as String;
      return Act0SeatStateV1(
        seatId: id,
        seatLabel: s['position'],
        displayName: s['position'],
        isHero: s['is_hero'],
        isDealerButton: s['is_button'],
        isSmallBlind: s['is_small_blind'],
        isBigBlind: s['is_big_blind'],
        isActive: id == 'btn',
        isInHand: s['status'] == 'live',
        isFolded: s['status'] == 'folded',
        hasActed: id != 'btn',
        isLastAggressor: id == 'sb',
        stackLabel: '${s['remaining_stack_bb']} BB',
        currentBetLabel: id == 'sb' ? '2 BB' : '',
        bet: id == 'sb'
            ? const Act0SeatBetStateV1(
                kind: Act0SeatBetKindV1.bet,
                label: 'SB',
                amountLabel: '2 BB',
              )
            : null,
        cardsVisibleMode: id == 'btn'
            ? Act0CardsVisibleModeV1.faceUp
            : Act0CardsVisibleModeV1.none,
        holeCards: id == 'btn' ? hero : const [],
      );
    }).toList(),
  );
  final steps = (theory['steps'] as List)
      .map(
        (s) => Act0TeachingStepV1(
          title: s['title'],
          body: s['body'],
          table: table,
        ),
      )
      .toList();
  final runner = Act0RunnerStateV1(
    lessonId: old.runner.lessonId,
    lessonTitle: theory['title'],
    lessonSubtitle: 'New authored unscored demonstration',
    beatIndex: old.runner.beatIndex,
    beatCount: old.runner.beatCount,
    phase: Act0LessonPhaseV1.theory,
    caption: steps.first.body,
    hint: steps.first.body,
    question: steps.first.title,
    options: const [],
    feedbackTitle: '',
    feedbackReason: '',
    primaryCtaLabel: old.runner.primaryCtaLabel,
    nextLessonId: old.runner.nextLessonId,
    returnTarget: old.runner.returnTarget,
    table: table,
    teachingSteps: steps,
  );
  return Act0LessonTaskV1(
    taskId: old.taskId,
    title: theory['title'],
    phase: old.phase,
    runner: runner,
    rewardXp: old.rewardXp,
    stepKind: old.stepKind,
    taskFamily: old.taskFamily,
    tablePresentation: old.tablePresentation,
    summary: old.summary,
    lockedSummary: old.lockedSummary,
  );
}
