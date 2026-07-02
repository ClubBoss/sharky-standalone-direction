import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

/// Semantic earned-proof role. Downstream of proof contracts only; never
/// derives or mutates product truth.
enum Act0ProofIconRoleV1 {
  /// A source-backed repair was completed.
  repairCompleted,

  /// A completed repair later received supporting transfer evidence.
  reinforced,

  /// A larger earned progression event (world completion, band transition).
  /// Reserved: must not be emitted on ordinary repair proof.
  milestone,
}

enum Act0ProofIconSizeV1 { inline, tile, seal }

/// Small stateless proof-icon mark shared by Profile and Session Summary.
/// Accepts only the semantic role and a size — no rarity, level, progress,
/// lock, animation, or monetization state.
class Act0ProofIconV1 extends StatelessWidget {
  const Act0ProofIconV1({
    super.key,
    required this.role,
    this.size = Act0ProofIconSizeV1.inline,
  });

  final Act0ProofIconRoleV1 role;
  final Act0ProofIconSizeV1 size;

  double get _boxSize => switch (size) {
    Act0ProofIconSizeV1.inline => 20,
    Act0ProofIconSizeV1.tile => 32,
    Act0ProofIconSizeV1.seal => 44,
  };

  double get _glyphSize => switch (size) {
    Act0ProofIconSizeV1.inline => 13,
    Act0ProofIconSizeV1.tile => 17,
    Act0ProofIconSizeV1.seal => 22,
  };

  IconData get _glyph => switch (role) {
    Act0ProofIconRoleV1.repairCompleted => Icons.check_rounded,
    Act0ProofIconRoleV1.reinforced => Icons.done_all_rounded,
    Act0ProofIconRoleV1.milestone => Icons.verified_rounded,
  };

  double get _rimWidth => role == Act0ProofIconRoleV1.milestone ? 1.6 : 1.1;

  double get _rimOpacity => switch (role) {
    Act0ProofIconRoleV1.repairCompleted => 0.45,
    Act0ProofIconRoleV1.reinforced => 0.65,
    Act0ProofIconRoleV1.milestone => 0.85,
  };

  @override
  Widget build(BuildContext context) {
    final box = _boxSize;
    final mark = Container(
      key: Key('act0_proof_icon_v1_${role.name}'),
      width: box,
      height: box,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(box * 0.32),
        border: Border.all(
          color: Act0ShellTokensV1.gold.withValues(alpha: _rimOpacity),
          width: _rimWidth,
        ),
      ),
      child: Icon(_glyph, size: _glyphSize, color: Act0ShellTokensV1.gold),
    );
    if (role != Act0ProofIconRoleV1.reinforced) {
      return mark;
    }
    final echoBox = box + 6;
    return SizedBox(
      key: const Key('act0_proof_icon_v1_reinforced_echo'),
      width: echoBox,
      height: echoBox,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: echoBox,
            height: echoBox,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(echoBox * 0.32),
              border: Border.all(
                color: Act0ShellTokensV1.gold.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
          ),
          mark,
        ],
      ),
    );
  }
}
