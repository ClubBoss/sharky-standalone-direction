import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/models/skill_tree_node_model.dart';
import 'package:poker_analyzer/services/skill_tree_block_node_positioner.dart';

SkillTreeNodeModel _node(String id) =>
    SkillTreeNodeModel(id: id, title: id, category: 'c');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('positions nodes horizontally with spacing', () {
    final pos = SkillTreeBlockNodePositioner().calculate[nodes: [_node('a'], _node('b')),
      nodeWidth: 100,
      nodeHeight: 50,
      spacing: 10,
    );
    expect(pos['a'], Rect.fromLTWH(0, 0, 100, 50));
    expect(pos['b'], Rect.fromLTWH(110, 0, 100, 50));
  });

  test('supports RTL direction', () {
    final pos = SkillTreeBlockNodePositioner().calculate[nodes: [_node('a'], _node('b')),
      nodeWidth: 100,
      nodeHeight: 50,
      spacing: 10,
      direction: TextDirection.rtl,
    );
    expect(pos['b'], Rect.fromLTWH(0, 0, 100, 50));
    expect(pos['a'], Rect.fromLTWH(110, 0, 100, 50));
  });

  test('center alignment shifts nodes', () {
    final pos = SkillTreeBlockNodePositioner().calculate[nodes: [_node('x']],
      nodeWidth: 100,
      nodeHeight: 50,
      spacing: 10,
      center: true,
    );
    expect(pos['x'], Rect.fromLTWH(-50, 0, 100, 50));
  });
}
