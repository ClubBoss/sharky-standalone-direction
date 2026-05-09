import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';

import '../tools/modern_table_audit_note_v1.dart' as tool;

void main() {
  const expectedChecklist = [
    '- [ ] Felt spotlight/vignette',
    '- [ ] Board card lift/shadow',
    '- [ ] Dealer puck acrylic',
    '- [ ] Avatar bezel metallic',
    '- [ ] Action buttons glass finish',
    '- [ ] Watermark not behind board',
    '- [ ] Numeric jitter stable (tabular + longestLine)',
    '- [ ] Hit targets >=44',
  ];

  test('audit note prints RUN line when zip missing', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'modern_table_audit_note_missing_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));

    String? output;
    await runZoned(
      () async {
        tool.main([tempDir.path]);
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          output = line;
        },
      ),
    );

    expect(output, isNotNull, reason: 'Expected audit note output.');
    expect(
      output!.startsWith(
        'Audit pack: `RUN: dart run tools/modern_table_screenshot_v1.dart && '
        'SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh`',
      ),
      isTrue,
    );
    for (final item in expectedChecklist) {
      expect(output!.contains(item), isTrue);
    }
  });

  test('audit note prints env var when zip exists', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'modern_table_audit_note_present_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final outDir = Directory('${tempDir.path}${Platform.pathSeparator}out');
    await outDir.create();
    final zipFile = File(
      '${outDir.path}${Platform.pathSeparator}modern_table_screenshots_v1.zip',
    );
    await zipFile.writeAsString('ok');

    String? output;
    await runZoned(
      () async {
        tool.main([tempDir.path]);
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          output = line;
        },
      ),
    );

    expect(output, isNotNull, reason: 'Expected audit note output.');
    expect(
      output!.startsWith(
        'Audit pack: `MODERN_TABLE_AUDIT_PACK=out/modern_table_screenshots_v1.zip`',
      ),
      isTrue,
    );
    final lines = output!.split('\n');
    expect(lines.length, 10);
    expect(
      lines.first,
      'Audit pack: `MODERN_TABLE_AUDIT_PACK=out/modern_table_screenshots_v1.zip`',
    );
    expect(lines[1], '');
    for (var i = 0; i < expectedChecklist.length; i++) {
      expect(lines[i + 2], expectedChecklist[i]);
    }
  });
}
