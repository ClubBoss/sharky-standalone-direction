// Local Q12 export. Run with Flutter because the catalog uses Flutter types.
// flutter test tools/act0_audit_export_v1.dart --dart-define=OUT=/absolute/dir
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_glossary_v1.dart';

import '../test/support/act0_catalog_snapshot_v1.dart';
import '../test/support/act0_catalog_starting_chart_v1.dart';

String _render({required int first, required int last, required String sha}) {
  final worlds = {for (var world = first; world <= last; world++) world};
  return [
    'SHARKY POKER · Q12 · W$first–W$last',
    'Catalog source: $sha',
    '',
    '===== STARTING CHART =====',
    '',
    renderStartingChartOpening(),
    '',
    renderStartingChartFacingRaise(),
    '',
    '===== COURSE GLOSSARY =====',
    '',
    for (final term in act0GlossaryTermsV1) '${term.name} — ${term.definition}',
    '',
    renderCatalogSnapshot(worlds: worlds).trimRight(),
    '',
  ].join('\n');
}

void main() {
  test('write the two local review packets', () {
    const out = String.fromEnvironment('OUT');
    expect(out, isNotEmpty, reason: 'Set --dart-define=OUT=/absolute/dir.');
    final head = Process.runSync('git', ['rev-parse', 'HEAD']);
    expect(head.exitCode, 0, reason: '${head.stderr}');
    final status = Process.runSync('git', [
      'status',
      '--porcelain',
      '--untracked-files=no',
    ]);
    expect(status.exitCode, 0, reason: '${status.stderr}');
    final sha = head.stdout.toString().trim();
    final source = status.stdout.toString().trim().isEmpty
        ? sha
        : '$sha + local tracked changes';
    final directory = Directory(out)..createSync(recursive: true);
    for (final (first, last) in [(1, 4), (9, 12)]) {
      final content = _render(first: first, last: last, sha: source);
      File.fromUri(
        directory.absolute.uri.resolve('sharky_q12_w${first}_w$last.txt'),
      ).writeAsStringSync(content);
    }
  });
}
