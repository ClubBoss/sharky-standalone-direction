import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Act0 feedback source contract', () {
    final sourcePath = 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart';

    final titlePattern = RegExp(r"feedbackTitle:\s*'((?:\\'|[^'])*)'");
    final reasonPattern = RegExp(r"feedbackReason:\s*'((?:\\'|[^'])*)'");

    test('feedback titles and reasons are present and non-empty', () {
      final source = File(sourcePath).readAsStringSync();
      final titles = titlePattern
          .allMatches(source)
          .map((m) => m.group(1) ?? '')
          .toList(growable: false);
      final reasons = reasonPattern
          .allMatches(source)
          .map((m) => m.group(1) ?? '')
          .toList(growable: false);

      expect(titles, isNotEmpty, reason: 'feedbackTitle entries not found');
      expect(reasons, isNotEmpty, reason: 'feedbackReason entries not found');
      expect(
        reasons.length,
        greaterThanOrEqualTo(titles.length),
        reason: 'feedbackReason count should not be below feedbackTitle count',
      );

      final emptyTitles = titles.where((t) => t.trim().isEmpty).toList();
      final emptyReasons = reasons.where((r) => r.trim().isEmpty).toList();
      expect(emptyTitles, isEmpty, reason: 'Empty feedbackTitle detected');
      expect(emptyReasons, isEmpty, reason: 'Empty feedbackReason detected');
    });

    test('feedback title diversity stays above minimum threshold', () {
      final source = File(sourcePath).readAsStringSync();
      final titles = titlePattern
          .allMatches(source)
          .map((m) => m.group(1) ?? '')
          .toList(growable: false);

      final counts = <String, int>{};
      for (final title in titles) {
        counts[title] = (counts[title] ?? 0) + 1;
      }

      final sortedCounts = counts.values.toList()..sort((a, b) => b - a);
      final topTwo = sortedCounts.take(2).fold<int>(0, (sum, v) => sum + v);
      final topTwoShare = titles.isEmpty ? 1.0 : topTwo / titles.length;
      final uniqueShare = titles.isEmpty ? 0.0 : counts.length / titles.length;

      expect(
        topTwoShare,
        lessThan(0.25),
        reason:
            'Top-2 title share exceeded 25% (actual: ${(topTwoShare * 100).toStringAsFixed(1)}%)',
      );
      expect(
        uniqueShare,
        greaterThan(0.35),
        reason:
            'Unique title share dropped below 35% (actual: ${(uniqueShare * 100).toStringAsFixed(1)}%)',
      );
    });

    test('known synthetic/generic title fallbacks are not present', () {
      final source = File(sourcePath).readAsStringSync();
      final bannedTitles = <String>{
        'Nice read.',
        'Almost there.',
        'Good instinct.',
        'Good.',
        'Playable move.',
      };

      final titles = titlePattern
          .allMatches(source)
          .map((m) => m.group(1) ?? '')
          .toSet();

      final presentBanned = bannedTitles.where(titles.contains).toList()
        ..sort();
      expect(
        presentBanned,
        isEmpty,
        reason:
            'Banned feedbackTitle values found: ${presentBanned.join(', ')}',
      );
    });
  });
}
