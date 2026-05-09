# Micro-Loop Rewrite Instructions v1

## Purpose
- Describe the standard micro-loop structure every `core_*` `theory.md` must follow for consistent knowledge distillation.
- Target future rewrites so they stay ASCII-only, concise, and faithful to the original concepts.

## Procedure
1. Read the existing `theory.md` content and identify core concepts, examples, plans, and sizing families.
2. Preserve the logical order; do not add new strategies or rename ideas.
3. Replace every paragraph with the four mandated headings below.
4. Rewrite each section to be 35–55% shorter by removing fluff while keeping the original meaning.

## Section Order and Style
- `## Key Idea`: 1–2 short sentences summarizing the main driver or insight; avoid repetition.
- `## Mini-Example`: 2–3 lines showing a concrete scenario that reflects the original lines or sizing families.
- `## Actionable Rules`: bullet list where each rule is one sentence, concrete, and actionable.
- `## Quick Check`: 1–2 bullets posing a simple question that tests whether the reader grasped the key decision point.

## Style Rules
- ASCII-only characters throughout.
- Short sentences only; avoid compound, rambling sentences.
- One idea per block; do not mix multiple concepts in a single sentence.
- Use original terminology (range_advantage, dry_board, etc.) when present.
- Maintain factual, instructional tone; no jokes or narrative aside from the mini-example.

## Constraints
- Only edit `theory.md`; do not touch `drills.jsonl`, `recap.md`, `quiz.jsonl`, `cheatsheet.md`, `rubric.md`, or `checkpoints`.
- Keep each module diff minimal (<150 lines).
- Do not introduce solver-specific or unrelated terminology unless it already exists in the source.
- Keep spacing and headings consistent across modules.

## Final Check
- Confirm the new file uses the prescribed headings in order.
- Ensure each sentence is concise and the file remains ASCII-only.
- Verify no additional files were changed.
