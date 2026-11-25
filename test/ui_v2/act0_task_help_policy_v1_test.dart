import 'package:poker_analyzer/ui_v2/act0_shell/act0_task_help_policy_v1.dart';
import 'package:test/test.dart';

void main() {
  test(
    'task types select only calculators relevant to the quantitative task',
    () {
      final cases = <(String, String, Set<Act0TaskHelpToolV1>)>[
        ('What is a flop?', '', {}),
        ('What are pot odds?', '', {}),
        (
          'Calculate the winning chance against a range',
          'Your cards are AK.',
          {},
        ),
        ('How many chips did BB post?', '', {}), // Learn
        ('Which seat is BB?', 'The pot is 4 BB.', {}), // Recognition
        (
          'Call or fold?',
          'CO bets 10 into 20; wins 35% of the time.',
          {Act0TaskHelpToolV1.potOdds},
        ), // Decision
        ('Which size is half-pot?', 'Pot 6 BB.', {}), // Sizing
        ('Which hand wins?', 'Board has five cards.', {}), // Compare
        ('How many combos does AK have?', '', {}), // Counting
        (
          'How many chips is 2 BB?',
          '20 chips per BB.',
          {Act0TaskHelpToolV1.blindUnits},
        ), // Repair
        (
          'What chance breaks even if you call?',
          'Call 2 BB into 10 BB.',
          {Act0TaskHelpToolV1.potOdds},
        ), // Review
        (
          'What percentage do 9 clean outs hit on the turn?',
          '',
          {Act0TaskHelpToolV1.outs},
        ), // Transfer
        (
          'What chance do 8 outs give compared with the call price?',
          '',
          {Act0TaskHelpToolV1.outs, Act0TaskHelpToolV1.potOdds},
        ),
        (
          'How many outs make a flush?',
          '',
          {},
        ), // Counting cards, not probability
        (
          'What is the chance with 7 clean outs?',
          'SB shows 9d 9c.',
          {},
        ), // Known opponent
      ];
      for (final (question, context, tools) in cases) {
        expect(
          act0TaskHelpToolsV1(question: question, context: context),
          tools,
          reason: question,
        );
      }
    },
  );
  test('definition recall is not supplied as an answer', () {
    expect(act0TaskHelpTestsDefinitionV1('What is an out?'), isTrue);
    expect(
      act0TaskHelpTestsDefinitionV1('How many combos does AK have?'),
      isTrue,
    );
    expect(
      act0TaskHelpToolsV1(
        question: 'What percentage do 9 outs hit?',
        context: '',
        canDraw: false,
      ),
      isEmpty,
    );
    expect(
      act0TaskHelpToolsV1(
        question: 'What percentage do 9 outs hit?',
        context: '',
        hasExposedOpponentCards: true,
      ),
      isEmpty,
    );
    expect(act0TaskHelpTestsDefinitionV1('Which street comes next?'), isTrue);
    expect(act0TaskHelpTestsDefinitionV1('Call or fold?'), isFalse);
  });
}
