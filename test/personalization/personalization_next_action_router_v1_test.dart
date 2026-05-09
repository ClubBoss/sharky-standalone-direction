// Run with: dart test test/personalization/personalization_next_action_router_v1_test.dart
import 'package:test/test.dart';
import 'package:poker_analyzer/personalization/personalization_next_action_router_v1.dart';

void main() {
  test('known actions map to expected targets', () {
    expect(
      targetForNextAction('repeat_phase1'),
      PersonalizationNextActionTarget.phase1,
    );
    expect(
      targetForNextAction('run_phase1'),
      PersonalizationNextActionTarget.phase1,
    );
    expect(
      targetForNextAction('run_phase2'),
      PersonalizationNextActionTarget.phase2,
    );
    expect(
      targetForNextAction('run_phase3'),
      PersonalizationNextActionTarget.phase3,
    );
  });

  test('unknown action returns none target and not routable', () {
    expect(
      targetForNextAction('zap_the_moon'),
      PersonalizationNextActionTarget.none,
    );
    expect(isRoutableNextAction('zap_the_moon'), isFalse);
  });

  test('empty action treated as none', () {
    expect(targetForNextAction(''), PersonalizationNextActionTarget.none);
    expect(isRoutableNextAction(''), isFalse);
  });

  test('focus labels map to next actions', () {
    expect(focusLabelToNextAction('range'), equals('run_phase1'));
    expect(focusLabelToNextAction('position'), equals('run_phase1'));
    expect(focusLabelToNextAction('board'), equals('run_phase1'));
    expect(focusLabelToNextAction('sizing'), equals('run_phase2'));
    expect(focusLabelToNextAction('value'), equals('run_phase2'));
    expect(focusLabelToNextAction('bluff'), equals('run_phase3'));
    expect(focusLabelToNextAction('discipline'), equals('run_phase3'));
    expect(focusLabelToNextAction('unknown'), isNull);
  });
}
