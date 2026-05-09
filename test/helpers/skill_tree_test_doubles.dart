import 'dart:async';
import 'package:poker_analyzer/models/skill_tree_node_model.dart';
import 'package:poker_analyzer/services/targeted_pack_booster_engine.dart';

class TestOptionalNode extends SkillTreeNodeModel {
  final bool isOptional;
  const TestOptionalNode(String id)
    : isOptional = true,
      super(id: id, title: id, category: 'cat', level: 1);
}

class TestStreamDecayTracker implements SkillDecayTracker {
  final _c = StreamController<String>.broadcast();
  final Set<String> _decayed = <String>{};
  int calls = 0;
  void emit(String tag) {
    _decayed.add(tag);
    _c.add(tag);
  }

  @override
  Future<List<String>> getDecayedTags({required double threshold}) async {
    calls++;
    return _decayed.toList();
  }

  @override
  Stream<String> get onDecayStateChanged => _c.stream;

  void dispose() {
    _c.close();
  }
}
