import 'package:test/test.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_action_area_contract_v1.dart';

void main() {
  test('canonical learner action ordering normalizes primary decision actions', () {
    expect(
      canonicalLearnerPrimaryActionOrderV1(
        const <String>['fold', 'call', 'raise'],
        (actionId) => actionId,
      ),
      const <String>['fold', 'call', 'raise'],
    );
    expect(
      canonicalLearnerPrimaryActionOrderV1(
        const <String>['fold', 'check', 'bet'],
        (actionId) => actionId,
      ),
      const <String>['fold', 'check', 'bet'],
    );
    expect(
      canonicalLearnerPrimaryActionOrderV1(
        const <String>['call', 'raise', 'fold'],
        (actionId) => actionId,
      ),
      const <String>['fold', 'call', 'raise'],
    );
  });
}
