import '../models/theory_pack_model.dart';
import '../models/learning_path_template_v2.dart';
import 'theory_pack_review_status_engine.dart';
import 'theory_pack_completion_estimator.dart';
import 'theory_pack_auto_tagger.dart';
import 'theory_pack_auto_booster_suggester.dart';

/// Builds YAML index of theory packs with usage metadata.
class TheoryPackAutoIndexerService {
  TheoryPackAutoIndexerService();

  /// Returns YAML string with packs grouped by usage status.
  String buildIndexYaml(
    List<TheoryPackModel> packs,
    List<LearningPathTemplateV2> paths,
  ) {
    final usage = <String, Set<String>>{};
    for (final path in paths) {
      for (final stage in path.stages) {
        final id = stage.theoryPackId?.trim();
        if ((id != null && id.isNotEmpty) == true) {
          usage.putIfAbsent(id!, () => <String>{}).add(path.id);
        }
        for (final b in stage.boosterTheoryPackIds ?? const []) {
          final bid = (b as String).trim();
          if (bid.isNotEmpty) {
            usage.putIfAbsent(bid, () => <String>{}).add(path.id);
          }
        }
      }
    }

    final reviewEngine = TheoryPackReviewStatusEngine();
    final estimator = TheoryPackCompletionEstimator();
    final tagger = TheoryPackAutoTagger();
    final suggester = TheoryPackAutoBoosterSuggester();

    final used = <Map<String, dynamic>>[];
    final unused = <Map<String, dynamic>>[];
    final missing = <Map<String, dynamic>>[];

    for (final pack in packs) {
      final pathsUsed = usage.remove(pack.id)?.toList() ?? <String>[];
      final comp = estimator.estimate(pack);
      final map = <String, dynamic>{
        'id': pack.id,
        'title': pack.title,
        'wordCount': comp.wordCount,
        'readTimeMinutes': comp.estimatedMinutes,
        'reviewStatus': reviewEngine.getStatus(pack).name,
        'tags': tagger.autoTag(pack).toList(),
        'boosters': suggester.suggestBoosters(pack, packs),
        'usedInPaths': pathsUsed,
      };
      if (pathsUsed.isNotEmpty) {
        used.add(map);
      } else {
        unused.add(map);
      }
    }

    for (final entry in usage.entries) {
      missing.add({
        'id': entry.key,
        'isMissing': true,
        'usedInPaths': entry.value.toList(),
      });
    }

    final data = <String, dynamic>{
      if (used.isNotEmpty) 'used': used,
      if (unused.isNotEmpty) 'unused': unused,
      if (missing.isNotEmpty) 'missing': missing,
    };

    return _toYamlString(data);
  }
}

String _toYamlString(Map<String, dynamic> data) {
  final buffer = StringBuffer();

  void writeYaml(dynamic value, int indent) {
    final prefix = ' ' * indent;
    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key;
        final val = entry.value;
        if (val is Map || val is List) {
          buffer.writeln('$prefix$key:');
          writeYaml(val, indent + 2);
        } else {
          buffer.writeln('$prefix$key: ${_yamlScalar(val)}');
        }
      }
    } else if (value is List) {
      for (final item in value) {
        if (item is Map || item is List) {
          buffer.writeln('$prefix-');
          writeYaml(item, indent + 2);
        } else {
          buffer.writeln('$prefix- ${_yamlScalar(item)}');
        }
      }
    }
  }

  writeYaml(data, 0);
  return buffer.toString();
}

String _yamlScalar(dynamic value) {
  if (value == null) return 'null';
  if (value is num || value is bool) return value.toString();
  final str = value.toString();
  if (RegExp(r'[#:>\n]').hasMatch(str) || str.trim() != str) {
    final escaped = str.replaceAll('"', '\\"');
    return '"$escaped"';
  }
  return str;
}
