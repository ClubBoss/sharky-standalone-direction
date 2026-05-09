// Core track patcher: add "### Contrast line", enforce position tokens (avoid "seat"), and trim verbosity.
// Usage: dart run tooling/core_patch.dart --fix [--verbose]
// - Inserts a short Contrast line section between "Mini example" and "Common mistakes" if missing.
// - Replaces whole-word "seat"/"seats" with "position"/"positions".
// - Trims verbosity by removing trailing "Why:" and "Why it happens:" clauses on lines.
// - Keeps ASCII-only text; run ascii_sanitize separately after.

import 'dart:io';

void main(List<String> args) {
  var fix = false;
  var verbose = false;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--fix') fix = true;
    if (args[i] == '--verbose') verbose = true;
  }
  final coreModules = _discoverCoreModules();
  var files = 0, changed = 0;
  for (final m in coreModules) {
    final p = 'content/$m/v1/theory.md';
    final f = File(p);
    if (!f.existsSync()) continue;
    files++;
    final raw = f.readAsStringSync();
    final updated = _process(raw);
    if (updated != null && updated != raw) {
      changed++;
      if (verbose) stdout.writeln('CORE-PATCH: $p');
      if (fix) f.writeAsStringSync(updated);
    }
  }
  stdout.writeln('CORE-PATCH files=$files changed=$changed');
}

String? _process(String raw) {
  final lines = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');

  // Pass 1: Replace whole-word 'seat'/'seats' with 'position'/'positions'. Avoid in code fences.
  bool inFence = false;
  for (var i = 0; i < lines.length; i++) {
    final l = lines[i];
    if (l.trimLeft().startsWith('```') || l.trimLeft().startsWith('~~~')) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    var t = lines[i];
    // Whole-word replacements using regex boundaries
    t = t.replaceAll(RegExp(r'\bSeats\b'), 'Positions');
    t = t.replaceAll(RegExp(r'\bseats\b'), 'positions');
    t = t.replaceAll(RegExp(r'\bSeat\b'), 'Position');
    t = t.replaceAll(RegExp(r'\bseat\b'), 'position');
    lines[i] = t;
  }

  // Replace any prior markdown header variant with plain header expected by audit
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].trim() == '### Contrast line') {
      lines[i] = 'Contrast line';
    }
  }

  // Pass 2: Insert Contrast line section between Mini example and Common mistakes if missing.
  final hasContrastLineHeader = lines.any((l) => l.trim() == 'Contrast line');
  if (!hasContrastLineHeader) {
    final miniIdx = _findExactHeader(lines, 'Mini example');
    final commonIdx = _findExactHeader(lines, 'Common mistakes');
    if (miniIdx != -1 && commonIdx != -1 && commonIdx > miniIdx) {
      final insertAt = commonIdx; // insert just before Common mistakes
      final contrastBlock = <String>[
        'Contrast line',
        'Correct: position-led, initiative-aware plans with disciplined sizes. Mistake: position-agnostic thinking and autopilot bets.',
        '',
      ];
      lines.insertAll(insertAt, contrastBlock);
    }
  }

  // Pass 3: Trim verbosity: remove trailing "Why:" and "Why it happens:" clauses.
  for (var i = 0; i < lines.length; i++) {
    final t = lines[i];
    if (t.trim().isEmpty) continue;
    // Split at ' Why: ' or '; Why: ' keeping the part before.
    var idx = t.indexOf(' Why:');
    var cut = idx >= 0 ? t.substring(0, idx) : t;
    // Also trim '; Why it happens:' patterns
    idx = cut.indexOf(' Why it happens:');
    cut = idx >= 0 ? cut.substring(0, idx) : cut;
    // Also trim ' Mistake:' explanations if they follow a bullet header
    idx = cut.indexOf(' Mistake:');
    cut = idx >= 0 ? cut.substring(0, idx) : cut;
    lines[i] = cut.trimRight();
  }

  // Pass 4: If still over the word budget, trim conservatively by removing
  // trailing lines from Common mistakes, then Rules of thumb, then Mini example,
  // preserving at least a minimal number of lines in each section.
  final out = lines;
  var text = out.join('\n');
  final wc = _wordCount(text);
  const maxWords = 550;
  if (wc > maxWords) {
    final trimmed = _trimSections(out, targetMax: maxWords);
    text = trimmed.join('\n');
  }
  return text == raw ? null : text;
}

int _findExactHeader(List<String> lines, String header) {
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].trim() == header) return i;
  }
  return -1;
}

List<String> _discoverCoreModules() {
  final root = Directory('content');
  if (!root.existsSync()) return <String>[];
  final out = <String>[];
  for (final e in root.listSync()) {
    if (e is! Directory) continue;
    final id = _basename(e.path);
    if (!id.startsWith('core_')) continue;
    final v1 = Directory('${e.path}/v1');
    if (v1.existsSync()) out.add(id);
  }
  out.sort();
  return out;
}

String _basename(String path) {
  final norm = path.replaceAll('\\', '/');
  final s = norm.endsWith('/') ? norm.substring(0, norm.length - 1) : norm;
  final idx = s.lastIndexOf('/');
  return idx == -1 ? s : s.substring(idx + 1);
}

int _wordCount(String s) =>
    s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

List<String> _trimSections(List<String> lines, {required int targetMax}) {
  // ignore: prefer_final_locals
  var out = List<String>.from(lines);
  int wc() => _wordCount(out.join('\n'));

  int header(String name) {
    for (var i = 0; i < out.length; i++) {
      if (out[i].trim() == name) return i;
    }
    return -1;
  }

  int nextHeaderAfter(int start) {
    for (var i = start + 1; i < out.length; i++) {
      final t = out[i].trim();
      if (t.isEmpty) continue;
      // treat any known section label as a header boundary
      if (_knownHeaders.contains(t)) return i;
    }
    return out.length;
  }

  void trimFromSection(String name, {int minLines = 1}) {
    final s = header(name);
    if (s == -1) return;
    final e = nextHeaderAfter(s);
    // Collect indexes of non-empty, non-image lines within the section
    final idxs = <int>[];
    for (var i = s + 1; i < e; i++) {
      final t = out[i].trimRight();
      if (t.isEmpty) continue;
      if (t.startsWith('![') || t.startsWith('[[IMAGE:')) continue;
      idxs.add(i);
    }
    // Remove from end while over budget, preserving at least minLines
    while (wc() > targetMax && idxs.length > minLines) {
      final i = idxs.removeLast();
      out[i] = '';
    }
  }

  // Pass A: Trim Common mistakes to at least 2 lines
  trimFromSection('Common mistakes', minLines: 2);
  if (wc() <= targetMax) return out;

  // Pass B: Trim Rules of thumb to at least 3 lines
  trimFromSection('Rules of thumb', minLines: 3);
  if (wc() <= targetMax) return out;

  // Pass C: Trim Mini example to at least 2 lines
  trimFromSection('Mini example', minLines: 2);
  if (wc() <= targetMax) return out;

  return out;
}

const _knownHeaders = {
  'What it is',
  'Why it matters',
  'Rules of thumb',
  'Mini example',
  'Contrast line',
  'Common mistakes',
  'Mini-glossary',
  'Contrast',
  'See also',
};
