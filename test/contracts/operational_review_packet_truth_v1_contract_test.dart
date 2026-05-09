import 'dart:io';

import 'package:test/test.dart';

import '../../tools/operational_review_packet_v1.dart';
import '../../tools/release_readiness_snapshot_v1.dart';

void main() {
  test(
    'operational review packet truth stays bounded, runner-backed, and non-governing',
    () {
      final owner = File('docs/release/operational_review_packet_truth_v1.md');
      final runner = File('tools/operational_review_packet_v1.dart');
      final baseline = File(
        'docs/release/operational_confidence_baseline_v1.md',
      );
      final jsonArtifact = File(
        'release/_reports/operational_review_packet_v1.json',
      );
      final markdownArtifact = File(
        'release/_reports/operational_review_packet_v1.md',
      );

      expect(owner.existsSync(), isTrue);
      expect(runner.existsSync(), isTrue);
      expect(baseline.existsSync(), isTrue);
      expect(jsonArtifact.existsSync(), isTrue);
      expect(markdownArtifact.existsSync(), isTrue);

      final content = owner.readAsStringSync();

      expect(content, contains('Current Bounded Proof On Main'));
      expect(
        content,
        contains(
          'This owner records one bounded governed operational review packet family on',
        ),
      );
      expect(content, contains('tools/operational_review_packet_v1.dart'));
      expect(
        content,
        contains('release/_reports/operational_review_packet_v1.md'),
      );
      expect(
        content,
        contains('release/_reports/operational_review_packet_v1.json'),
      );
      expect(content, contains('tools/release_readiness_snapshot_v1.dart'));
      expect(
        content,
        contains('docs/release/operational_confidence_baseline_v1.md'),
      );
      expect(
        content,
        contains('## Governed Release-Question Loop On Current Main'),
      );
      expect(content, contains('Review owner:'));
      expect(content, contains('Review cadence:'));
      expect(content, contains('Decision use:'));
      expect(
        content,
        contains('## Active Release Questions This Packet Must Answer'),
      );
      expect(content, contains('operationalReviewPacketOwnerPresent = true'));
      expect(content, contains('operationalReviewPacketRunnerPresent = true'));
      expect(content, contains('operationalReviewPacketJsonPresent = true'));
      expect(
        content,
        contains('operationalReviewPacketMarkdownPresent = true'),
      );
      expect(
        content,
        contains(
          'This owner promotes one governed bounded release-question loop on current',
        ),
      );
      expect(
        content,
        contains('This owner does not claim governed dashboards.'),
      );
      expect(
        content,
        contains(
          'This owner does not claim production observability maturity.',
        ),
      );
      expect(
        content,
        contains('This owner does not claim post-launch operational closure.'),
      );
      expect(
        content,
        contains('This owner does not claim GO or launch readiness.'),
      );

      final snapshot = buildReleaseReadinessSnapshot();
      expect(snapshot['operationalReviewPacketOwnerPresent'], isTrue);
      expect(snapshot['operationalReviewPacketRunnerPresent'], isTrue);
      expect(snapshot['operationalReviewPacketJsonPresent'], isTrue);
      expect(snapshot['operationalReviewPacketMarkdownPresent'], isTrue);
      expect(snapshot['operationalConfidenceBaselinePresent'], isTrue);
      expect(snapshot['goNoGoStateIsHold'], isTrue);

      final packet = buildOperationalReviewPacket(
        timestamp: '2026-04-03T00:00:00Z',
      );
      expect(packet['review_owner'], 'docs/release/release_owner_review_v1.md');
      expect(packet['review_cadence'], isA<List<Object?>>());
      expect(packet['active_release_questions'], isA<List<Object?>>());
      expect(packet['decision_use_now'], isA<List<Object?>>());
    },
  );
}
