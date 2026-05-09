import 'dart:convert';
import 'dart:io';

enum FeedbackAuditSeverityV1 {
  releaseBlocking('release-blocking', 3),
  mediumDebt('medium-debt', 2),
  laterSophisticationCandidate('later-sophistication-candidate', 1);

  const FeedbackAuditSeverityV1(this.label, this.rank);

  final String label;
  final int rank;
}

class FeedbackAuditFindingV1 {
  const FeedbackAuditFindingV1({
    required this.severity,
    required this.issueType,
    required this.worldId,
    required this.familyPath,
    required this.filePath,
    required this.referenceLabel,
    required this.feedback,
    required this.normalizedFeedback,
  });

  final FeedbackAuditSeverityV1 severity;
  final String issueType;
  final int worldId;
  final String familyPath;
  final String filePath;
  final String referenceLabel;
  final String feedback;
  final String normalizedFeedback;
}

class FeedbackAuditFamilySummaryV1 {
  const FeedbackAuditFamilySummaryV1({
    required this.familyPath,
    required this.worldId,
    required this.highestSeverity,
    required this.findings,
    required this.repeatedWeakCloneCount,
    required this.rankScore,
  });

  final String familyPath;
  final int worldId;
  final FeedbackAuditSeverityV1 highestSeverity;
  final List<FeedbackAuditFindingV1> findings;
  final int repeatedWeakCloneCount;
  final int rankScore;
}

class FeedbackAuditCloneSummaryV1 {
  const FeedbackAuditCloneSummaryV1({
    required this.feedback,
    required this.normalizedFeedback,
    required this.severity,
    required this.occurrenceCount,
    required this.familyPaths,
  });

  final String feedback;
  final String normalizedFeedback;
  final FeedbackAuditSeverityV1 severity;
  final int occurrenceCount;
  final List<String> familyPaths;
}

class FeedbackQualityAuditReportV1 {
  const FeedbackQualityAuditReportV1({
    required this.filesChecked,
    required this.findings,
    required this.families,
    required this.clones,
  });

  final int filesChecked;
  final List<FeedbackAuditFindingV1> findings;
  final List<FeedbackAuditFamilySummaryV1> families;
  final List<FeedbackAuditCloneSummaryV1> clones;
}

const Set<String> _kFeedbackFamilyRootsV1 = <String>{
  'content/worlds/world0/v1/sessions',
  'content/worlds/world1/v1/sessions',
  'content/worlds/world2/v1/sessions',
  'content/worlds/world3/v1/sessions',
  'content/worlds/world4/v1/sessions',
  'content/worlds/world5/v1/sessions',
  'content/worlds/world6/v1/sessions',
  'content/worlds/world7/v1/sessions',
  'content/worlds/world8/v1/sessions',
  'content/worlds/world9/v1/sessions',
  'content/worlds/world10/v1/sessions',
  'content/worlds/world10/v1/tracks/cash/sessions',
  'content/worlds/world10/v1/tracks/tournament/sessions',
  'content/worlds/world10/v1/tracks/mixed/sessions',
};

final RegExp _kBareIncorrectV1 = RegExp(
  r'^incorrect\.?$',
  caseSensitive: false,
);
final RegExp _kPlaceholderFeedbackV1 = RegExp(
  r'\b(todo|tbd|placeholder|lorem|stub)\b',
  caseSensitive: false,
);
final RegExp _kGenericTemplateV1 = RegExp(
  r'^(incorrect\.\s*)?(this|that)\s+.+\b(expects|should|must)\b.+$',
  caseSensitive: false,
);
final RegExp _kGenericAnchorV1 = RegExp(
  r'^(incorrect\.\s*)?(find|identify|set|lock|tap)\b.+\b(first|before action)\.?$',
  caseSensitive: false,
);
final RegExp _kGenericActionTailV1 = RegExp(
  r'\b(expects|should|must)\s+(raise|call|fold|bet|check|bluff|release|hero|villain|board_plays)\b',
  caseSensitive: false,
);
final RegExp _kCollapseWhitespaceV1 = RegExp(r'\s+');
final RegExp _kSentenceTrimPrefixV1 = RegExp(
  r'^incorrect\.\s*',
  caseSensitive: false,
);

void main(List<String> args) {
  if (args.isNotEmpty) {
    stderr.writeln(
      'feedback_quality_audit_v1: no arguments supported (deterministic scan only)',
    );
    exitCode = 64;
    return;
  }

  final report = buildFeedbackQualityAuditReportV1();
  stdout.write(renderFeedbackQualityAuditReportV1(report));
  exitCode = 0;
}

FeedbackQualityAuditReportV1 buildFeedbackQualityAuditReportV1({
  String rootPath = '.',
}) {
  final findings = <FeedbackAuditFindingV1>[];
  var filesChecked = 0;

  final roots = _kFeedbackFamilyRootsV1
      .map((relative) => Directory(_joinRootV1(rootPath, relative)))
      .where((directory) => directory.existsSync())
      .toList(growable: false);

  for (final root in roots) {
    final files =
        root
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .where((file) => file.path.contains('/drills/'))
            .toList(growable: false)
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      filesChecked++;
      findings.addAll(_scanFeedbackFileV1(file, rootPath: rootPath));
    }
  }

  final repeatedCloneCounts = _buildRepeatedCloneCountsV1(findings);
  final families = _buildFamilySummariesV1(findings, repeatedCloneCounts);
  final clones = _buildCloneSummariesV1(findings);

  return FeedbackQualityAuditReportV1(
    filesChecked: filesChecked,
    findings: findings,
    families: families,
    clones: clones,
  );
}

String renderFeedbackQualityAuditReportV1(FeedbackQualityAuditReportV1 report) {
  final buffer = StringBuffer()
    ..writeln('FEEDBACK_QUALITY_AUDIT_V1')
    ..writeln('FILES_CHECKED\t${report.filesChecked}')
    ..writeln('TOTAL_FINDINGS\t${report.findings.length}')
    ..writeln(
      'SEVERITY_TOTALS\t'
      'release-blocking=${report.findings.where((item) => item.severity == FeedbackAuditSeverityV1.releaseBlocking).length}\t'
      'medium-debt=${report.findings.where((item) => item.severity == FeedbackAuditSeverityV1.mediumDebt).length}\t'
      'later-sophistication-candidate=${report.findings.where((item) => item.severity == FeedbackAuditSeverityV1.laterSophisticationCandidate).length}',
    );

  buffer.writeln();
  buffer.writeln('RANKED_FAMILIES');
  if (report.families.isEmpty) {
    buffer.writeln('STATUS\tOK');
  } else {
    for (final family in report.families) {
      buffer.writeln(
        'FAMILY\t${family.highestSeverity.label}\tworld${family.worldId}\t'
        '${family.familyPath}\tfindings=${family.findings.length}\t'
        'repeated_weak_clones=${family.repeatedWeakCloneCount}\trank_score=${family.rankScore}',
      );
      for (final finding in family.findings.take(3)) {
        buffer.writeln(
          '  FINDING\t${finding.severity.label}\t${finding.issueType}\t${finding.referenceLabel}\t${finding.feedback}',
        );
      }
    }
  }

  buffer.writeln();
  buffer.writeln('REPEATED_WEAK_CLONES');
  if (report.clones.isEmpty) {
    buffer.writeln('STATUS\tOK');
  } else {
    for (final clone in report.clones) {
      buffer.writeln(
        'CLONE\t${clone.severity.label}\toccurrences=${clone.occurrenceCount}\tfamilies=${clone.familyPaths.length}\t${clone.feedback}',
      );
      for (final familyPath in clone.familyPaths.take(5)) {
        buffer.writeln('  FAMILY\t$familyPath');
      }
    }
  }

  return buffer.toString();
}

List<FeedbackAuditFindingV1> _scanFeedbackFileV1(
  File file, {
  required String rootPath,
}) {
  final content = file.readAsStringSync();
  final decoded = jsonDecode(content);
  if (decoded is! Map<String, Object?>) {
    return const <FeedbackAuditFindingV1>[];
  }

  final findings = <FeedbackAuditFindingV1>[];
  final relPath = _normalizePathV1(file.path, rootPath: rootPath);
  final worldId = _worldIdFromPathV1(relPath);
  if (worldId == null) {
    return const <FeedbackAuditFindingV1>[];
  }
  final familyPath = _familyPathFromFileV1(relPath);

  final drillFeedback = _readNonEmptyStringV1(decoded['feedback_incorrect_v1']);
  if (drillFeedback != null) {
    final finding = _classifyFeedbackV1(
      feedback: drillFeedback,
      worldId: worldId,
      familyPath: familyPath,
      filePath: relPath,
      referenceLabel: relPath,
    );
    if (finding != null) {
      findings.add(finding);
    }
  }

  if (decoded['kind'] == 'hand_chain_v1' && decoded['steps'] is List) {
    final steps = decoded['steps'] as List<dynamic>;
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (step is! Map<String, Object?>) {
        continue;
      }
      final stepFeedback = _readNonEmptyStringV1(step['feedback_incorrect_v1']);
      if (stepFeedback == null) {
        continue;
      }
      final finding = _classifyFeedbackV1(
        feedback: stepFeedback,
        worldId: worldId,
        familyPath: familyPath,
        filePath: relPath,
        referenceLabel: '$relPath#step${i + 1}',
      );
      if (finding != null) {
        findings.add(finding);
      }
    }
  }

  return findings;
}

FeedbackAuditFindingV1? _classifyFeedbackV1({
  required String feedback,
  required int worldId,
  required String familyPath,
  required String filePath,
  required String referenceLabel,
}) {
  final normalized = _normalizeFeedbackV1(feedback);
  if (normalized.isEmpty) {
    return null;
  }

  if (_kPlaceholderFeedbackV1.hasMatch(normalized)) {
    return FeedbackAuditFindingV1(
      severity: FeedbackAuditSeverityV1.releaseBlocking,
      issueType: 'placeholder_like_feedback',
      worldId: worldId,
      familyPath: familyPath,
      filePath: filePath,
      referenceLabel: referenceLabel,
      feedback: feedback,
      normalizedFeedback: normalized,
    );
  }

  if (_kBareIncorrectV1.hasMatch(normalized)) {
    return FeedbackAuditFindingV1(
      severity: FeedbackAuditSeverityV1.releaseBlocking,
      issueType: 'bare_incorrect_feedback',
      worldId: worldId,
      familyPath: familyPath,
      filePath: filePath,
      referenceLabel: referenceLabel,
      feedback: feedback,
      normalizedFeedback: normalized,
    );
  }

  final stripped = normalized.replaceFirst(_kSentenceTrimPrefixV1, '').trim();
  final wordCount = stripped.isEmpty
      ? 0
      : stripped.split(' ').where((word) => word.isNotEmpty).length;
  final isShort = wordCount > 0 && wordCount <= 7;
  final looksGeneric =
      _kGenericAnchorV1.hasMatch(normalized) ||
      (_kGenericTemplateV1.hasMatch(normalized) &&
          (_kGenericActionTailV1.hasMatch(normalized) || isShort));

  if (looksGeneric) {
    return FeedbackAuditFindingV1(
      severity: FeedbackAuditSeverityV1.mediumDebt,
      issueType: 'generic_template_feedback',
      worldId: worldId,
      familyPath: familyPath,
      filePath: filePath,
      referenceLabel: referenceLabel,
      feedback: feedback,
      normalizedFeedback: normalized,
    );
  }

  if (isShort) {
    return FeedbackAuditFindingV1(
      severity: FeedbackAuditSeverityV1.laterSophisticationCandidate,
      issueType: 'suspiciously_short_feedback',
      worldId: worldId,
      familyPath: familyPath,
      filePath: filePath,
      referenceLabel: referenceLabel,
      feedback: feedback,
      normalizedFeedback: normalized,
    );
  }

  return null;
}

Map<String, int> _buildRepeatedCloneCountsV1(
  List<FeedbackAuditFindingV1> findings,
) {
  final familySets = <String, Set<String>>{};
  for (final finding in findings) {
    familySets
        .putIfAbsent(finding.normalizedFeedback, () => <String>{})
        .add(finding.familyPath);
  }

  final cloneCounts = <String, int>{};
  for (final entry in familySets.entries) {
    if (entry.value.length >= 2) {
      cloneCounts[entry.key] = entry.value.length;
    }
  }
  return cloneCounts;
}

List<FeedbackAuditFamilySummaryV1> _buildFamilySummariesV1(
  List<FeedbackAuditFindingV1> findings,
  Map<String, int> repeatedCloneCounts,
) {
  final grouped = <String, List<FeedbackAuditFindingV1>>{};
  for (final finding in findings) {
    grouped
        .putIfAbsent(finding.familyPath, () => <FeedbackAuditFindingV1>[])
        .add(finding);
  }

  final families =
      grouped.entries
          .map((entry) {
            final items = List<FeedbackAuditFindingV1>.from(entry.value)
              ..sort((a, b) {
                final severity = b.severity.rank.compareTo(a.severity.rank);
                if (severity != 0) {
                  return severity;
                }
                final type = a.issueType.compareTo(b.issueType);
                if (type != 0) {
                  return type;
                }
                return a.referenceLabel.compareTo(b.referenceLabel);
              });
            final highestSeverity = items.first.severity;
            final repeatedWeakCloneCount = items
                .where(
                  (item) =>
                      repeatedCloneCounts.containsKey(item.normalizedFeedback),
                )
                .map((item) => item.normalizedFeedback)
                .toSet()
                .length;
            final worldId = items.first.worldId;
            final earlyWorldBonus = worldId <= 3
                ? 1000 - (worldId * 10)
                : 100 - worldId;
            final rankScore =
                highestSeverity.rank * 100000 +
                earlyWorldBonus * 100 +
                items.length * 10 +
                repeatedWeakCloneCount;
            return FeedbackAuditFamilySummaryV1(
              familyPath: entry.key,
              worldId: worldId,
              highestSeverity: highestSeverity,
              findings: items,
              repeatedWeakCloneCount: repeatedWeakCloneCount,
              rankScore: rankScore,
            );
          })
          .toList(growable: false)
        ..sort((a, b) {
          final rank = b.rankScore.compareTo(a.rankScore);
          if (rank != 0) {
            return rank;
          }
          return a.familyPath.compareTo(b.familyPath);
        });

  return families;
}

List<FeedbackAuditCloneSummaryV1> _buildCloneSummariesV1(
  List<FeedbackAuditFindingV1> findings,
) {
  final grouped = <String, List<FeedbackAuditFindingV1>>{};
  for (final finding in findings) {
    grouped
        .putIfAbsent(
          finding.normalizedFeedback,
          () => <FeedbackAuditFindingV1>[],
        )
        .add(finding);
  }

  final clones = <FeedbackAuditCloneSummaryV1>[];
  for (final entry in grouped.entries) {
    final familyPaths =
        entry.value
            .map((item) => item.familyPath)
            .toSet()
            .toList(growable: false)
          ..sort();
    if (familyPaths.length < 2) {
      continue;
    }
    final highestSeverity = entry.value
        .map((item) => item.severity)
        .reduce((left, right) => left.rank >= right.rank ? left : right);
    final feedback =
        entry.value.map((item) => item.feedback).toSet().toList(growable: false)
          ..sort();
    clones.add(
      FeedbackAuditCloneSummaryV1(
        feedback: feedback.first,
        normalizedFeedback: entry.key,
        severity: highestSeverity,
        occurrenceCount: entry.value.length,
        familyPaths: familyPaths,
      ),
    );
  }

  clones.sort((a, b) {
    final severity = b.severity.rank.compareTo(a.severity.rank);
    if (severity != 0) {
      return severity;
    }
    final families = b.familyPaths.length.compareTo(a.familyPaths.length);
    if (families != 0) {
      return families;
    }
    return a.feedback.compareTo(b.feedback);
  });

  return clones;
}

String? _readNonEmptyStringV1(Object? value) {
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _normalizeFeedbackV1(String input) {
  return input.trim().toLowerCase().replaceAll(_kCollapseWhitespaceV1, ' ');
}

String _familyPathFromFileV1(String relPath) {
  final marker = '/drills/';
  final index = relPath.indexOf(marker);
  if (index == -1) {
    return relPath;
  }
  return relPath.substring(0, index);
}

int? _worldIdFromPathV1(String relPath) {
  final match = RegExp(r'content/worlds/world(\d+)/').firstMatch(relPath);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}

String _normalizePathV1(String fullPath, {required String rootPath}) {
  var root = Directory(rootPath).absolute.path.replaceAll('\\', '/');
  if (root.endsWith('/.')) {
    root = root.substring(0, root.length - 2);
  }
  final absolute = File(fullPath).absolute.path;
  var normalizedAbsolute = absolute.replaceAll('\\', '/');
  var relative = normalizedAbsolute.startsWith('$root/')
      ? normalizedAbsolute.substring(root.length + 1)
      : (normalizedAbsolute == root ? '' : normalizedAbsolute);
  relative = relative.replaceAll('\\', '/');
  if (relative.startsWith('/')) {
    relative = relative.substring(1);
  }
  return relative;
}

String _joinRootV1(String rootPath, String relPath) {
  if (rootPath == '.' || rootPath.isEmpty) {
    return relPath;
  }
  return '${rootPath.replaceAll('\\', '/')}/$relPath';
}
