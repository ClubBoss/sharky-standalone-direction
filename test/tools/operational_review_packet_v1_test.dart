import 'package:test/test.dart';

import '../../tools/operational_review_packet_v1.dart';

void main() {
  test('operational review packet is deterministic for a fixed timestamp', () {
    final packet = buildOperationalReviewPacket(
      timestamp: '2026-04-02T12:00:00Z',
    );

    expect(packet['version'], 'v1');
    expect(packet['review_timestamp'], '2026-04-02T12:00:00Z');
    expect(packet['scope'], 'bounded_operational_review_packet');
    expect(
      packet['sources'],
      contains('docs/release/operational_confidence_baseline_v1.md'),
    );
    expect(
      packet['machine_supported_decisions'],
      contains(
        'release-critical telemetry events remain registered in the SSOT',
      ),
    );
    expect(
      packet['manual_inference_only'],
      contains('governed launch or post-launch dashboard ownership'),
    );
    expect(
      packet['unresolved'],
      contains(
        'no canonical active dashboard is currently the governed decision owner',
      ),
    );

    final telemetry = packet['telemetry_summary'] as Map<String, Object>;
    expect(telemetry['telemetry_log_present'], isTrue);
  });
}
