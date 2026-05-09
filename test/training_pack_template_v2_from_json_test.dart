import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;

void main() {
  test('fromJson parses metadata fields', () {
    final tpl = TrainingPackTemplate.fromJson({
      'id': 't',
      'name': 'Test',
      'trainingType': 'pushFold',
      'tags': ['a', 'b'],
      'goal': 'Learn',
      'audience': 'Beginners',
      'meta': {'x': 1, 'theme': 'BTN vs BB'},
    });
    expect(tpl.tags, ['a', 'b']);
    expect(tpl.category, 'a');
    expect(tpl.goal, 'Learn');
    expect(tpl.audience, 'Beginners');
    expect(tpl.meta['x'], 1);
    expect(tpl.theme, 'BTN vs BB');
  });

  test('category falls back to first tag', () {
    final tpl = TrainingPackTemplate.fromJson({
      'id': 'x',
      'name': 'X',
      'trainingType': 'pushFold',
      'tags': ['m'],
    });
    expect(tpl.category, 'm');
  });
}
