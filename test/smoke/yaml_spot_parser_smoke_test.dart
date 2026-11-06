@TestOn('vm')
import 'package:test/test.dart';

import 'package:yaml/yaml.dart';
import 'package:poker_analyzer/models/v2/training_pack_template.dart';
import 'package:poker_analyzer/utils/yaml_utils.dart';

const _yaml = '''
id: t_pack_2
name: Simple
level: beginner
type: theory
tags: [preflop]
spots: []
''';

void main() {
  test('YAML → model → JSON (smoke)', () {
    final map = Map<String, dynamic>.from(yamlToDart(loadYaml(_yaml)) as Map);
    final model = TrainingPackTemplate.fromJson(map);
    expect(model.id, 't_pack_2');
    expect(model.tags, contains('preflop'));
    expect(model.spots, isEmpty);
  });
}
