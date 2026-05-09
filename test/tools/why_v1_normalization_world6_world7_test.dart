import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/why_v1_ssot_v1.dart';

void main() {
  test('world6/world7 admitted invalid_why_v1 family stays runtime valid', () {
    final repoRoot = Directory.current.path;
    const admittedFiles = <String, String>{
      'content/worlds/world6/v1/sessions/w6.s08/drills/d.choose_call_blocker_mod.json':
          'The blocker helps a little, but not enough to turn this range-based call into a raise.',
      'content/worlds/world7/v1/sessions/w7.s04/drills/d.choose_call_deep_leverage.json':
          'Calling keeps deep-stack leverage alive; an early raise spends that extra maneuvering room too soon.',
    };

    for (final entry in admittedFiles.entries) {
      final file = File('$repoRoot/${entry.key}');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final whyV1 = json['why_v1'];

      expect(
        whyV1,
        entry.value,
        reason: '${entry.key} should keep the admitted normalized why_v1.',
      );
      expect(
        isRuntimeValidWhyV1V1(whyV1),
        isTrue,
        reason: '${entry.key} should keep a runtime-valid why_v1.',
      );
      expect(
        (whyV1 as String).length <= 140,
        isTrue,
        reason: '${entry.key} should stay within the why_v1 max length.',
      );
    }

    expect(admittedFiles.length, 2);
  });
}
