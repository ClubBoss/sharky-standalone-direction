import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'project readiness epics ssot keeps required structure and enum values',
    () {
      final file = File('docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      const sections = <String>[
        '## Purpose / scope',
        '## Definition of true 100%',
        '## Core vs Ship vs Final readiness model',
        '## Layered readiness architecture',
        '## Fixed readiness blocks',
        '## Status model',
        '## Blocking model',
        '## Proof model',
        '## Scoring model',
        '## Update protocol',
        '## Reporting protocol',
        '## Block-by-block epic registry',
        '## Execution graph / dependency notes',
        '## Current bottlenecks / active frontier',
        '## Rules against false readiness',
      ];

      var lastIndex = -1;
      for (final section in sections) {
        final index = content.indexOf(section);
        expect(
          index,
          greaterThan(lastIndex),
          reason: 'missing or out of order: $section',
        );
        lastIndex = index;
      }

      expect(content, contains('Core Product Readiness'));
      expect(content, contains('Ship / Distribution Readiness'));
      expect(
        content,
        contains('Final Product Readiness = Core + Ship/Distribution complete'),
      );
      expect(content, contains('machine proof'));
      expect(content, contains('human proof'));
      expect(content, contains('proof_pending'));
      expect(content, contains('human_proof_pending'));
      expect(
        content,
        contains('No percentage rises unless epic state actually changed.'),
      );
      expect(content, contains('Weight-governance rule:'));
      expect(content, contains('Registry framing:'));
      expect(content, contains('Block closeout rules:'));
      expect(content, contains('Score-reporting rule:'));
      expect(
        content,
        contains(
          'already accepted epic progress may not be downgraded because the model became',
        ),
      );
      expect(
        content,
        contains(
          'Exact readiness SSOT version path, audit date, branch, and `HEAD`',
        ),
      );

      const allowedStatuses = <String>{
        'not_started',
        'in_progress',
        'blocked',
        'proof_pending',
        'human_proof_pending',
        'done',
        'deferred',
      };
      final statusMatches = RegExp(
        r'^- status: ([a-z_]+)$',
        multiLine: true,
      ).allMatches(content).toList();
      expect(statusMatches, isNotEmpty);
      for (final match in statusMatches) {
        final value = match.group(1)!;
        expect(
          allowedStatuses.contains(value),
          isTrue,
          reason: 'unexpected status value: $value',
        );
      }

      const allowedBlockingLevels = <String>{
        'hard_blocker',
        'soft_blocker',
        'non_blocking',
      };
      final blockingMatches = RegExp(
        r'^- blocking_level: ([a-z_]+)$',
        multiLine: true,
      ).allMatches(content).toList();
      expect(blockingMatches, isNotEmpty);
      for (final match in blockingMatches) {
        final value = match.group(1)!;
        expect(
          allowedBlockingLevels.contains(value),
          isTrue,
          reason: 'unexpected blocking_level value: $value',
        );
      }

      const allowedScopes = <String>{'core', 'ship', 'final', 'multi'};
      final scopeMatches = RegExp(
        r'^- scope: ([a-z_]+)$',
        multiLine: true,
      ).allMatches(content).toList();
      expect(scopeMatches, isNotEmpty);
      for (final match in scopeMatches) {
        final value = match.group(1)!;
        expect(
          allowedScopes.contains(value),
          isTrue,
          reason: 'unexpected scope value: $value',
        );
      }

      final blockMatches = RegExp(
        r'^### ([A-N]) ',
        multiLine: true,
      ).allMatches(content).toList();
      expect(
        blockMatches.map((match) => match.group(1)).toList(),
        orderedEquals(<String>[
          'A',
          'B',
          'C',
          'D',
          'E',
          'F',
          'G',
          'H',
          'I',
          'J',
          'K',
          'L',
          'M',
          'N',
        ]),
      );

      for (var i = 0; i < blockMatches.length; i++) {
        final start = blockMatches[i].start;
        final end = i + 1 < blockMatches.length
            ? blockMatches[i + 1].start
            : content.length;
        final blockSection = content.substring(start, end);
        final epicIds = RegExp(
          r'^- id: [A-N]\d+$',
          multiLine: true,
        ).allMatches(blockSection).toList();
        expect(
          epicIds,
          isNotEmpty,
          reason: 'block ${blockMatches[i].group(1)} has no populated epic',
        );
        final scopeCount = RegExp(
          r'^- scope: [a-z_]+$',
          multiLine: true,
        ).allMatches(blockSection).length;
        expect(
          scopeCount,
          epicIds.length,
          reason: 'block ${blockMatches[i].group(1)} has an epic without scope',
        );
      }
    },
  );
}
