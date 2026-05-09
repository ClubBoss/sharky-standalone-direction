import 'dart:convert';
import 'dart:io';

/// Designer Integration & Visual Sync Tool (Stage Ω17)
///
/// Reads designer_handoff_manifest.md and generates JSON exports for design tools:
/// - figma_tokens.json: Theme tokens in JSON format
/// - assets_index.json: Asset paths and sizes
///
/// Usage:
///   dart run tools/designer_sync_uploader.dart
void main() async {
  final stopwatch = Stopwatch()..start();

  print('=== Designer Sync Uploader (Stage Ω17) ===\n');

  final manifestPath = 'release/_reports/designer_handoff_manifest.md';
  final exportDir = Directory('release/_exports');

  // Ensure export directory exists
  if (!await exportDir.exists()) {
    await exportDir.create(recursive: true);
  }

  // Read manifest
  final manifestFile = File(manifestPath);
  if (!await manifestFile.exists()) {
    print('ERROR: Manifest not found at $manifestPath');
    exit(1);
  }

  final manifestContent = await manifestFile.readAsString();
  final lines = manifestContent.split('\n');

  // Parse tokens and assets
  final tokens = _parseTokens(lines);
  final assets = _parseAssets(lines);

  // Generate JSON exports
  final figmaTokensPath = '${exportDir.path}/figma_tokens.json';
  final assetsIndexPath = '${exportDir.path}/assets_index.json';

  await _writeFigmaTokens(figmaTokensPath, tokens);
  await _writeAssetsIndex(assetsIndexPath, assets);

  stopwatch.stop();

  // Print ASCII summary
  _printSummary(tokens, assets, figmaTokensPath, assetsIndexPath);

  // Emit telemetry
  await _emitTelemetry(
    tokens.length,
    assets.length,
    stopwatch.elapsedMilliseconds,
  );

  print('\n✓ Designer sync upload complete.');
}

/// Parse theme tokens from manifest markdown
Map<String, String> _parseTokens(List<String> lines) {
  final tokens = <String, String>{};
  var inColorSection = false;
  var inSpacingSection = false;
  var inTypographySection = false;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    // Section detection
    if (line.startsWith('## Section 1')) {
      continue;
    } else if (line == '### Colors') {
      inColorSection = true;
      inSpacingSection = false;
      inTypographySection = false;
      i++; // Skip table header
      i++; // Skip separator
      continue;
    } else if (line == '### Spacing') {
      inColorSection = false;
      inSpacingSection = true;
      inTypographySection = false;
      i++; // Skip table header
      i++; // Skip separator
      continue;
    } else if (line == '### Typography') {
      inColorSection = false;
      inSpacingSection = false;
      inTypographySection = true;
      i++; // Skip table header
      i++; // Skip separator
      continue;
    } else if (line.startsWith('## Section')) {
      // End of tokens section
      break;
    }

    // Parse token lines
    if (line.startsWith('|') && !line.contains('-----')) {
      final parts = line.split('|').map((e) => e.trim()).toList();
      if (parts.length >= 3 && parts[1].isNotEmpty && parts[2].isNotEmpty) {
        final name = parts[1];
        var value = parts[2];

        if (inColorSection) {
          // Extract hex color from Color(0xFF...)
          final colorMatch = RegExp(
            r'Color\(0x([0-9A-F]+)\)',
          ).firstMatch(value);
          if (colorMatch != null) {
            final hex = colorMatch.group(1)!;
            // Convert to #RRGGBB format (strip alpha if present)
            if (hex.length == 8) {
              value = '#${hex.substring(2)}';
            } else {
              value = '#$hex';
            }
          } else if (value.contains('withValues') ||
              value.contains('kUseDarkSkin')) {
            // Skip complex computed values
            continue;
          }
        } else if (inSpacingSection) {
          // Keep numeric values as-is
          value = value.replaceAll('.0', '');
        } else if (inTypographySection) {
          // Keep typography definitions as-is for reference
          value = value.replaceAll(', ', ',');
        }

        tokens[name] = value;
      }
    }
  }

  return tokens;
}

/// Parse assets from manifest markdown
List<Map<String, dynamic>> _parseAssets(List<String> lines) {
  final assets = <Map<String, dynamic>>[];
  var inAssetSection = false;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    if (line == '## Section 2 — Asset List') {
      inAssetSection = true;
      i++; // Skip table header
      i++; // Skip separator
      continue;
    } else if (line.startsWith('## Section') && inAssetSection) {
      break;
    }

    if (inAssetSection && line.startsWith('|') && !line.contains('-----')) {
      final parts = line.split('|').map((e) => e.trim()).toList();
      if (parts.length >= 3 && parts[1].isNotEmpty && parts[2].isNotEmpty) {
        final path = parts[1];
        final sizeStr = parts[2].replaceAll(' KB', '').trim();
        final sizeKb = double.tryParse(sizeStr) ?? 0.0;

        assets.add({
          'path': path,
          'size_kb': sizeKb,
          'size_bytes': (sizeKb * 1024).round(),
        });
      }
    }
  }

  return assets;
}

/// Write figma_tokens.json
Future<void> _writeFigmaTokens(String path, Map<String, String> tokens) async {
  final output = <String, dynamic>{
    'colors': {},
    'spacing': {},
    'typography': {},
  };

  // Categorize tokens
  for (final entry in tokens.entries) {
    final name = entry.key;
    final value = entry.value;

    if (name.contains('spacing') ||
        name == 'spacingXS' ||
        name == 'spacingS' ||
        name == 'spacingSM' ||
        name == 'spacingM' ||
        name == 'spacingL' ||
        name == 'spacingXL') {
      output['spacing'][name] = value;
    } else if (name.contains('display') ||
        name.contains('headline') ||
        name.contains('body') ||
        name.contains('label')) {
      output['typography'][name] = value;
    } else {
      output['colors'][name] = value;
    }
  }

  final jsonStr = const JsonEncoder.withIndent('  ').convert(output);
  await File(path).writeAsString(jsonStr);
}

/// Write assets_index.json
Future<void> _writeAssetsIndex(
  String path,
  List<Map<String, dynamic>> assets,
) async {
  final output = {
    'assets': assets,
    'total_count': assets.length,
    'total_size_kb': assets.fold<double>(
      0.0,
      (sum, a) => sum + (a['size_kb'] as double),
    ),
  };

  final jsonStr = const JsonEncoder.withIndent('  ').convert(output);
  await File(path).writeAsString(jsonStr);
}

/// Print ASCII summary
void _printSummary(
  Map<String, String> tokens,
  List<Map<String, dynamic>> assets,
  String figmaPath,
  String assetsPath,
) {
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ Designer Sync Summary                                   │');
  print('├─────────────────────────────────────────────────────────┤');
  print(
    '│ Tokens Exported:  ${tokens.length.toString().padLeft(3)}                                │',
  );
  print(
    '│ Assets Indexed:   ${assets.length.toString().padLeft(3)}                                │',
  );
  print('├─────────────────────────────────────────────────────────┤');
  print('│ Exports:                                                │');
  print('│   - $figmaPath');
  print('│   - $assetsPath');
  print('└─────────────────────────────────────────────────────────┘');
}

/// Emit telemetry event
Future<void> _emitTelemetry(int tokens, int assets, int durationMs) async {
  final telemetryFile = File('release/_exports/designer_sync_telemetry.jsonl');
  final event = {
    'event': 'designer_sync_uploaded',
    'tokens': tokens,
    'assets': assets,
    'duration_ms': durationMs,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
  };

  final eventLine = '${jsonEncode(event)}\n';

  try {
    if (await telemetryFile.exists()) {
      await telemetryFile.writeAsString(eventLine, mode: FileMode.append);
    } else {
      await telemetryFile.writeAsString(eventLine);
    }
  } catch (e) {
    // Gracefully handle telemetry write failures
    print('Note: Could not write telemetry event ($e)');
  }
}
