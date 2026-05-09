import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

class _RecordingInstructionSourceV1 implements RunnerInstructionSourceV1 {
  @override
  RunnerInstructionContentV1? getIntroInstruction({
    required String moduleId,
    required String moduleTitle,
    required int railIndex,
    required int railTotal,
    required RunnerInstructionContentV1 fallback,
  }) => fallback;

  @override
  RunnerInstructionContentV1? getOutcomeInstruction({
    required String moduleId,
    required bool handLoopMode,
    required bool isCorrect,
    required RunnerInstructionContentV1 fallback,
  }) => fallback;

  @override
  RunnerInstructionContentV1 getStepInstruction({
    required String moduleId,
    required bool handLoopMode,
    required RunnerInstructionContentV1 fallback,
  }) => fallback;
}

void main() {
  testWidgets(
    'world1 foundations runner route cuts over through the canonical world1 host adapter',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    world1FoundationsRunnerRouteV1<void>(
                      moduleId: 'world1_spine_campaign_v1',
                      moduleTitle: 'Quick Drill',
                      mode: kWorld1RunnerModeCampaignSpine,
                      startHandIndex: 3,
                      hintsEnabledV1: false,
                    ),
                  );
                },
                child: const Text('go'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      final runner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      );
      expect(runner.moduleId, 'world1_spine_campaign_v1');
      expect(runner.moduleTitle, 'Quick Drill');
      expect(runner.mode, kWorld1RunnerModeCampaignSpine);
      expect(runner.startHandIndex, 3);
      expect(runner.hintsEnabledV1, isFalse);
    },
  );

  testWidgets('world1 foundations runner route preserves instruction source', (
    tester,
  ) async {
    final instructionSourceV1 = _RecordingInstructionSourceV1();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  world1FoundationsRunnerRouteV1<void>(
                    moduleId: 'world1_spine_campaign_v1',
                    moduleTitle: 'Quick Drill',
                    mode: kWorld1RunnerModeTablePractice,
                    instructionSourceV1: instructionSourceV1,
                  ),
                );
              },
              child: const Text('go'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    final runner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
      find.byType(World1FoundationsMicroTaskRunnerScreen),
    );
    expect(runner.mode, kWorld1RunnerModeTablePractice);
    expect(runner.instructionSourceV1, same(instructionSourceV1));
  });
}
