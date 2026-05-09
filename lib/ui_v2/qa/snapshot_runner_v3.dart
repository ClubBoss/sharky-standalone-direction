import 'package:flutter/foundation.dart';

import '../persona/persona_renderer_v3.dart';
import '../persona/persona_snapshot_binder_v3.dart';
import '../persona/persona_snapshot_registry_v3.dart';
import 'snapshot_registry_v3.dart';

class SnapshotRunnerV3 {
  SnapshotRunnerV3({PersonaSnapshotBinderV3? binder})
    : binder = binder ?? PersonaSnapshotBinderV3();

  static const bool _hardGateEnabled = true;

  static const _allowedV4Keys = <String>{
    'v4Tint',
    'v4LabelSize',
    'v4LabelWeight',
    'v4LetterSpacing',
    'v4IconTone',
  };
  static const _coreKeys = [
    'surfaceToken',
    'motionFactor',
    'elevationFactor',
    'fusionToken',
  ];

  final PersonaSnapshotBinderV3 binder;

  Map<String, dynamic> captureSnapshot(
    String style, {
    PersonaRendererV3V4Style? v4Style,
  }) {
    binder.syncStyle(style);
    if (v4Style != null) {
      binder.attachV4Style(v4Style);
    }
    return binder.buildSnapshot();
  }

  Map<String, String> compareSnapshots(
    Map<String, dynamic> baseline,
    Map<String, dynamic> current,
  ) {
    final baselineVariant =
        baseline['variant'] ?? PersonaSnapshotRegistryV3.personaV3;
    final currentVariant =
        current['variant'] ?? PersonaSnapshotRegistryV3.personaV3;
    final results = <String, String>{};
    final keys = <String>{...baseline.keys, ...current.keys};
    if (baselineVariant != currentVariant) {
      results['variant'] = 'DIFF';
    } else {
      results['variant'] = 'OK';
    }
    if (baselineVariant == PersonaSnapshotRegistryV3.personaV4 &&
        currentVariant == PersonaSnapshotRegistryV3.personaV4) {
      final sanitizedBaseline = _sanitizeForComparison(baseline);
      final sanitizedCurrent = _sanitizeForComparison(current);
      final sanitizedKeys = <String>{
        ...sanitizedBaseline.keys,
        ...sanitizedCurrent.keys,
      };
      for (final key in sanitizedKeys) {
        if (key == 'variant') continue;
        final baselineValue = sanitizedBaseline[key];
        final currentValue = sanitizedCurrent[key];
        if (_allowedV4Keys.contains(key)) {
          results[key] = baselineValue == currentValue ? 'OK' : 'ALLOWED_DRIFT';
        } else {
          results[key] = baselineValue == currentValue ? 'OK' : 'DIFF';
        }
      }
      results['disallowedDrift'] = _hasDisallowedDiff(baseline, current)
          ? 'DIFF'
          : 'OK';
      return results;
    }
    for (final key in _coreKeys) {
      final baselineValue = baseline[key];
      final currentValue = current[key];
      results[key] = baselineValue == currentValue ? 'OK' : 'DIFF';
    }
    return results;
  }

  String runReport({
    required Map<String, Map<String, dynamic>> snapshots,
    Map<String, Map<String, dynamic>>? baselines,
  }) {
    final sortedVariants = snapshots.keys.toList()..sort();
    final buffer = StringBuffer('Persona Snapshot QA Consolidated');
    final outcomes = <_VariantHardGateResult>[];
    for (final variant in sortedVariants) {
      final snapshot = snapshots[variant]!;
      final baseline = baselines?[variant];
      final diff = baseline != null
          ? compareSnapshots(baseline, snapshot)
          : <String, String>{};
      final outcome = _hardGateCheck(variant, diff, baseline != null);
      outcomes.add(_VariantHardGateResult(variant, outcome));
      buffer.writeln();
      buffer.write('Variant: $variant');
      final displaySnapshot = variant == PersonaSnapshotRegistryV3.personaV4
          ? _compressSnapshot(_driftFunnel(snapshot))
          : snapshot;
      if (variant == PersonaSnapshotRegistryV3.personaV4) {
        buffer.writeln();
        buffer.write(' v4Tint: ${displaySnapshot['v4Tint']}');
        buffer.writeln();
        buffer.write(' fontSize: ${displaySnapshot['v4LabelSize']}');
        buffer.writeln();
        buffer.write(' fontWeight: ${displaySnapshot['v4LabelWeight']}');
        buffer.writeln();
        buffer.write(' letterSpacing: ${displaySnapshot['v4LetterSpacing']}');
        if (displaySnapshot.containsKey('v4IconTone')) {
          buffer.writeln();
          buffer.write(' iconTone: ${displaySnapshot['v4IconTone']}');
        }
      }
      if (baseline == null) {
        buffer.writeln();
        buffer.write('Baseline: missing');
      } else {
        buffer.writeln();
        buffer.write('Diff:');
        diff.forEach((key, status) {
          buffer.writeln();
          buffer.write('  $key: $status');
        });
      }
      buffer.writeln();
      buffer.write(
        'HardGate: ${outcome.passed ? 'PASS' : 'FAIL'} - ${outcome.reason}',
      );
      if (_hardGateEnabled && !outcome.passed) {
        buffer.writeln();
        buffer.write('HardGate enforced: FAIL');
      }
    }
    final consolidated = consolidateResults(outcomes);
    if (consolidated.isNotEmpty) {
      buffer.writeln();
      buffer.write(consolidated);
    }
    return buffer.toString();
  }

  void writeBaseline(Map<String, dynamic> snapshot, String variantKey) {
    final ordered = _orderedSnapshot(snapshot);
    final destination =
        '${SnapshotRegistryV3.personaBaselineDir}/$variantKey-baseline.txt';
    final buffer = StringBuffer('Baseline $variantKey');
    buffer.writeln();
    ordered.forEach((key, value) {
      buffer.writeln('$key=$value');
    });
    // TODO: Replace print with file write when wiring the baseline store.
    debugPrint('writeBaseline -> $destination\n$buffer');
  }

  Map<String, dynamic> _orderedSnapshot(Map<String, dynamic> snapshot) {
    final ordered = <String, dynamic>{};
    for (final key in _coreKeys) {
      if (snapshot.containsKey(key)) ordered[key] = snapshot[key];
    }
    final extras =
        snapshot.keys.where((key) => !_coreKeys.contains(key)).toList()..sort();
    for (final key in extras) {
      ordered[key] = snapshot[key];
    }
    return ordered;
  }

  Map<String, Map<String, dynamic>> runAllSnapshots(
    String style,
    PersonaRendererV3V4Style v4Style, {
    bool updateBaseline = false,
  }) {
    final v3 = captureSnapshot(style);
    final v4 = captureSnapshot(style, v4Style: v4Style);
    if (updateBaseline) {
      writeBaseline(v3, PersonaSnapshotRegistryV3.personaV3);
      writeBaseline(v4, PersonaSnapshotRegistryV3.personaV4);
    }
    return {
      PersonaSnapshotRegistryV3.personaV3: v3,
      PersonaSnapshotRegistryV3.personaV4: v4,
    };
  }

  String runCIValidation(
    String style,
    PersonaRendererV3V4Style v4Style, {
    Map<String, Map<String, dynamic>>? baselines,
  }) {
    final snapshots = runAllSnapshots(style, v4Style);
    final sortedVariants = snapshots.keys.toList()..sort();
    bool allPass = true;
    final lines = <String>[];
    final enforcementCandidates = <_VariantHardGateResult>[];
    final integrityRecords = <String, _IntegrityOutcome>{};
    for (final variant in sortedVariants) {
      final snapshot = snapshots[variant]!;
      final baseline = baselines?[variant];
      final integrity = baseline != null
          ? _checkBaselineIntegrity(baseline, variant)
          : _IntegrityOutcome(false, 'missing baseline');
      integrityRecords[variant] = integrity;
      final diff = baseline != null
          ? compareSnapshots(baseline, snapshot)
          : <String, String>{};
      final outcome = _hardGateCheck(variant, diff, baseline != null);
      enforcementCandidates.add(_VariantHardGateResult(variant, outcome));
      if (!outcome.passed || !integrity.ok) {
        allPass = false;
      }
      lines.add(
        'variant: $variant | status: ${outcome.passed ? 'PASS' : 'FAIL'} | reason: ${outcome.reason}',
      );
      lines.add(
        'baseline: $variant | integrity: ${integrity.ok ? 'OK' : 'FAIL'} | reason: ${integrity.reason}',
      );
    }
    final enforcement = enforceHardCI(enforcementCandidates, integrityRecords);
    if (!enforcement.passed) {
      allPass = false;
    }
    final invariants = enforceInvariants(snapshots);
    if (!invariants.passed) {
      allPass = false;
    }
    final buffer = StringBuffer('CI_CHECK: ${allPass ? 'PASS' : 'FAIL'}');
    for (final line in lines) {
      buffer.writeln();
      buffer.write(line);
    }
    buffer.writeln();
    buffer.write(
      'ci_enforcement: ${enforcement.passed ? 'PASS' : 'CI_STOP'} | reason: ${enforcement.reason}',
    );
    buffer.writeln();
    buffer.write(
      'invariants: ${invariants.passed ? 'PASS' : 'FAIL'} | reason: ${invariants.reason}',
    );
    return buffer.toString();
  }

  static Map<String, dynamic> _sanitizeForComparison(
    Map<String, dynamic> snapshot,
  ) {
    final sanitized = <String, dynamic>{};
    for (final key in _coreKeys) {
      if (snapshot.containsKey(key)) sanitized[key] = snapshot[key];
    }
    sanitized.addAll(_compressSnapshot(_driftFunnel(snapshot)));
    sanitized.addAll(_finalizeAllowedDrift(sanitized));
    return sanitized;
  }

  static Map<String, dynamic> _driftFunnel(Map<String, dynamic> snapshot) {
    final funnel = <String, dynamic>{};
    final seen = <String>{};
    final orderedKeys = _allowedV4Keys.toList()..sort();
    for (final key in orderedKeys) {
      if (!snapshot.containsKey(key)) continue;
      final value = snapshot[key];
      final repr = value?.toString() ?? 'null';
      if (seen.contains(repr)) continue;
      seen.add(repr);
      funnel[key] = value;
    }
    return funnel;
  }

  static Map<String, dynamic> _compressSnapshot(Map<String, dynamic> snapshot) {
    final compressed = <String, dynamic>{};
    final canonicalOrder = _allowedV4Keys.toList()..sort();
    final seenValues = <String>{};
    for (final key in canonicalOrder) {
      if (!snapshot.containsKey(key)) continue;
      final value = snapshot[key];
      final repr = value?.toString() ?? 'null';
      if (seenValues.contains(repr)) continue;
      seenValues.add(repr);
      compressed[key] = value;
    }
    return compressed;
  }

  static Map<String, dynamic> _finalizeAllowedDrift(
    Map<String, dynamic> snapshot,
  ) {
    final finalized = <String, dynamic>{};
    for (final key in _allowedV4Keys) {
      if (!snapshot.containsKey(key)) continue;
      final value = snapshot[key];
      finalized[key] = _normalizeDriftValue(value);
    }
    return finalized;
  }

  static dynamic _normalizeDriftValue(dynamic value) {
    if (value is String && value.startsWith('0x')) {
      final hex = value.substring(2).padLeft(8, '0').toUpperCase();
      return '#$hex';
    }
    if (value is num) {
      final formatted = value.toStringAsFixed(2);
      return formatted
          .replaceAll(RegExp(r'(?<=\.\d*?)0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return value;
  }

  bool _hasDisallowedDiff(
    Map<String, dynamic> baseline,
    Map<String, dynamic> current,
  ) {
    final keys = <String>{...baseline.keys, ...current.keys};
    for (final key in keys) {
      if (_coreKeys.contains(key) ||
          _allowedV4Keys.contains(key) ||
          key == 'variant') {
        continue;
      }
      if (baseline[key] != current[key]) return true;
    }
    return false;
  }

  _IntegrityOutcome _checkBaselineIntegrity(
    Map<String, dynamic> baseline,
    String variant,
  ) {
    final allowed = <String>{..._coreKeys, 'variant'};
    if (variant == PersonaSnapshotRegistryV3.personaV4) {
      allowed.addAll(_allowedV4Keys);
    }
    for (final key in baseline.keys) {
      if (!allowed.contains(key)) {
        return _IntegrityOutcome(false, 'unexpected key $key');
      }
    }
    return _IntegrityOutcome(true, 'OK');
  }

  String consolidateResults(List<_VariantHardGateResult> results) {
    if (results.isEmpty) return '';
    final sorted = [...results]..sort((a, b) => a.variant.compareTo(b.variant));
    final buffer = StringBuffer('Consolidated QA Summary');
    for (final result in sorted) {
      buffer.writeln();
      buffer.write(
        'variant: ${result.variant} | status: ${result.outcome.passed ? 'PASS' : 'FAIL'} | reason: ${result.outcome.reason}',
      );
    }
    return buffer.toString();
  }

  _HardGateOutcome _hardGateCheck(
    String variant,
    Map<String, String> diff,
    bool hasBaseline,
  ) {
    if (!hasBaseline) {
      return _HardGateOutcome(false, 'missing baseline');
    }
    if (variant == PersonaSnapshotRegistryV3.personaV4) {
      if (diff['disallowedDrift'] == 'DIFF') {
        return _HardGateOutcome(false, 'DISALLOWED_DRIFT');
      }
      final failEntry = diff.entries.firstWhere(
        (entry) =>
            entry.key != 'variant' &&
            entry.key != 'disallowedDrift' &&
            entry.value == 'DIFF',
        orElse: () => const MapEntry('', ''),
      );
      if (failEntry.key.isNotEmpty) {
        return _HardGateOutcome(false, 'DIFF ${failEntry.key}');
      }
      return _HardGateOutcome(true, 'OK');
    }
    final failEntry = diff.entries.firstWhere(
      (entry) => entry.key != 'variant' && entry.value != 'OK',
      orElse: () => const MapEntry('', ''),
    );
    if (failEntry.key.isNotEmpty) {
      return _HardGateOutcome(false, 'DIFF ${failEntry.key}');
    }
    return _HardGateOutcome(true, 'OK');
  }
}

_CIEnforcementOutcome enforceHardCI(
  List<_VariantHardGateResult> results,
  Map<String, _IntegrityOutcome> integrityRecords,
) {
  for (final result in results) {
    final integrity = integrityRecords[result.variant];
    if (integrity == null || !integrity.ok) {
      return _CIEnforcementOutcome(
        false,
        'BASELINE_INTEGRITY_FAIL (${integrity?.reason ?? 'missing'})',
      );
    }
    if (!result.outcome.passed) {
      if (result.variant == PersonaSnapshotRegistryV3.personaV4) {
        if (result.outcome.reason.contains('DISALLOWED_DRIFT')) {
          return _CIEnforcementOutcome(false, 'DISALLOWED_DRIFT');
        }
        return _CIEnforcementOutcome(false, 'NON_CANONICAL_VALUE');
      }
      return _CIEnforcementOutcome(false, 'V3_MISMATCH');
    }
  }
  return const _CIEnforcementOutcome(true, 'OK');
}

_CIInvariantsOutcome enforceInvariants(
  Map<String, Map<String, dynamic>> snapshots,
) {
  for (final entry in snapshots.entries) {
    final variant = entry.key;
    final snapshot = entry.value;
    final allowed = <String>{...SnapshotRunnerV3._coreKeys, 'variant'};
    if (variant == PersonaSnapshotRegistryV3.personaV4) {
      allowed.addAll(SnapshotRunnerV3._allowedV4Keys);
      final sanitized = SnapshotRunnerV3._compressSnapshot(
        SnapshotRunnerV3._driftFunnel(snapshot),
      );
      final normalized = SnapshotRunnerV3._finalizeAllowedDrift(sanitized);
      for (final key in SnapshotRunnerV3._allowedV4Keys) {
        if (normalized[key] != sanitized[key]) {
          return _CIInvariantsOutcome(false, 'NON_CANONICAL_VALUE');
        }
      }
    }
    for (final key in snapshot.keys) {
      if (!allowed.contains(key)) {
        return _CIInvariantsOutcome(false, 'INVARIANT_FAIL ($key)');
      }
    }
  }
  return const _CIInvariantsOutcome(true, 'OK');
}

class _CIEnforcementOutcome {
  const _CIEnforcementOutcome(this.passed, this.reason);

  final bool passed;
  final String reason;
}

class _HardGateOutcome {
  const _HardGateOutcome(this.passed, this.reason);

  final bool passed;
  final String reason;
}

class _VariantHardGateResult {
  const _VariantHardGateResult(this.variant, this.outcome);

  final String variant;
  final _HardGateOutcome outcome;
}

class _CIInvariantsOutcome {
  const _CIInvariantsOutcome(this.passed, this.reason);

  final bool passed;
  final String reason;
}

class _IntegrityOutcome {
  const _IntegrityOutcome(this.ok, this.reason);

  final bool ok;
  final String reason;
}
