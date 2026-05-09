import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_host_grammar_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxTicks = 120,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxTicks; i++) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(step);
  }
}

void main() {
  testWidgets('early World 1 act0 packs resolve capability-aware payoff copy', (
    WidgetTester tester,
  ) async {
    final tableContract =
        resolveWorld1FoundationsRunnerProgressionChromeContractV1(
          moduleId: 'world1_act0_table_literacy',
          currentStepIndex: 0,
          totalSteps: 3,
        );
    final actionContract =
        resolveWorld1FoundationsRunnerProgressionChromeContractV1(
          moduleId: 'world1_act0_action_literacy',
          currentStepIndex: 0,
          totalSteps: 3,
        );
    final streetContract =
        resolveWorld1FoundationsRunnerProgressionChromeContractV1(
          moduleId: 'world1_act0_street_flow',
          currentStepIndex: 0,
          totalSteps: 3,
        );

    expect(
      tableContract?.completionBodyText,
      'You can now find Button, small blind, and big blind without guessing.',
    );
    expect(
      tableContract?.nextSessionProgressLabel,
      'World 1 · Pack 2 of 7 · First action choices',
    );
    expect(
      actionContract?.completionBodyText,
      'You can now choose fold, call, and raise from the right seat without action order feeling random.',
    );
    expect(
      actionContract?.nextSessionProgressLabel,
      'World 1 · Pack 3 of 7 · Street flow reads',
    );
    expect(
      streetContract?.completionBodyText,
      'You can now keep the action-order anchor while reading flop, turn, and river changes.',
    );
    expect(
      streetContract?.nextSessionProgressLabel,
      'World 1 · Pack 4 of 7 · Campaign spine',
    );
    expect(
      tableContract?.statusText,
      'Table map · Pack 1 of 7 · Step 1 of 3',
    );
    expect(
      actionContract?.statusText,
      'First action choices · Pack 2 of 7 · Step 1 of 3',
    );
    expect(
      streetContract?.statusText,
      'Street flow reads · Pack 3 of 7 · Step 1 of 3',
    );
  });

  testWidgets('campaign-pack adapter resolves canonical world1 chrome', (
    WidgetTester tester,
  ) async {
    final contract = resolveWorld1FoundationsRunnerProgressionChromeContractV1(
      moduleId: 'world1_spine_campaign_v1',
      currentStepIndex: 0,
      totalSteps: 10,
    );

    expect(contract, isNotNull);
    expect(contract!.titleText, 'World 1');
    expect(contract.statusText, 'Campaign Spine · Pack 4 of 7 · Step 1 of 10');
    expect(
      contract.completionBodyText,
      'Next lesson ready: World 1 · Pack 5 of 7.',
    );
    expect(contract.nextSessionId, 'world1_spine_followup_v1_b0');
  });

  testWidgets(
    'campaign-pack runner surfaces canonical title and status chrome',
    (WidgetTester tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('microtask_step_prompt')),
      );

      final statusFinder = find.byKey(
        const Key('microtask_runner_progression_status_v1'),
      );
      expect(statusFinder, findsOneWidget);
      final statusText = tester.widget<Text>(statusFinder).data;
      expect(statusText, 'Campaign Spine · Pack 4 of 7 · Step 1 of 12');
      final headlineFinder = find.byKey(const Key('microtask_step_header'));
      expect(headlineFinder, findsOneWidget);
      expect(tester.widget<Text>(headlineFinder).data, 'World 1');
      expect(find.text('Step 1 of 12'), findsOneWidget);
      expect(
        find.byKey(const Key('microtask_runner_prompt_capsule_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('microtask_scene_support_lane_v1')),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 200));
    },
  );

  testWidgets(
    'campaign spine slice surfaces canonical prompt and support primitives from shared grammar',
    (WidgetTester tester) async {
      final adoption = resolveSharedLearnerHostGrammarAdoptionV1(
        hostFamily: 'world1FoundationsRunner',
        screenFamily: 'World1FoundationsMicroTaskRunnerScreen',
        itemType: 'campaign_pack',
        modeFamily: 'campaignSpine',
      );

      expect(adoption, isNotNull);
      expect(
        adoption!.profile.primitives,
        contains(SharedLearnerHostPrimitiveV1.promptStatusCapsule),
      );
      expect(
        adoption.profile.primitives,
        contains(SharedLearnerHostPrimitiveV1.sceneSupportLane),
      );

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('microtask_step_prompt')),
      );

      expect(
        find.byKey(const Key('microtask_runner_prompt_capsule_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('microtask_scene_support_lane_v1')),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 200));
    },
  );
}
