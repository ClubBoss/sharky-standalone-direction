import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/l3/weights_contract.dart';
import 'package:poker_analyzer/services/l3_cli_runner.dart';
import 'package:test/test.dart';

void main() {
  test('extractTargetMix parses inline json with aliases', () {
    final payload = {
      kTargetMixKey: {'monotone': 0.2, 'two_tone': 0.3, 'broadway-heavy': 0.1},
      kMixToleranceKey: 0.15,
      'mixToleranceByKey': {'twoTone': 0.05},
      'minTotal': 50,
    };

    final mix = extractTargetMix(jsonEncode(payload));
    expect(mix, isNotNull, reason: 'Expected inline JSON target mix to parse.');
    expect(mix!.tolerance, closeTo(0.15, 1e-9));
    expect(mix.byKeyTol['twoTone'], closeTo(0.05, 1e-9));
    expect(mix.minTotal, 50);
    expect(mix.mix['monotone'], closeTo(0.2, 1e-9));
    expect(mix.mix['twoTone'], closeTo(0.3, 1e-9));
    expect(mix.mix['broadwayHeavy'], closeTo(0.1, 1e-9));
  });

  test('extractTargetMix reads json from file path', () async {
    final tempDir = await Directory.systemTemp.createTemp('l3_weights_');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final file = File('${tempDir.path}/weights.json');
    final payload = {
      kTargetMixKey: {'paired': 0.4, 'ace-high': 0.2},
      kMixToleranceKey: '0.2',
    };
    file.writeAsStringSync(jsonEncode(payload));

    final mix = extractTargetMix(file.path);
    expect(mix, isNotNull, reason: 'Expected file path weights to parse.');
    expect(mix!.tolerance, closeTo(0.2, 1e-9));
    expect(mix.mix['paired'], closeTo(0.4, 1e-9));
    expect(mix.mix['aceHigh'], closeTo(0.2, 1e-9));
  });
}
