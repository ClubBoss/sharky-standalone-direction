import 'package:poker_analyzer/services/outcome_summary_v1.dart';
import 'package:poker_analyzer/services/personalization_hint_v1.dart';
import 'package:test/test.dart';

OutcomeSummaryV1 _summary({required OutcomeKindV1 kind, String? errorType}) {
  return OutcomeSummaryV1(
    packId: 'world1_spine_campaign_v1',
    worldId: 1,
    beatIndex: 2,
    outcomeKind: kind,
    lines: const <String>['Outcome: sample'],
    errorType: errorType,
  );
}

void main() {
  test('mistake produces deterministic hint', () {
    final hint = buildHint(
      _summary(kind: OutcomeKindV1.mistake, errorType: 'incorrect_seat'),
    );
    expect(hint, 'Hint: W1 #3, mistake type: incorrect seat.');
  });

  test('non-mistake outcomes return null hint', () {
    expect(buildHint(_summary(kind: OutcomeKindV1.success)), isNull);
    expect(buildHint(_summary(kind: OutcomeKindV1.aborted)), isNull);
    expect(buildHint(_summary(kind: OutcomeKindV1.unknown)), isNull);
  });

  test('same input always yields the same hint', () {
    final summary = _summary(
      kind: OutcomeKindV1.mistake,
      errorType: 'incorrect_line',
    );
    final first = buildHint(summary);
    final second = buildHint(summary);
    expect(first, second);
  });
}
