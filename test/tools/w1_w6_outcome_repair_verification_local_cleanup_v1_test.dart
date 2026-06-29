import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('W1 seat-role feedback explains the selected role', () {
    final tasks = _tasks(
      'test/fixtures/content_factory_mvp/'
      'w1_seat_role_orientation_migration_pr2_v1.json',
    );

    const expectedCopyByAction = <String, String>{
      'btn': 'The Button is the seat marked BTN.',
      'sb': 'The small blind is the seat marked SB.',
      'bb': 'The big blind is the seat marked BB.',
    };

    for (final task in tasks) {
      final action = task['correct_action']! as String;
      expect(
        task['feedback_reason'],
        contains(expectedCopyByAction[action]),
        reason: task['task_id']! as String,
      );
    }
  });

  test('W2 approved-raise learner copy avoids trigger jargon', () {
    final learnerCopy = [
      _feedbackText(
        'test/fixtures/content_factory_mvp/'
        'w2_approved_raise_discipline_canonical_pr3_v1.json',
      ),
      File(
        'content/worlds/world2/v1/sessions/w2.s03/drills/'
        'd.choose_raise_to_facing_bet.json',
      ).readAsStringSync(),
    ].join('\n').toLowerCase();

    expect(learnerCopy, isNot(matches(RegExp(r'\btrigger\b'))));
    expect(learnerCopy, contains('clear approved raise spot'));
  });

  test('W5 river learner copy names the final river card plainly', () {
    final sourceDir = Directory('content/worlds/world5/v1/sessions/w5.s05');
    final sourceCopy = sourceDir
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) => file.path.endsWith('.json') || file.path.endsWith('.md'),
        )
        .map((file) => file.readAsStringSync())
        .join('\n');
    final fixtureCopy = _feedbackText(
      'test/fixtures/content_factory_mvp/'
      'w5_board_shift_awareness_canonical_pr2_v1.json',
    );
    final learnerCopy = '$sourceCopy\n$fixtureCopy'.toLowerCase();

    expect(learnerCopy, isNot(contains('river closure')));
    expect(learnerCopy, contains('final river card'));
  });
}

List<Map<String, Object?>> _tasks(String path) {
  final fixture = (jsonDecode(File(path).readAsStringSync()) as Map)
      .cast<String, Object?>();
  return (fixture['tasks']! as List).cast<Map<String, Object?>>();
}

String _feedbackText(String path) =>
    _tasks(path).map((task) => task['feedback_reason']).join('\n');
