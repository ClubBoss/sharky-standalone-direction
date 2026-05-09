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
      'world6_spine_campaign_v1',
    );

    expect(context, isNotNull);
    expect(context!.statusLine, 'Campaign route -> World 6 sessions');
  });

  test('early-arc world2 handoff carries shared headline and reason', () {
    final context = buildProgressionHandoffContextForPackV1(
      'world2_spine_campaign_v1',
    );

    expect(context, isNotNull);
    expect(
      context!.statusLine,
      'Stage shift · World 1 foundations -> World 2 table reads',
    );
    expect(
      context.continuationHeadline,
      'What changes now: Read visible table truth',
    );
    expect(
      context.continuationReasonLine,
      'Why: World 1 gave you position, action order, and simple preflop discipline. World 2 now asks you to read visible table truth before you choose.',
    );
  });

  test('world10 followup emits track handoff context', () {
    final context = buildProgressionHandoffContextForPackV1(
      'world10_spine_followup_v1_b0',
    );

    expect(context, isNotNull);
    expect(context!.statusLine, 'World 10 core -> Cash track');
  });
}
