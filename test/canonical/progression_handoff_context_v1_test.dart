import 'package:test/test.dart';

import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';

void main() {
  test(
    'campaign packs that stay campaign-native do not emit handoff context',
    () {
      expect(
        buildProgressionHandoffContextForPackV1('world1_spine_campaign_v1'),
        isNull,
      );
    },
  );

  test('campaign to session promotion emits world-session handoff context', () {
    final context = buildProgressionHandoffContextForPackV1(
      'world8_spine_campaign_v1',
    );

    expect(context, isNotNull);
    expect(context!.statusLine, 'Campaign route -> World 8 sessions');
  });

  test('early-arc world2 handoff carries Hand Discipline headline and reason', () {
    final context = buildProgressionHandoffContextForPackV1(
      'world2_spine_campaign_v1',
    );

    expect(context, isNotNull);
    expect(
      context!.statusLine,
      'Stage shift - World 1 foundations -> World 2 Hand Discipline',
    );
    expect(
      context.continuationHeadline,
      'What changes now: Build Hand Discipline from position, price, and approved pressure cues',
    );
    expect(
      context.continuationReasonLine,
      'Why: World 1 gave you position, action order, and simple preflop discipline. World 2 now trains when to fold, call, or raise from position, price, and approved pressure cues.',
    );
  });

  test(
    'early-arc world3 handoff carries Position Thinking headline and reason',
    () {
      final context = buildProgressionHandoffContextForPackV1(
        'world3_spine_campaign_v1',
      );

      expect(context, isNotNull);
      expect(
        context!.statusLine,
        'Stage shift - World 2 table reads -> World 3 Position Thinking',
      );
      expect(
        context.continuationHeadline,
        'What changes now: Build Position Thinking from seat, hand bucket, and action-frame cues',
      );
      expect(
        context.continuationReasonLine,
        'Why: World 2 grounded visible table truth and pressure reads. World 3 now trains Position Thinking through position-first choices plus hand-bucket action frames before open, call, or fold.',
      );
      expect(context.continuationReasonLine, isNot(contains('8.0')));
      expect(context.continuationReasonLine, isNot(contains('9.0')));
      expect(
        context.continuationReasonLine!.toLowerCase(),
        isNot(contains('launch')),
      );
      expect(
        context.continuationReasonLine!.toLowerCase(),
        isNot(contains('solver')),
      );
      expect(context.continuationReasonLine, isNot(contains('Human QA')));
    },
  );

  test('world5 handoff carries Board Awareness headline and reason', () {
    final context = buildProgressionHandoffContextForPackV1(
      'world5_spine_campaign_v1',
    );

    expect(context, isNotNull);
    expect(
      context!.statusLine,
      'Stage shift - World 4 Bet Purpose / Price -> World 5 Board Awareness',
    );
    expect(
      context.continuationHeadline,
      'What changes now: Build Board Awareness from texture, board shifts, and action context',
    );
    expect(
      context.continuationReasonLine,
      'Why: World 4 trained Bet Purpose / Price by connecting intent, price, and action before the click. World 5 now trains Board Awareness through dry, wet, paired, and connected board reads before action.',
    );
    expect(context.continuationReasonLine, isNot(contains('8.0')));
    expect(context.continuationReasonLine, isNot(contains('9.0')));
    expect(
      context.continuationReasonLine!.toLowerCase(),
      isNot(contains('launch')),
    );
    expect(
      context.continuationReasonLine!.toLowerCase(),
      isNot(contains('solver')),
    );
    expect(context.continuationReasonLine, isNot(contains('Human QA')));
  });

  test('world6 handoff points to Range Thinking without closure claim', () {
    final context = buildProgressionHandoffContextForPackV1(
      'world6_spine_campaign_v1',
    );

    expect(context, isNotNull);
    expect(
      context!.statusLine,
      'Stage shift - World 5 Board Awareness -> World 6 Range Thinking',
    );
    expect(
      context.continuationHeadline,
      'What changes now: Build Range Thinking from board-aware pressure and likely hand groups',
    );
    expect(
      context.continuationReasonLine,
      'Why: World 5 trained Board Awareness before action. World 6 now introduces Range Thinking by connecting board-aware pressure to likely hand groups.',
    );
    expect(context.continuationReasonLine, isNot(contains('8.0')));
    expect(context.continuationReasonLine, isNot(contains('9.0')));
    expect(
      context.continuationReasonLine!.toLowerCase(),
      isNot(contains('launch')),
    );
    expect(
      context.continuationReasonLine!.toLowerCase(),
      isNot(contains('solver')),
    );
    expect(context.continuationReasonLine, isNot(contains('Human QA')));
  });

  test('world10 followup emits track handoff context', () {
    final context = buildProgressionHandoffContextForPackV1(
      'world10_spine_followup_v1_b0',
    );

    expect(context, isNotNull);
    expect(context!.statusLine, 'World 10 core -> Cash track');
  });
}
