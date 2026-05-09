import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v1.dart';

void main() {
  test('report buckets bare, generic, short, and repeated weak feedback', () {
    final tempRoot = Directory.systemTemp.createTempSync(
      'feedback_quality_audit_v1_',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    _writeFileV1(
      tempRoot,
      'content/worlds/world1/v1/sessions/w1.s07/drills/d.raise.json',
      jsonEncode(<String, Object?>{
        'id': 'raise',
        'kind': 'action_choice',
        'feedback_incorrect_v1': 'Incorrect.',
      }),
    );
    _writeFileV1(
      tempRoot,
      'content/worlds/world1/v1/sessions/w1.s08/drills/d.call.json',
      jsonEncode(<String, Object?>{
        'id': 'call',
        'kind': 'action_choice',
        'feedback_incorrect_v1': 'Incorrect. This spot expects raise.',
      }),
    );
    _writeFileV1(
      tempRoot,
      'content/worlds/world3/v1/sessions/w3.s07/drills/d.short.json',
      jsonEncode(<String, Object?>{
        'id': 'short',
        'kind': 'action_choice',
        'feedback_incorrect_v1': 'Incorrect. Too loose here.',
      }),
    );
    _writeFileV1(
      tempRoot,
      'content/worlds/world3/v1/sessions/w3.s08/drills/d.clone.json',
      jsonEncode(<String, Object?>{
        'id': 'clone',
        'kind': 'action_choice',
        'feedback_incorrect_v1': 'Incorrect. This spot expects raise.',
      }),
    );
    _writeFileV1(
      tempRoot,
      'content/worlds/world3/v1/sessions/w3.s09/drills/d.chain.json',
      jsonEncode(<String, Object?>{
        'id': 'chain',
        'kind': 'hand_chain_v1',
        'steps': <Object?>[
          <String, Object?>{'feedback_incorrect_v1': 'Incorrect.'},
        ],
      }),
    );

    final report = buildFeedbackQualityAuditReportV1(rootPath: tempRoot.path);
    final rendered = renderFeedbackQualityAuditReportV1(report);

    expect(report.filesChecked, 5);
    expect(
      report.findings.where(
        (item) => item.issueType == 'bare_incorrect_feedback',
      ),
      hasLength(2),
    );
    expect(
      report.findings.where(
        (item) => item.issueType == 'generic_template_feedback',
      ),
      hasLength(2),
    );
    expect(
      report.findings.where(
        (item) => item.issueType == 'suspiciously_short_feedback',
      ),
      hasLength(1),
    );
    expect(report.clones, hasLength(2));
    expect(
      report.families.first.highestSeverity,
      FeedbackAuditSeverityV1.releaseBlocking,
    );
    expect(
      report.families.first.familyPath,
      'content/worlds/world1/v1/sessions/w1.s07',
    );
    expect(rendered, contains('RANKED_FAMILIES'));
    expect(rendered, contains('release-blocking'));
    expect(rendered, contains('medium-debt'));
    expect(rendered, contains('later-sophistication-candidate'));
  });
}

void _writeFileV1(Directory root, String relativePath, String contents) {
  final file = File('${root.path}/$relativePath');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}
