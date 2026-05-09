import 'package:poker_analyzer/release/release_assembly_harmonizer_v1.dart';
import 'package:poker_analyzer/release/consolidated_scoring_lockin_v1.dart';
import 'package:poker_analyzer/release/cross_domain_flag_zeroing_v1.dart';

class ReleaseColdPathValidatorV1 {
  const ReleaseColdPathValidatorV1({
    required this.harmonizer,
    required this.scoringLockIn,
    required this.flagZeroing,
  });

  final ReleaseAssemblyHarmonizerV1 harmonizer;
  final ConsolidatedScoringLockInV1 scoringLockIn;
  final CrossDomainFlagZeroingV1 flagZeroing;

  Map<String, Object> toReadOnlyMap() {
    final unresolved = <String>[];
    final warnings = <String>[];
    final harmonized = harmonizer.toReadOnlyMap()['harmonized_ok'] == true;
    final scoringLocked =
        scoringLockIn.toReadOnlyMap()['scoring_locked'] == true;
    final flagsOk = flagZeroing.toReadOnlyMap()['zeroing_ok'] == true;
    if (!harmonized) unresolved.add('harmonizer');
    if (!scoringLocked) unresolved.add('scoring');
    if (!flagsOk) unresolved.add('flags');
    final coldPathOk = unresolved.isEmpty;
    return Map<String, Object>.unmodifiable({
      'cold_path_ok': coldPathOk,
      'unresolved': List<String>.unmodifiable(unresolved),
      'warnings': List<String>.unmodifiable(warnings),
    });
  }
}
