import 'dart:io';

import 'package:test/test.dart';

void main() {
  const proofZip = 'out/modern_table_screenshots_v1.zip';
  const proofDoc = 'docs/release/store_assets_v1.md';
  const proofReadme = 'assets/store/README.md';
  const requiredZipEntries = <String>[
    'modern_table_default.png',
    'modern_table_json.png',
    'modern_table_asset.png',
    'modern_table_default_portrait.png',
    'modern_table_json_portrait.png',
    'modern_table_asset_portrait.png',
  ];
  const zipMinBytes = 20000;

  test('store package assets follow canonical proof path and coverage', () {
    final guardEnabled = Platform.environment['STORE_PACKAGE_GUARD'] == '1';
    final zipFile = File(proofZip);
    if (!zipFile.existsSync()) {
      if (!guardEnabled) {
        stdout.writeln(
          'SKIP: canonical store proof artifact not present; set STORE_PACKAGE_GUARD=1 to enforce.',
        );
        return;
      }
      fail('Missing canonical store proof artifact: $proofZip');
    }

    final missing = <String>[
      if (!File(proofDoc).existsSync()) proofDoc,
      if (!File(proofReadme).existsSync()) proofReadme,
    ];
    final zipSize = zipFile.lengthSync();
    if (zipSize < zipMinBytes) {
      missing.add('$proofZip smaller than ${zipMinBytes}B');
    }

    final unzip = Process.runSync('unzip', <String>['-l', proofZip]);
    if (unzip.exitCode != 0) {
      missing.add('failed to inspect $proofZip with unzip');
    }
    final zipListing = unzip.stdout.toString();
    for (final entry in requiredZipEntries) {
      if (!zipListing.contains(entry)) {
        missing.add('missing $entry inside $proofZip');
      }
    }

    if (missing.isNotEmpty) {
      final buffer = StringBuffer()
        ..writeln('Store package asset contract failed.')
        ..writeln(
          'Use out/modern_table_screenshots_v1.zip + docs/release/store_assets_v1.md as the canonical repo proof path.',
        )
        ..writeln(missing.join('\n'));
      fail(buffer.toString());
    }
  });
}
