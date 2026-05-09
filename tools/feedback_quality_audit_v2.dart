import 'dart:convert';
import 'dart:io';

enum FeedbackAuditSeverityV2 {
  releaseBlocking('release-blocking', 3),
  mediumDebt('medium-debt', 2),
  laterSophisticationCandidate('later-sophistication-candidate', 1);

  const FeedbackAuditSeverityV2(this.label, this.rank);

  final String label;
  final int rank;
}

class FeedbackAuditFindingV2 {
  const FeedbackAuditFindingV2({
    required this.severity,
    required this.issueType,
    required this.worldId,
    required this.familyPath,
    required this.filePath,
    required this.referenceLabel,
    required this.feedback,
    required this.normalizedFeedback,
  });

  final FeedbackAuditSeverityV2 severity;
  final String issueType;
  final int worldId;
  final String familyPath;
  final String filePath;
  final String referenceLabel;
  final String feedback;
  final String normalizedFeedback;
}

class FeedbackAuditFamilySummaryV2 {
  const FeedbackAuditFamilySummaryV2({
    required this.familyPath,
    required this.worldId,
    required this.highestSeverity,
    required this.findings,
    required this.repeatedWeakCloneCount,
    required this.rankScore,
  });

  final String familyPath;
  final int worldId;
  final FeedbackAuditSeverityV2 highestSeverity;
  final List<FeedbackAuditFindingV2> findings;
  final int repeatedWeakCloneCount;
  final int rankScore;
}

class FeedbackAuditCloneSummaryV2 {
  const FeedbackAuditCloneSummaryV2({
    required this.feedback,
    required this.normalizedFeedback,
    required this.severity,
    required this.occurrenceCount,
    required this.familyPaths,
  });

  final String feedback;
  final String normalizedFeedback;
  final FeedbackAuditSeverityV2 severity;
  final int occurrenceCount;
  final List<String> familyPaths;
}

class FeedbackQualityAuditReportV2 {
  const FeedbackQualityAuditReportV2({
    required this.filesChecked,
    required this.findings,
    required this.families,
    required this.clones,
    required this.issueTotals,
  });

  final int filesChecked;
  final List<FeedbackAuditFindingV2> findings;
  final List<FeedbackAuditFamilySummaryV2> families;
  final List<FeedbackAuditCloneSummaryV2> clones;
  final Map<String, int> issueTotals;
}

const Set<String> _kFeedbackFamilyRootsV2 = <String>{
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

final RegExp _kBareIncorrectV2 = RegExp(
  r'^incorrect\.?$',
  caseSensitive: false,
);
final RegExp _kCorrectPrefixV2 = RegExp(r'^correct\.\s*', caseSensitive: false);
final RegExp _kPlaceholderFeedbackV2 = RegExp(
  r'\b(todo|tbd|placeholder|lorem|stub)\b',
  caseSensitive: false,
);
final RegExp _kGenericTemplateV2 = RegExp(
  r'^(incorrect\.\s*)?(this|that)\s+.+\b(expects|should|must|wants)\b.+$',
  caseSensitive: false,
);
final RegExp _kGenericAnchorV2 = RegExp(
  r'^(incorrect\.\s*)?(find|identify|set|lock|tap)\b.+\b(first|before action|target)\b.*$',
  caseSensitive: false,
);
final RegExp _kGenericExpectationObjectV2 = RegExp(
  r'\b(expects|should|must|wants)\s+'
  r'(a\s+different\s+action|'
  r'the\s+target\s+(seat|role|anchor|card)|'
  r'the\s+draw\s+bucket|'
  r'raise|call|fold|bet|check|bluff|release|'
  r'tap|slow\s+down|'
  r'hero|villain|board_plays)\b',
  caseSensitive: false,
);
final RegExp _kInternalCurriculumLabelV2 = RegExp(
  r'\b(world\s*\d+|world|track|checkpoint|session)\b',
  caseSensitive: false,
);
final RegExp _kNavigationEscapeV2 = RegExp(
  r'\b(go to|back to|return to|open)\b',
  caseSensitive: false,
);
final RegExp _kPositiveTargetCueV2 = RegExp(
  r'\b(expected|action|anchor|seat|board|hole-card|button|position|river|turn|flop)\b',
  caseSensitive: false,
);
final RegExp _kPositiveConfirmationCueV2 = RegExp(
  r'\b(confirmed|set)\b',
  caseSensitive: false,
);
final RegExp _kCollapseWhitespaceV2 = RegExp(r'\s+');
final RegExp _kSentenceTrimPrefixV2 = RegExp(
  r'^incorrect\.\s*',
  caseSensitive: false,
);

const Map<String, int> _kIssuePriorityWeightsV2 = <String, int>{
  'placeholder_like_feedback': 40,
  'bare_incorrect_feedback': 40,
  'internal_curriculum_label_feedback': 30,
  'generic_template_feedback': 24,
  'generic_anchor_feedback': 22,
  'shallow_positive_feedback': 12,
  'suspiciously_short_feedback': 10,
};

void main(List<String> args) {
  if (args.isNotEmpty) {
    stderr.writeln(
      'feedback_quality_audit_v2: no arguments supported (deterministic scan only)',
    );
    exitCode = 64;
    return;
  }

  final report = buildFeedbackQualityAuditReportV2();
  stdout.write(renderFeedbackQualityAuditReportV2(report));
  exitCode = 0;
}

FeedbackQualityAuditReportV2 buildFeedbackQualityAuditReportV2({
  String rootPath = '.',
}) {
  final findings = <FeedbackAuditFindingV2>[];
  var filesChecked = 0;

  final roots = _kFeedbackFamilyRootsV2
      .map((relative) => Directory(_joinRootV2(rootPath, relative)))
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
      findings.addAll(_scanFeedbackFileV2(file, rootPath: rootPath));
    }
  }

  final repeatedCloneCounts = _buildRepeatedCloneCountsV2(findings);
  final families = _buildFamilySummariesV2(findings, repeatedCloneCounts);
  final clones = _buildCloneSummariesV2(findings);
  final issueTotals = <String, int>{};
  for (final finding in findings) {
    issueTotals.update(
      finding.issueType,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }

  return FeedbackQualityAuditReportV2(
    filesChecked: filesChecked,
    findings: findings,
    families: families,
    clones: clones,
    issueTotals: issueTotals,
  );
}

String renderFeedbackQualityAuditReportV2(FeedbackQualityAuditReportV2 report) {
  final buffer = StringBuffer()
    ..writeln('FEEDBACK_QUALITY_AUDIT_V2')
    ..writeln('FILES_CHECKED\t${report.filesChecked}')
    ..writeln('TOTAL_FINDINGS\t${report.findings.length}')
    ..writeln(
      'SEVERITY_TOTALS\t'
      'release-blocking=${report.findings.where((item) => item.severity == FeedbackAuditSeverityV2.releaseBlocking).length}\t'
      'medium-debt=${report.findings.where((item) => item.severity == FeedbackAuditSeverityV2.mediumDebt).length}\t'
      'later-sophistication-candidate=${report.findings.where((item) => item.severity == FeedbackAuditSeverityV2.laterSophisticationCandidate).length}',
    );

  buffer.writeln();
  buffer.writeln('ISSUE_TOTALS');
  if (report.issueTotals.isEmpty) {
    buffer.writeln('STATUS\tOK');
  } else {
    final sortedIssues = report.issueTotals.keys.toList()..sort();
    for (final issueType in sortedIssues) {
      buffer.writeln(
        'ISSUE\t$issueType\tcount=${report.issueTotals[issueType]}',
      );
    }
  }

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

List<FeedbackAuditFindingV2> _scanFeedbackFileV2(
  File file, {
  required String rootPath,
}) {
  final content = file.readAsStringSync();
  final decoded = jsonDecode(content);
  if (decoded is! Map<String, Object?>) {
    return const <FeedbackAuditFindingV2>[];
  }

  final findings = <FeedbackAuditFindingV2>[];
  final relPath = _normalizePathV2(file.path, rootPath: rootPath);
  final worldId = _worldIdFromPathV2(relPath);
  if (worldId == null) {
    return const <FeedbackAuditFindingV2>[];
  }
  final familyPath = _familyPathFromFileV2(relPath);

  final drillFeedback = _readNonEmptyStringV2(decoded['feedback_incorrect_v1']);
  if (drillFeedback != null) {
    final finding = _classifyFeedbackV2(
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

  final drillPositive = _readNonEmptyStringV2(decoded['feedback_correct_v1']);
  if (drillPositive != null) {
    final finding = _classifyPositiveFeedbackV2(
      feedback: drillPositive,
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
      final stepFeedback = _readNonEmptyStringV2(step['feedback_incorrect_v1']);
      if (stepFeedback == null) {
        continue;
      }
      final finding = _classifyFeedbackV2(
        feedback: stepFeedback,
        worldId: worldId,
        familyPath: familyPath,
        filePath: relPath,
        referenceLabel: '$relPath#step${i + 1}',
      );
      if (finding != null) {
        findings.add(finding);
      }

      final stepPositive = _readNonEmptyStringV2(step['feedback_correct_v1']);
      if (stepPositive == null) {
        continue;
      }
      final positiveFinding = _classifyPositiveFeedbackV2(
        feedback: stepPositive,
        worldId: worldId,
        familyPath: familyPath,
        filePath: relPath,
        referenceLabel: '$relPath#step${i + 1}',
      );
      if (positiveFinding != null) {
        findings.add(positiveFinding);
      }
    }
  }

  return findings;
}

FeedbackAuditFindingV2? _classifyPositiveFeedbackV2({
  required String feedback,
  required int worldId,
  required String familyPath,
  required String filePath,
  required String referenceLabel,
}) {
  final normalized = _normalizeFeedbackV2(feedback);
  if (normalized.isEmpty) {
    return null;
  }

  final stripped = normalized.replaceFirst(_kCorrectPrefixV2, '').trim();
  final wordCount = stripped.isEmpty
      ? 0
      : stripped.split(' ').where((word) => word.isNotEmpty).length;
  final shallowConfirmation =
      wordCount > 0 &&
      wordCount <= 7 &&
      _kPositiveTargetCueV2.hasMatch(stripped) &&
      _kPositiveConfirmationCueV2.hasMatch(stripped);

  if (!shallowConfirmation) {
    return null;
  }

  return FeedbackAuditFindingV2(
    severity: FeedbackAuditSeverityV2.laterSophisticationCandidate,
    issueType: 'shallow_positive_feedback',
    worldId: worldId,
    familyPath: familyPath,
    filePath: filePath,
    referenceLabel: referenceLabel,
    feedback: feedback,
    normalizedFeedback: normalized,
  );
}

FeedbackAuditFindingV2? _classifyFeedbackV2({
  required String feedback,
  required int worldId,
  required String familyPath,
  required String filePath,
  required String referenceLabel,
}) {
  final normalized = _normalizeFeedbackV2(feedback);
  if (normalized.isEmpty) {
    return null;
  }

  if (_kPlaceholderFeedbackV2.hasMatch(normalized)) {
    return FeedbackAuditFindingV2(
      severity: FeedbackAuditSeverityV2.releaseBlocking,
      issueType: 'placeholder_like_feedback',
      worldId: worldId,
      familyPath: familyPath,
      filePath: filePath,
      referenceLabel: referenceLabel,
      feedback: feedback,
      normalizedFeedback: normalized,
    );
  }

  if (_kBareIncorrectV2.hasMatch(normalized)) {
    return FeedbackAuditFindingV2(
      severity: FeedbackAuditSeverityV2.releaseBlocking,
      issueType: 'bare_incorrect_feedback',
      worldId: worldId,
      familyPath: familyPath,
      filePath: filePath,
      referenceLabel: referenceLabel,
      feedback: feedback,
      normalizedFeedback: normalized,
    );
  }

  if (_kInternalCurriculumLabelV2.hasMatch(normalized) &&
      !_kNavigationEscapeV2.hasMatch(normalized)) {
    return FeedbackAuditFindingV2(
      severity: FeedbackAuditSeverityV2.mediumDebt,
      issueType: 'internal_curriculum_label_feedback',
      worldId: worldId,
      familyPath: familyPath,
      filePath: filePath,
      referenceLabel: referenceLabel,
      feedback: feedback,
      normalizedFeedback: normalized,
    );
  }

  final stripped = normalized.replaceFirst(_kSentenceTrimPrefixV2, '').trim();
  final wordCount = stripped.isEmpty
      ? 0
      : stripped.split(' ').where((word) => word.isNotEmpty).length;
  final isShort = wordCount > 0 && wordCount <= 7;
  final genericTemplate =
      _kGenericTemplateV2.hasMatch(normalized) &&
      (_kGenericExpectationObjectV2.hasMatch(normalized) || isShort);
  final genericAnchor = _kGenericAnchorV2.hasMatch(normalized);

  if (genericTemplate) {
    return FeedbackAuditFindingV2(
      severity: FeedbackAuditSeverityV2.mediumDebt,
      issueType: 'generic_template_feedback',
      worldId: worldId,
      familyPath: familyPath,
      filePath: filePath,
      referenceLabel: referenceLabel,
      feedback: feedback,
      normalizedFeedback: normalized,
    );
  }

  if (genericAnchor) {
    return FeedbackAuditFindingV2(
      severity: FeedbackAuditSeverityV2.mediumDebt,
      issueType: 'generic_anchor_feedback',
      worldId: worldId,
      familyPath: familyPath,
      filePath: filePath,
      referenceLabel: referenceLabel,
      feedback: feedback,
      normalizedFeedback: normalized,
    );
  }

  if (isShort) {
    return FeedbackAuditFindingV2(
      severity: FeedbackAuditSeverityV2.laterSophisticationCandidate,
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

Map<String, int> _buildRepeatedCloneCountsV2(
  List<FeedbackAuditFindingV2> findings,
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

List<FeedbackAuditFamilySummaryV2> _buildFamilySummariesV2(
  List<FeedbackAuditFindingV2> findings,
  Map<String, int> repeatedCloneCounts,
) {
  final grouped = <String, List<FeedbackAuditFindingV2>>{};
  for (final finding in findings) {
    grouped
        .putIfAbsent(finding.familyPath, () => <FeedbackAuditFindingV2>[])
        .add(finding);
  }

  final families =
      grouped.entries
          .map((entry) {
            final items = List<FeedbackAuditFindingV2>.from(entry.value)
              ..sort((a, b) {
                final severity = b.severity.rank.compareTo(a.severity.rank);
                if (severity != 0) {
                  return severity;
                }
                final issueWeight = _issueTypeWeightV2(
                  b.issueType,
                ).compareTo(_issueTypeWeightV2(a.issueType));
                if (issueWeight != 0) {
                  return issueWeight;
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
            final earlyWorldBonus = _earlyWorldBonusV2(worldId);
            final issueWeightSum = items.fold<int>(
              0,
              (sum, item) => sum + _issueTypeWeightV2(item.issueType),
            );
            final canonicalFamilyBonus = entry.key.contains('/tracks/')
                ? 0
                : 25;
            final rankScore =
                highestSeverity.rank * 100000 +
                earlyWorldBonus * 100 +
                issueWeightSum * 10 +
                repeatedWeakCloneCount * 5 +
                canonicalFamilyBonus;
            return FeedbackAuditFamilySummaryV2(
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

List<FeedbackAuditCloneSummaryV2> _buildCloneSummariesV2(
  List<FeedbackAuditFindingV2> findings,
) {
  final grouped = <String, List<FeedbackAuditFindingV2>>{};
  for (final finding in findings) {
    grouped
        .putIfAbsent(
          finding.normalizedFeedback,
          () => <FeedbackAuditFindingV2>[],
        )
        .add(finding);
  }

  final clones = <FeedbackAuditCloneSummaryV2>[];
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
      FeedbackAuditCloneSummaryV2(
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

int _earlyWorldBonusV2(int worldId) {
  if (worldId <= 3) {
    return 2000 - (worldId * 20);
  }
  if (worldId <= 5) {
    return 500 - (worldId * 5);
  }
  return 100 - worldId;
}

int _issueTypeWeightV2(String issueType) {
  return _kIssuePriorityWeightsV2[issueType] ?? 1;
}

String? _readNonEmptyStringV2(Object? value) {
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _normalizeFeedbackV2(String input) {
  return input.trim().toLowerCase().replaceAll(_kCollapseWhitespaceV2, ' ');
}

String _familyPathFromFileV2(String relPath) {
  final marker = '/drills/';
  final index = relPath.indexOf(marker);
  if (index == -1) {
    return relPath;
  }
  return relPath.substring(0, index);
}

int? _worldIdFromPathV2(String relPath) {
  final match = RegExp(r'content/worlds/world(\d+)/').firstMatch(relPath);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}

String _normalizePathV2(String fullPath, {required String rootPath}) {
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

String _joinRootV2(String rootPath, String relPath) {
  if (rootPath == '.' || rootPath.isEmpty) {
    return relPath;
  }
  return '${rootPath.replaceAll('\\', '/')}/$relPath';
}
