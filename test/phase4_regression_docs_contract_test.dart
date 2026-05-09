import 'dart:io';

import 'package:test/test.dart';

const _docAnchor = '## 7. How to Run Phase-4 Regression';

void main() {
  test('Phase 4 regression spec matches script flags', () {
    final docText = File('docs/phase4_regression_spec.md').readAsStringSync();
    final anchorIndex = docText.indexOf(_docAnchor);
    expect(
      anchorIndex,
      isNonNegative,
      reason: 'Doc missing "$_docAnchor" section header.',
    );
    final docSection = docText.substring(anchorIndex);
    final docFlags = _extractFlags(docSection);
    final scriptText = File('tool/dev/precommit_sanity.sh').readAsStringSync();
    final scriptFlags = _extractFlags(scriptText);

    final missingInDoc = scriptFlags.difference(docFlags);
    final missingInScript = docFlags.difference(scriptFlags);

    final failMessages = <String>[];
    if (missingInDoc.isNotEmpty) {
      failMessages.add(
        'Documentation drift detected: undocumented flags: $missingInDoc',
      );
    }
    if (missingInScript.isNotEmpty) {
      failMessages.add(
        'Documentation drift detected: missing-in-script flags: $missingInScript',
      );
    }
    expect(failMessages, isEmpty, reason: failMessages.join(' | '));
  });
}

final _flagRegex = RegExp(r'\b(?:RUN_PHASE4|PHASE4_[A-Z_]+)\w*(?:=[^\s`]*)?\b');

Set<String> _extractFlags(String text) {
  final matches = _flagRegex.allMatches(text).map((match) {
    final raw = match.group(0)!;
    return raw.split('=').first;
  });
  return matches.toSet();
}
