import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_host_grammar_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_state_entry_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxTicks = 120,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var tick = 0; tick < maxTicks; tick++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(step);
  }
}

void main() {
  test(
    'canonical World1 host adapter resolves explicit runtime config defaults',
    () {
      final runtimeConfig = resolveCanonicalTerminalWorld1RuntimeConfigV1(
        const CanonicalTerminalWorld1RuntimeConfigInputV1(
          moduleId: 'world1_spine_campaign_v1',
          startHandIndexV1: 3,
          hintsEnabledV1: true,
        ),
      );

      expect(
        runtimeConfig.moduleTitleV1,
        recommendedModuleTitleForId('world1_spine_campaign_v1'),
      );
      expect(runtimeConfig.modeV1, 'campaign_spine');
      expect(runtimeConfig.startHandIndexV1, 3);
      expect(runtimeConfig.hintsEnabledV1, isTrue);
    },
  );

  test(
    'canonical World1 host resolution preserves launch state and identity',
    () {
      final resolved = resolveWorld1CanonicalResolvedHostLaunchV1(
        entryInput: const World1CanonicalHostStateEntryInputV1(
          moduleId: 'world1_spine_campaign_v1',
          explicitMode: null,
          isCheckpoint: false,
          isDailyRun: false,
          isTablePractice: false,
          startHandIndex: 2,
          isGlobalCheckpointPack: false,
          checkpointSteps: <MicroTaskStep>[],
          packSteps: <MicroTaskStep>[
            MicroTaskStep(
              prompt: 'Prompt',
              hint: 'Hint',
              expectedSeatIds: <String>['btn'],
            ),
          ],
          fallbackSteps: <MicroTaskStep>[
            MicroTaskStep(
              prompt: 'Fallback',
              hint: 'Fallback hint',
              expectedSeatIds: <String>['bb'],
            ),
          ],
          campaignSpineModeId: 'campaign_spine',
          reviewQueueModeId: 'review_queue',
          checkpointModeId: 'checkpoint',
          dailyRunModeId: 'daily_run',
          tablePracticeModeId: 'table_practice',
          defaultModeId: 'foundations_check',
        ),
        learningEffectSliceMarker: 'world1_spine_campaign_v1::campaign',
      );
      expect(resolved.mode, 'foundations_check');
      expect(
        resolved.learningEffectSliceMarker,
        'world1_spine_campaign_v1::campaign',
      );
      expect(resolved.steps.single.prompt, 'Prompt');
      expect(resolved.initialStepIndex, 0);
      expect(resolved.shouldApplyCheckpointSeed, isFalse);
      expect(resolved.shouldBootstrapCampaignState, isFalse);
      expect(resolved.shouldBootstrapIntroPreludes, isFalse);
      expect(resolved.shouldBootstrapReviewQueue, isFalse);
      expect(
        resolveWorld1CanonicalHostSessionIdentityV1(
          'world1_spine_campaign_v1',
          checkpointId: null,
          startHandIndex: 0,
        ),
        'world1_spine_campaign_v1::none::0',
      );
      expect(
        resolveWorld1CanonicalHostSessionIdentityV1(
          'world1_spine_campaign_v1',
          checkpointId: null,
          startHandIndex: 2,
        ),
        'world1_spine_campaign_v1::none::2',
      );
    },
  );

  test('World1 progression contracts preserve exact payoff and chrome values', () {
    final table = resolveWorld1FoundationsRunnerProgressionChromeContractV1(
      moduleId: 'world1_act0_table_literacy',
      currentStepIndex: 0,
      totalSteps: 3,
    );
    final action = resolveWorld1FoundationsRunnerProgressionChromeContractV1(
      moduleId: 'world1_act0_action_literacy',
      currentStepIndex: 0,
      totalSteps: 3,
    );
    final street = resolveWorld1FoundationsRunnerProgressionChromeContractV1(
      moduleId: 'world1_act0_street_flow',
      currentStepIndex: 0,
      totalSteps: 3,
    );
    expect(
      table?.completionBodyText,
      'You can now find Button, small blind, and big blind without guessing.',
    );
    expect(
      table?.nextSessionProgressLabel,
      'World 1 · Pack 2 of 7 · First action choices',
    );
    expect(table?.statusText, 'Table map · Pack 1 of 7 · Step 1 of 3');
    expect(
      action?.completionBodyText,
      'You can now choose fold, call, and raise from the right seat without action order feeling random.',
    );
    expect(
      action?.nextSessionProgressLabel,
      'World 1 · Pack 3 of 7 · Street flow reads',
    );
    expect(
      action?.statusText,
      'First action choices · Pack 2 of 7 · Step 1 of 3',
    );
    expect(
      street?.completionBodyText,
      'You can now keep the action-order anchor while reading flop, turn, and river changes.',
    );
    expect(
      street?.nextSessionProgressLabel,
      'World 1 · Pack 4 of 7 · Campaign spine',
    );
    expect(street?.statusText, 'Street flow reads · Pack 3 of 7 · Step 1 of 3');
    final campaign = resolveWorld1FoundationsRunnerProgressionChromeContractV1(
      moduleId: 'world1_spine_campaign_v1',
      currentStepIndex: 0,
      totalSteps: 10,
    );
    expect(campaign?.titleText, 'World 1');
    expect(campaign?.statusText, 'Campaign Spine · Pack 4 of 7 · Step 1 of 10');
    expect(
      campaign?.completionBodyText,
      'Next lesson ready: World 1 · Pack 5 of 7.',
    );
    expect(campaign?.nextSessionId, 'world1_spine_followup_v1_b0');
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
  });

  testWidgets(
    'canonical World1 launcher renders campaign title status and prompt chrome',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: CanonicalLauncherV1.sessionDrill(
            sessionId: 'world1_spine_campaign_v1',
            world1ModuleTitleV1: 'World 1',
            world1ModeV1: 'campaign_spine',
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
      expect(
        tester.widget<Text>(statusFinder).data,
        'Campaign Spine · Pack 4 of 7 · Step 1 of 12',
      );
      final headlineFinder = find.byKey(const Key('microtask_step_header'));
      expect(headlineFinder, findsOneWidget);
      expect(tester.widget<Text>(headlineFinder).data, 'World 1');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 200));
    },
  );
}
