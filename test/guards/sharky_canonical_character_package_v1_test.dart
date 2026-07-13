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
      expect(
        authority.single['logicalId'],
        'sharky_canonical_3q_front_authority_v1_1',
      );
      expect(
        authority.single['filename'],
        'sharky_canonical_3q_front_authority_v1_1.png',
      );
      expect(authority.single['version'], 'v1.1');
      expect(authority.single['pixelDimensions'], <String, int>{
        'width': 1254,
        'height': 1254,
      });
      expect(authority.single['colorMode'], 'RGBA');
      expect(authority.single['hasAlpha'], isTrue);
      expect(authority.single['byteSize'], 2582381);
      expect(
        authority.single['sha256'],
        'b8cd60fa5165f95111425ec451b943ca62a821b714e846ebf15f33c69e452db1',
      );
      expect(authority.single['runtimeEligibility'], isFalse);

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
        contains('sharky_canonical_3q_front_authority_v1_1.png'),
      );
      expect(
        bible.readAsStringSync(),
        contains('smooth uninterrupted no-crest crown'),
      );
    },
  );
}
