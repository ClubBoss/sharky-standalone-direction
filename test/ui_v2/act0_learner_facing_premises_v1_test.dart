import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

List<String> _words(String s) =>
    (s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList()..sort());

void main() {
  test('decision facts first, setup sentence last', () {
    const caption =
        'For this example, all six start with 100 BB before the 0.5/1 BB '
        'blinds; no ante, straddle or rake. UTG, HJ and CO fold. '
        'The pot is 4.5 BB.';
    expect(
      act0LearnerFacingPremisesV1(caption),
      'UTG, HJ and CO fold. The pot is 4.5 BB. For this example, all six '
      'start with 100 BB before the 0.5/1 BB blinds; no ante, straddle or '
      'rake.',
    );
  });

  test('captions without the setup sentence are unchanged', () {
    expect(
      act0LearnerFacingPremisesV1('HJ bets and your hand is weak.'),
      'HJ bets and your hand is weak.',
    );
  });

  test('every catalogue caption keeps all of its words', () {
    final tasks = Act0ShellStateV1.sample.worlds
        .expand((w) => w.lessons)
        .expand((l) => l.taskList);
    for (final t in tasks) {
      expect(
        _words(act0LearnerFacingPremisesV1(t.runner.caption)),
        _words(t.runner.caption),
        reason: t.taskId,
      );
    }
  });
}
