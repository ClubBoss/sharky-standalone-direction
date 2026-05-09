import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

import 'release_readiness_snapshot_v1.dart';

const _jsonOutPath = 'release/_reports/operational_review_packet_v1.json';
const _mdOutPath = 'release/_reports/operational_review_packet_v1.md';

Map<String, Object?> buildOperationalReviewPacket({
  String rootPath = '.',
  required String timestamp,
  bool packetOutputsPlanned = false,
}) {
  final root = Directory(rootPath);
  final telemetryLog = File(
    '${root.path}${Platform.pathSeparator}release${Platform.pathSeparator}_reports${Platform.pathSeparator}telemetry.jsonl',
  );
  final snapshot = Map<String, Object>.from(
    buildReleaseReadinessSnapshot(rootPath: rootPath),
  );
  if (packetOutputsPlanned) {
    snapshot['operationalReviewPacketJsonPresent'] = true;
    snapshot['operationalReviewPacketMarkdownPresent'] = true;
  }

  return <String, Object?>{
    'version': 'v1',
    'review_timestamp': timestamp,
    'scope': 'bounded_operational_review_packet',
    'review_owner': 'docs/release/release_owner_review_v1.md',
    'decision_template': 'docs/release/release_owner_decision_template_v1.md',
    'review_cadence': <String>[
      'after any wave that changes release-confidence, telemetry ownership, or launch-surface truth',
      'before any pre-release build or dry-run review',
    ],
    'sources': <String>[
      'docs/release/operational_confidence_baseline_v1.md',
      'docs/release/release_confidence_baseline_v1.md',
      'docs/release/final_product_release_checklist_v1.md',
      'docs/release/final_product_smoke_baseline_v1.md',
      'docs/release/go_hold_rollback_truth_v1.md',
      'docs/release/rollback_ownership_truth_v1.md',
      'docs/release/release_owner_decision_template_v1.md',
      'tools/release_readiness_snapshot_v1.dart',
      'release/_reports/telemetry.jsonl',
      'docs/ops/low_ops_burden_proof_v1.md',
    ],
    'active_release_questions': <String>[
      'Does current main still support HOLD, not GO, on bounded machine proof?',
      'Do the bounded checklist and smoke owners still match the release scope being claimed?',
      'Do release-critical telemetry references and the local telemetry sink still exist for bounded release review?',
      'Is rollback ownership still explicit, even though a finished rollback runbook is unresolved?',
      'Which areas remain manual-only before stronger launch claims can be made?',
    ],
    'machine_supported_decisions': <String>[
      'release-critical telemetry events remain registered in the SSOT',
      'release-critical telemetry event names remain referenced in runtime code',
      'bounded release-confidence owners remain present and aligned',
      'local telemetry sink remains present for bounded release review',
      'low-ops proof artifact remains present on current main',
      'bounded release-confidence still supports HOLD instead of an overclaimed GO verdict',
      'rollback ownership remains explicit even while rollback runbook truth is unresolved',
    ],
    'decision_use_now': <String>[
      'bounded release-owner review of whether HOLD remains honest on current main',
      'bounded review of whether release checklist, smoke baseline, and rollback ownership truth still align',
      'bounded review of what remains manual-only before stronger release claims can be made',
    ],
    'human_decision_handoff': <String>[
      'if a newer active human decision artifact is recorded after this review, it should be created from docs/release/release_owner_decision_template_v1.md',
      'this packet supports review and handoff only; it does not itself fill the newer human decision artifact',
    ],
    'manual_inference_only': <String>[
      'real user cohort and device outcomes in production',
      'repeatable release-owner review cadence with decision history beyond bounded local packet runs',
      'governed launch or post-launch dashboard ownership',
    ],
    'unresolved': <String>[
      'no canonical active dashboard is currently the governed decision owner',
      'current operational confidence remains bounded to local repo-owned telemetry and release artifacts',
      'human review is still required before stronger operational maturity claims',
    ],
    'telemetry_summary': _readTelemetrySummary(telemetryLog),
    'snapshot': snapshot,
  };
}

Map<String, Object> _readTelemetrySummary(File telemetryLog) {
  if (!telemetryLog.existsSync()) {
    return <String, Object>{
      'telemetry_log_present': false,
      'line_count': 0,
      'release_critical_events_seen': 0,
    };
  }

  var lineCount = 0;
  final seenReleaseCritical = <String>{};
  for (final line in telemetryLog.readAsLinesSync()) {
    if (line.trim().isEmpty) continue;
    lineCount += 1;
    try {
      final payload = jsonDecode(line);
      if (payload is Map<String, dynamic>) {
        final event = payload['event'];
        if (event is String &&
            TelemetryEvents.releaseCriticalMap.values.contains(event)) {
          seenReleaseCritical.add(event);
        }
      }
    } catch (_) {
      continue;
    }
  }

  return <String, Object>{
    'telemetry_log_present': true,
    'line_count': lineCount,
    'release_critical_events_seen': seenReleaseCritical.length,
  };
}

String encodeOperationalReviewPacket(Map<String, Object?> packet) {
  return const JsonEncoder.withIndent('  ').convert(packet);
}

String renderOperationalReviewPacketMarkdown(Map<String, Object?> packet) {
  final telemetry = packet['telemetry_summary'] as Map<String, Object>;
  final buffer = StringBuffer()
    ..writeln('# Operational Review Packet v1')
    ..writeln()
    ..writeln('- Review timestamp: `${packet['review_timestamp']}`')
    ..writeln('- Scope: `${packet['scope']}`')
    ..writeln('- Review owner: `${packet['review_owner']}`')
    ..writeln('- Decision template: `${packet['decision_template']}`')
    ..writeln()
    ..writeln('## Review Cadence')
    ..writeln(_markdownList(packet['review_cadence'] as List<Object?>))
    ..writeln()
    ..writeln('## Sources')
    ..writeln(_markdownList(packet['sources'] as List<Object?>))
    ..writeln()
    ..writeln('## Active Release Questions')
    ..writeln(
      _markdownList(packet['active_release_questions'] as List<Object?>),
    )
    ..writeln()
    ..writeln('## Machine-Supported Decisions')
    ..writeln(
      _markdownList(packet['machine_supported_decisions'] as List<Object?>),
    )
    ..writeln()
    ..writeln('## Decision Use Now')
    ..writeln(_markdownList(packet['decision_use_now'] as List<Object?>))
    ..writeln()
    ..writeln('## Human Decision Handoff')
    ..writeln(
      _markdownList(packet['human_decision_handoff'] as List<Object?>),
    )
    ..writeln()
    ..writeln('## Manual-Inference-Only')
    ..writeln(_markdownList(packet['manual_inference_only'] as List<Object?>))
    ..writeln()
    ..writeln('## Unresolved')
    ..writeln(_markdownList(packet['unresolved'] as List<Object?>))
    ..writeln()
    ..writeln('## Telemetry Summary')
    ..writeln(
      '- telemetry_log_present: `${telemetry['telemetry_log_present']}`',
    )
    ..writeln('- line_count: `${telemetry['line_count']}`')
    ..writeln(
      '- release_critical_events_seen: `${telemetry['release_critical_events_seen']}`',
    )
    ..writeln()
    ..writeln('## Guardrail')
    ..writeln(
      'This packet is a bounded local operational review artifact. It does not imply governed dashboards, production observability, or post-launch operational maturity.',
    );
  return buffer.toString();
}

String _markdownList(List<Object?> values) =>
    values.map((value) => '- $value').join('\n');

void main(List<String> args) {
  final write = args.contains('--write');
  final timestampFlagIndex = args.indexOf('--timestamp');
  if (timestampFlagIndex == -1 || timestampFlagIndex + 1 >= args.length) {
    stderr.writeln(
      'usage: dart run tools/operational_review_packet_v1.dart --timestamp <iso8601> [--write]',
    );
    exitCode = 64;
    return;
  }

  final timestamp = args[timestampFlagIndex + 1];
  final packet = buildOperationalReviewPacket(
    timestamp: timestamp,
    packetOutputsPlanned: write,
  );
  final json = encodeOperationalReviewPacket(packet);
  final markdown = renderOperationalReviewPacketMarkdown(packet);

  stdout.writeln(json);

  if (!write) return;

  final jsonFile = File(_jsonOutPath);
  final mdFile = File(_mdOutPath);
  jsonFile.parent.createSync(recursive: true);
  jsonFile.writeAsStringSync('$json\n');
  mdFile.writeAsStringSync(markdown);
}
