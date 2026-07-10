import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_presentation_config_v1.dart';

void main() {
  test('unannotated teaching steps preserve current production identity', () {
    const step = Act0TeachingStepV1(title: 'Legacy', body: 'No migration.');
    expect(step.identityTeachingSemantics,
        Act0TableIdentityTeachingSemanticsV1.legacy);
    expect(
      act0TableIdentityPolicyForTeachingSemanticsV1(
        step.identityTeachingSemantics,
      ),
      Act0TableIdentityPolicyV1.currentProduction,
    );
  });

  test('teaching semantics map without copy or localization input', () {
    expect(
      act0TableIdentityPolicyForTeachingSemanticsV1(
        Act0TableIdentityTeachingSemanticsV1.learnerOnly,
      ),
      Act0TableIdentityPolicyV1.learnerOnly,
    );
    expect(
      act0TableIdentityPolicyForTeachingSemanticsV1(
        Act0TableIdentityTeachingSemanticsV1.position,
      ),
      Act0TableIdentityPolicyV1.learnerPosition,
    );
    expect(
      act0TableIdentityPolicyForTeachingSemanticsV1(
        Act0TableIdentityTeachingSemanticsV1.dealerOrder,
      ),
      Act0TableIdentityPolicyV1.learnerPositionAndDealerOrder,
    );
  });
}
