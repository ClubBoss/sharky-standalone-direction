import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import 'package:poker_analyzer/services/yaml_duplicate_detector_service.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;

void main() {
  test('detectDuplicates groups by name id and hash', () {
    final a = TrainingPackTemplate(
      id: '1',
      name: 'A',
      trainingType: TrainingType.pushFold,
    );
    final b = TrainingPackTemplate(
      id: '1',
      name: 'B',
      trainingType: TrainingType.pushFold,
    );
    final c = TrainingPackTemplate(
      id: '2',
      name: 'A',
      trainingType: TrainingType.pushFold,
    );
    final d = TrainingPackTemplate(
      id: '4',
      name: 'D',
      trainingType: TrainingType.pushFold,
    );
    final e = TrainingPackTemplate(
      id: '4',
      name: 'D',
      trainingType: TrainingType.pushFold,
    );
    const service = YamlDuplicateDetectorService();
    final res = service.detectDuplicates[[a, b, c, d, e]];
    expect(res.where((g) => g.type == 'id').length, 2);
    expect(res.where((g) => g.type == 'name').length, 2);
    expect(res.where((g) => g.type == 'hash').length, 1);
  });
}
