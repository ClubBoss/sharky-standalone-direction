import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('Modern Table screenshot outputs and zip exist locally', () {
    const screenshotTool = 'tools/modern_table_screenshot_v1.dart';
    const zipScript = 'tools/modern_table_screenshots_zip_v1.sh';
    const requiredPngEntries = <String>[
      'out/modern_table_default.png',
      'out/modern_table_json.png',
      'out/modern_table_asset.png',
      'out/modern_table_default_portrait.png',
      'out/modern_table_json_portrait.png',
      'out/modern_table_asset_portrait.png',
    ];
    const zipPath = 'out/modern_table_screenshots_v1.zip';

    expect(
      File(screenshotTool).existsSync(),
      isTrue,
      reason: 'Missing $screenshotTool.',
    );
    expect(File(zipScript).existsSync(), isTrue, reason: 'Missing $zipScript.');
    expect(File(zipPath).existsSync(), isTrue, reason: 'Missing $zipPath.');

    final unzip = Process.runSync('unzip', <String>['-l', zipPath]);
    if (unzip.exitCode != 0) {
      fail('Failed to inspect $zipPath with unzip: ${unzip.stderr}');
    }
    final listing = unzip.stdout.toString();
    for (final entry in requiredPngEntries) {
      final name = entry.replaceFirst('out/', '');
      expect(
        listing.contains(name),
        isTrue,
        reason: 'Missing $name inside $zipPath.',
      );
    }
  });
}
