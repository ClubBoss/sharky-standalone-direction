import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_f7_scene_compatibility_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_f7_scene_source_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const profile = act0PremiumTableSceneProfileV1;
final tasks = Act0ShellStateV1.sample.worlds
    .expand((w) => w.lessons)
    .expand((l) => l.taskList)
    .toList();
Act0LessonTaskV1 task(String id) => tasks.singleWhere((t) => t.taskId == id);
Act0F7SceneSourceV1 source(Act0TableStateV1 table) =>
    Act0F7SceneSourceV1(scenarioKey: 'test/attempt-1', tables: {'test': table});

void main() {
  test('exact owner PNG bytes, dimensions and baked actor ownership', () {
    final bytes = File(profile.assetPath).readAsBytesSync();
    expect(bytes.length, 2688679);
    expect(
      sha256.convert(bytes).toString(),
      'a34b9cec6cdb64743fc5ad5047223bf62a75b5a8f118da0b63332ff469efcd03',
    );
    int integer(int offset) => bytes
        .sublist(offset, offset + 4)
        .fold(0, (int value, int byte) => value * 256 + byte);
    expect(
      Size(integer(16).toDouble(), integer(20).toDouble()),
      profile.sourceSize,
    );
    expect(profile.isValid, isTrue);
    expect(profile.paintsIndependentActors, isFalse);
    expect(profile.supportsEmptySeats, isFalse);
    expect(profile.supportsFoldedSeatedPlayers, isTrue);
  });

  test('donor registration round trips and reserves Hero/river/shelf', () {
    final r = profile.register(const Size(393, 759));
    expect(r.sourceRect, Offset.zero & profile.sourceSize);
    expect(
      r.destinationRect.width / r.destinationRect.height,
      closeTo(965 / 1629, 1e-10),
    );
    for (final anchor in [
      ...profile.seatAnchorsFromHero,
      ...profile.betAnchorsFromHero,
      ...profile.holeCardAnchorsFromHero,
      ...profile.dealerAnchorsFromHero,
      profile.boardAnchor,
      profile.potAnchor,
    ]) {
      expect((r.unmap(r.map(anchor)) - anchor).distance, lessThan(1e-10));
      expect(profile.uiExclusionZones.any((z) => z.contains(anchor)), isFalse);
    }
    final seed = jsonEncode(profile.calibrationData);
    expect(
      act0SceneProfileFromCalibrationV1(seed)!.boardAnchor,
      profile.boardAnchor,
    );
    expect(act0SceneProfileFromCalibrationV1('{broken'), isNull);
    final board = r.map(profile.boardAnchor);
    final cardWidth = r.destinationRect.width * profile.boardCardWidth;
    expect(board.dx - 2.5 * cardWidth, greaterThan(0));
    expect(board.dx + 2.5 * cardWidth, lessThan(393));
    expect(
      r.map(profile.heroAnchor).dy,
      lessThan(r.map(Offset(0, profile.controlShelfTop!)).dy),
    );
  });

  test(
    'current source eligibility ledger includes exact task and variant reasons',
    () {
      final rows = <Map<String, Object?>>[];
      var variants = 0;
      for (final t in tasks) {
        final s = Act0F7SceneSourceV1.fromTask(
          t,
          scenarioKey: '${t.taskId}/attempt-1',
        );
        final result = act0F7SceneCompatibilityV1(s);
        variants += s.tables.length;
        expect(result.certifiesPokerTruth, isFalse, reason: t.taskId);
        if (result.canUsePng) {
          expect(
            profile.supportsScenario(s.tables.values),
            isTrue,
            reason: t.taskId,
          );
          expect(
            s.tables.values.every(
              (v) => v.seats.every((seat) => seat.isOccupied),
            ),
            isTrue,
          );
        }
        rows.add({
          'task_id': t.taskId,
          'disposition': result.disposition.name,
          'reasons': result.reasons,
          'variants': s.tables.keys.toList(),
          'certifies_poker_truth': result.certifiesPokerTruth,
        });
      }
      final counts = {
        for (final d in Act0F7SceneDispositionV1.values)
          d.name: rows.where((r) => r['disposition'] == d.name).length,
      };
      final out = Directory('output/f7_preparation')
        ..createSync(recursive: true);
      File('${out.path}/compatibility.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'tasks': rows.length,
          'variants': variants,
          'counts': counts,
          'evidence': 'SCENERY_PREFLIGHT_ONLY',
          'rows': rows,
        }),
      );
      // Deliberately derive counts from live source; historical 337/30 is not an
      // eligibility oracle. New exclusions must remain visible in the ledger.
      expect(rows.map((r) => r['task_id']).toSet().length, tasks.length);
      stdout.writeln(
        'F7 tasks=${rows.length} variants=$variants counts=$counts',
      );
    },
  );

  test('real empty teaching seat excludes the entire scenario', () {
    final t = task('actions_theory');
    final s = Act0F7SceneSourceV1.fromTask(t, scenarioKey: t.taskId);
    final result = act0F7SceneCompatibilityV1(s);
    expect(
      result.disposition,
      Act0F7SceneDispositionV1.proceduralFallbackRequired,
    );
    expect(result.reasons.any((r) => r.contains('empty_seat/utg')), isTrue);
    expect(
      t.runner.table.seats.singleWhere((s) => s.seatId == 'utg').isOccupied,
      isFalse,
    );
  });

  test(
    'runtime adapter retains generated inputs instead of catalog lookup',
    () {
      final original = task('your_first_hand_flop');
      final generated = original.runner.copyWith(
        lessonId: 'generated-placement-owner',
        table: original.runner.table.copyWith(potLabel: 'runtime-owned amount'),
      );
      final input = Act0F7SceneSourceV1.fromRunner(
        runner: generated,
        taskFamily: null,
        scenarioKey: 'placement/table-read/attempt-2',
      );
      expect(input.tables['authored'], same(generated.table));
      expect(input.tables['authored']!.potLabel, 'runtime-owned amount');
      expect(input.tables['authored'], isNot(same(original.runner.table)));
      expect(
        input.tables.keys,
        containsAll(generated.options.map((o) => 'feedback/${o.id}')),
      );
    },
  );

  test(
    'folded source players remain seated through the real first hand streets',
    () {
      for (final id in [
        'your_first_hand_preflop',
        'your_first_hand_flop',
        'your_first_hand_turn',
        'your_first_hand_river',
        'your_first_hand_showdown',
      ]) {
        // Look up by authored street below, rather than fabricating board cards.
        final t = task(id);
        final s = Act0F7SceneSourceV1.fromTask(t, scenarioKey: t.taskId);
        expect(act0F7SceneCompatibilityV1(s).canUsePng, isTrue, reason: id);
        expect(identical(s.tables['authored'], t.runner.table), isTrue);
        final folded = t.runner.table.seats.where((s) => s.isFolded).toList();
        expect(folded, isNotEmpty);
        expect(folded.every((s) => s.isOccupied), isTrue);
      }
      final hand = Act0ShellStateV1.sample
          .lessonById('your_first_hand')
          .taskList;
      expect(
        hand.map((t) => t.runner.table.streetLabel).toSet(),
        containsAll(['Preflop', 'Flop', 'Turn', 'River']),
      );
      for (final t in hand) {
        final s = Act0F7SceneSourceV1.fromTask(t, scenarioKey: t.taskId);
        expect(
          act0F7SceneCompatibilityV1(s).canUsePng,
          isTrue,
          reason: t.taskId,
        );
        final authored = s.tables['authored']!;
        expect(authored, same(t.runner.table));
        expect(authored.potLabel, t.runner.table.potLabel);
        expect(authored.activeSeatId, t.runner.table.activeSeatId);
        expect(authored.heroCards, same(t.runner.table.heroCards));
        expect(authored.boardCards, same(t.runner.table.boardCards));
        expect(authored.seats, same(t.runner.table.seats));
        for (var i = 0; i < t.runner.teachingSteps.length; i++) {
          final expected = act0TeachingTableForRunnerV1(
            t.runner.table,
            t.runner.teachingSteps[i],
          );
          final projected = s.tables['teaching/$i/projected']!;
          expect(projected.activeSeatId, expected.activeSeatId);
          expect(projected.potLabel, expected.potLabel);
          expect(
            projected.seats.map(
              (v) =>
                  '${v.seatId}/${v.isDealerButton}/${v.isFolded}/${v.currentBetLabel}/${v.bet?.amountLabel}',
            ),
            expected.seats.map(
              (v) =>
                  '${v.seatId}/${v.isDealerButton}/${v.isFolded}/${v.currentBetLabel}/${v.bet?.amountLabel}',
            ),
          );
        }
      }
    },
  );

  test('missing source and ambiguous Hero/actor/board context fail closed', () {
    final table = task('your_first_hand_showdown').runner.table;
    final missing = Act0F7SceneSourceV1(scenarioKey: '', tables: {});
    expect(
      act0F7SceneCompatibilityV1(missing).disposition,
      Act0F7SceneDispositionV1.sourceContextInsufficient,
    );
    for (final invalid in [
      table.copyWith(scope: Act0TableScopeV1.unclassified),
      table.copyWith(heroSeatId: 'not-a-seat'),
      table.copyWith(activeSeatId: 'co'), // actually folded
      table.copyWith(boardCards: table.boardCards.take(4).toList()),
      table.copyWith(
        seats: [
          table.seats.first,
          ...table.seats.skip(1).take(4),
          table.seats.first,
        ],
      ),
    ]) {
      final result = act0F7SceneCompatibilityV1(source(invalid));
      expect(
        result.disposition,
        Act0F7SceneDispositionV1.sourceContextInsufficient,
      );
      expect(result.canUsePng, isFalse);
      expect(result.certifiesPokerTruth, isFalse);
    }
  });
}
