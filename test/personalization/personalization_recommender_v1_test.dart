import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/personalization_recommender_v1.dart';

Map<String, Object?> _summary(String schema, {bool? ok}) => {
  'schema': schema,
  if (ok != null) 'ok': ok,
};

void main() {
  test('recommends repeat when phase1 ok false', () {
    final recommendation = recommend(
      phase1: _summary('phase1_summary_v1', ok: false),
      phase2: _summary('phase2_summary_v1', ok: true),
      phase3: _summary('phase3_summary_v1', ok: true),
    );
    expect(recommendation.action, PersonalizationNextAction.repeat_phase1);
    expect(recommendation.reason, contains('phase1_summary_v1'));
  });

  test('recommends phase2 when it reported ok false', () {
    final recommendation = recommend(
      phase1: _summary('phase1_summary_v1', ok: true),
      phase2: _summary('phase2_summary_v1', ok: false),
      phase3: _summary('phase3_summary_v1', ok: true),
    );
    expect(recommendation.action, PersonalizationNextAction.run_phase2);
    expect(recommendation.reason, contains('phase2_summary_v1'));
  });

  test('recommends phase3 when it reported ok false', () {
    final recommendation = recommend(
      phase1: _summary('phase1_summary_v1', ok: true),
      phase2: _summary('phase2_summary_v1', ok: true),
      phase3: _summary('phase3_summary_v1', ok: false),
    );
    expect(recommendation.action, PersonalizationNextAction.run_phase3);
    expect(recommendation.reason, contains('phase3_summary_v1'));
  });

  test('recommends idle when phase1 missing', () {
    final recommendation = recommend(
      phase2: _summary('phase2_summary_v1', ok: true),
      phase3: _summary('phase3_summary_v1', ok: true),
    );
    expect(recommendation.action, PersonalizationNextAction.idle);
    expect(recommendation.reason, contains('phase1_summary_v1'));
  });

  test('recommends run_phase2 when missing', () {
    final recommendation = recommend(
      phase1: _summary('phase1_summary_v1', ok: true),
      phase3: _summary('phase3_summary_v1', ok: true),
    );
    expect(recommendation.action, PersonalizationNextAction.run_phase2);
    expect(recommendation.reason, contains('phase2_summary_v1'));
  });

  test('recommends run_phase3 when missing', () {
    final recommendation = recommend(
      phase1: _summary('phase1_summary_v1', ok: true),
      phase2: _summary('phase2_summary_v1', ok: true),
    );
    expect(recommendation.action, PersonalizationNextAction.run_phase3);
  });

  test('recommends idle when all ok', () {
    final recommendation = recommend(
      phase1: _summary('phase1_summary_v1', ok: true),
      phase2: _summary('phase2_summary_v1', ok: true),
      phase3: _summary('phase3_summary_v1', ok: true),
    );
    expect(recommendation.action, PersonalizationNextAction.idle);
    expect(recommendation.reason, contains('all available'));
  });
}
