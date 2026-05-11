import 'package:test/test.dart';

import '../../tools/why_v1_ssot_v1.dart';

void main() {
  test('accepts valid why_v1 text', () {
    expect(
      isRuntimeValidWhyV1V1('Raise now to build value before draws realize.'),
      isTrue,
    );
  });

  test('rejects placeholder/default why_v1 text', () {
    expect(isRuntimeValidWhyV1V1('TODO'), isFalse);
    expect(isRuntimeValidWhyV1V1('TBD explanation'), isFalse);
    expect(isRuntimeValidWhyV1V1('placeholder'), isFalse);
    expect(isRuntimeValidWhyV1V1('lorem ipsum'), isFalse);
    expect(isRuntimeValidWhyV1V1('n/a'), isFalse);
  });

  test('feedback label mismatch fence is deterministic', () {
    expect(
      hasFeedbackLabelMismatchV1(
        feedbackCorrectV1: 'Correct. Keep pressure.',
        feedbackIncorrectV1: 'Incorrect. This line is too loose.',
      ),
      isFalse,
    );
    expect(
      hasFeedbackLabelMismatchV1(
        feedbackCorrectV1: 'Incorrect. Nice choice.',
        feedbackIncorrectV1: 'Try again.',
      ),
      isTrue,
    );
    expect(
      hasFeedbackLabelMismatchV1(
        feedbackCorrectV1: 'Good job.',
        feedbackIncorrectV1: 'Correct. Try again.',
      ),
      isTrue,
    );
  });

  test('primary-correct contradiction fence is deterministic', () {
    expect(
      hasPrimaryCorrectContradictionV1(
        'Correct. Legal, but worse than our recommended play.',
      ),
      isTrue,
    );
    expect(
      hasPrimaryCorrectContradictionV1(
        'Correct. Legal, but worse than recommended play.',
      ),
      isFalse,
    );
    expect(
      hasPrimaryCorrectContradictionV1(
        'Correct. Raise is expected in this value spot.',
      ),
      isFalse,
    );
  });

  test('generic acceptable feedback fence is deterministic', () {
    expect(
      hasGenericAcceptableFeedbackV1(
        'Acceptable. Legal, but worse than our recommended play.',
      ),
      isTrue,
    );
    expect(
      hasGenericAcceptableFeedbackV1('Acceptable. This is legal but weaker.'),
      isTrue,
    );
    expect(
      hasGenericAcceptableFeedbackV1(
        'Acceptable. Calling keeps the hand in play, but raising wins more by isolating weaker continues right away.',
      ),
      isFalse,
    );
    expect(
      hasGenericAcceptableFeedbackV1(
        'Calling keeps the hand in play, but raising wins more by isolating weaker continues right away.',
      ),
      isTrue,
    );
  });

  test('generic incorrect feedback fence is deterministic', () {
    expect(hasGenericIncorrectFeedbackV1('Incorrect.'), isTrue);
    expect(hasGenericIncorrectFeedbackV1('Incorrect. Try again.'), isTrue);
    expect(
      hasGenericIncorrectFeedbackV1(
        'Incorrect. A passive response just absorbs pressure here, while raising pushes back now and applies the stronger counter.',
      ),
      isFalse,
    );
    expect(
      hasGenericIncorrectFeedbackV1(
        'A passive response just absorbs pressure here, while raising pushes back now and applies the stronger counter.',
      ),
      isTrue,
    );
  });

  test('session TODO placeholder fence is deterministic', () {
    expect(
      hasSessionTodoPlaceholderLeakV1('# Session w1.s01\n\n## Objective\nTODO'),
      isTrue,
    );
    expect(
      hasSessionTodoPlaceholderLeakV1(
        '# Session w1.s01\n\n## Objective\nUse the drill sequence for this spot.',
      ),
      isFalse,
    );
  });

  test('prompt answer leak fence is deterministic', () {
    expect(
      hasPromptAnswerLeakV1(
        'After turn anchor is set, choose the expected action.',
      ),
      isTrue,
    );
    expect(
      hasPromptAnswerLeakV1(
        'Trap: ICM can punish aggression, but this proxy asks for raise.',
      ),
      isTrue,
    );
    expect(
      hasPromptAnswerLeakV1(
        'After turn anchor is set, choose the best next action.',
      ),
      isFalse,
    );
    expect(
      hasPromptAnswerLeakV1('Trap line remains, but Tap raise to continue.'),
      isTrue,
    );
    expect(
      hasPromptAnswerLeakV1('Use context only, then tap your chosen action.'),
      isFalse,
    );
    expect(hasPromptAnswerLeakV1('In this spot, choose raise.'), isTrue);
    expect(hasPromptAnswerLeakV1('In this cash spot, choose raise.'), isTrue);
    expect(
      hasPromptAnswerLeakV1('In this spot, choose the best action.'),
      isFalse,
    );
    expect(
      hasPromptAnswerLeakV1('In this cash spot, choose the best action.'),
      isFalse,
    );
    expect(
      hasPromptAnswerLeakV1('When the second cue appears, choose raise.'),
      isTrue,
    );
    expect(
      hasPromptAnswerLeakV1(
        'When the second cue appears, choose the best action.',
      ),
      isFalse,
    );
    expect(
      hasPromptAnswerLeakV1('When the third cue appears, choose call.'),
      isTrue,
    );
    expect(
      hasPromptAnswerLeakV1(
        'When the third cue appears, choose the best action.',
      ),
      isFalse,
    );
    expect(hasPromptAnswerLeakV1('Range-first proxy: choose raise.'), isTrue);
    expect(
      hasPromptAnswerLeakV1(
        'Range-first proxy: choose the best action for this node.',
      ),
      isFalse,
    );
  });

  test('direct choose-action prompt leak fence is deterministic', () {
    expect(hasDirectChooseActionPromptLeakV1('Choose raise.'), isTrue);
    expect(hasDirectChooseActionPromptLeakV1('Choose call'), isTrue);
    expect(
      hasDirectChooseActionPromptLeakV1('Choose the best action.'),
      isFalse,
    );
    expect(
      hasDirectChooseActionPromptLeakV1('In this spot, choose raise.'),
      isFalse,
    );
  });

  test('action focus cue leak fence is deterministic', () {
    expect(
      hasActionFocusCueLeakV1('Choose the best action. Focus: raise.'),
      isTrue,
    );
    expect(
      hasActionFocusCueLeakV1('Choose the best action. Focus: call'),
      isTrue,
    );
    expect(hasActionFocusCueLeakV1('Think it through. Focus: jam'), isTrue);
    expect(hasActionFocusCueLeakV1('Think it through. Focus: all-in'), isTrue);
    expect(hasActionFocusCueLeakV1('Choose the best action.'), isFalse);
    expect(
      hasActionFocusCueLeakV1('Choose the best action. Use board and chips.'),
      isFalse,
    );
  });
}
