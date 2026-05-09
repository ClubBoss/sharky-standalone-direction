import 'dart:io';

import 'package:poker_analyzer/services/player_progression_service.dart';

void main(List<String> args) {
  final cli = _ProgressionAuditCli.parse(args);
  if (cli.showSummary) {
    _printSummary();
  } else {
    _printUsage();
  }
}

class _ProgressionAuditCli {
  _ProgressionAuditCli({required this.showSummary});

  final bool showSummary;

  static _ProgressionAuditCli parse(List<String> args) {
    var summary = false;
    for (final arg in args) {
      switch (arg) {
        case '--summary':
          summary = true;
          break;
        case '--help':
        case '-h':
          _printUsage();
          exit(0);
        default:
          stderr.writeln('Unknown option: $arg');
          _printUsage();
          exit(64);
      }
    }
    return _ProgressionAuditCli(showSummary: summary);
  }
}

void _printSummary() {
  final state = PlayerProgressionService.instance.snapshot();
  final xpIntoLevel = state.xpTotal;
  final xpNeeded = state.nextLevelXp;
  final progressPercent = xpNeeded == 0
      ? 0.0
      : (xpIntoLevel / xpNeeded * 100.0);

  final lines = <String>[
    'Player Progression Summary',
    '--------------------------',
    'Level        : ${state.level}',
    'XP Total     : ${state.xpTotal}',
    'Next Level   : ${state.nextLevelXp}',
    'Progress     : ${progressPercent.toStringAsFixed(2)}%',
    'Chips Total  : ${state.chipTotal}',
    'League Tier  : ${state.leagueTier}',
    'Streak       : ${state.streak}',
  ];
  stdout.writeln(lines.join('\n'));
}

void _printUsage() {
  stdout
    ..writeln('Usage: dart run tools/progression_audit.dart --summary')
    ..writeln('Options:')
    ..writeln('  --summary   Print progression summary')
    ..writeln('  --help      Show this message');
}
