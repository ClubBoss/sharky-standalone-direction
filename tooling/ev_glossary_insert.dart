// Insert standardized EV line into Mini-glossary for non-Cash/non-MTT modules.
// Usage: dart run tooling/ev_glossary_insert.dart --fix
// Options: --dry-run to preview; --verbose for logs.

import 'dart:io';

void main(List<String> args) {
  var fix = false;
  var dry = false;
  var verbose = false;
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--fix') fix = true;
    if (a == '--dry-run') dry = true;
    if (a == '--verbose') verbose = true;
  }
  final modules = _discoverModules();
  final targets = modules.where(
    (m) => !m.startsWith('cash_') && !m.startsWith('mtt_') && m != '_reference',
  );

  final evLine =
      "EV: Expected Value - the average amount you'd win or lose if you made the same play many times";

  var files = 0;
  var changed = 0;
  for (final m in targets) {
    final path = 'content/$m/v1/theory.md';
    final f = File(path);
    if (!f.existsSync()) continue;
    files++;
    final raw = f.readAsStringSync();
    final res = _insertEv(raw, evLine);
    if (res != null && res != raw) {
      changed++;
      if (verbose || dry) {
        stdout.writeln('EV+INSERT: $path');
      }
      if (fix && !dry) {
        f.writeAsStringSync(res);
      }
    } else {
      if (verbose) stdout.writeln('OK: $path');
    }
  }
  stdout.writeln('EV-INSERT files=$files changed=$changed');
}

String? _insertEv(String raw, String evLine) {
  final lines = raw.split('\n');
  // Find "Mini-glossary" header line index
  int idx = -1;
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].trim() == 'Mini-glossary') {
      idx = i;
      break;
    }
  }
  if (idx == -1) return null; // no section; don't modify

  // Determine end of mini-glossary block: until next major header or known markers
  final endIdx = _findGlossaryEnd(lines, start: idx + 1);

  // Check if EV already present within block
  for (var i = idx + 1; i < endIdx; i++) {
    if (lines[i].trim().startsWith('EV:')) {
      return null; // already has EV line
    }
  }

  // Insert EV line one line before endIdx, maintaining a newline separation if needed
  final out = <String>[];
  out.addAll(lines.sublist(0, endIdx));
  // Avoid duplicate blank lines
  if (out.isNotEmpty && out.last.trim().isEmpty) {
    // keep single blank
  }
  out.add(evLine);
  out.addAll(lines.sublist(endIdx));
  return out.join('\n');
}

int _findGlossaryEnd(List<String> lines, {required int start}) {
  final n = lines.length;
  for (var i = start; i < n; i++) {
    final t = lines[i].trim();
    if (t == 'Contrast') return i;
    if (t.startsWith('_This module uses')) return i;
    if (t == 'See also') return i;
    // Guard against next header-like line (e.g., Title Case words, no colon)
    if (t.isNotEmpty && !_isGlossaryEntry(t) && _looksLikeHeader(t)) return i;
  }
  return n;
}

bool _isGlossaryEntry(String t) {
  // Glossary entries often have ":" or "/" tokens; be permissive
  if (t.contains(':')) return true;
  if (t.contains('/')) return true;
  if (t.contains('_')) return true;
  if (t.contains('(') && t.contains(')')) return true;
  return false;
}

bool _looksLikeHeader(String t) {
  // Simple heuristic: line with no punctuation besides underscores and spaces that starts with uppercase word
  if (t.contains(':') || t.contains('.') || t.contains(',')) return false;
  if (t.startsWith('#')) return true; // markdown header
  if (t == t.toUpperCase()) return true; // SHOUTY words
  // Title case single or two-word headers
  final words = t.split(RegExp(r'\s+'));
  if (words.isEmpty) return false;
  final first = words.first;
  if (first.isEmpty) return false;
  final c = first.codeUnitAt(0);
  return c >= 65 && c <= 90; // 'A'..'Z'
}

List<String> _discoverModules() {
  final root = Directory('content');
  if (!root.existsSync()) return <String>[];
  final out = <String>[];
  for (final e in root.listSync()) {
    if (e is! Directory) continue;
    final id = _basename(e.path);
    if (id.isEmpty || id.startsWith('_')) continue;
    final v1 = Directory('${e.path}/v1');
    if (v1.existsSync()) out.add(id);
  }
  out.sort();
  return out;
}

String _basename(String path) {
  final norm = path.replaceAll('\\', '/');
  var s = norm;
  if (s.endsWith('/')) s = s.substring(0, s.length - 1);
  final idx = s.lastIndexOf('/');
  return idx == -1 ? s : s.substring(idx + 1);
}
