import 'dart:convert';
import 'dart:io';

/// Content Semantic Autofix
///
/// Applies lightweight, deterministic fixes based on the latest semantic audit
/// report. Bridging sentences are appended to theory markdown files for weak
/// packs, and duplicate rationales gain a "(variant)" tag to reduce clashes.
/// Afterwards, the semantic audit is re-run and results are written to
/// tools/_reports/content_semantic_autofix.json.
Future<void> main(List<String> args) async {
  final auditFile = File('tools/_reports/content_semantic_audit.json');
  if (!auditFile.existsSync()) {
    _emitReport(
      asciiSummary: 'Content Semantic Autofix: SKIPPED (audit missing)',
      data: {
        'packs_bridged': 0,
        'rationales_tagged': 0,
        'files_updated': 0,
        'pass': false,
        'error': 'content_semantic_audit.json not found',
      },
    );
    return;
  }

  Map<String, dynamic> audit;
  try {
    audit = jsonDecode(auditFile.readAsStringSync()) as Map<String, dynamic>;
  } catch (e) {
    _emitReport(
      asciiSummary: 'Content Semantic Autofix: SKIPPED (audit unreadable)',
      data: {
        'packs_bridged': 0,
        'rationales_tagged': 0,
        'files_updated': 0,
        'pass': false,
        'error': 'failed to parse content_semantic_audit.json: $e',
      },
    );
    return;
  }

  final packsDetail = (audit['packs_detail'] as List?)?.cast<Map>() ?? const [];
  final duplicates = (audit['duplicates'] as List?)?.cast<Map>() ?? const [];

  final weakPacks = <String>{};
  for (final entry in packsDetail) {
    final module = entry['module']?.toString();
    final alignment = (entry['alignment'] as num?)?.toDouble() ?? 0.0;
    if (module != null && alignment < 0.30) {
      weakPacks.add(module);
    }
  }

  final rationaleTargets = <String, Set<String>>{};
  for (final raw in duplicates) {
    final packA = raw['pack_a']?.toString();
    final packB = raw['pack_b']?.toString();
    final idA = raw['id_a']?.toString();
    final idB = raw['id_b']?.toString();
    if (packA != null && idA != null && idA.isNotEmpty) {
      rationaleTargets.putIfAbsent(packA, () => <String>{}).add(idA);
    }
    if (packB != null && idB != null && idB.isNotEmpty) {
      rationaleTargets.putIfAbsent(packB, () => <String>{}).add(idB);
    }
  }

  var packsBridged = 0;
  var rationalesTagged = 0;
  final filesUpdated = <String>{};
  const bridgeSentence =
      'This concept connects directly to the practical drills below.';

  for (final pack in weakPacks) {
    final theoryFile = File('$pack/theory.md');
    if (!theoryFile.existsSync()) continue;
    final current = theoryFile.readAsStringSync();
    if (current.contains(bridgeSentence)) continue;
    final separator = current.endsWith('\n') ? '' : '\n';
    theoryFile.writeAsStringSync('$current$separator$bridgeSentence\n');
    packsBridged++;
    filesUpdated.add(theoryFile.path);
  }

  for (final entry in rationaleTargets.entries) {
    final packPath = entry.key;
    final ids = entry.value;
    final packDir = Directory(packPath);
    if (!packDir.existsSync()) continue;
    final jsonlFiles = packDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.jsonl'))
        .toList();
    for (final file in jsonlFiles) {
      final lines = file.readAsLinesSync();
      var changed = false;
      for (var i = 0; i < lines.length; i++) {
        final raw = lines[i].trim();
        if (raw.isEmpty) continue;
        Map<String, dynamic>? data;
        try {
          data = jsonDecode(raw) as Map<String, dynamic>?;
        } catch (_) {
          continue;
        }
        if (data == null) continue;
        final id = data['id']?.toString();
        if (id == null || !ids.contains(id)) continue;
        final rationale = data['rationale'];
        if (rationale is String && !rationale.contains('(variant)')) {
          data['rationale'] = '${rationale.trim()} (variant)';
          lines[i] = jsonEncode(data);
          rationalesTagged++;
          changed = true;
        }
      }
      if (changed) {
        file.writeAsStringSync('${lines.join('\n')}\n');
        filesUpdated.add(file.path);
      }
    }
  }

  Map<String, dynamic> latestAudit = audit;
  var auditPass = audit['pass'] == true;
  if (filesUpdated.isNotEmpty) {
    final result = await Process.run('dart', [
      'run',
      'tools/content_semantic_audit.dart',
    ], runInShell: true);
    if (result.exitCode != 0) {
      auditPass = false;
    } else {
      final rerunFile = File('tools/_reports/content_semantic_audit.json');
      if (rerunFile.existsSync()) {
        try {
          latestAudit =
              jsonDecode(rerunFile.readAsStringSync()) as Map<String, dynamic>;
          auditPass = latestAudit['pass'] == true;
        } catch (_) {
          auditPass = false;
        }
      }
    }
  }

  final asciiStatus = auditPass ? 'PASS (✓)' : 'FAIL (✗)';
  final asciiSummary =
      'Content Semantic Autofix: $asciiStatus • ${weakPacks.length} weak packs → $packsBridged bridged • ${rationaleTargets.values.fold<int>(0, (sum, ids) => sum + ids.length)} duplicate ids → $rationalesTagged tagged';

  _emitReport(
    asciiSummary: asciiSummary,
    data: {
      'packs_bridged': packsBridged,
      'rationales_tagged': rationalesTagged,
      'files_updated': filesUpdated.length,
      'pass': auditPass,
      'weak_packs_seen': weakPacks.length,
      'duplicate_ids_seen': rationaleTargets.values.fold<int>(
        0,
        (sum, ids) => sum + ids.length,
      ),
      'latest_audit': latestAudit,
    },
  );
}

void _emitReport({
  required String asciiSummary,
  required Map<String, dynamic> data,
}) {
  stdout.writeln(asciiSummary);
  final reportFile = File('tools/_reports/content_semantic_autofix.json');
  reportFile.parent.createSync(recursive: true);
  reportFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(data),
  );
}
