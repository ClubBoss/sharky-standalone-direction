import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_design_tokens_v1.dart';

/// Presentation only. The suit mark is a club-room motif, never a dealt hand,
/// action, achievement or source of learner state.
class Act0AcademyFolioPlateV1 extends StatelessWidget {
  const Act0AcademyFolioPlateV1({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.detail,
  });

  final String eyebrow;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Act0AcademyDesignTokensV1.primaryAction,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFB29A6C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  eyebrow,
                  style: Act0AcademyDesignTokensV1.label.copyWith(
                    color: const Color(0xFFE4CDA5),
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const ExcludeSemantics(
                child: Text(
                  '♠',
                  style: TextStyle(color: Color(0xFFE4CDA5), fontSize: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Act0AcademyDesignTokensV1.sectionHeading.copyWith(
              color: Act0AcademyDesignTokensV1.onPrimaryAction,
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            detail,
            style: Act0AcademyDesignTokensV1.body.copyWith(
              color: Act0AcademyDesignTokensV1.onPrimaryAction,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// A chapter label with a quiet rule, shared by Academy reading surfaces.
class Act0AcademyFolioLabelV1 extends StatelessWidget {
  const Act0AcademyFolioLabelV1({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Flexible(
        child: Text(
          label,
          style: Act0AcademyDesignTokensV1.label.copyWith(
            color: const Color(0xFF7A414D),
            fontSize: 11,
            letterSpacing: 0.7,
          ),
        ),
      ),
      const SizedBox(width: 12),
      const Expanded(child: Divider(color: Act0AcademyDesignTokensV1.rule)),
    ],
  );
}
