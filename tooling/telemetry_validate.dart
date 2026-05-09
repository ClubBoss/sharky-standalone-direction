// Validate telemetry JSONL against a simple schema.
// Usage:
// dart run tooling/telemetry_validate.dart --schema build/ui_assets/telemetry_schema.json --in path/to/events.jsonl
// ASCII-only, deterministic, no external deps.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  String schemaPath = '';
  String inPath = '';
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--schema' && i + 1 < args.length) {
      schemaPath = args[++i];
    } else if (a == '--in' && i + 1 < args.length)
      inPath = args[++i];
  }
  if (schemaPath.isEmpty || inPath.isEmpty) {
    stderr.writeln('usage: --schema <schema.json> --in <events.jsonl>');
    exit(2);
  }

  Map<String, dynamic> schema;
  try {
    schema =
        jsonDecode(File(schemaPath).readAsStringSync()) as Map<String, dynamic>;
  } catch (e) {
    stderr.writeln('error: cannot read schema: $e');
    exit(2);
  }

  // Extract schema bits
  final events = (schema['events'] is Map)
      ? (schema['events'] as Map).cast<String, dynamic>()
      : <String, dynamic>{};
  final required = <String, List<String>>{};
  final optional = <String, List<String>>{};
  for (final e in events.entries) {
    final mp = (e.value is Map)
        ? (e.value as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    required[e.key] = (mp['required'] is List)
        ? (mp['required'] as List).map((x) => '$x').toList()
        : <String>[];
    optional[e.key] = (mp['optional'] is List)
        ? (mp['optional'] as List).map((x) => '$x').toList()
        : <String>[];
  }
  final enums = (schema['enums'] is Map)
      ? (schema['enums'] as Map).cast<String, dynamic>()
      : <String, dynamic>{};
  final enumStage = (enums['stage'] is List)
      ? (enums['stage'] as List).map((x) => '$x').toList()
      : <String>[];
  final enumLocale = (enums['locale'] is List)
      ? (enums['locale'] as List).map((x) => '$x').toList()
      : <String>[];

  // Validation helpers
  bool isAscii(String s) => s.runes.every((r) => r >= 0x00 && r <= 0x7F);
  bool isIso8601(String s) {
    try {
      DateTime.parse(s);
      return true;
    } catch (_) {
      return false;
    }
  }

  int total = 0, ok = 0, fail = 0;
  final lines = File(inPath).readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    final lineNo = i + 1;
    final raw = lines[i].trim();
    if (raw.isEmpty) {
      total++;
      fail++;
      stdout.writeln('line=$lineNo err=empty msg=empty line');
      continue;
    }
    Map<String, dynamic> obj;
    try {
      final parsed = jsonDecode(raw);
      if (parsed is! Map) throw const FormatException('not object');
      obj = parsed.cast<String, dynamic>();
    } catch (_) {
      total++;
      fail++;
      stdout.writeln('line=$lineNo err=invalid_json msg=not a JSON object');
      continue;
    }

    String errCode = '';
    String errMsg = '';

    // type
    final type = obj['type'];
    if (type is! String) {
      errCode = 'missing_required';
      errMsg = 'field "type" absent';
    } else if (!events.containsKey(type)) {
      errCode = 'unknown_type';
      errMsg = 'type "$type" not in schema';
    }

    // Required fields
    if (errCode.isEmpty) {
      final req = required[type] ?? const <String>[];
      for (final k in req) {
        if (!obj.containsKey(k)) {
          errCode = 'missing_required';
          errMsg = 'field "$k" absent';
          break;
        }
      }
    }

    // stage/locale enums
    final stage = obj['stage'];
    final locale = obj['locale'];
    if (errCode.isEmpty &&
        stage is String &&
        enumStage.isNotEmpty &&
        !enumStage.contains(stage)) {
      errCode = 'bad_enum';
      errMsg = 'stage "$stage" not in enum';
    }
    if (errCode.isEmpty &&
        locale is String &&
        enumLocale.isNotEmpty &&
        !enumLocale.contains(locale)) {
      errCode = 'bad_enum';
      errMsg = 'locale "$locale" not in enum';
    }

    // ts_iso
    final ts = obj['ts_iso'];
    if (errCode.isEmpty && ts is String && !isIso8601(ts)) {
      errCode = 'bad_ts';
      errMsg = 'ts_iso not ISO-8601';
    }
    if (errCode.isEmpty && ts is! String) {
      errCode = 'missing_required';
      errMsg = 'field "ts_iso" absent';
    }

    // ASCII string fields
    if (errCode.isEmpty) {
      for (final entry in obj.entries) {
        final k = entry.key;
        final v = entry.value;
        if (v is String && !isAscii(v)) {
          errCode = 'non_ascii';
          errMsg = 'field "$k" not ASCII';
          break;
        }
      }
    }

    total++;
    if (errCode.isEmpty) {
      ok++;
    } else {
      fail++;
      stdout.writeln('line=$lineNo err=$errCode msg=$errMsg');
    }
  }

  stdout.writeln('TLMT-VALID total=$total ok=$ok fail=$fail');
  exit(fail == 0 ? 0 : 1);
}
