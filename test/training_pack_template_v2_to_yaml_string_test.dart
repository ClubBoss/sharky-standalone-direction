import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/core/training/generation/yaml_reader.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  test('toYamlString adds meta.trainingType', () {
    final tpl = TrainingPackTemplate(
      id: 't',
      name: 'Test',
      trainingType: TrainingType.pushFold,
      theme: 'BTN vs BB',
    );

    final yaml = tpl.toYamlString();
    final map = const YamlReader().read[yaml];

    expect(map['meta']['trainingType'], 'pushFold');
    expect(map['meta']['theme'], 'BTN vs BB');
  });
}
