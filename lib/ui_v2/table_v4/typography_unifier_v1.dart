import 'dart:collection';

class TypographyUnifierV1 {
  const TypographyUnifierV1();

  static Map<String, Object> build({
    required Map<String, Object?> injectorMap,
    required Map<String, Object?> fineTuneMap,
    required Map<String, Object?> compensationMap,
    required Map<String, Object?> responsiveScalingMap,
    required Map<String, Object?> cohesionMap,
  }) {
    final Map<String, List<String>> sectionIssues = <String, List<String>>{
      'injector': <String>[],
      'finetune': <String>[],
      'compensation': <String>[],
      'responsive': <String>[],
      'cohesion': <String>[],
    };
    _validateSection(
      name: 'injector',
      map: injectorMap,
      reference: injectorMap,
      issues: sectionIssues['injector']!,
    );
    _validateSection(
      name: 'finetune',
      map: fineTuneMap,
      reference: injectorMap,
      issues: sectionIssues['finetune']!,
    );
    _validateSection(
      name: 'compensation',
      map: compensationMap,
      reference: injectorMap,
      issues: sectionIssues['compensation']!,
    );
    _validateSection(
      name: 'responsive',
      map: responsiveScalingMap,
      reference: injectorMap,
      issues: sectionIssues['responsive']!,
    );
    _validateSection(
      name: 'cohesion',
      map: cohesionMap,
      reference: cohesionMap,
      issues: sectionIssues['cohesion']!,
    );
    _checkDrift(
      injectorMap: injectorMap,
      fineTuneMap: fineTuneMap,
      compensationMap: compensationMap,
      responsiveScalingMap: responsiveScalingMap,
      issues: sectionIssues['responsive']!,
    );
    final List<String> allIssues = sectionIssues.values
        .expand((list) => list)
        .toList();
    allIssues.sort();
    final Map<String, bool> sectionsOk = <String, bool>{
      for (final MapEntry<String, List<String>> entry in sectionIssues.entries)
        entry.key: entry.value.isEmpty,
    };
    final Map<String, Object> merged = SplayTreeMap<String, Object>();
    final double baseScale = _doubleValue(injectorMap, 'font_scale');
    final double fineTuneDelta = _doubleValue(fineTuneMap, 'font_scale_delta');
    final double compensationBias = _doubleValue(compensationMap, 'scale_bias');
    final double responsiveScale = _doubleValue(
      responsiveScalingMap,
      'scale_factor_normdpi',
      1.0,
    );
    final double mergedScale =
        (baseScale + fineTuneDelta + compensationBias) * responsiveScale;
    final double baseLetter = _doubleValue(injectorMap, 'letter_spacing');
    final double fineTuneLetter = _doubleValue(
      fineTuneMap,
      'letter_spacing_delta',
    );
    final double compensationLetter = _doubleValue(
      compensationMap,
      'letter_spacing_bias',
    );
    final double mergedLetter =
        baseLetter + fineTuneLetter + compensationLetter;
    final int baseWeight = _intValue(injectorMap, 'font_weight');
    final int fineTuneWeight = _intValue(fineTuneMap, 'weight_tweak');
    final int compensationWeight = _intValue(compensationMap, 'weight_bias');
    final int mergedWeight = (baseWeight + fineTuneWeight + compensationWeight)
        .clamp(100, 900);
    final int baseAlpha = _intValue(injectorMap, 'alpha');
    final int compensationAlpha = _intValue(compensationMap, 'alpha_bias');
    final int responsiveAlpha = _intValue(
      responsiveScalingMap,
      'alpha_adjust_normdpi',
    );
    final int mergedAlpha = (baseAlpha + compensationAlpha + responsiveAlpha)
        .clamp(0, 255);
    merged['font_scale'] = mergedScale;
    merged['letter_spacing'] = mergedLetter;
    merged['font_weight'] = mergedWeight;
    merged['alpha'] = mergedAlpha;
    return <String, Object>{
      'typography_unifier_v1': <String, Object>{
        'merged': merged,
        'sections_ok': sectionsOk,
        'issues': allIssues,
        'ready': false,
      },
    };
  }

  static void _validateSection({
    required String name,
    required Map<String, Object?> map,
    required Map<String, Object?> reference,
    required List<String> issues,
  }) {
    for (final String key in map.keys) {
      final Object? value = map[key];
      if (!_isPrimitive(value)) {
        issues.add('invalid:$name:$key');
      }
    }
    for (final String key in reference.keys) {
      if (!map.containsKey(key)) {
        issues.add('missing:$name:$key');
      }
    }
    for (final String key in map.keys) {
      if (!reference.containsKey(key)) {
        issues.add('extra:$name:$key');
      }
    }
  }

  static void _checkDrift({
    required Map<String, Object?> injectorMap,
    required Map<String, Object?> fineTuneMap,
    required Map<String, Object?> compensationMap,
    required Map<String, Object?> responsiveScalingMap,
    required List<String> issues,
  }) {
    final double totalScale =
        _doubleValue(injectorMap, 'font_scale') +
        _doubleValue(fineTuneMap, 'font_scale_delta') +
        _doubleValue(compensationMap, 'scale_bias');
    final double responsiveScale = _doubleValue(
      responsiveScalingMap,
      'scale_factor_normdpi',
      1.0,
    );
    if ((totalScale - responsiveScale).abs() > 0.15) {
      issues.add('drift:scale');
    }
    final double samplerLetter =
        _doubleValue(injectorMap, 'letter_spacing') +
        _doubleValue(fineTuneMap, 'letter_spacing_delta') +
        _doubleValue(compensationMap, 'letter_spacing_bias');
    if ((samplerLetter -
                _doubleValue(
                  responsiveScalingMap,
                  'letter_spacing',
                  samplerLetter,
                ))
            .abs() >
        0.3) {
      issues.add('drift:letter_spacing');
    }
    final int totalWeight =
        _intValue(injectorMap, 'font_weight') +
        _intValue(fineTuneMap, 'weight_tweak') +
        _intValue(compensationMap, 'weight_bias');
    final int responsiveWeight = _intValue(
      responsiveScalingMap,
      'font_weight',
      totalWeight,
    );
    if ((totalWeight - responsiveWeight).abs() > 150) {
      issues.add('drift:weight');
    }
    final int totalAlpha =
        _intValue(injectorMap, 'alpha') +
        _intValue(compensationMap, 'alpha_bias');
    final int responsiveAlpha = _intValue(
      responsiveScalingMap,
      'alpha_adjust_normdpi',
      totalAlpha,
    );
    if ((totalAlpha + responsiveAlpha).abs() > 255) {
      issues.add('drift:alpha');
    }
  }

  static bool _isPrimitive(Object? value) {
    return value is String || value is num || value is bool || value == null;
  }

  static double _doubleValue(
    Map<String, Object?> map,
    String key, [
    double fallback = 0.0,
  ]) {
    final Object? value = map[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static int _intValue(
    Map<String, Object?> map,
    String key, [
    int fallback = 0,
  ]) {
    final Object? value = map[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }
}
