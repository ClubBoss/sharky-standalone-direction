import 'package:poker_analyzer/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1.dart';
import 'package:test/test.dart';

void main() {
  test('world2 chrome carries Hand Discipline payoff and safe progression', () {
    final contract = resolveSessionDrillRunnerProgressionChromeContractV1(
      const SessionDrillRunnerProgressionChromeInputV1(
        sessionId: 'w2.s01',
        stepLabel: 'Showdown Truth',
        currentDrillIndex: 0,
        totalDrills: 1,
        drillId: 'showdown_truth_intro',
      ),
    );

    expect(contract.titleText, 'World 2');
    expect(contract.nextSessionId, 'w2.s02');
    expect(
      contract.completionBodyText,
      startsWith(
        'World 2 trained fold, call, and raise discipline from position, price, and approved pressure cues.',
      ),
    );
    expect(contract.completionBodyText, contains('Next lesson ready: World 2'));
    expect(contract.completionBodyText, contains('Session 2 of '));
    expect(contract.completionBodyText, isNot(contains('8.0')));
    expect(contract.completionBodyText, isNot(contains('9.0')));
    expect(
      contract.completionBodyText.toLowerCase(),
      isNot(contains('launch')),
    );
    expect(contract.completionBodyText.toLowerCase(), isNot(contains('gto')));
    expect(
      contract.completionBodyText.toLowerCase(),
      isNot(contains('solver')),
    );
  });

  test('canonical world-session chrome resolves from session truth', () {
    final contract = resolveSessionDrillRunnerProgressionChromeContractV1(
      const SessionDrillRunnerProgressionChromeInputV1(
        sessionId: 'w5.s01',
        stepLabel: 'Board Texture',
        currentDrillIndex: 0,
        totalDrills: 1,
        drillId: 'texture_done',
      ),
    );

    expect(contract.titleText, 'World 5');
    expect(contract.statusText, 'World 5 · Session 1 of 10 · Board Texture');
    expect(contract.nextSessionId, 'w5.s02');
    expect(
      contract.completionBodyText,
      'Next lesson ready: World 5 · Session 2 of 10.',
    );
  });

  test('canonical world10 track chrome resolves full track progression', () {
    final contract = resolveSessionDrillRunnerProgressionChromeContractV1(
      const SessionDrillRunnerProgressionChromeInputV1(
        sessionId: 'cash.s09',
        stepLabel: 'Board Texture',
        currentDrillIndex: 0,
        totalDrills: 1,
        drillId: 'track_done_late',
      ),
    );

    expect(contract.titleText, 'World 10 Cash Track');
    expect(
      contract.statusText,
      'World 10 Cash Track · Session 9 of 10 · Board Texture',
    );
    expect(contract.nextSessionId, 'cash.s10');
    expect(
      contract.completionBodyText,
      'Next lesson ready: World 10 Cash Track · Session 10 of 10.',
    );
  });

  test('generic fallback remains deterministic for non-canonical sessions', () {
    final contract = resolveSessionDrillRunnerProgressionChromeContractV1(
      const SessionDrillRunnerProgressionChromeInputV1(
        sessionId: 'debug.session',
        stepLabel: 'Drill',
        currentDrillIndex: 0,
        totalDrills: 3,
        drillId: 'd.debug',
        currentChainStepIndex: 1,
        totalChainSteps: 4,
      ),
    );

    expect(contract.titleText, 'Drill Player debug.session');
    expect(contract.statusText, 'Drill 1/3: d.debug, step 2/4');
    expect(
      contract.completionBodyText,
      'Back to the map when you are ready for the next lesson.',
    );
    expect(contract.nextSessionId, isNull);
  });
}
