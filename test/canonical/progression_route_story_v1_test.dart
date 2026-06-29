import 'package:test/test.dart';

import 'package:poker_analyzer/canonical/progression_route_story_v1.dart';

void main() {
  test('campaign packs keep campaign route semantics', () {
    final story = resolveProgressionRouteStoryForPackV1(
      nextPackId: 'world1_spine_campaign_v1',
      reviewRequired: false,
      activePackId: 'world1_spine_campaign_v1',
      nextHandIndex: 3,
      rhythmReason: '',
    );

    expect(story.target.family, ProgressionRouteFamilyV1.campaignPack);
    expect(story.ctaLabel, 'CONTINUE CAMPAIGN');
    expect(story.semanticsLabel, 'Continue current campaign route');
    expect(story.reasonLine, 'Why: Continue your next campaign route.');
  });

  test('later session worlds keep generic world-session route story', () {
    final story = resolveProgressionRouteStoryForPackV1(
      nextPackId: 'world8_spine_campaign_v1',
      reviewRequired: false,
      activePackId: '',
      nextHandIndex: 0,
      rhythmReason: '',
    );

    expect(story.target.family, ProgressionRouteFamilyV1.sessionWorld);
    expect(story.target.world, 8);
    expect(story.target.routeLabel, 'World 8 sessions');
    expect(story.ctaLabel, 'OPEN WORLD 8');
    expect(story.semanticsLabel, 'Open World 8 session route');
    expect(
      story.reasonLine,
      'Why: Your next learning route is World 8 sessions.',
    );
  });

  test(
    'early-arc world2 route story carries Hand Discipline payoff language',
    () {
      final story = resolveProgressionRouteStoryForPackV1(
        nextPackId: 'world2_spine_campaign_v1',
        reviewRequired: false,
        activePackId: '',
        nextHandIndex: 0,
        rhythmReason: '',
      );

      expect(story.target.family, ProgressionRouteFamilyV1.sessionWorld);
      expect(story.target.world, 2);
      expect(story.ctaLabel, 'OPEN WORLD 2');
      expect(story.semanticsLabel, 'Open World 2 session route');
      expect(
        story.reasonLine,
        'Why: World 1 gave you position, action order, and simple preflop discipline. World 2 now trains when to fold, call, or raise from position, price, and approved pressure cues.',
      );
    },
  );

  test(
    'early-arc world3 route story carries Position Thinking payoff language',
    () {
      final target = resolveProgressionRouteTargetForPackIdV1(
        'world3_spine_campaign_v1',
      );
      final story = resolveProgressionRouteStoryForPackV1(
        nextPackId: 'world3_spine_campaign_v1',
        reviewRequired: false,
        activePackId: '',
        nextHandIndex: 0,
        rhythmReason: '',
      );

      expect(story.target.family, ProgressionRouteFamilyV1.sessionWorld);
      expect(story.target.world, 3);
      expect(
        progressionRouteStatusLineForTargetV1(target),
        'Stage shift - World 2 table reads -> World 3 Position Thinking',
      );
      expect(
        progressionRouteStageShiftHeadlineForTargetV1(target),
        'What changes now: Build Position Thinking from seat, hand bucket, and action-frame cues',
      );
      expect(
        story.reasonLine,
        'Why: World 2 grounded visible table truth and pressure reads. World 3 now trains Position Thinking through position-first choices plus hand-bucket action frames before open, call, or fold.',
      );
      expect(story.reasonLine, contains('Position'));
      expect(story.reasonLine.toLowerCase(), contains('hand-bucket'));
      expect(story.reasonLine, isNot(contains('8.0')));
      expect(story.reasonLine, isNot(contains('9.0')));
      expect(story.reasonLine.toLowerCase(), isNot(contains('launch')));
      expect(story.reasonLine.toLowerCase(), isNot(contains('gto')));
      expect(story.reasonLine.toLowerCase(), isNot(contains('solver')));
      expect(story.reasonLine, isNot(contains('Human QA')));
    },
  );

  test('world5 route story carries Board Awareness payoff handoff', () {
    final target = resolveProgressionRouteTargetForPackIdV1(
      'world5_spine_campaign_v1',
    );
    final story = resolveProgressionRouteStoryForPackV1(
      nextPackId: 'world5_spine_campaign_v1',
      reviewRequired: false,
      activePackId: '',
      nextHandIndex: 0,
      rhythmReason: '',
    );

    expect(story.target.family, ProgressionRouteFamilyV1.sessionWorld);
    expect(story.target.world, 5);
    expect(
      progressionRouteStatusLineForTargetV1(target),
      'Stage shift - World 4 Bet Purpose / Price -> World 5 Board Awareness',
    );
    expect(
      progressionRouteStageShiftHeadlineForTargetV1(target),
      'What changes now: Build Board Awareness from texture, board shifts, and action context',
    );
    expect(
      story.reasonLine,
      'Why: World 4 trained Bet Purpose / Price by connecting intent, price, and action before the click. World 5 now trains Board Awareness through dry, wet, paired, and connected board reads before action.',
    );
    expect(story.reasonLine, contains('Board Awareness'));
    expect(story.reasonLine, isNot(contains('8.0')));
    expect(story.reasonLine, isNot(contains('9.0')));
    expect(story.reasonLine.toLowerCase(), isNot(contains('launch')));
    expect(story.reasonLine.toLowerCase(), isNot(contains('gto')));
    expect(story.reasonLine.toLowerCase(), isNot(contains('solver')));
    expect(story.reasonLine, isNot(contains('Human QA')));
  });

  test(
    'world6 route story carries Range Thinking handoff without closure claim',
    () {
      final target = resolveProgressionRouteTargetForPackIdV1(
        'world6_spine_campaign_v1',
      );
      final story = resolveProgressionRouteStoryForPackV1(
        nextPackId: 'world6_spine_campaign_v1',
        reviewRequired: false,
        activePackId: '',
        nextHandIndex: 0,
        rhythmReason: '',
      );

      expect(story.target.family, ProgressionRouteFamilyV1.sessionWorld);
      expect(story.target.world, 6);
      expect(
        progressionRouteStatusLineForTargetV1(target),
        'Stage shift - World 5 Board Awareness -> World 6 Range Thinking',
      );
      expect(
        progressionRouteStageShiftHeadlineForTargetV1(target),
        'What changes now: Build Range Thinking from board-aware pressure and likely hand groups',
      );
      expect(
        story.reasonLine,
        'Why: World 5 trained Board Awareness before action. World 6 now introduces Range Thinking by connecting board-aware pressure to likely hand groups.',
      );
      expect(story.reasonLine, contains('Range Thinking'));
      expect(story.reasonLine, isNot(contains('8.0')));
      expect(story.reasonLine, isNot(contains('9.0')));
      expect(story.reasonLine.toLowerCase(), isNot(contains('launch')));
      expect(story.reasonLine.toLowerCase(), isNot(contains('gto')));
      expect(story.reasonLine.toLowerCase(), isNot(contains('solver')));
      expect(story.reasonLine, isNot(contains('Human QA')));
    },
  );

  test(
    'world6 completion payoff names buckets and width without strategy claim',
    () {
      final body = progressionRouteCompletionBodyTextForSessionWorldV1(
        world: 6,
        nextSessionProgressLabel: 'World 6 \u00B7 Session 2 of 10',
      );

      expect(
        body,
        startsWith(
          'World 6 trained Range Thinking by reading broad range buckets and range width before action.',
        ),
      );
      expect(body, contains('Next lesson ready: World 6'));
      expect(body.toLowerCase(), contains('buckets'));
      expect(body.toLowerCase(), contains('width'));
      expect(body, isNot('Next lesson ready: World 6 \u00B7 Session 2 of 10.'));
      _expectNoW6ForbiddenStrategyTerms(body);
    },
  );

  test('world10 followups resolve to track route story', () {
    final story = resolveProgressionRouteStoryForPackV1(
      nextPackId: 'world10_spine_followup_v1_b0',
      reviewRequired: false,
      activePackId: '',
      nextHandIndex: 0,
      rhythmReason: '',
    );

    expect(story.target.family, ProgressionRouteFamilyV1.trackSession);
    expect(story.target.trackKind, 'cash');
    expect(story.target.routeLabel, 'Cash track');
    expect(story.ctaLabel, 'OPEN CASH TRACK');
    expect(story.semanticsLabel, 'Open the Cash track route');
    expect(
      story.reasonLine,
      'Why: Your next learning route is the Cash track.',
    );
  });

  test('review gating preserves review CTA semantics', () {
    final story = resolveProgressionRouteStoryForPackV1(
      nextPackId: 'world8_spine_campaign_v1',
      reviewRequired: true,
      activePackId: '',
      nextHandIndex: 0,
      rhythmReason: 'Missed spots ready',
    );

    expect(story.target.family, ProgressionRouteFamilyV1.sessionWorld);
    expect(story.ctaLabel, 'REVIEW MISSED');
    expect(story.semanticsLabel, 'Open review queue session');
    expect(story.reasonLine, 'Why: Missed spots ready.');
  });

  test('early-arc review gating carries checkpoint cadence language', () {
    final story = resolveProgressionRouteStoryForPackV1(
      nextPackId: 'world2_spine_campaign_v1',
      reviewRequired: true,
      activePackId: '',
      nextHandIndex: 0,
      rhythmReason: 'Review required',
    );

    expect(story.target.family, ProgressionRouteFamilyV1.sessionWorld);
    expect(story.ctaLabel, 'REVIEW MISSED');
    expect(
      story.reasonLine,
      'Why: Checkpoint review: lock the World 1 foundations before the next World 2 session.',
    );
  });
}

void _expectNoW6ForbiddenStrategyTerms(String value) {
  final lower = value.toLowerCase();
  for (final term in <String>[
    '8.0',
    '9.0',
    'advanced strategy',
    'blocker',
    'combo',
    'exploit',
    'frequency',
    'gto',
    'human qa',
    'launch',
    'opponent',
    'perfect counter',
    'polar',
    'solver',
    'stack',
    'tournament',
  ]) {
    expect(lower, isNot(contains(term)));
  }
}
