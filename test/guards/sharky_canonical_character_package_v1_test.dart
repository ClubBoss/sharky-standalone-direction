import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const manifestPath =
      'assets/design/sharky_character_v1/sharky_character_package_manifest_v1.json';

  test(
    'canonical Sharky character package keeps authority and bytes intact',
    () {
      final manifestFile = File(manifestPath);
      expect(manifestFile.existsSync(), isTrue);
      final manifest = jsonDecode(manifestFile.readAsStringSync()) as Map;
      final files = (manifest['files'] as List).cast<Map>();
      expect(files, hasLength(4));

      final authority = files
          .where((entry) => entry['role'] == 'canonical_visual_authority')
          .toList(growable: false);
      expect(authority, hasLength(1));
      expect(authority.single['authorityRank'], 1);

      for (final entry in files) {
        final path = entry['relativePath'] as String;
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: path);
        expect(file.lengthSync(), entry['byteSize']);
        expect(
          sha256.convert(file.readAsBytesSync()).toString(),
          entry['sha256'],
        );
        expect(entry['runtimeEligibility'], isFalse);
      }

      final bible = File('docs/design/SHARKY_CHARACTER_BIBLE_v1.md');
      expect(bible.existsSync(), isTrue);
      expect(
        bible.readAsStringSync(),
        contains('sharky_canonical_3q_front_authority_v1.png'),
      );
    },
  );
}
