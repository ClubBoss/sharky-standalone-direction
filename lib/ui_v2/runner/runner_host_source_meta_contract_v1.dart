import 'package:flutter/foundation.dart';

@immutable
class RunnerHostSourceMetaEntryV1 {
  const RunnerHostSourceMetaEntryV1({
    required this.testKey,
    required this.text,
    this.useBodySmall = false,
  });

  final String testKey;
  final String text;
  final bool useBodySmall;
}

@immutable
class RunnerHostSourceMetaContractV1 {
  const RunnerHostSourceMetaContractV1({
    this.entries = const <RunnerHostSourceMetaEntryV1>[],
  });

  final List<RunnerHostSourceMetaEntryV1> entries;

  bool get hasEntries => entries.isNotEmpty;
}
