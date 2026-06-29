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

  test('world3 chrome carries Position Thinking payoff and safe progression', () {
    final contract = resolveSessionDrillRunnerProgressionChromeContractV1(
      const SessionDrillRunnerProgressionChromeInputV1(
        sessionId: 'w3.s01',
        stepLabel: 'Position Thinking',
        currentDrillIndex: 0,
        totalDrills: 1,
        drillId: 'position_thinking_intro',
      ),
    );

    expect(contract.titleText, 'World 3');
    expect(contract.nextSessionId, 'w3.s02');
    expect(
      contract.completionBodyText,
      startsWith(
        'World 3 trained Position Thinking through position-first choices and hand-bucket action frames.',
      ),
    );
    expect(contract.completionBodyText, contains('Next lesson ready: World 3'));
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
    expect(contract.completionBodyText, isNot(contains('Human QA')));
  });

  test('world4 chrome carries Bet Purpose Price payoff and safe progression', () {
    final contract = resolveSessionDrillRunnerProgressionChromeContractV1(
      const SessionDrillRunnerProgressionChromeInputV1(
        sessionId: 'w4.s01',
        stepLabel: 'Bet Purpose / Price',
        currentDrillIndex: 0,
        totalDrills: 1,
        drillId: 'price_given_before_action_intro',
      ),
    );

    expect(contract.titleText, 'World 4');
    expect(contract.nextSessionId, 'w4.s02');
    expect(
      contract.completionBodyText,
      startsWith(
        'World 4 trained Bet Purpose / Price by connecting why a bet is made, price, and action before the click.',
      ),
    );
    expect(contract.completionBodyText, contains('Next lesson ready: World 4'));
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
    expect(contract.completionBodyText, isNot(contains('Human QA')));
  });

  test('world5 chrome carries Board Awareness payoff and safe progression', () {
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
    expect(contract.nextSessionId, 'w5.s02');
    expect(
      contract.completionBodyText,
      startsWith(
        'World 5 trained Board Awareness by reading dry, wet, paired, connected, and shifting boards before action.',
      ),
    );
    expect(contract.completionBodyText, contains('Next lesson ready: World 5'));
    expect(contract.completionBodyText, contains('Session 2 of '));
    expect(
      contract.completionBodyText,
      isNot('Next lesson ready: World 5 \u00B7 Session 2 of 10.'),
    );
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
    expect(contract.completionBodyText, isNot(contains('Human QA')));
  });

  test('world6 chrome carries Range Thinking payoff and safe progression', () {
    final contract = resolveSessionDrillRunnerProgressionChromeContractV1(
      const SessionDrillRunnerProgressionChromeInputV1(
        sessionId: 'w6.s01',
        stepLabel: 'Range Thinking',
        currentDrillIndex: 0,
        totalDrills: 1,
        drillId: 'range_thinking_done',
      ),
    );

    expect(contract.titleText, 'World 6');
    expect(contract.nextSessionId, 'w6.s02');
    expect(
      contract.statusText,
      'World 6 \u00B7 Session 1 of 10 \u00B7 Range Thinking',
    );
    expect(
      contract.completionBodyText,
      startsWith(
        'World 6 trained Range Thinking by reading broad range buckets and range width before action.',
      ),
    );
    expect(contract.completionBodyText, contains('Next lesson ready: World 6'));
    expect(contract.completionBodyText.toLowerCase(), contains('buckets'));
    expect(contract.completionBodyText.toLowerCase(), contains('width'));
    expect(
      contract.completionBodyText,
      isNot('Next lesson ready: World 6 \u00B7 Session 2 of 10.'),
    );
    _expectNoW6ForbiddenStrategyTerms(contract.completionBodyText);
  });

  test('world6 final chrome keeps future route locked and claim safe', () {
    final contract = resolveSessionDrillRunnerProgressionChromeContractV1(
      const SessionDrillRunnerProgressionChromeInputV1(
        sessionId: 'w6.s10',
        stepLabel: 'Range Thinking',
        currentDrillIndex: 0,
        totalDrills: 1,
        drillId: 'range_thinking_final',
      ),
    );

    expect(contract.titleText, 'World 6');
    expect(contract.nextSessionId, isNull);
    expect(contract.hasNextSession, isFalse);
    expect(
      contract.completionBodyText,
      'World 6 completed Range Thinking: keep reading buckets and width before action. Future range topics stay locked for later.',
    );
    expect(contract.completionBodyText.toLowerCase(), contains('locked'));
    expect(contract.completionBodyText.toLowerCase(), contains('buckets'));
    expect(contract.completionBodyText.toLowerCase(), contains('width'));
    expect(contract.completionBodyText.toLowerCase(), isNot(contains('w7')));
    expect(
      contract.completionBodyText.toLowerCase(),
      isNot(contains('world 7')),
    );
    _expectNoW6ForbiddenStrategyTerms(contract.completionBodyText);
  });

  test('later world-session chrome still uses generic terminal copy', () {
    final contract = resolveSessionDrillRunnerProgressionChromeContractV1(
      const SessionDrillRunnerProgressionChromeInputV1(
        sessionId: 'w8.s10',
        stepLabel: 'Future Route',
        currentDrillIndex: 0,
        totalDrills: 1,
        drillId: 'future_route_final',
      ),
    );

    expect(contract.titleText, 'World 8');
    expect(contract.nextSessionId, isNull);
    expect(
      contract.completionBodyText,
      'Back to the map when you are ready for the next lesson.',
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
      'World 10 Cash Track \u00B7 Session 9 of 10 \u00B7 Board Texture',
    );
    expect(contract.nextSessionId, 'cash.s10');
    expect(
      contract.completionBodyText,
      'Next lesson ready: World 10 Cash Track \u00B7 Session 10 of 10.',
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

void _expectNoW6ForbiddenStrategyTerms(String value) {
  final lower = value.toLowerCase();
  for (final term in <String>[
    '8.0',
    '9.0',
    'advanced strategy',
    'blocker',
    'combo',
    'exploit',
    'frequency',
    'gto',
    'human qa',
    'launch',
    'opponent',
    'perfect counter',
    'polar',
    'solver',
    'stack',
    'tournament',
  ]) {
    expect(lower, isNot(contains(term)));
  }
}
