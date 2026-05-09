import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/constants/telemetry_schema.dart';

Future<void> main(List<String> args) async {
  final generator = _DesignerHandoffPackager();
  final manifest = await generator.buildManifest();
  await generator.writeManifest(manifest);
  await generator.emitTelemetry();
}

class _DesignerHandoffPackager {
  final DateTime _timestamp = DateTime.now().toUtc();
  final List<_Token> _colorTokens = <_Token>[];
  final List<_Token> _spacingTokens = <_Token>[];
  final List<_Token> _typographyTokens = <_Token>[];
  final List<_AssetEntry> _assets = <_AssetEntry>[];
  final List<_TelemetryEntry> _telemetryEntries = <_TelemetryEntry>[];

  Future<String> buildManifest() async {
    final themeSource = await File(
      'lib/ui_v3/theme/visual_theme_v3.dart',
    ).readAsString();
    _parseColors(themeSource);
    _parseSpacings(themeSource);
    _parseTypography(themeSource);
    await _loadAssets();
    await _loadTelemetryEntries();

    final buffer = StringBuffer()
      ..writeln('# Designer Handoff Manifest')
      ..writeln('Generated: ${_timestamp.toIso8601String()}')
      ..writeln()
      ..writeln('## Section 1 — Theme Tokens')
      ..writeln('### Colors')
      ..writeln('| Token | Value |')
      ..writeln('| ----- | ----- |');
    for (final token in _colorTokens) {
      buffer.writeln('| ${token.name} | ${token.value} |');
    }
    buffer
      ..writeln()
      ..writeln('### Spacing')
      ..writeln('| Token | Value |')
      ..writeln('| ----- | ----- |');
    for (final token in _spacingTokens) {
      buffer.writeln('| ${token.name} | ${token.value} |');
    }
    buffer
      ..writeln()
      ..writeln('### Typography')
      ..writeln('| Token | Definition |')
      ..writeln('| ----- | ---------- |');
    for (final token in _typographyTokens) {
      buffer.writeln('| ${token.name} | ${token.value} |');
    }

    buffer
      ..writeln()
      ..writeln('## Section 2 — Asset List')
      ..writeln('| Asset | Size (KB) |')
      ..writeln('| ----- | ---------- |');
    for (final asset in _assets) {
      buffer.writeln('| ${asset.path} | ${asset.sizeKb.toStringAsFixed(2)} |');
    }

    buffer
      ..writeln()
      ..writeln('## Section 3 — UX/Visual Telemetry Events')
      ..writeln('| Event | Description |')
      ..writeln('| ----- | ----------- |');
    for (final entry in _telemetryEntries) {
      buffer.writeln('| ${entry.name} | ${entry.description} |');
    }

    final gitSha = await _readCommitSha();
    buffer
      ..writeln()
      ..writeln('## Section 4 — Build Info')
      ..writeln('- Commit: ${gitSha ?? 'unknown'}')
      ..writeln('- Timestamp: ${_timestamp.toIso8601String()}');

    return buffer.toString();
  }

  Future<void> writeManifest(String contents) async {
    final file = File('release/_reports/designer_handoff_manifest.md');
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
  }

  Future<void> emitTelemetry() async {
    final payload = <String, Object>{
      'event': TelemetryEvents.designerHandoffPackaged,
      'timestamp': _timestamp.toIso8601String(),
      'tokens':
          _colorTokens.length +
          _spacingTokens.length +
          _typographyTokens.length,
      'assets': _assets.length,
      'events': _telemetryEntries.length,
    };
    final telemetryFile = File('release/_reports/telemetry.jsonl');
    await telemetryFile.parent.create(recursive: true);
    await telemetryFile.writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  void _parseColors(String source) {
    final constPattern = RegExp(r'static const Color\s+(\w+)\s*=\s*([^;]+);');
    for (final match in constPattern.allMatches(source)) {
      _colorTokens.add(_Token(match.group(1)!, match.group(2)!.trim()));
    }

    final getterPattern = RegExp(
      r'static Color\s+get\s+(\w+)\s*=>\s*([^;]+);',
      dotAll: true,
    );
    for (final match in getterPattern.allMatches(source)) {
      final expression = match
          .group(2)!
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      _colorTokens.add(_Token(match.group(1)!, expression));
    }
  }

  void _parseSpacings(String source) {
    final spacingPattern = RegExp(
      r'static const double\s+(spacing\w+)\s*=\s*([^;]+);',
    );
    for (final match in spacingPattern.allMatches(source)) {
      _spacingTokens.add(_Token(match.group(1)!, match.group(2)!.trim()));
    }
  }

  void _parseTypography(String source) {
    final typographyPattern = RegExp(
      r'(\w+):\s*textThemeBase\.\w+\?\.\w+\((.*?)\),',
      dotAll: true,
    );
    for (final match in typographyPattern.allMatches(source)) {
      final content = match
          .group(2)!
          .split('\n')
          .map((line) => line.split('//').first.trim())
          .where((line) => line.isNotEmpty)
          .join(' ');
      _typographyTokens.add(_Token(match.group(1)!, content));
    }
  }

  Future<void> _loadAssets() async {
    const directories = <String>['assets/mascot', 'assets/icons'];
    for (final dirPath in directories) {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) {
        continue;
      }
      await for (final entity in dir.list(recursive: true)) {
        if (entity is! File) continue;
        final sizeKb = await entity.length() / 1024;
        _assets.add(_AssetEntry(entity.path, sizeKb));
      }
    }
    _assets.sort((a, b) => a.path.compareTo(b.path));
  }

  Future<void> _loadTelemetryEntries() async {
    final mdLines = await File('TELEMETRY_EVENTS.md').readAsLines();
    final names = <String>{};
    for (final line in mdLines) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('- ')) continue;
      final name = trimmed.substring(2).trim();
      if (name.startsWith('visual_') || name.startsWith('ux_')) {
        names.add(name);
      }
    }

    final schemaById = {for (final def in TelemetrySchema.events) def.id: def};
    for (final name in names.toList()..sort()) {
      final definition = schemaById[name];
      final description = definition?.description ?? 'No description';
      _telemetryEntries.add(_TelemetryEntry(name, description));
    }
  }

  Future<String?> _readCommitSha() async {
    try {
      final result = await Process.run('git', ['rev-parse', 'HEAD']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (_) {
      // ignore
    }
    return null;
  }
}

class _Token {
  const _Token(this.name, this.value);

  final String name;
  final String value;
}

class _AssetEntry {
  const _AssetEntry(this.path, this.sizeKb);

  final String path;
  final double sizeKb;
}

class _TelemetryEntry {
  const _TelemetryEntry(this.name, this.description);

  final String name;
  final String description;
}
