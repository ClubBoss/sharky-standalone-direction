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

  test('session worlds resolve to world-session route story', () {
    final story = resolveProgressionRouteStoryForPackV1(
      nextPackId: 'world6_spine_campaign_v1',
      reviewRequired: false,
      activePackId: '',
      nextHandIndex: 0,
      rhythmReason: '',
    );

    expect(story.target.family, ProgressionRouteFamilyV1.sessionWorld);
    expect(story.target.world, 6);
    expect(story.target.routeLabel, 'World 6 sessions');
    expect(story.ctaLabel, 'OPEN WORLD 6');
    expect(story.semanticsLabel, 'Open World 6 session route');
    expect(
      story.reasonLine,
      'Why: Your next learning route is World 6 sessions.',
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

  test('early-arc world3 route story carries continuity language', () {
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
      story.reasonLine,
      'Why: World 2 grounded visible table truth and pressure reads. World 3 now turns that clarity into the first simple open / call / fold framework.',
    );
  });

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
