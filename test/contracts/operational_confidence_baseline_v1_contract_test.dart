import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'operational confidence baseline keeps cadence and dashboard truth explicit',
    () {
      final file = File('docs/release/operational_confidence_baseline_v1.md');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains('## Review Cadence On Current Main'));
      expect(
        content,
        contains('## Canonical Governed Review Loop On Current Main'),
      );
      expect(content, contains('## Decisions Current Main Can Support'));
      expect(
        content,
        contains('## Active Release Questions This Loop Answers Now'),
      );
      expect(content, contains('## Decisions Still Manual-Inference-Only'));
      expect(content, contains('## Dashboard / Report Truth On Current Main'));
      expect(
        content,
        contains('docs/release/operational_review_packet_truth_v1.md'),
      );
      expect(content, contains('docs/release/release_owner_review_v1.md'));
      expect(
        content,
        contains(
          'supports bounded release-owner review on whether HOLD remains honest',
        ),
      );
      expect(
        content,
        contains(
          'No canonical active dashboard is currently the governed decision owner',
        ),
      );
      expect(content, contains('release/_reports/telemetry.jsonl'));
      expect(content, contains('docs/release/RELEASE_README.md'));
      expect(content.toLowerCase(), contains('historical snapshot'));
    },
  );
}
