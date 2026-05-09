import 'dart:io';

import 'package:flutter/material.dart';

import '../lib/ui_v2/theme/v4_snapshot_registry.dart';
import '../lib/ui_v2/theme/v4_theme_builder.dart';
import '../lib/ui_v2/theme/v4_token_registry.dart';

void main() {
  final builder = V4ThemeDataBuilder();
  final theme = builder.build(ThemeData.light(), true, const V4TokenRegistry());
  final snapshot = builder.exportSnapshot(theme);
  const registry = V4SnapshotRegistry(V4SnapshotRegistry.baselineValues);
  var status = 0;
  stdout.writeln('=== V4 SNAPSHOT REPORT ===');
  for (final entry in snapshot.entries) {
    final baseline = registry.baseline[entry.key];
    final tag = baseline == null
        ? 'NEW'
        : (baseline == entry.value ? 'OK' : 'DIFF');
    if (tag == 'DIFF') status = 1;
    stdout.writeln('${entry.key}: $tag → ${entry.value}');
  }
  exit(status);
}
