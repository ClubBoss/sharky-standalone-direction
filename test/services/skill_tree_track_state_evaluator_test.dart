import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/skill_tree_node_model.dart';
import 'package:poker_analyzer/services/skill_tree_builder_service.dart';
import 'package:poker_analyzer/services/skill_tree_track_progress_service.dart';
import 'package:poker_analyzer/services/skill_tree_track_state_evaluator.dart';

class _FakeProgressService extends SkillTreeTrackProgressService {
  final List<TrackProgressEntry> entries;
  _FakeProgressService(this.entries);

  @override
  Future<List<TrackProgressEntry>> getAllTrackProgress() async => entries;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const builder = SkillTreeBuilderService();

  SkillTreeNodeModel node(String id, String cat) =>
      SkillTreeNodeModel(id: id, title: id, category: cat);

  test('computes locked state when prerequisites missing', () async {
    final treeA = builder.build([node('a1', 'A']]).tree;
    final treeB = builder.build([node('b1', 'B']]).tree;

    final svc = SkillTreeTrackStateEvaluator(
      progressService: _FakeProgressService([
        TrackProgressEntry(
          tree: treeA,
          completionRate: 0.0,
          isCompleted: false,
        ),
        TrackProgressEntry(
          tree: treeB,
          completionRate: 0.0,
          isCompleted: false,
        ),
      ]),
      prerequisites: {
        'B': ['A'],
      },
    );

    final states = await svc.evaluateStates();
    final map = {
      for (final e in states)
        e.progress.tree.nodes.values.first.category: e.state,
    };
    expect(map['A'], SkillTreeTrackState.unlocked);
    expect(map['B'], SkillTreeTrackState.locked);
  });

  test('reports unlocked, inProgress and completed states', () async {
    final treeA = builder.build([node('a1', 'A']]).tree;
    final treeB = builder.build([node('b1', 'B']]).tree;
    final treeC = builder.build([node('c1', 'C']]).tree;

    final svc = SkillTreeTrackStateEvaluator(
      progressService: _FakeProgressService([
        TrackProgressEntry(tree: treeA, completionRate: 1.0, isCompleted: true),
        TrackProgressEntry(
          tree: treeB,
          completionRate: 0.3,
          isCompleted: false,
        ),
        TrackProgressEntry(
          tree: treeC,
          completionRate: 0.0,
          isCompleted: false,
        ),
      ]),
      prerequisites: {
        'B': ['A'],
      },
    );

    final states = await svc.evaluateStates();
    final map = {
      for (final e in states)
        e.progress.tree.nodes.values.first.category: e.state,
    };
    expect(map['A'], SkillTreeTrackState.completed);
    expect(map['B'], SkillTreeTrackState.inProgress);
    expect(map['C'], SkillTreeTrackState.unlocked);
  });
}
