import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_presentation_config_v1.dart';

void main() {
  Future<String> label(
    WidgetTester tester,
    Act0TableIdentityPolicyV1 policy, {
    String position = 'BTN',
  }) async {
    String? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        result = act0RuntimeLocalizedSeatPrimaryLabelV1(
          context,
          seat: Act0SeatStateV1(
            seatId: 'hero',
            seatLabel: position,
            displayName: 'Hero',
            isHero: true,
          ),
          hero: true,
          refined: true,
          identityPolicy: policy,
        );
        return const SizedBox();
      }),
    ));
    return result!;
  }

  testWidgets('preserves the legacy production learner label', (tester) async {
    expect(
      await label(tester, Act0TableIdentityPolicyV1.currentProduction),
      'BTN Hero',
    );
  });

  testWidgets('formats learner only without Hero or position', (tester) async {
    expect(
      await label(tester, Act0TableIdentityPolicyV1.learnerOnly),
      'You',
    );
  });

  testWidgets('formats canonical BTN and non-BTN positions', (tester) async {
    expect(
      await label(tester, Act0TableIdentityPolicyV1.learnerPosition),
      'You · BTN',
    );
    expect(
      await label(
        tester,
        Act0TableIdentityPolicyV1.learnerPosition,
        position: 'BB',
      ),
      'You · BB',
    );
  });

  testWidgets('falls back cleanly and keeps dealer-order label-only', (
    tester,
  ) async {
    expect(
      await label(
        tester,
        Act0TableIdentityPolicyV1.learnerPosition,
        position: '',
      ),
      'You',
    );
    expect(
      await label(
        tester,
        Act0TableIdentityPolicyV1.learnerPositionAndDealerOrder,
      ),
      'You · BTN',
    );
  });
}
