import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _expandedRoot = 'content_adaptive_expanded';
const String _fusionRoot = 'content_skill_fusion';

class SkillFusionChallengesService {
  Future<SkillFusionResult> generateChallenges() async {
    final packs = await _scanExpandedPacks();
    final topics = packs.where((pack) => pack.evUplift >= 1.09).toList();
    final coverage = packs.isEmpty
        ? 0.0
        : (topics.length / packs.length).clamp(0, 1).toDouble();

    final challenges = <FusionChallenge>[];
    final random = Random(0);

    for (var i = 0; i < topics.length; i += 2) {
      final first = topics[i];
      final second = topics[(i + 1) % topics.length];
      final third = topics.length > 2 ? topics[(i + 2) % topics.length] : null;
      final skillSet = {
        first.topic,
        second.topic,
        if (third != null) third.topic,
      };
      final evScore =
          (first.evUplift +
              second.evUplift +
              (third?.evUplift ?? first.evUplift)) /
          skillSet.length;
      final difficultyMix =
          ((first.difficulty + second.difficulty + (third?.difficulty ?? 0)) /
                  skillSet.length)
              .clamp(0, 1)
              .toDouble();
      final localizedTitle = _localizedTitle(skillSet);

      final challenge = FusionChallenge(
        skills: skillSet.toList(),
        evScore: evScore,
        difficultyMix: difficultyMix,
        localizedTitle: localizedTitle,
      );
      challenges.add(challenge);
      await _writeChallenge(challenge, random.nextInt(999999));
    }

    final averageEv = challenges.isEmpty
        ? 1.0
        : challenges.map((c) => c.evScore).reduce((a, b) => a + b) /
              challenges.length;

    return SkillFusionResult(
      challenges: challenges,
      averageEv: averageEv,
      coverageRatio: coverage,
    );
  }

  Future<List<_ExpandedPack>> _scanExpandedPacks() async {
    final root = Directory(_expandedRoot);
    if (!await root.exists()) return const [];
    final packs = <_ExpandedPack>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.jsonl')) continue;
      final pathSegments = entity.uri.pathSegments;
      final idx = pathSegments.indexOf('content_adaptive_expanded');
      if (idx < 0 || idx + 1 >= pathSegments.length) continue;
      final topic = pathSegments[idx + 1];
      final lines = await entity.readAsLines();
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final decoded = json.decode(line);
          if (decoded is Map<String, Object?>) {
            final ev = (decoded['ev_score'] as num?)?.toDouble() ?? 1.0;
            final difficulty =
                (decoded['difficulty'] as num?)?.toDouble() ?? 0.5;
            packs.add(
              _ExpandedPack(topic: topic, evUplift: ev, difficulty: difficulty),
            );
          }
        } catch (_) {
          continue;
        }
      }
    }
    return packs;
  }

  Future<void> _writeChallenge(FusionChallenge challenge, int seed) async {
    final dir = Directory('$_fusionRoot/${challenge.skills.first}/v1');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File('${dir.path}/challenges.jsonl');
    final payload = {
      'id': 'fusion_${seed}_${challenge.skills.hashCode}',
      'skills': challenge.skills,
      'difficulty_mix': challenge.difficultyMix,
      'ev_score': double.parse(challenge.evScore.toStringAsFixed(4)),
      'title': challenge.localizedTitle,
      'generated': DateTime.now().toIso8601String(),
    };
    await file.writeAsString('${jsonEncode(payload)}\n', mode: FileMode.append);
  }

  String _localizedTitle(Set<String> skills) {
    final base = skills.map(_titleCase).join(' & ');
    return '$base Challenge';
  }

  String _titleCase(String value) {
    return value
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class SkillFusionResult {
  const SkillFusionResult({
    required this.challenges,
    required this.averageEv,
    required this.coverageRatio,
  });

  final List<FusionChallenge> challenges;
  final double averageEv;
  final double coverageRatio;
}

class FusionChallenge {
  const FusionChallenge({
    required this.skills,
    required this.evScore,
    required this.difficultyMix,
    required this.localizedTitle,
  });

  final List<String> skills;
  final double evScore;
  final double difficultyMix;
  final String localizedTitle;
}

class _ExpandedPack {
  const _ExpandedPack({
    required this.topic,
    required this.evUplift,
    required this.difficulty,
  });

  final String topic;
  final double evUplift;
  final double difficulty;
}
