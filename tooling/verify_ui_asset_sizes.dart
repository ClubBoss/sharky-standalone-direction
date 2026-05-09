// Verify UI asset sizes against a committed budget.
// Usage:
//   dart run tooling/verify_ui_asset_sizes.dart \
//     --manifest build/ui_assets/manifest.json \
//     --budget tooling/budgets/ui_assets_budget.json
// ASCII-only. Deterministic. Exits 1 on budget violation.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  String manifestPath = 'build/ui_assets/manifest.json';
  String budgetPath = 'tooling/budgets/ui_assets_budget.json';

  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--manifest' && i + 1 < args.length) {
      manifestPath = args[++i];
    } else if (a == '--budget' && i + 1 < args.length) {
      budgetPath = args[++i];
    }
  }

  Map<String, dynamic> manifest;
  Map<String, dynamic> budget;
  try {
    manifest =
        jsonDecode(File(manifestPath).readAsStringSync())
            as Map<String, dynamic>;
  } catch (e) {
    stderr.writeln('error: cannot read manifest: $e');
    exit(1);
  }
  try {
    budget =
        jsonDecode(File(budgetPath).readAsStringSync()) as Map<String, dynamic>;
  } catch (e) {
    stderr.writeln('error: cannot read budget: $e');
    exit(1);
  }

  final sizes =
      (manifest['sizes'] as Map?)?.cast<String, dynamic>() ??
      <String, dynamic>{};
  final totalBytes = manifest['total_bytes'] is int
      ? manifest['total_bytes'] as int
      : _sumSizes(sizes);
  final filesBudget =
      (budget['files'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
  final totalMax = budget['total_max_bytes'] is int
      ? budget['total_max_bytes'] as int
      : 0;
  // Optional gzip fields
  final sizesGzip =
      (manifest['sizes_gzip'] as Map?)?.cast<String, dynamic>() ??
      <String, dynamic>{};
  final totalBytesGzip = manifest['total_bytes_gzip'] is int
      ? manifest['total_bytes_gzip'] as int
      : _sumSizes(sizesGzip);
  final totalMaxGzip = budget['total_bytes_gzip'] is int
      ? budget['total_bytes_gzip'] as int
      : 0;
  final filesBudgetGzip =
      (budget['files_gzip'] as Map?)?.cast<String, dynamic>() ??
      <String, dynamic>{};

  var ok = true;

  final fileNames = sizes.keys.toList()..sort();
  final results = <String>[];
  for (final name in fileNames) {
    final sizeVal = sizes[name];
    final size = sizeVal is int
        ? sizeVal
        : (sizeVal is num ? sizeVal.toInt() : 0);
    final maxVal = filesBudget[name];
    final max = maxVal is int ? maxVal : (maxVal is num ? maxVal.toInt() : 0);
    final pass = max == 0 ? true : size <= max;
    if (!pass) ok = false;
    results.add('file=$name size=$size max=$max ${pass ? 'OK' : 'FAIL'}');
  }

  final totalPass = totalMax == 0 ? true : totalBytes <= totalMax;
  if (!totalPass) ok = false;

  stdout.writeln(
    'UIASSETS-SIZES total=$totalBytes/$totalMax ${totalPass ? 'OK' : 'FAIL'}',
  );
  for (final line in results) {
    stdout.writeln(line);
  }

  // Optional gzip checks (only if limits present)
  final runTotalGzip = totalMaxGzip > 0;
  final runPerFileGzip = filesBudgetGzip.isNotEmpty;
  if (runTotalGzip || runPerFileGzip) {
    final totalGzipPass = !runTotalGzip ? true : totalBytesGzip <= totalMaxGzip;
    if (!totalGzipPass) ok = false;
    stdout.writeln(
      'UIASSETS-SIZES-GZIP total_gzip=$totalBytesGzip/$totalMaxGzip ${totalGzipPass ? 'OK' : 'FAIL'}',
    );
    if (runPerFileGzip) {
      final names = <String>{
        ...sizesGzip.keys,
        ...filesBudgetGzip.keys,
      }.toList()..sort();
      for (final name in names) {
        final curVal = sizesGzip[name];
        final cur = curVal is int
            ? curVal
            : (curVal is num ? curVal.toInt() : 0);
        final maxVal = filesBudgetGzip[name];
        final max = maxVal is int
            ? maxVal
            : (maxVal is num ? maxVal.toInt() : 0);
        final pass = max == 0 ? true : cur <= max;
        if (!pass) ok = false;
        stdout.writeln(
          'file=$name gzip=$cur max_gzip=$max ${pass ? 'OK' : 'FAIL'}',
        );
      }
    }
  }

  exit(ok ? 0 : 1);
}

int _sumSizes(Map<String, dynamic> sizes) {
  var sum = 0;
  for (final v in sizes.values) {
    if (v is int) {
      sum += v;
    } else if (v is num)
      sum += v.toInt();
  }
  return sum;
}
