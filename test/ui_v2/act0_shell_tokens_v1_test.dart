import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

void main() {
  test('Deep Ocean Gold v1.1 keeps filled primary actions readable', () {
    expect(
      _contrastRatio(Act0ShellTokensV1.onPrimary, Act0ShellTokensV1.primary),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('Deep Ocean Gold v1.1 keeps dark-surface text comfortably readable', () {
    expect(
      _contrastRatio(Act0ShellTokensV1.text, Act0ShellTokensV1.background),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(Act0ShellTokensV1.textMuted, Act0ShellTokensV1.surface),
      greaterThanOrEqualTo(4.5),
    );
  });

  test(
    'Deep Ocean Gold v1.1 keeps the bright shark accent above shared CTA cyan',
    () {
      expect(
        _relativeLuminance(Act0ShellTokensV1.runnerSharkBlue),
        greaterThan(_relativeLuminance(Act0ShellTokensV1.primary)),
      );
    },
  );
}

double _contrastRatio(Color colorA, Color colorB) {
  final luminanceA = _relativeLuminance(colorA);
  final luminanceB = _relativeLuminance(colorB);
  final lighter = luminanceA > luminanceB ? luminanceA : luminanceB;
  final darker = luminanceA > luminanceB ? luminanceB : luminanceA;
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  final red = _linearize(color.red.toDouble());
  final green = _linearize(color.green.toDouble());
  final blue = _linearize(color.blue.toDouble());
  return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue);
}

double _linearize(double channel) {
  final normalized = channel / 255.0;
  if (normalized <= 0.04045) {
    return normalized / 12.92;
  }
  return math.pow((normalized + 0.055) / 1.055, 2.4).toDouble();
}
