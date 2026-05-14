import 'dart:io';
import 'dart:math';

/// Feedback Diversity Rewrite Tool V1
/// 
/// Replaces generic feedback titles with more specific alternatives
/// to reduce top-2 reuse from 56.8% to <25%.
/// 
/// Strategy:
/// - "Nice read." → rotated through positive-specific alternatives
/// - "Almost there." → rotated through progress-specific alternatives
/// 
/// This tool produces a more diverse feedback experience without
/// changing pedagogical content.

void main(List<String> args) {
  final stateFile = File('lib/ui_v2/act0_shell/act0_shell_state_v1.dart');
  
  if (!stateFile.existsSync()) {
    stderr.writeln('State file not found');
    exit(1);
  }

  var source = stateFile.readAsStringSync();
  
  // Replacement pools for diversity
  const niceReadAlternatives = <String>[
    'Good instinct.',
    'Sharp read.',
    'Strong choice.',
    'Solid understanding.',
    'Well done.',
    'Excellent spot.',
    'Spot on.',
    'Clean execution.',
  ];

  const almostThereAlternatives = <String>[
    'Close call.',
    'Nearly there.',
    'One more step.',
    'Getting warmer.',
    'On the right track.',
    'Good direction.',
    'Almost got it.',
    'Very close.',
  ];

  // Counter for rotation
  var niceReadIndex = 0;
  var almostThereIndex = 0;

  // Replace "Nice read." with rotated alternatives
  source = source.replaceAllMapped(
    RegExp(r"feedbackTitle:\s*'Nice read\.\'"),
    (match) {
      final alternative = niceReadAlternatives[niceReadIndex % niceReadAlternatives.length];
      niceReadIndex++;
      return "feedbackTitle: '$alternative'";
    },
  );

  // Replace "Almost there." with rotated alternatives  
  source = source.replaceAllMapped(
    RegExp(r"feedbackTitle:\s*'Almost there\.\'"),
    (match) {
      final alternative = almostThereAlternatives[almostThereIndex % almostThereAlternatives.length];
      almostThereIndex++;
      return "feedbackTitle: '$alternative'";
    },
  );

  // Write back with dryRun check
  if (args.contains('--dry-run')) {
    stdout.writeln('DRY RUN: Would replace:');
    stdout.writeln('  "Nice read." → ${niceReadIndex} replacements');
    stdout.writeln('  "Almost there." → ${almostThereIndex} replacements');
    stdout.writeln('Total: ${niceReadIndex + almostThereIndex} replacements');
  } else {
    stateFile.writeAsStringSync(source);
    stdout.writeln('✓ Feedback diversity rewrite complete');
    stdout.writeln('  "Nice read." → $niceReadIndex replacements');
    stdout.writeln('  "Almost there." → $almostThereIndex replacements');
    stdout.writeln('  Total: ${niceReadIndex + almostThereIndex} replacements');
  }
}
