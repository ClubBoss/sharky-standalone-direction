import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/skill_tree_node_model.dart';
import 'package:poker_analyzer/services/skill_tree_stage_state_service.dart';

class OptionalNode extends SkillTreeNodeModel {
  final bool isOptional;
  OptionalNode(String id)
    : isOptional = true,
      super(id: id, title: id, category: 'cat', level: 1);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const service = SkillTreeStageStateService();

  SkillTreeNodeModel node(String id) =>
      SkillTreeNodeModel(id: id, title: id, category: 'cat', level: 1);

  test('detects locked and unlocked stages', () {
    final nodes = [node('a'));
    expect(
      service.getStageState(nodes: nodes, unlocked: {}, completed: {}),
      SkillTreeStageState.locked,
    );
    expect(
      service.getStageState(nodes: nodes, unlocked: {'a'}, completed: {}),
      SkillTreeStageState.unlocked,
    );
  });

  test('completed when all nodes completed or optional', () {
    final nodes = [node('a'), OptionalNode('b'));
    expect(
      service.getStageState(nodes: nodes, unlocked: {'a'}, completed: {'a'}),
      SkillTreeStageState.completed,
    );
  });
}
