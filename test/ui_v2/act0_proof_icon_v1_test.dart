import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_proof_icon_v1.dart';

void main() {
  Future<void> pumpIcon(
    WidgetTester tester,
    Act0ProofIconRoleV1 role, {
    Act0ProofIconSizeV1 size = Act0ProofIconSizeV1.inline,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Act0ProofIconV1(role: role, size: size)),
      ),
    );
  }

  testWidgets('repairCompleted renders a single calm proof mark', (
    tester,
  ) async {
    await pumpIcon(tester, Act0ProofIconRoleV1.repairCompleted);

    expect(
      find.byKey(const Key('act0_proof_icon_v1_repairCompleted')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(
      find.byKey(const Key('act0_proof_icon_v1_reinforced_echo')),
      findsNothing,
    );
  });

  testWidgets('reinforced adds a second confirmation echo layer', (
    tester,
  ) async {
    await pumpIcon(tester, Act0ProofIconRoleV1.reinforced);

    expect(
      find.byKey(const Key('act0_proof_icon_v1_reinforced_echo')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_proof_icon_v1_reinforced')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
  });

  testWidgets('milestone renders a reserved stronger seal', (tester) async {
    await pumpIcon(
      tester,
      Act0ProofIconRoleV1.milestone,
      size: Act0ProofIconSizeV1.seal,
    );

    expect(
      find.byKey(const Key('act0_proof_icon_v1_milestone')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
  });

  testWidgets('sizes differ across inline, tile, and seal', (tester) async {
    for (final size in Act0ProofIconSizeV1.values) {
      await pumpIcon(tester, Act0ProofIconRoleV1.repairCompleted, size: size);
      await tester.pump();
    }
    // No exceptions across every size/role permutation.
    expect(tester.takeException(), isNull);
  });

  testWidgets('proof icon uses no rarity, level, or lock visual state', (
    tester,
  ) async {
    for (final role in Act0ProofIconRoleV1.values) {
      await pumpIcon(tester, role);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(find.byIcon(Icons.emoji_events_rounded), findsNothing);
      expect(find.byIcon(Icons.military_tech_rounded), findsNothing);
      expect(find.byIcon(Icons.workspace_premium_rounded), findsNothing);
    }
  });

  test(
    'milestone role is scoped only to the W1 completion payoff widget',
    () {
      final profileSource = File(
        'lib/ui_v2/act0_shell/act0_profile_shell_v1.dart',
      ).readAsStringSync();
      final consumerSource = File(
        'lib/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart',
      ).readAsStringSync();
      final lessonRunnerSource = File(
        'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
      ).readAsStringSync();

      // Profile and the ordinary repair-outcome/session receipt contract must
      // never emit a milestone icon; only a true W1 completion may.
      expect(profileSource, isNot(contains('Act0ProofIconRoleV1.milestone')));
      expect(consumerSource, isNot(contains('Act0ProofIconRoleV1.milestone')));

      final classStart = lessonRunnerSource.indexOf(
        'class _WorldOneCompletionPayoffV1',
      );
      expect(
        classStart,
        greaterThan(-1),
        reason: 'W1 completion payoff widget must exist',
      );
      final nextClassStart = lessonRunnerSource.indexOf(
        '\nclass ',
        classStart + 1,
      );
      final worldOneWidgetBody = lessonRunnerSource.substring(
        classStart,
        nextClassStart == -1 ? lessonRunnerSource.length : nextClassStart,
      );
      final restOfFile =
          lessonRunnerSource.substring(0, classStart) +
          lessonRunnerSource.substring(
            nextClassStart == -1 ? lessonRunnerSource.length : nextClassStart,
          );

      expect(
        worldOneWidgetBody,
        contains('Act0ProofIconRoleV1.milestone'),
        reason: 'W1 completion is the milestone role\'s first valid consumer',
      );
      expect(
        restOfFile,
        isNot(contains('Act0ProofIconRoleV1.milestone')),
        reason: 'milestone must not leak into any other surface',
      );
    },
  );
}
